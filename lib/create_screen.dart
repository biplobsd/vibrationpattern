import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vibrationpattern/shared_preferences_helper.dart';

import 'home_screen.dart';
import 'notification_service.dart';

const notificationDataKey = 'notificationData';

final defaultData = NotificationData(
    title: 'Huston! The eagle has landed!',
    body: "A small step for a man, but a giant leap to Flutter's community!",
    imageURL:
        'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png');

class NotificationData {
  String title;
  String body;
  String imageURL;

  NotificationData({
    required this.title,
    required this.body,
    required this.imageURL,
  });

  static NotificationData fromJson(Map<dynamic, dynamic> json) {
    final title = json['title'];
    final body = json['body'];
    final imageURL = json['imageURL'];
    return NotificationData(
      title: title,
      body: body,
      imageURL: imageURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'imageURL': imageURL,
    };
  }
}

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  CreateScreenState createState() => CreateScreenState();
}

class CreateScreenState extends State<CreateScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _urlController = TextEditingController();

  Widget _displayImage() {
    if (_urlController.text.isNotEmpty) {
      return Image.network(_urlController.text, height: 150,
          errorBuilder: (context, error, stackTrace) {
        return const Text('Invalid image URL');
      });
    }
    return const Text('No image selected');
  }

  Future<void> loadData() async {
    final data =
        await SharedPreferencesHelper.loadNotificationData(notificationDataKey);
    if (data != null) {
      _titleController.text = data.title;
      _bodyController.text = data.body;
      _urlController.text = data.imageURL;
    } else {
      _titleController.text = defaultData.title;
      _bodyController.text = defaultData.body;
      _urlController.text = defaultData.imageURL;
      await saveData();
    }
  }

  Future<void> saveData() async {
    await SharedPreferencesHelper.saveNotificationData(
      notificationDataKey,
      NotificationData(
        title: _titleController.text,
        body: _bodyController.text,
        imageURL: _urlController.text,
      ),
    );
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Combine TimeOfDay with the current date
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Convert to epoch time (milliseconds)
      final epochInt = selectedDateTime.millisecondsSinceEpoch;

      String? token = await FirebaseMessaging.instance.getToken();

      await Dio().get(
        'http://192.168.103.90:3000/api/webhook',
        queryParameters: {
          'date': epochInt,
          'deviceToken': token,
          'title': _titleController.text,
          'body': _bodyController.text,
          'vibrationLevel': 'high'
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a notification content'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (_) => saveData(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                onChanged: (_) => saveData(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) {
                  setState(() {}); // Refresh to display image from URL
                  saveData();
                },
              ),
              const SizedBox(height: 16),
              _displayImage(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await NotificationService.createNewNotification(
                      TypeNotification.high.name);
                },
                child: const Text('Fire'),
              ),
              ElevatedButton(
                onPressed: () => selectTime(context),
                child: const Text("Schedule Pick Time"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
