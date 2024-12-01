import 'package:flutter/material.dart';
import 'package:vibrationpattern/create_screen.dart';

import 'widgets/editor.dart';

enum TypeNotification { high, medium, low }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vibration Pattern'),
          bottom: TabBar(tabs: [
            const Tab(text: 'Create'),
            ...TypeNotification.values.map((e) => Tab(text: e.name))
          ]),
        ),
        body: TabBarView(
          children: [
            const CreateScreen(),
            ...TypeNotification.values.map(
              (e) => Editor(typeNotification: e),
            )
          ],
        ),
      ),
    );
  }
}
