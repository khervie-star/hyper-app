import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hyper_app/services/bp_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _resetBPHistory() async {
    try {
      final bpService = Provider.of<BPService>(context, listen: false);
      await bpService.clearBPReadings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('History cleared successfully'),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('Error clearing BP readings: $e');
    }
  }

  Widget _buildSettingSection(String title, List<SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index != 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1),
                    ),
                  _buildSettingTile(item),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(SettingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: item.isDestructive
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: item.isDestructive
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResetConfirmationDialog() async {
    if (Platform.isIOS) {
      return showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Reset History'),
            content: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'This will permanently delete all your blood pressure readings. This action cannot be undone.',
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Reset'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _resetBPHistory();
                },
              ),
            ],
          );
        },
      );
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Reset History'),
          content: Text(
            'This will permanently delete all your blood pressure readings. This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetBPHistory();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferenceItems = [
      SettingItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage your alert preferences',
        onTap: () {},
      ),
      SettingItem(
        icon: Icons.person_outline,
        title: 'Account',
        subtitle: 'Profile settings and preferences',
        onTap: () {},
      ),
      SettingItem(
        icon: Icons.tune_outlined,
        title: 'Appearance',
        subtitle: 'Customize your app experience',
        onTap: () {},
      ),
    ];

    final privacyItems = [
      SettingItem(
        icon: Icons.shield_outlined,
        title: 'Privacy',
        subtitle: 'Manage your data and permissions',
        onTap: () {},
      ),
      SettingItem(
        icon: Icons.security_outlined,
        title: 'Security',
        subtitle: 'Password and authentication',
        onTap: () {},
      ),
    ];

    final dangerItems = [
      SettingItem(
        icon: Icons.delete_outline_rounded,
        title: 'Reset History',
        subtitle: 'Delete all blood pressure readings',
        onTap: _showResetConfirmationDialog,
        isDestructive: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: Platform.isIOS,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildSettingSection('Preferences', preferenceItems),
            _buildSettingSection('Privacy & Security', privacyItems),
            _buildSettingSection('Danger Zone', dangerItems),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}
