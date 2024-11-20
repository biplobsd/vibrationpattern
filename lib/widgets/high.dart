import 'package:flutter/material.dart';
import 'package:vibrationpattern/notification_service.dart';

import '../home_screen.dart';
import '../shared_preferences_helper.dart';

class High extends StatefulWidget {
  final TypeNotification typeNotification;
  const High({super.key, required this.typeNotification});

  @override
  State<High> createState() => _HighState();
}

class _HighState extends State<High> {
  List<int> pattern = [];
  List<int> intensities = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> save(List<int> pattern, List<int> intensities) async {
    await SharedPreferencesHelper.saveMap(
      widget.typeNotification.name,
      {
        'pattern': pattern,
        'intensities': intensities,
      },
    );
  }

  Future<void> load() async {
    final value =
        await SharedPreferencesHelper.loadMap(widget.typeNotification.name);

    if (value == null) {
      print('${widget.typeNotification.name} = $value');
      switch (widget.typeNotification) {
        case TypeNotification.high:
          await save(
            [0, 1000, 200, 1000, 200, 1000],
            [0, 255, 0, 255, 0, 255],
          );

          break;
        case TypeNotification.medium:
          await save(
            [0, 500, 200, 500],
            [0, 128, 0, 128],
          );

          break;
        case TypeNotification.low:
          await save(
            [0, 200, 100, 200],
            [0, 64, 0, 64],
          );

          break;
        default:
      }
      await load();
      return;
    }
    print('${widget.typeNotification.name} = $value');

    setState(() {
      pattern = value['pattern'] ?? [];
      intensities = value['intensities'] ?? [];
    });
  }

  String _getStepType(int index) => index % 2 == 0 ? "Wait" : "Vibrate";

  Color _getCardColor(int index) =>
      index % 2 == 0 ? Colors.blue.shade100 : Colors.green.shade100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () async {
            await NotificationService.createNewNotification(
                widget.typeNotification.name);
          },
          icon: const Icon(Icons.play_arrow),
        ),
        Text(
          'Pattern=$pattern\nIntensities=$intensities',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pattern.length,
            itemBuilder: (context, index) {
              final stepType = _getStepType(index);
              return Card(
                color: _getCardColor(index),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$stepType Step ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Duration (ms):'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter duration (ms)',
                              ),
                              onChanged: (value) async {
                                final newValue = int.tryParse(value) ?? 0;
                                setState(() {
                                  pattern[index] = newValue.clamp(0, 10000);
                                });
                                await save(pattern, intensities);
                              },
                              controller: TextEditingController(
                                text: pattern[index].toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Intensity (0-255):'),
                          Expanded(
                            child: Slider(
                              value: intensities[index].toDouble(),
                              min: 0,
                              max: 255,
                              divisions: 20,
                              label: '${intensities[index]}',
                              onChanged: (value) async {
                                setState(() {
                                  intensities[index] = value.toInt();
                                });
                                await save(pattern, intensities);
                              },
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            setState(() {
                              pattern.removeAt(index);
                              intensities.removeAt(index);
                            });
                            await save(pattern, intensities);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                pattern.add(500);
                intensities.add(pattern.length % 2 == 0 ? 0 : 128);
              });
              await save(pattern, intensities);
            },
            child: const Text('Add Step'),
          ),
        ),
      ],
    );
  }
}
