import 'package:flutter/material.dart';
import 'package:code_editor/code_editor.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // example of a easier way to write code instead of writing it in a single string
    List<String> contentOfPage1 = [
      "<!DOCTYPE html>",
      "<html lang='fr'>",
      "\t<body>",
      "\t\t<a href='page2.html'>go to page 2</a>",
      "\t</body>",
      "</html>",
    ];

    // The files displayed in the navigation bar of the editor.
    // You are not limited.
    // By default, [name] = "file.${language ?? 'txt'}", [language] = "text" and [code] = "",
    List<FileEditor> files = [
      FileEditor(
        name: "page1.html",
        language: "html",
        code: contentOfPage1.join("\n"), // [code] needs a string
      ),
      FileEditor(
        name: "helo.py",
        language: "python",
        code: "print('hello world')",
      ),
      FileEditor(
        name: "style.css",
        language: "css",
        code: "a { color: red; }",
      ),
    ];


    // A custom TextEditingController.
    final myController = TextEditingController(text: 'hello!');

    return Scaffold(
      appBar: AppBar(title: const Text("code_editor example")),
      body: SingleChildScrollView(
        // /!\ important because of the telephone keypad which causes a "RenderFlex overflowed by x pixels on the bottom" error
        // display the CodeEditor widget
        child: CodeEditor(
          model: EditorModel(
            files: files, // the files created above
            // you can customize the editor as you want
            styleOptions: EditorModelStyleOptions(
              fontSize: 13,
            ),
          ), // the model created above, not required since 1.0.0
          edit: true, // can edit the files? by default true
          onSubmit: (String? language, String? value) => print("yo"),
          disableNavigationbar:
          false, // hide the navigation bar ? by default false
          textEditingController:
          myController, // Provide an optional, custom TextEditingController.
        ),
      ),
    );
  }
}