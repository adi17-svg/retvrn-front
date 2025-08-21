import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SpiralEvolutionChartScreen extends StatefulWidget {
  const SpiralEvolutionChartScreen({super.key});

  @override
  State<SpiralEvolutionChartScreen> createState() =>
      _SpiralEvolutionChartScreenState();
}

class _SpiralEvolutionChartScreenState
    extends State<SpiralEvolutionChartScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  DateTime? selectedDate;

  final Map<String, int> stageToValue = {
    "Beige": 1,
    "Purple": 2,
    "Red": 3,
    "Blue": 4,
    "Orange": 5,
    "Green": 6,
    "Yellow": 7,
    "Turquoise": 8,
  };

  final Map<int, String> valueToStage = {
    1: "Beige",
    2: "Purple",
    3: "Red",
    4: "Blue",
    5: "Orange",
    6: "Green",
    7: "Yellow",
    8: "Turquoise",
  };

  List<FlSpot> spots = [];
  List<String> times = [];

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  void _loadToday() {
    final today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    _loadStageDataForDate(selectedDate!);
  }

  Future<void> _loadStageDataForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot =
        await firestore
            .collection('users')
            .doc(user!.uid)
            .collection('mergedMessages')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('timestamp', isLessThan: Timestamp.fromDate(end))
            .orderBy('timestamp')
            .get();

    final messages =
        snapshot.docs
            .map((doc) => doc.data())
            .where((msg) => msg['type'] == 'spiral' && msg['stage'] != null)
            .toList();

    final dateSpots = <FlSpot>[];
    final timeLabels = <String>[];

    for (int i = 0; i < messages.length; i++) {
      final timestamp = messages[i]['timestamp'] as Timestamp;
      final stage = messages[i]['stage'];
      final timeStr = DateFormat('hh:mm a').format(timestamp.toDate());

      if (stageToValue.containsKey(stage)) {
        dateSpots.add(FlSpot(i.toDouble(), stageToValue[stage]!.toDouble()));
        timeLabels.add(timeStr);
      }
    }

    setState(() {
      spots = dateSpots;
      times = timeLabels;
    });
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= times.length) return const SizedBox.shrink();
    return Transform.rotate(
      angle: -0.5,
      child: Text(times[index], style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    final intValue = value.toInt();
    final label = valueToStage[intValue];
    if (label == null) return const SizedBox.shrink();
    return Text(label, style: const TextStyle(fontSize: 10));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      _loadStageDataForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    final selectedDateStr =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : 'Select a date';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Spiral Evolution Chart",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: textColor),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Date: $selectedDateStr",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 🔹 Chart Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        spots.isEmpty
                            ? Center(
                              child: Text(
                                "No data found for this date.",
                                style: TextStyle(color: textColor),
                              ),
                            )
                            : LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    barWidth: 3,
                                    color: Colors.purple,
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                                minY: 1,
                                maxY: 8,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: _bottomTitleWidgets,
                                      reservedSize: 40,
                                      interval: 1,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: _leftTitleWidgets,
                                      reservedSize: 60,
                                      interval: 1,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: true),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
