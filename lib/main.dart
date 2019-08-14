import 'dart:async';
import 'dart:convert' as convert ;
import 'dart:convert';
import 'package:flutter_web/material.dart';
import 'dart:html';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List data ;
  String strbase64;
  String result = "Result";
  String origineFileName;
  var image ;
  var response;
  String url = "https://picsum.photos/v2/list";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            _buttonImage(),
            RaisedButton(
              child: Text("Get"),
              onPressed: ()=> getDate(),
            ),
            Text(this.result!=null?this.result:"sans reponse")
          ],
        )
      ),
    );
  }



  Future getDate()async{
    var url = "https://picsum.photos/v2/list";
    // Await the http get response, then decode the json-formatted responce.
    var response = await http.get(Uri.encodeFull(url));
      setState(() {
        var jsonResponse = json.decode(response.body);
        print("Avant : ${jsonResponse[0]['id']}");
        this.data = jsonResponse;
        this.result = data[0]["author"];
        print("{data}: $result ");
      });
      print("data: $this.data ");
  }

  postImage(x)async{
    var image = await x;
    var url = 'http://localhost:8081/uploadImage2';
    var response = await http.post(url, body: {'imageValue':image,"fileName":this.origineFileName});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  _inputImage()async{
    var t = await getFile();
    this.strbase64 = t.split(',')[1];
    postImage(this.strbase64);
    print("Type file: ${t.split(',')[0].split('.')[0]}");
    var image = convert.base64.decode(strbase64);
    setState(() {
      this.image = image;
    });
  }

  Future<String> getFile(){
    final completer = Completer<String>();
    final InputElement input = document.createElement("input");
    input
      ..type = "file"
      ..accept = "application/pdf";
    input.onChange.listen((e) async {
      final List<File> files = input.files;
      final reader = FileReader();
      reader.readAsDataUrl(files[0]);
      print("Name: ${files[0].name}");
      print("extension: ${files[0].type.split('/')[1]}");
      setState((){
        this.origineFileName = files[0].name;
      });
      reader.onError.listen((error) => completer.completeError(error));
      await reader.onLoad.first;
      completer.complete(reader.result as String);
    });
    input.click();
    return completer.future;
  }


  Widget _image(){
    if(this.image==null){
      return Text("Inserer image");
    }else{
      return Image.memory(this.image, width: 200);
    }
  }

  _buttonImage()=>InkWell(
    onTap: ()=>_inputImage(),
    child: Card(
      child: Container(
        width: 200.0,
        height: 200.0,
        child: Center(
          child: _image(),
        ),
      ),
    ),
  );
}

