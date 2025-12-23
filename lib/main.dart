import 'package:flutter/material.dart';
import 'package:webview_input/core_web_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  bool showWebView = false;

  @override
  Widget build(BuildContext context) {
    const flutterVersion = String.fromEnvironment('FLUTTER_VERSION');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 8.0,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(flutterVersion),
            TextFormField(),
            TextFormField(),
            FilledButton(
                onPressed: () {
                  setState(() {
                    showWebView = !showWebView;
                  });
                },
                child: Text("Toggle WebView")),
            SizedBox(
              height: 200,
              width: 500,
              child: showWebView
                  ? Row(
                      spacing: 16.0,
                      children: [
                        SimpleInputWebView(),
                        SimpleInputWebView(),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleInputWebView extends StatelessWidget {
  const SimpleInputWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 150,
      child: CoreWebView(
        initialHtml: """
    <!DOCTYPE html>
    <html lang="en">
      <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
      </head>
      <body>
    <textarea></textarea>
      </body>
    </html>
      """,
      ),
    );
  }
}
