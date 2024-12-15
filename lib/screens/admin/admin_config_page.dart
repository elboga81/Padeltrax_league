import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/match_maker.dart';
import '../../constants/app_constants.dart';

class AdminConfigPage extends StatefulWidget {
  const AdminConfigPage({Key? key}) : super(key: key);

  @override
  State<AdminConfigPage> createState() => _AdminConfigPageState();
}

class _AdminConfigPageState extends State<AdminConfigPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _earlyTimeslotCourtsController =
      TextEditingController();
  final TextEditingController _earlyStartTimeController =
      TextEditingController();
  final TextEditingController _earlyEndTimeController = TextEditingController();
  final TextEditingController _laterTimeslotCourtsController =
      TextEditingController();
  final TextEditingController _laterStartTimeController =
      TextEditingController();
  final TextEditingController _laterEndTimeController = TextEditingController();

  bool _isLoading = false;
  String _earlyMatchDuration = '';
  String _laterMatchDuration = '';

  final List<String> _timeOptions = [
    '8:00',
    '8:30',
    '9:00',
    '9:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '1:00',
    '1:30',
    '2:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
    _earlyStartTimeController.addListener(() => _updateDuration(true));
    _earlyEndTimeController.addListener(() => _updateDuration(true));
    _laterStartTimeController.addListener(() => _updateDuration(false));
    _laterEndTimeController.addListener(() => _updateDuration(false));
  }

  void _updateDuration(bool isEarly) {
    if (isEarly) {
      if (_earlyStartTimeController.text.isNotEmpty &&
          _earlyEndTimeController.text.isNotEmpty) {
        setState(() {
          _earlyMatchDuration = _calculateDuration(
            _earlyStartTimeController.text,
            _earlyEndTimeController.text,
          );
        });
      }
    } else {
      if (_laterStartTimeController.text.isNotEmpty &&
          _laterEndTimeController.text.isNotEmpty) {
        setState(() {
          _laterMatchDuration = _calculateDuration(
            _laterStartTimeController.text,
            _laterEndTimeController.text,
          );
        });
      }
    }
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final now = DateTime.now();
      final start = _parseTimeString(startTime, now);
      final end = _parseTimeString(endTime, now);

      if (start == null || end == null) return '';

      final difference = end.difference(start);
      return '${difference.inMinutes} min Match Time';
    } catch (e) {
      debugPrint('Error calculating duration: $e');
      return '';
    }
  }

  DateTime? _parseTimeString(String timeString, DateTime baseDate) {
    try {
      final parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Adjust for PM times
      if (hour < 8) {
        // If hour is 1-7, assume PM
        hour += 12;
      }

      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return null;
    }
  }

  Future<void> _loadExistingConfig() async {
    try {
      final configDoc = await FirebaseFirestore.instance
          .collection(TimeslotConstants.adminConfigCollection)
          .doc(TimeslotConstants.weeklyConfigDoc)
          .get();

      if (configDoc.exists && configDoc.data() != null) {
        final data = configDoc.data()!;
        final earlySlot = data['earlyTimeslot'] as Map<String, dynamic>? ?? {};
        final laterSlot = data['laterTimeslot'] as Map<String, dynamic>? ?? {};

        setState(() {
          _earlyTimeslotCourtsController.text =
              (earlySlot['numberOfCourts']?.toString() ?? '3');
          _earlyStartTimeController.text =
              earlySlot['startTime']?.toString() ?? '8:00';
          _earlyEndTimeController.text =
              earlySlot['endTime']?.toString() ?? '9:30';

          _laterTimeslotCourtsController.text =
              (laterSlot['numberOfCourts']?.toString() ?? '3');
          _laterStartTimeController.text =
              laterSlot['startTime']?.toString() ?? '9:30';
          _laterEndTimeController.text =
              laterSlot['endTime']?.toString() ?? '11:00';
        });
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final messenger = ScaffoldMessenger.of(context);
      final firestore = FirebaseFirestore.instance;

      // 1. First, get existing matches with correct typing
      final existingMatchesSnapshot =
          await firestore.collection('matches').get();
      final existingMatches = Map<String, Map<String, dynamic>>.fromEntries(
        existingMatchesSnapshot.docs.map(
          (doc) => MapEntry(doc.id, doc.data()),
        ),
      );

      // 2. Save admin configuration
      final adminConfig = {
        'earlyTimeslot': {
          'numberOfCourts': int.parse(_earlyTimeslotCourtsController.text),
          'startTime': _earlyStartTimeController.text,
          'endTime': _earlyEndTimeController.text,
        },
        'laterTimeslot': {
          'numberOfCourts': int.parse(_laterTimeslotCourtsController.text),
          'startTime': _laterStartTimeController.text,
          'endTime': _laterEndTimeController.text,
        },
      };

      await firestore
          .collection(TimeslotConstants.adminConfigCollection)
          .doc(TimeslotConstants.weeklyConfigDoc)
          .set(adminConfig);

      final appState = context.read<AppState>();

      if (!mounted) return;

      // 3. Create/update courts while preserving existing data
      await MatchMaker.createCourtsForAllDaysPreservingData(
        context,
        appState.players,
        existingMatches,
        earlyConfig:
            Map<String, dynamic>.from(adminConfig['earlyTimeslot'] as Map),
        laterConfig:
            Map<String, dynamic>.from(adminConfig['laterTimeslot'] as Map),
      );

      await appState.refreshMatches();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Configuration saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving configuration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTimeDropdown({
    required String label,
    required TextEditingController controller,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
      dropdownColor: Colors.white,
      value: controller.text.isNotEmpty ? controller.text : null,
      items: items
          .map((time) => DropdownMenuItem<String>(
                value: time,
                child: Text(
                  time,
                  style: const TextStyle(color: Colors.black),
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            controller.text = value;
          });
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a time' : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
      dropdownColor: Colors.white,
      value: controller.text.isNotEmpty ? controller.text : null,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.black),
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            controller.text = value;
          });
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a value' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Configuration'),
        backgroundColor: const Color(0xFF4285F4),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF922790)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Early Timeslot',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Number of Courts',
                    controller: _earlyTimeslotCourtsController,
                    items: List.generate(10, (index) => (index + 1).toString()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeDropdown(
                          label: 'Start Time',
                          controller: _earlyStartTimeController,
                          items: _timeOptions,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeDropdown(
                          label: 'End Time',
                          controller: _earlyEndTimeController,
                          items: _timeOptions,
                        ),
                      ),
                    ],
                  ),
                  if (_earlyMatchDuration.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _earlyMatchDuration,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Later Timeslot',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Number of Courts',
                    controller: _laterTimeslotCourtsController,
                    items: List.generate(10, (index) => (index + 1).toString()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeDropdown(
                          label: 'Start Time',
                          controller: _laterStartTimeController,
                          items: _timeOptions,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeDropdown(
                          label: 'End Time',
                          controller: _laterEndTimeController,
                          items: _timeOptions,
                        ),
                      ),
                    ],
                  ),
                  if (_laterMatchDuration.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _laterMatchDuration,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Save Configuration',
                              style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _earlyTimeslotCourtsController.dispose();
    _earlyStartTimeController.dispose();
    _earlyEndTimeController.dispose();
    _laterTimeslotCourtsController.dispose();
    _laterStartTimeController.dispose();
    _laterEndTimeController.dispose();
    super.dispose();
  }
}
