import 'package:flutter/material.dart';
import 'package:sample_state/custom_state_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = CustomStateViewController<String>();

  Future<ViewState<String>> loadTitleMessage() async {
    await Future.delayed(const Duration(seconds: 2));
    return Success("test data success");
  }

  void _handleStateChange(ViewState<String> state) {
    // Handle the state change
  }

  @override
  void initState() {
    controller.addViewStateCallback(_handleStateChange);
    controller.setOnLoadCallback(() async => await loadTitleMessage());

    super.initState();
  }

  @override
  void dispose() {
    controller.removeViewStateCallback(_handleStateChange);
    super.dispose();
  }

  void _incrementCounter() {
    controller.switchState(Failed());
  }

  Future<void> _refreshData() async {
    await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: CustomStateView<String>(
        controller: controller,
        child: (data) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.amber,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    title: Text('Post Title $index'),
                    subtitle: Text('Post content...'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
