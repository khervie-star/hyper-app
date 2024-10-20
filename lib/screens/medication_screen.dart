import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MedicationLifestyleScreen extends StatefulWidget {
  final String classification;
  final Color classificationColor;

  const MedicationLifestyleScreen({
    Key? key,
    required this.classification,
    required this.classificationColor,
  }) : super(key: key);

  @override
  _MedicationLifestyleScreenState createState() =>
      _MedicationLifestyleScreenState();
}

class _MedicationLifestyleScreenState extends State<MedicationLifestyleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic> healthData = {};
  Map<DateTime, List<dynamic>> _events = {};
  bool _showAddMedication = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _loadHealthData();
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleMedicationReminder(
      String medicationName, TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    const androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Medication Reminder',
      'Time to take $medicationName',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Widget _buildAdherenceChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    DateFormat('MM/dd').format(DateTime.now()
                        .subtract(Duration(days: (7 - value).toInt()))),
                    style: TextStyle(fontSize: 10),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (index) {
                return FlSpot(index.toDouble(), (index % 3 == 0) ? 1 : 0.8);
              }),
              isCurved: true,
              color: widget.classificationColor,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationTimeSelector() {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Medication Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildTimeChip(
                    'Morning', TimeOfDay(hour: 8, minute: 0), setState),
                _buildTimeChip(
                    'Afternoon', TimeOfDay(hour: 13, minute: 0), setState),
                _buildTimeChip(
                    'Evening', TimeOfDay(hour: 18, minute: 0), setState),
                _buildTimeChip(
                    'Night', TimeOfDay(hour: 21, minute: 0), setState),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, TimeOfDay time, StateSetter setState) {
    return ActionChip(
      label: Text(label),
      onPressed: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          // Schedule reminder
          _scheduleMedicationReminder('Medication Name', picked);
        }
      },
      backgroundColor: widget.classificationColor.withOpacity(0.1),
      labelStyle: TextStyle(color: widget.classificationColor),
    );
  }

  Widget _buildMedicationDetails(Map<String, dynamic> medication) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication['medicationName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.classificationColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dosage: ${medication['schedule']['dosage']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notification_add),
                  color: widget.classificationColor,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildMedicationTimeSelector(),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.classificationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: widget.classificationColor),
                  SizedBox(width: 8),
                  Text(
                    '${medication['schedule']['frequency']} - ${medication['schedule']['time']}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(medication['instructions']),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleCard(
      String title, IconData icon, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.classificationColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.classificationColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: widget.classificationColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.classificationColor,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['recommendations'],
                  style: TextStyle(fontSize: 14.0, height: 1.5),
                ),
                if (data['examples'] != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.classificationColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examples:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.classificationColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['examples'],
                          style: TextStyle(
                            fontSize: 14.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

// Add these methods to the _MedicationLifestyleScreenState class

  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: widget.classificationColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: widget.classificationColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: widget.classificationColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonDecoration: BoxDecoration(
            color: widget.classificationColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: TextStyle(color: widget.classificationColor),
          titleCentered: true,
        ),
      ),
    );
  }

  Future<void> _loadHealthData() async {
    // Simulate loading data from a database or API
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      healthData = {
        "NormalBloodPressure": {
          "bloodPressureRange": "Less than 120/80 mmHg",
          "lifestyle": {
            "diet": {
              "recommendations":
                  "Maintain a balanced diet rich in fruits, vegetables, whole grains, and lean proteins.",
              "saltIntake":
                  "Limit sodium intake to under 2,300 mg per day, preferably closer to 1,500 mg."
            },
            "exercise": {
              "recommendations":
                  "Engage in regular physical activity for at least 150 minutes of moderate exercise or 75 minutes of vigorous exercise per week.",
              "examples": "Jogging, swimming, strength training, and cycling."
            },
            "weightManagement": {
              "recommendations":
                  "Maintain a healthy BMI between 18.5 and 24.9.",
              "strategy":
                  "Healthy diet and regular exercise to keep weight in check."
            },
            "alcohol": {
              "recommendations":
                  "Consume alcohol in moderation: no more than 1 drink per day for women and 2 drinks per day for men."
            },
            "smoking": {
              "recommendations":
                  "Avoid smoking and secondhand smoke exposure to maintain cardiovascular health."
            },
            "stressManagement": {
              "recommendations":
                  "Practice stress reduction techniques like mindfulness, yoga, or meditation regularly."
            }
          }
        },
        "Stage1Hypertension": {
          "bloodPressureRange": "130-139/80-89 mmHg",
          "lifestyle": {
            "diet": {
              "recommendations":
                  "Adopt the DASH diet (rich in fruits, vegetables, whole grains, and low-fat dairy).",
              "saltIntake":
                  "Limit sodium to less than 2,300 mg per day, ideally 1,500 mg."
            },
            "exercise": {
              "recommendations":
                  "Engage in at least 150 minutes of moderate-intensity exercise per week.",
              "examples": "Walking, swimming, cycling."
            },
            "weightManagement": {
              "recommendations":
                  "Aim to maintain a healthy BMI between 18.5 and 24.9.",
              "strategy":
                  "Losing 1-2 pounds per week through diet and exercise."
            },
            "alcohol": {
              "recommendations":
                  "Limit alcohol to no more than 1 drink per day for women and 2 drinks per day for men."
            },
            "smoking": {
              "recommendations": "Quit smoking to improve heart health."
            },
            "stressManagement": {
              "recommendations":
                  "Incorporate stress-relief techniques like yoga, meditation, or deep breathing exercises."
            }
          },
          "medications": {
            "ThiazideDiuretics": {
              "medicationName": "Hydrochlorothiazide, Chlorthalidone",
              "schedule": {
                "frequency": "Once daily",
                "time": "Morning",
                "dosage": "12.5-25 mg",
                "numberOfPills": 1
              },
              "instructions":
                  "Take in the morning to avoid nighttime urination. Ensure adequate fluid intake."
            },
            "ACEInhibitors": {
              "medicationName": "Lisinopril, Enalapril",
              "schedule": {
                "frequency": "Once daily",
                "time": "Morning or Evening",
                "dosage": "10-40 mg",
                "numberOfPills": 1
              },
              "instructions":
                  "Can be taken with or without food. If starting, consider taking first dose at night to avoid dizziness."
            },
            "ARBs": {
              "medicationName": "Losartan, Valsartan",
              "schedule": {
                "frequency": "Once daily",
                "time": "Morning or Evening",
                "dosage": "50-100 mg",
                "numberOfPills": 1
              },
              "instructions":
                  "Take with or without food. Monitor for dizziness."
            },
            "CalciumChannelBlockers": {
              "medicationName": "Amlodipine",
              "schedule": {
                "frequency": "Once daily",
                "time": "Morning",
                "dosage": "5-10 mg",
                "numberOfPills": 1
              },
              "instructions":
                  "Take with or without food. Watch for leg swelling."
            }
          }
        },
        "Stage2Hypertension": {
          "bloodPressureRange": "≥140/90 mmHg",
          "lifestyle": {
            "diet": {
              "recommendations":
                  "Strict adherence to the DASH diet, with increased focus on potassium-rich foods.",
              "saltIntake": "Limit sodium to less than 1,500 mg per day."
            },
            "exercise": {
              "recommendations":
                  "Engage in 150 minutes of moderate-intensity aerobic exercise weekly.",
              "examples": "Walking, cycling, or water aerobics."
            },
            "weightManagement": {
              "recommendations":
                  "Lose 5-10% of body weight to help reduce blood pressure.",
              "strategy":
                  "Reduce caloric intake and increase physical activity."
            },
            "alcohol": {
              "recommendations":
                  "Reduce alcohol consumption to 1 drink daily for women, 2 drinks daily for men."
            },
            "smoking": {
              "recommendations":
                  "Quit smoking immediately for heart and blood vessel health."
            },
            "stressManagement": {
              "recommendations":
                  "Use stress-reducing methods like progressive muscle relaxation or therapy."
            }
          },
          "medications": {
            "CombinationTherapy": {
              "ACEInhibitor": {
                "medicationName": "Lisinopril",
                "schedule": {
                  "frequency": "Once daily",
                  "time": "Morning or Evening",
                  "dosage": "10-40 mg",
                  "numberOfPills": 1
                },
                "instructions":
                    "Take at the same time each day. Can be taken with or without food."
              },
              "ARB": {
                "medicationName": "Losartan",
                "schedule": {
                  "frequency": "Once daily",
                  "time": "Morning or Evening",
                  "dosage": "50-100 mg",
                  "numberOfPills": 1
                },
                "instructions": "Take with or without food."
              },
              "ThiazideDiuretic": {
                "medicationName": "Hydrochlorothiazide",
                "schedule": {
                  "frequency": "Once daily",
                  "time": "Morning",
                  "dosage": "12.5-25 mg",
                  "numberOfPills": 1
                },
                "instructions":
                    "Drink fluids. Take in the morning to avoid nighttime urination."
              },
              "CalciumChannelBlocker": {
                "medicationName": "Amlodipine",
                "schedule": {
                  "frequency": "Once daily",
                  "time": "Morning or Evening",
                  "dosage": "5-10 mg",
                  "numberOfPills": 1
                },
                "instructions":
                    "Take with or without food. Watch for leg swelling."
              }
            },
            "BetaBlockers": {
              "medicationName": "Metoprolol, Atenolol",
              "schedule": {
                "frequency": "Once or Twice daily",
                "time": "Morning and/or Evening",
                "dosage": "25-100 mg",
                "numberOfPills": "1-2"
              },
              "instructions":
                  "Take with food. Do not stop taking without medical advice."
            },
            "AldosteroneAntagonists": {
              "medicationName": "Spironolactone",
              "schedule": {
                "frequency": "Once daily",
                "time": "Morning",
                "dosage": "25-50 mg",
                "numberOfPills": 1
              },
              "instructions": "Take with food. Monitor potassium levels."
            }
          }
        },
        "HypertensiveCrisis": {
          "bloodPressureRange": "≥180/120 mmHg",
          "lifestyle": {
            "diet": {
              "recommendations":
                  "Follow strict low-sodium diet under medical supervision.",
              "saltIntake": "Sodium intake limited to 1,000-1,500 mg per day."
            },
            "exercise": {
              "recommendations":
                  "Limited physical activity initially, under doctor guidance.",
              "examples": "Gentle walking as advised."
            },
            "weightManagement": {
              "recommendations":
                  "Gradual weight loss, but focus on stabilizing blood pressure first."
            },
            "alcohol": {
              "recommendations":
                  "Avoid alcohol until blood pressure is stabilized."
            },
            "smoking": {
              "recommendations": "Immediate smoking cessation required."
            },
            "stressManagement": {
              "recommendations":
                  "Manage stress with guided relaxation techniques."
            }
          },
          "medications": {
            "Nitroglycerin": {
              "medicationName": "Nitroglycerin (IV)",
              "schedule": {
                "frequency": "Continuous infusion",
                "dosage": "Varies",
                "administration": "Hospital setting"
              },
              "instructions":
                  "Administered in hospital via IV to control blood pressure."
            },
            "Labetalol": {
              "medicationName": "Labetalol (IV)",
              "schedule": {
                "frequency": "IV bolus or continuous infusion",
                "dosage": "20-80 mg bolus, or infusion",
                "administration": "Hospital setting"
              },
              "instructions":
                  "Monitored in a medical facility to reduce BP rapidly."
            }
          }
        }
      };
    });
  }

  Widget _buildLifestyleRecommendations() {
    final lifestyleData = healthData['lifestyle'] as Map<String, dynamic>;
    return Column(
      children: [
        _buildLifestyleCard(
          'Diet Recommendations',
          Icons.restaurant_menu,
          lifestyleData['diet'],
        ),
        _buildLifestyleCard(
          'Exercise Routine',
          Icons.fitness_center,
          lifestyleData['exercise'],
        ),
        _buildLifestyleCard(
          'Sleep Schedule',
          Icons.nightlight_round,
          lifestyleData['sleep'],
        ),
        _buildLifestyleCard(
          'Stress Management',
          Icons.spa,
          lifestyleData['stress'],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Management'),
        backgroundColor: widget.classificationColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.medication), text: 'Medications'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Lifestyle'),
          ],
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Medications Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarSection(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Medication Adherence',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildAdherenceChart(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medication Schedule',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        color: widget.classificationColor,
                        onPressed: () {
                          setState(() {
                            _showAddMedication = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (healthData['medications'] != null)
                  ...healthData['medications']
                      .values
                      .map((medication) => _buildMedicationDetails(medication))
                      .toList(),
              ],
            ),
          ),
          // Lifestyle Tab
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (healthData['lifestyle'] != null)
                    _buildLifestyleRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
