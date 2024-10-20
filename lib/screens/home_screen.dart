import 'package:flutter/material.dart';
import 'package:hyper_app/services/bp_service.dart';
import 'package:hyper_app/widgets/health_info_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BPReading? lastReading;
  bool isLoading = true;
  List<BPReading> readings = [];

  @override
  void initState() {
    super.initState();
    loadLastReading();
  }

  Future<void> loadLastReading() async {
    setState(() => isLoading = true);
    try {
      final bpService = Provider.of<BPService>(context, listen: false);
      await bpService.loadBPReadings();
      readings = bpService.readings;

      if (readings.isNotEmpty) {
        readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        setState(() {
          lastReading = readings.first;
        });
      }
    } catch (e) {
      print('Error loading BP readings: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BPService>(builder: (context, bpService, child) {
      final currentReadings = bpService.readings;
      BPReading? recentReading;

      if (currentReadings.isNotEmpty) {
        currentReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        recentReading = currentReadings.first;
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hypertension Manager',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: loadLastReading,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Card
                _buildDashboardCard(recentReading),
                SizedBox(height: 24),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 16),
                _buildNavigationGrid(),
                SizedBox(height: 16),
                HealthInfoCard(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDashboardCard(BPReading? recentReading) {
    if (isLoading) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Container(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (recentReading == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/bp_input'),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 70,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                      Icon(
                        Icons.add_circle,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Start Tracking Your Health',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                SizedBox(height: 12),
                Text(
                  'Monitor your blood pressure regularly to maintain a healthy lifestyle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add First Reading',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Takes less than a minute',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stateColor = BPReading.getStateColor(recentReading.state);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: recentReading.state.isNotEmpty
              ? stateColor.withOpacity(0.3)
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${recentReading.systolic}/${recentReading.diastolic}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: stateColor,
                              ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'mmHg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recentReading.state,
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(recentReading.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildNavigationTile(
          context,
          'Record BP',
          Icons.add_circle_outline,
          '/bp_input',
          Colors.blue,
        ),
        _buildNavigationTile(
          context,
          'BP History',
          Icons.history,
          '/bp_history',
          Colors.green,
        ),
        _buildNavigationTile(
          context,
          'Medications',
          Icons.medication,
          '/medications',
          Colors.orange,
        ),
        _buildNavigationTile(
          context,
          'Settings',
          Icons.settings,
          '/settings',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMMM dd, yyyy - hh:mm a');
    return formatter.format(date);
  }
}
