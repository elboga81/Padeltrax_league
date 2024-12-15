import 'package:flutter/material.dart';
import 'dart:typed_data';

class RegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController levelController;
  final TextEditingController nationalityController;
  final String preferredSide;
  final Function(String?) onSideChanged;
  final VoidCallback onImagePick;
  final Uint8List? selectedImageBytes;
  final String? error;

  const RegistrationForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.levelController,
    required this.nationalityController,
    required this.preferredSide,
    required this.onSideChanged,
    required this.onImagePick,
    this.selectedImageBytes,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onImagePick,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: selectedImageBytes != null
                  ? MemoryImage(selectedImageBytes!)
                  : null,
              child: selectedImageBytes == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: emailController,
            label: 'Email',
            icon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: levelController,
            label: 'Current Level (1-5)',
            icon: Icons.stars,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your current level';
              }
              final level = double.tryParse(value);
              if (level == null || level < 1 || level > 5) {
                return 'Enter a valid level between 1 and 5';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: nationalityController,
            label: 'Nationality',
            icon: Icons.flag,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your nationality'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: preferredSide,
            decoration: InputDecoration(
              labelText: 'Preferred Side',
              labelStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.white), // Updated to white
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.white), // Updated to white
              ),
              prefixIcon: const Icon(Icons.sports_tennis, color: Colors.white),
            ),
            items: const [
              DropdownMenuItem(value: 'Left', child: Text('Left')),
              DropdownMenuItem(value: 'Right', child: Text('Right')),
              DropdownMenuItem(value: 'Both', child: Text('Both')),
            ],
            onChanged: onSideChanged,
          ),
          if (error != null) ...[
            const SizedBox(height: 24),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white), // Updated to white
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white), // Updated to white
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white), // Updated to white
        ),
      ),
    );
  }
}
