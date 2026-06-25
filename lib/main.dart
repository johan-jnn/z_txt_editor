import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/plaintext.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/xml.dart';
import 'package:z_txt_editor/routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  highlight.registerLanguage('javascript', javascript);
  highlight.registerLanguage('css', css);
  highlight.registerLanguage('xml', xml);
  highlight.registerLanguage('html', xml);
  highlight.registerLanguage('markdown', markdown);
  highlight.registerLanguage('python', python);
  highlight.registerLanguage('plaintext', plaintext);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZTxtEditor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRoutes,
    );
  }
}
