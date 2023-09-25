import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData createTheme() {
    return ThemeData(
        colorScheme: const ColorScheme(
          primary: AcColors.primary,
          secondary: AcColors.secondary,
          background: AcColors.background,
          brightness: Brightness.dark,
          surface: AcColors.background,
          error: AcColors.danger,
          onPrimary: AcColors.background,
          onSecondary: AcColors.black,
          onBackground: AcColors.primary,
          onSurface: AcColors.primary,
          onError: AcColors.black,
        ),
        useMaterial3: true,
        fontFamily: "Roboto",
        appBarTheme: const AppBarTheme(
          backgroundColor: AcColors.secondary,
          foregroundColor: AcColors.primary,
          elevation: AcSizes.md,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AcColors.primary,
              fontSize: AcSizes.fontBig),
        ));
  }

  List<SingleChildWidget> buildProviders() {
    return [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: createTheme(),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
