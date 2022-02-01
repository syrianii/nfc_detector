import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var availability;
  List<String> _stream = [];
  List<String> _rawStream = [];

  NFCTag tag;
  bool _reading = false;

  checkNFCAvailability() async {
    availability = await FlutterNfcKit.nfcAvailability;
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      checkNFCAvailability();
    });
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(availability.toString()),
        Text("NDEF Available : " + tag.ndefAvailable.toString()),
        Text("NFC Type : " + tag.ndefType),
        Expanded(
          flex: 1,
          child: ListView.builder(
              itemCount: _stream.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(32),
                  margin: EdgeInsets.all(32),
                  height: size.height * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey,
                  ),
                  child: Text(
                    _stream[index],
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }),
        ),
        availability == NFCAvailability.available
            ? RaisedButton(
                child: Text(_reading ? "Stop reading" : "Start reading"),
                onPressed: () async {
                  if (_reading) {
                    setState(() {
                      _reading = false;
                    });
                  } else {
                    setState(() {
                      _reading = true;
                    });

                    try {
                      tag = (await FlutterNfcKit.poll(
                          timeout: Duration(seconds: 10)));

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        jsonEncode(tag),
                        style: TextStyle(color: Colors.orangeAccent),
                      )));

                      if (tag.ndefAvailable) {
                        for (var record in await FlutterNfcKit.readNDEFRecords(
                            cached: false)) {
                          print(" record readed + ${record.toString}");
                          setState(() {
                            _stream.add(record.toString());
                          });
                        }

                        for (var record
                            in await FlutterNfcKit.readNDEFRawRecords(
                                cached: false)) {
                          _rawStream.add(record.toString());
                        }
                      }
                      FlutterNfcKit.finish();
                    } catch (exception) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        exception.toString(),
                        style: TextStyle(color: Colors.blue),
                      )));
                    }
                  }
                })
            : Text(
                "Please turn on NFC First , if you don't have Nfc then you can't run the app",
              ),
      ],
    ));
  }
}
