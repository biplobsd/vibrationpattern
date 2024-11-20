import 'package:flutter/material.dart';

import 'widgets/high.dart';

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vibration Pattern'),
          bottom: TabBar(
              tabs: TypeNotification.values
                  .map((e) => Tab(text: e.name))
                  .toList()),
        ),
        body: TabBarView(
          children: TypeNotification.values
              .map(
                (e) => High(typeNotification: e),
              )
              .toList(),
        ),
      ),
    );
  }
}
