import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart';
import 'file:///C:/Users/noelm/Documents/InstaSmart/lib/models/login_functions.dart';
import 'package:instasmart/models/user.dart';

class ReminderData extends ChangeNotifier {
  final db = Firestore.instance;
  final FirebaseFunctions firebase = FirebaseFunctions();

  void createReminder({String caption, String picture_url}) async {
    try {
      User user = await firebase.currentUser();
      await db
          .collection("Users")
          .document(user.uid)
          .collection('reminders')
          .add({
        'caption': caption,
        'isPosted': false,
        'scheduled_image': picture_url,
        'date':
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        'postTime': DateTime.now().add(Duration(days: 1)),
      });
      print('done creating');
    } catch (e) {
      print(e);
    }
  }

  Future<List<Reminder>> getReminders(DateTime date) async {
    try {
      List<Reminder> reminders = List<Reminder>();
      User user = await firebase.currentUser();
      await db
          .collection("Users")
          .document(user.uid)
          .collection('reminders')
          .where('date', isEqualTo: "${date.day}/${date.month}/${date.year}")
          .getDocuments()
          .then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((reminder) {
          Reminder rem = Reminder(
              caption: reminder['caption'],
              isPosted: reminder['isPosted'],
              picture: Image.network(reminder['scheduled_image']),
              postTime: reminder['postTime'].toDate(),
              date: reminder['date'],
              id: reminder.documentID);
          reminders.add(rem);
        });
      });
      return reminders;
    } catch (e) {
      print(e);
    }
  }

  Future<List<Reminder>> getAllReminders() async {
    try {
      List<Reminder> reminders = List<Reminder>();
      User user = await firebase.currentUser();
      await db
          .collection("Users")
          .document(user.uid)
          .collection('reminders')
          .getDocuments()
          .then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((reminder) {
          Reminder rem = Reminder(
              caption: reminder['caption'],
              isPosted: reminder['isPosted'],
              picture: Image.network(reminder['scheduled_image']),
              postTime: reminder['postTime'].toDate(),
              date: reminder['date'],
              picture_url: reminder['scheduled_image'],
              id: reminder.documentID);
          reminders.add(rem);
        });
      });
      return reminders;
    } catch (e) {
      print(e);
    }
  }

  void updateReminder(Reminder reminder) async {
    try {
      User user = await firebase.currentUser();
      await db
          .collection("Users")
          .document(user.uid)
          .collection('reminders')
          .document(reminder.id)
          .updateData({
        'caption': reminder.caption,
        'isPosted': reminder.isPosted,
        'scheduled_image': reminder.picture_url,
        'date': reminder.date,
        'postTime': reminder.postTime,
      });
      print('done updating');
    } catch (e) {
      print(e);
    }
  }

  void deleteReminder(Reminder reminder) async {
    try {
      User user = await firebase.currentUser();
      await db
          .collection("Users")
          .document(user.uid)
          .collection('reminders')
          .document(reminder.id)
          .delete();
      print('done deleting');
    } catch (e) {
      print(e);
    }
  }

}
