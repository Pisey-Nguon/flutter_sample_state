import 'package:flutter/material.dart';

abstract class ViewState<T> {}

class Loading<T> extends ViewState<T> {}

class Success<T> extends ViewState<T> {
  final T data;

  Success(this.data);
}

class Failed<T> extends ViewState<T> {}

class Empty<T> extends ViewState<T> {}

class NoInternet<T> extends ViewState<T> {}

class Timeout<T> extends ViewState<T> {}

class SomethingWentWrong<T> extends ViewState<T> {
  final dynamic exception;

  SomethingWentWrong(this.exception);
}

class CustomStateViewController<T> {
  List<void Function(ViewState<T>)> _setStateCallbacks = [];
  Future<ViewState<T>> Function()? _onLoad;
  late T data;

  void addViewStateCallback(void Function(ViewState<T> viewState) callback) {
    _setStateCallbacks.add(callback);
  }

  void removeViewStateCallback(void Function(ViewState<T> viewState) callback) {
    _setStateCallbacks.remove(callback);
  }

  void switchState(ViewState<T> state) {
    for (var callback in _setStateCallbacks) {
      callback(state);
    }
  }

  void setOnLoadCallback(Future<ViewState<T>> Function() onLoad) {
    _onLoad = onLoad;
  }

  Future<void> load() async {
    if (_onLoad != null) {
      final viewState = await _onLoad!();
      if (viewState is Success<T>) {
        data = viewState.data;
      }
      switchState(viewState);
    }
  }
}

class _RequestStateView extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Function() onPressed;
  const _RequestStateView(
      {Key? key,
      required this.iconData,
      required this.title,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(title),
          ),
          TextButton(onPressed: onPressed, child: Text("Retry"))
        ],
      ),
    );
  }
}

class CustomStateView<T> extends StatefulWidget {
  final CustomStateViewController<T> controller;
  final Widget Function(T data) child;

  const CustomStateView(
      {Key? key, required this.controller, required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomStateViewState<T>();
}

class _CustomStateViewState<T> extends State<CustomStateView<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  ViewState<T> _currentState = Loading();
  CustomStateViewController<T> get controller => widget.controller;
  Widget Function(T data) get child => widget.child;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    widget.controller.load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomStateView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.switchState(Success(controller.data));
      widget.controller.switchState(_currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        );
      },
      child: _getChildForState(),
    );
  }

  Widget _getChildForState() {
    switch (_currentState) {
      case Loading():
        return const Center(child: CircularProgressIndicator());
      case Success():
        return child.call(controller.data);
      case NoInternet():
        return _RequestStateView(
          iconData: Icons.network_check,
          title: "No internet",
          onPressed: _retry,
        );
      case SomethingWentWrong():
        return _RequestStateView(
          iconData: Icons.running_with_errors,
          title: "Something went wrong",
          onPressed: _retry,
        );
      case Timeout():
        return _RequestStateView(
          iconData: Icons.timer_rounded,
          title: "Request timeout",
          onPressed: _retry,
        );
      case Failed():
        return _RequestStateView(
          iconData: Icons.error,
          title: "Request Failed",
          onPressed: _retry,
        );
      default:
        return Container();
    }
  }

  void _retry() {
    controller.switchState(Loading());
    controller.load();
  }

  void _setState(ViewState<T> state) {
    if (state != _currentState) {
      _currentState = state;
      _animationController.reverse().then((_) {
        setState(() {
          _animationController.forward();
        });
      });
    }
  }
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addViewStateCallback(_setState);
  }
}
