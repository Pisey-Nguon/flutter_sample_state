import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'custom_state_view.dart';

class CustomPagingView<T> extends StatefulWidget {
  final CustomStateViewController<List<T>> controller;
  final Widget Function(T data) child;
  final Future<ViewState<List<T>>> Function(int page) onLoadPage;

  const CustomPagingView({
    Key? key,
    required this.controller,
    required this.child,
    required this.onLoadPage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomPagingViewState<T>();
}

class _CustomPagingViewState<T> extends State<CustomPagingView<T>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  ViewState _loadingMoreState = Loading();
  var keyLoading = UniqueKey();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller
        .setOnLoadCallback(() async => await widget.onLoadPage(_currentPage));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_hasMore) {
      setState(() {
        _loadingMoreState = Loading();
      });
      _currentPage++;
      var newState = await widget.onLoadPage(_currentPage);
      if (newState is Success<List<T>>) {
        var newData = newState.data;
        if (newData.isEmpty) {
          setState(() {
            _hasMore = false;
            _loadingMoreState = Empty();
          });
        } else {
          widget.controller.data.addAll(newData);
          widget.controller.switchState(Success(widget.controller.data));
        }
      } else {
        setState(() {
          _loadingMoreState = newState;
        });
      }
      keyLoading = UniqueKey();
    }
  }

  Future<void> _refresh() async {
    _hasMore = true;
    _currentPage = 1;
    _loadingMoreState = Loading();
    return await widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return CustomStateView<List<T>>(
      controller: widget.controller,
      child: (data) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: data.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < data.length) {
                return widget.child(data[index]);
              } else if (_loadingMoreState is Loading) {
                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: VisibilityDetector(
                    key: keyLoading,
                    child: const CircularProgressIndicator(),
                    onVisibilityChanged: (info) async {
                      if (info.visibleFraction > 0.0) {
                        if (_isLoading) {
                          _isLoading = false;
                          await _loadMore();
                          _isLoading = true;
                        }
                      }
                    },
                  ),
                );
              } else if (_loadingMoreState is Failed ||
                  _loadingMoreState is NoInternet ||
                  _loadingMoreState is Timeout ||
                  _loadingMoreState is SomethingWentWrong) {
                return Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load more data'),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: () => _loadMore(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (_loadingMoreState is Empty) {
                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text('No more data'),
                );
              } else {
                return Container();
              }
            },
          ),
        );
      },
    );
  }
}
