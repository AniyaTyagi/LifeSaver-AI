import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _gcalSync = true;
  bool _gmailFetch = true;
  bool _gtasksSync = true;
  String _personality = 'Empathetic';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Settings & Integrations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Google Workspace Connections Section
          _buildHeader('GOOGLE WORKSPACE SYNC'),
          SwitchListTile(
            title: const Text('Google Calendar Sync'),
            subtitle: const Text('Permits calendar event fetching & focus block writing.'),
            value: _gcalSync,
            activeColor: colors.primary,
            onChanged: (val) => setState(() => _gcalSync = val),
          ),
          SwitchListTile(
            title: const Text('Gmail Task Scan'),
            subtitle: const Text('Scans messages for commitments & automated deadlines.'),
            value: _gmailFetch,
            activeColor: colors.primary,
            onChanged: (val) => setState(() => _gmailFetch = val),
          ),
          SwitchListTile(
            title: const Text('Google Tasks Sync'),
            subtitle: const Text('Imports and exports items to native tasks client.'),
            value: _gtasksSync,
            activeColor: colors.primary,
            onChanged: (val) => setState(() => _gtasksSync = val),
          ),
          const SizedBox(height: 24),
          
          // Working boundary setups
          _buildHeader('WORKING HOURS BOUNDARY'),
          ListTile(
            title: const Text('Set Daily Working Hours'),
            subtitle: const Text('09:00 AM to 06:00 PM'),
            trailing: Icon(Icons.chevron_right, color: colors.onSurface.withOpacity(0.5)),
            onTap: () {
              // Time selector dialog simulation
            },
          ),
          const SizedBox(height: 24),
          
          // Personality Settings
          _buildHeader('COACH PERSONALITY PROFILE'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _personality,
              isExpanded: true,
              dropdownColor: colors.surface,
              underline: Container(height: 1, color: const Color(0xFF1F2B4D)),
              items: <String>['Empathetic', 'Direct', 'Strict'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _personality = val);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Sensitivity Settings
          _buildHeader('INTERVENTION THRESHOLD'),
          ListTile(
            title: const Text('Intervention Sensitivity'),
            subtitle: const Text('Notify when risk probability climbs above 70%'),
            trailing: Icon(Icons.tune, color: colors.secondary),
          ),
          const SizedBox(height: 48),
          
          // Account Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboarding');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Sign Out of Account', style: TextStyle(color: colors.error)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
