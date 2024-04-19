import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workshop_mobile_uts/database/timer_database.dart';
import 'package:workshop_mobile_uts/models/timer.dart';
import '../widgets/round-button.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with TickerProviderStateMixin {
  late String _title;
  late String _description;
  late Duration _durationTimer;
  late AnimationController controller;
  bool isPlaying = false;
  double progress = 1.0;
  bool isDone = false;
  late Timer _timer;
  var _isLoading = false;
  var _isStop = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _refreshTimer() async {
    setState(() {
      _isLoading = true;
    });
    _timer = await TimerDatabase.instance.getTimerById(widget.id);
    setState(() {
      print(_timer.durationTime.inSeconds);
      _isLoading = false;
    });

    _title = _timer.title;
    _description = _timer.description;
    _durationTimer = _timer.durationTime;

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timer.durationTime.inSeconds),
    );

    controller.addListener(() {
      notify();
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
          isPlaying = false;
        });
      }
    });
  }

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${(controller.duration!.inHours)}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${(count.inHours)}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void notify() {
    if (controller.value == 0 && _isStop == false) {
      FlutterRingtonePlayer().playAlarm();
      _stopAlarm();
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTimer();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
              onPressed: () async {
                final updateNote = Timer(
                    id: widget.id,
                    title: _title,
                    description: _description,
                    durationTime: _durationTimer);
                if (_isLoading) return;
                final isValid = _formKey.currentState!.validate();

                if (isValid)
                  await TimerDatabase.instance.updateTimer(updateNote);
              },
              icon: const Icon(Icons.save),
              color: Colors.blue),
          IconButton(
              onPressed: () async {
                if (_isLoading) return;
                await TimerDatabase.instance.deleteTimerById(widget.id);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      ),
      backgroundColor: Color(0xfff5fbff),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Center(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextFormField(
                          maxLength: 30,
                          textAlign: TextAlign.center,
                          initialValue: _timer.title,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (title) {
                            _title = title;
                          },
                          validator: (title) {
                            if (title != null && title.isEmpty) {
                              return 'The Title Cannot be empty';
                            } else {
                              _title = title!;
                              return null;
                            }
                          }),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextFormField(
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        maxLength: 150,
                        initialValue: _timer.description,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              wordSpacing: 2,
                              letterSpacing: .6,
                              fontSize: 13),
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (desc) {
                          _description = desc;
                        },
                        validator: (desc) {
                          if (desc != null && desc.isEmpty) {
                            return 'The Title Cannot be empty';
                          } else {
                            _description = desc!;
                            return null;
                          }
                        }),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          color: Colors.amber.shade900,
                          value: progress,
                          strokeWidth: 6,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (controller.isDismissed) {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height: 300,
                                child: CupertinoTimerPicker(
                                    onTimerDurationChanged: (time) {
                                  setState(() {
                                    controller.duration = time;
                                    _durationTimer = time;
                                  });
                                }),
                              ),
                            );
                          }
                        },
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) => Text(
                            countText,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _isStop = false;
                          if (controller.isAnimating) {
                            controller.stop();
                            setState(() {
                              isPlaying = false;
                            });
                          } else {
                            controller.reverse(
                                from: controller.value == 0
                                    ? 1.0
                                    : controller.value);
                            setState(() {
                              isPlaying = true;
                            });
                          }
                        },
                        child: RoundButton(
                          icon: isPlaying == true
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _isStop = true;
                          controller.reset();
                          setState(() {
                            isPlaying = false;
                          });
                        },
                        child: RoundButton(
                          icon: Icons.stop,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Future<void> _stopAlarm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 200),
      builder: (context) {
        return Center(
            child: Column(
          children: [
            Text("Berhentikan Alarm ?"),
            GestureDetector(
              onTap: () {
                FlutterRingtonePlayer().stop();
              },
              child: RoundButton(
                icon: Icons.alarm_off,
              ),
            )
          ],
        ));
      },
    );
  }
}
