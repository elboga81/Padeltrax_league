import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'registration_form.dart';
import '../main_dashboard/main_dashboard.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _nationalityController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _preferredSide = 'Left';
  Uint8List? _selectedImageBytes;
  String? _error;
  bool _isRegistering = false;

  Future<void> _pickImage() async {
    try {
      final XFile? result =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || _isRegistering) return;

    if (!mounted) return;

    setState(() => _isRegistering = true);

    try {
      final contextBeforeAsync = context;

      // Simulate registration logic (replace with actual registration code)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pushReplacement(
        contextBeforeAsync,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Registration failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF4285F4),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF922790)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: RegistrationForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    nameController: _nameController,
                    levelController: _levelController,
                    nationalityController: _nationalityController,
                    preferredSide: _preferredSide,
                    onSideChanged: (value) {
                      setState(() {
                        _preferredSide = value!;
                      });
                    },
                    onImagePick: _pickImage,
                    selectedImageBytes: _selectedImageBytes,
                    error: _error,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _isRegistering ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isRegistering
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(Icons.app_registration, color: Colors.white),
                  label: Text(
                    _isRegistering ? 'Registering...' : 'Register',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _levelController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }
}
