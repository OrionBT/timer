import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(
        title: 'Timer App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1500;
  int _counterMinutes = 25;
  int _counterSeconds = 0;
  int _timerCycle = 0;
  bool _timerActive = false;
  bool _timerCompleted = false;
  final player = AudioCache();
  final NumberFormat _timerFormat = NumberFormat('00');

  getCounter() {
    return _counter;
  }

  setCounter(int minutes, int seconds) {
    if (_timerActive) {
      Alert(
              context: context,
              type: AlertType.warning,
              title: "Warning",
              desc: 'Please Stop Timer')
          .show();
    } else if ((minutes + seconds) == 0) {
      Alert(
              context: context,
              type: AlertType.warning,
              title: "Warning",
              desc: 'Please select time greater than 00:00')
          .show();
    } else {
      int minToSecs = (minutes * 60);
      _counterMinutes = minutes;
      _counterSeconds = seconds;
      _counter = (minToSecs + seconds);
      _timerCompleted = false;
    }
  }

  late Timer _timer;

  void _startTimer() {
    _counter = getCounter();
    if (!_timerActive && _counter > 0) {
      _timerActive = true;
      _timerCompleted = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_counter > 0) {
            _counter--;
            _counterMinutes = (_counter / 60).floor();
            _counterSeconds = (_counter % 60);
            if (_counter == 0) {
              //player.play("beep.wav");
              player.loop("beep.wav");
              _timerActive = false;
              _timerCompleted = true;
              _timerCycle += 1;
            }
          } else {
            _timer.cancel();
          }
        });
      });
    }
  }

  _stopTimer() {
    _counter = getCounter();
    _timerActive = false;
    _timerCompleted = false;
    _timer.cancel();
  }

  _clearTimer() {
    _counterSeconds = 0;
    _counterMinutes = 0;
    _counter = 0;
    _timer.cancel();
    _timerActive = false;
    _timerCompleted = false;
  }

  int _secondsValue = 0;
  int _minutesValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Timer App"),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      "Minutes",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    NumberPicker(
                      value: _minutesValue,
                      minValue: 0,
                      maxValue: 60,
                      onChanged: (value) =>
                          setState(() => _minutesValue = value),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      " Seconds",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    NumberPicker(
                      value: _secondsValue,
                      minValue: 0,
                      maxValue: 59,
                      onChanged: (value) =>
                          setState(() => _secondsValue = value),
                    ),
                  ],
                ),
              ],
            ),
            // ElevatedButton(
            //     onPressed: () =>
            //         setState(() => setCounter(_minutesValue, _secondsValue)),
            //     child: const Text('Set Time')),

            if (_timerCycle % 2 == 0)
              ElevatedButton(
                onPressed: () =>
                    setState(() => setCounter(_minutesValue, _secondsValue)),
                child: const Text('Set Work Time'),
              ),

            if (_timerCycle % 2 == 1)
              ElevatedButton(
                onPressed: () =>
                    setState(() => setCounter(_minutesValue, _secondsValue)),
                child: const Text('Set Break Time'),
              ),

            // const Text(
            //   "Time For a Break!",
            //   style: TextStyle(
            //     color: Colors.green,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 48,
            //   ),
            // ),
            Text(
              '${_timerFormat.format(_counterMinutes)}:${_timerFormat.format(_counterSeconds)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _startTimer(),
                  child: const Text("Start"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _stopTimer(),
                    child: const Text("Stop"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _clearTimer()),
                  child: const Text("Clear"),
                ),
              ],
            ),
            if (_counter == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => player.clearAll(),
                    child: const Text('Stop Alarm'),
                  ),
                ],
              )
          ],
        ));
  }
}
