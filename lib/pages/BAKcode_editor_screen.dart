import 'package:flutter/material.dart';
import 'package:code_editor/code_editor.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> contentOfPage1 = [
      "<!DOCTYPE html>",
      "<html lang='fr'>",
      "\t<body>",
      "\t\t<a href='page2.html'>go to page 2</a>",
      "\t</body>",
      "</html>",
    ];

    String code = """
    # This is a multi-line string
    x = 10
    y = 20
    z = x + y
    print("The sum of x and y is: ", z);
  """;

    List<FileEditor> files = [
      FileEditor(
        name: "page1.html",
        language: "html",
        code: contentOfPage1.join("\n"),
      ),
      FileEditor(
        name: "hello.py",
        language: "python",
        code: code,
      ),
      FileEditor(
        name: "style.css",
        language: "css",
        code: "a { color: red; }",
      ),
    ];

    final myController = TextEditingController(text: 'hello!');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text("Code Editor"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: CodeEditor(
          model: EditorModel(
            files: files, // the files created above
            styleOptions: EditorModelStyleOptions(
              fontSize: 13,
            ),
          ),
          edit: true,
          onSubmit: (String? language, String? value) => print("yo"),
          disableNavigationbar: false,
          textEditingController: myController,
        ),
      ),
    );
  }
}
