import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sample_state/custom_paging_view.dart';
import 'package:sample_state/custom_state_view.dart';
import 'package:sample_state/user.dart';
import 'package:sample_state/user_repository.dart';

Future<void> main() async {
  await GetStorage.init();
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
  final controller = CustomStateViewController<List<Datum>>();
  final UserRepository _userRepository = UserRepository();

  void _handleStateChange(ViewState<List<Datum>> state) {
    // Handle the state change
  }

  @override
  void initState() {
    controller.addViewStateCallback(_handleStateChange);

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
      body: CustomPagingView<Datum>(
        controller: controller,
        onLoadPage: (page) async {
          return await _userRepository.getUserList(page: page);
        },
        child: (data) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data.avatar),
              ),
              title: Text(data.firstName),
              subtitle: Text(data.email),
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
