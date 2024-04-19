import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workshop_mobile_uts/database/timer_database.dart';
import 'package:workshop_mobile_uts/models/timer.dart';
import 'package:workshop_mobile_uts/widgets/form-widget.dart';

class AddTimerPage extends StatefulWidget {
  const AddTimerPage({super.key, this.timers});
  final Timer? timers;

  @override
  State<AddTimerPage> createState() => _AddTimerPageState();
}

class _AddTimerPageState extends State<AddTimerPage>
    with TickerProviderStateMixin {
  late String _title;
  late String _description;
  late Duration _durationTime;
  final _formKey = GlobalKey<FormState>();
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title = widget.timers?.title ?? '';
    _description = widget.timers?.description ?? '';
    _durationTime = widget.timers?.durationTime ?? Duration.zero;
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    controller.duration = Duration.zero;
  }

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${(controller.duration!.inHours)}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${(count.inHours)}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Add Timer",
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
                color: Colors.black,
                wordSpacing: 2,
                letterSpacing: .6,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        actions: [
          _buildButtonSave(),
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: TimerFormWidget(
              title: _title,
              description: _description,
              onChangeTitle: (value) {
                setState(() {
                  _title = value;
                });
              },
              onChangeDescription: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
          ),
          Text("Duration Time"),
          GestureDetector(
            onTap: () {
              if (controller.isDismissed) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 300,
                    child: CupertinoTimerPicker(onTimerDurationChanged: (time) {
                      setState(() {
                        controller.duration = time;
                        _durationTime = time;
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
    );
  }

  Widget _buildButtonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
          onPressed: () async {
            final isValid = _formKey.currentState!.validate();
            if (isValid) {
              await _addNote();
              Navigator.pop(context);
            }
          },
          child: Text(
            'Save',
            style: GoogleFonts.plusJakartaSans(
              textStyle: TextStyle(
                  color: Colors.black,
                  wordSpacing: 2,
                  letterSpacing: .6,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          )),
    );
  }

  Future<void> _addNote() async {
    final timer = Timer(
        title: _title, description: _description, durationTime: _durationTime);
    await TimerDatabase.instance.create(timer);
  }
}
