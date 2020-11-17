import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image_resizer/image_resizer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _resizedImagePath = '';

  @override
  void initState() {
    super.initState();
  }

	Future<bool> _requestPermissions() async {
		final permissions = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
		return permissions[PermissionGroup.camera] == PermissionStatus.granted;
	}

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> resize() async {

		var hasPermissions = await _requestPermissions();

		if(!hasPermissions) return;
		
		var directory;
		if(Platform.isAndroid) {
			directory = await getExternalStorageDirectory();
		} else {
			directory = await getApplicationDocumentsDirectory();
		}

		var dirPath = '${directory.path}/IMAGE_RESIZER';
    String resizedImagePath = '$dirPath/demo.jpg';
		await Directory(dirPath).create(recursive: true);

		try {
			var image = await ImagePicker.pickImage(source: ImageSource.camera);
			await ImageResizer.resize(image.path, resizedImagePath, 500, format: ImageFormat.jpeg);
    } catch(error) {
      resizedImagePath = 'Failed to resize image.';
    }

    if (!mounted) return;

    setState(() {
      _resizedImagePath = resizedImagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Text('Running on: $_resizedImagePath\n'),
							RaisedButton(
								child: Text('Tap me!'),
								onPressed: resize,
							),
							_resizedImagePath.isNotEmpty
							? Container(
								height: 200,
								width: double.infinity,
							  child: Image.file(
							  	File(_resizedImagePath),
									fit: BoxFit.cover ,
							  ),
							) : Container(),
						], 
          ),
        ),
      ),
    );
  }
}
