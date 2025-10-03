// dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Masjid {
  final String name;
  final Map<String, TimeOfDay?> prayers;

  Masjid({
    required this.name,
    Map<String, TimeOfDay?>? prayers,
  }) : prayers = prayers ??
            {
              'Fajr': null,
              'Zuhr': null,
              'Asr': null,
              'Maghrib': null,
              'Isha': null,
            };

  Masjid copyWith({Map<String, TimeOfDay?>? prayers}) {
    return Masjid(
      name: name,
      prayers: prayers ?? Map.from(this.prayers),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid Timetable - Solapur',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MasjidListScreen(),
    );
  }
}

class MasjidListScreen extends StatefulWidget {
  const MasjidListScreen({super.key});
  @override
  State<MasjidListScreen> createState() => _MasjidListScreenState();
}

class _MasjidListScreenState extends State<MasjidListScreen> {
  final List<Masjid> _masjids = [
    Masjid(
      name: 'Quba Masjid',
      prayers: {
        'Fajr': TimeOfDay(hour: 5, minute: 15),
        'Zuhr': TimeOfDay(hour: 12, minute: 30),
        'Asr': TimeOfDay(hour: 16, minute: 0),
        'Maghrib': TimeOfDay(hour: 18, minute: 45),
        'Isha': TimeOfDay(hour: 20, minute: 0),
      },
    ),
    Masjid(name: 'Masjid Noor'),
    Masjid(name: 'Al-Falah Masjid'),
    Masjid(name: 'Jama Masjid'),
  ];

  String _format(TimeOfDay? t, BuildContext context) {
    if (t == null) return 'Not set';
    final local = MaterialLocalizations.of(context);
    return local.formatTimeOfDay(t, alwaysUse24HourFormat: false);
  }

  Future<void> _pickTimeFor(int index, String prayer) async {
    final current = _masjids[index].prayers[prayer] ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      setState(() {
        _masjids[index].prayers[prayer] = picked;
      });
    }
  }

  void _showSetTimesSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final keys = _masjids[index].prayers.keys.toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Set Prayer Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: keys.map((p) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickTimeFor(index, p);
                    },
                    child: Text(p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildPrayerLayout(Masjid m, double width, BuildContext context) {
    final entries = m.prayers.entries.toList();

    if (width < 600) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.key,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(_format(e.value, context),
                      style: const TextStyle(color: Colors.black87)),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else if (width < 1000) {
      return Row(
        children: entries.map((e) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(e.key,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                Text(_format(e.value, context),
                    style: const TextStyle(color: Colors.black87)),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: entries.map((e) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(e.key,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Text(_format(e.value, context),
                    style: const TextStyle(color: Colors.black87)),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.green,
            child: const Icon(Icons.mosque, color: Colors.white),
          ),
        ),
        title: const Text('Masjid wise timetable - Solapur'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, outerConstraints) {
          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
            itemCount: _masjids.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final masjid = _masjids[index];
              final bg = index.isEven ? Colors.white : Colors.green[10];
              return LayoutBuilder(
                builder: (context, itemConstraints) {
                  final itemWidth = itemConstraints.maxWidth;
                  final titleStyle = TextStyle(
                      fontSize: itemWidth < 600 ? 16 : 18,
                      fontWeight: FontWeight.bold);
                  return InkWell(
                    onTap: () => _showSetTimesSheet(index),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      color: bg, // simplified: only background color, no rounded corners
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(masjid.name, style: titleStyle),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildPrayerLayout(masjid, itemWidth, context),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // optional: add a new masjid or global action
        },
        icon: const Icon(Icons.add),
        label: const Text('Set Times'),
      ),
    );
  }
}