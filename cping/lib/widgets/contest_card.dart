import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../calendar/client.dart';
import '../config/colors.dart';
import '../firestore/user_data.dart';
import '../models/contest.dart';
import '../widgets/time.dart';

class ContestCard extends StatefulWidget {
  final Contest contest;

  String formatDate(DateTime dateTime) {
    return DateFormat('E, d MMM y - H:mm').format(dateTime);
  }

  const ContestCard({required this.contest, Key? key}) : super(key: key);

  @override
  _ContestCardState createState() => _ContestCardState();
}

class _ContestCardState extends State<ContestCard> {
  static const TextStyle contestNameStyle = TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontFamily: 'Kaisei',
    letterSpacing: 0.8,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 30,
      ),
      child: Container(
        color: MyColors.navyBlue,
        // width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(10),
        child: Column(children: <Widget>[
          DateTime.now().toLocal().isAfter(widget.contest.start)
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: const Text(
                    'Ongoing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                )
              : const Text(''),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              widget.contest.name,
              style: contestNameStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
              color: DateTime.now().toLocal().isAfter(widget.contest.start)
                  ? Colors.green
                  : Colors.brown),
          const SizedBox(height: 10),
          Row(
            children: [
              Time(time: widget.contest.start),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
              Time(time: widget.contest.end),
            ],
          ),
          widget.contest.calendarId == 'null'
              ? TextButton(
                  onPressed: () async {
                    CalendarClient client = CalendarClient();
                    try {
                      final contest = await client.insert(
                        title: widget.contest.name,
                        startTime: widget.contest.start,
                        endTime: widget.contest.end,
                      );

                      widget.contest.calendarId = contest['id'].toString();

                      final docId = await UserDatabase.addContest(
                        calendarId: widget.contest.calendarId,
                        start: widget.contest.start.toString(),
                        name: widget.contest.name,
                        length: widget.contest.length,
                      );

                      setState(() {
                        widget.contest.docId = docId;
                      });
                    } catch (e) {
                      debugPrint('event could not be added!');
                      debugPrint(e.toString());
                    }
                    showActionSnackBar(
                        context, "Event has been added to your calender");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ))
              : TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      CalendarClient client = CalendarClient();
                      await client.delete(widget.contest.calendarId);
                      UserDatabase.deleteContest(docId: widget.contest.docId);
                      setState(() {
                        widget.contest.calendarId = 'null';
                      });
                    } catch (e) {
                      debugPrint('event could not be deleted!');
                      debugPrint(e.toString());
                    }
                    showActionSnackBar(
                        context, "Event has been removed from your calender");
                  },
                )
        ]),
      ),
    );
  }
}

void showActionSnackBar(BuildContext context, String message) {
  final SnackBar snackBar = SnackBar(
    content: Text(message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 16, fontFamily: 'Kaisei', fontWeight: FontWeight.bold)),
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
