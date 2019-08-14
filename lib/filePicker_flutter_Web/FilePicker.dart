import 'dart:async';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert ;
import 'package:flutter_web/material.dart';

class FilePicker extends StatefulWidget {
  String _fileName;
  String _url;
  var _file;
  String _accept;
  String _fileBase64;


  FilePicker(this._fileName, this._fileBase64, [this._accept = "application/pdf"]);
  @override
  _FilePickerState createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePicker> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  postImage(data)async{
    var file = await data;
    var response = await http.post(widget._url, body: {'file':file,"fileName":widget._fileName});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  _inputImage()async{
    var t = await getFile();
    widget._fileBase64 = t.split(',')[1];
    postImage(widget._fileBase64);
    var image = convert.base64.decode(widget._fileBase64);
    setState(() {
      widget._file = image;
    });
  }

  Future<String> getFile(){
    final completer = Completer<String>();
    final InputElement input = document.createElement("input");
    input
      ..type = "file"
      ..accept = widget._accept;
    input.onChange.listen((e) async {
      final List<File> files = input.files;
      final reader = FileReader();
      reader.readAsDataUrl(files[0]);
      print("Name: ${files[0].name}");
      print("extension: ${files[0].type.split('/')[1]}");
      setState((){
        widget._fileName = files[0].name;
      });
      reader.onError.listen((error) => completer.completeError(error));
      await reader.onLoad.first;
      completer.complete(reader.result as String);
    });
    input.click();
    return completer.future;
  }
}
