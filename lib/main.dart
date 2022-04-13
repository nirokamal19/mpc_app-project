import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //Landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MPC_app',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(
          hexColor('#E7E7E5'),
        ),
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }

  int hexColor(String color) {
    //adding prefix
    String newColor = '0xff' + color;
    //removing # sign
    newColor = newColor.replaceAll('#', '');
    //converting it to the integer
    int finalColor = int.parse(newColor);
    return finalColor;
  }
}

class HomeScreen extends StatefulWidget {
  //audioplayer
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<String> _setupSubscription;
  MidiCommand midiCommand = MidiCommand();

  @override
  void initState() {
    super.initState();
    midiCommand.startScanningForBluetoothDevices().catchError((error) {
      print(error);
    });
    _setupSubscription = midiCommand.onMidiSetupChanged.listen((event) {
      print("setup changed $event");
      switch (event) {
        case "deviceFound":
          setState(() {});
          break;
        default:
          print("Unhandled setup changes: $event");
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _setupSubscription.cancel();
  }

  void playSound(int soundNumber) {
    final player = AudioCache();
    player.play('$soundNumber.wav');
  }

  var devices;
  createAlertDialog(BuildContext context) {
    //TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [
              Text('Select MIDI Output'),
              IconButton(
                onPressed: () {
                  midiCommand
                      .startScanningForBluetoothDevices()
                      .whenComplete(() => print("Success"))
                      .catchError((err) {
                    print(err);
                  });
                  setState(() {});
                },
                icon: Icon(
                  Icons.refresh,
                ),
              )
            ]),
            content: Container(
              height: 500,
              width: 500,
              child: FutureBuilder(
                future: midiCommand.devices,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    devices = snapshot.data as List<MidiDevice>;
                    print('my devices are $devices');
                    return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(devices[index].name),
                            subtitle: Text(
                                devices[index].outputPorts.length.toString()),
                            trailing: devices[index].type == "BLE"
                                ? Icon(Icons.bluetooth)
                                : Icon(Icons.usb),
                            onTap: () {
                              midiCommand.connectToDevice(devices[index]);
                            },
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          );
        }); //given by flutter
  }

  Expanded buildPad({Color color, int soundNumber}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
              ),
            ],
          ),
          child: FlatButton(
            color: Color(hexColor('#908e91')),
            onPressed: () {
              playSound(soundNumber);
              // midiCommand.sendData(devices[0].);
              //  MidiCommand.;
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add a call to call MIDI devices into a list
    // TODO:MIDICommand connect to PC
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 0.35,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 60, 20),
              child: Container(
                  color: Color(hexColor('#E7E7E5')),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
//AKAI LOGO
                      Expanded(
                        child: Image.asset('assets/akai_retro.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Container(
                          height: 15,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                              ),
                            ],

//MIDI Button
                          ),
                          child: MaterialButton(
                            child: Text('MIDI'),
                            height: 15,
                            color: Colors.white,
                            onPressed: () {
                              createAlertDialog(context);
                              // Future<List<MidiDevice>> midiDevice =
                              //     MidiCommand().devices;
                              // print(midiDevice);
                            },
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                child: Expanded(
                                  child: Center(
                                    child: Text(
                                      'mini',
                                      style: TextStyle(
                                        fontFamily: 'Cheltenham',
                                        fontSize: 30.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Expanded(
                                  child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          Colors.grey, BlendMode.modulate),
                                      child:
                                          Image.asset('assets/mpc_logo.png')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          SizedBox.expand(
            child: FractionallySizedBox(
              alignment: FractionalOffset.centerRight,
              widthFactor: 0.65,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 50, 20),
                child: Container(
                  color: Color(
                    hexColor('#A7B0B5'),
                  ),
//DRUM PADS
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  buildPad(soundNumber: 1),
                                  buildPad(soundNumber: 2),
                                  buildPad(soundNumber: 3),
                                  buildPad(soundNumber: 4),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  buildPad(soundNumber: 5),
                                  buildPad(soundNumber: 6),
                                  buildPad(soundNumber: 7),
                                  buildPad(soundNumber: 8),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  buildPad(soundNumber: 9),
                                  buildPad(soundNumber: 10),
                                  buildPad(soundNumber: 11),
                                  buildPad(soundNumber: 12),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  buildPad(soundNumber: 13),
                                  buildPad(soundNumber: 14),
                                  buildPad(soundNumber: 15),
                                  buildPad(soundNumber: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int hexColor(String color) {
    //adding prefix
    String newColor = '0xff' + color;
    //removing # sign
    newColor = newColor.replaceAll('#', '');
    //converting it to the integer
    int finalColor = int.parse(newColor);
    return finalColor;
  }
}
