import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workshop_mobile_uts/database/timer_database.dart';
import 'package:workshop_mobile_uts/models/timer.dart';
import 'package:workshop_mobile_uts/views/add_time_page.dart';
import 'package:workshop_mobile_uts/views/countdown_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Timer> _timers;
  int countTime = 0;
  var _isLoading = true;

  Future<void> _refreshTimers() async {
    setState(() {
      _isLoading = true;
    });
    _timers = await TimerDatabase.instance.getAllTimers();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTimers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Routine Timer App',
          style: GoogleFonts.plusJakartaSans(
            textStyle: TextStyle(
                color: Colors.black,
                wordSpacing: 2,
                letterSpacing: .6,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade50,
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTimerPage()));

          _refreshTimers();
        },
      ),
      body: Container(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _timers.isEmpty
                ? Center(
                    child: Text(
                    "Timer Masih Kosong...",
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          wordSpacing: 2,
                          letterSpacing: .6,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ))
                : ListView.builder(
                    itemCount: _timers.length,
                    itemBuilder: (context, index) {
                      final timer = _timers[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CountdownPage(id: timer.id!)));
                          _refreshTimers();
                        },
                        child: Container(
                          child: Center(
                              child: Text(
                            timer.title,
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          )),
                          height: 80,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
