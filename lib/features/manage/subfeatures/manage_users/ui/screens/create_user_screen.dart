import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/features/manage/subfeatures/manage_users/cubit/manage_users_cubit.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _maxActiveSessionsController = TextEditingController(text: '5');

  bool _isActive = true;
  bool _isStaff = false;
  bool _isSuperuser = false;
  XFile? _selectedImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _maxActiveSessionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ManageUsersCubit, ManageUsersState>(
      listener: (context, state) {
        if (state is ManageUsersCreateUserSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created successfully')),
          );
          Navigator.of(context).pop();
        } else if (state is ManageUsersCreateUserFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New User'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : null,
                        child: _selectedImage == null
                            ? Icon(Icons.person,
                                size: 50, color: colorScheme.primary)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: colorScheme.onPrimary,
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Required Fields Section
                Text(
                  'Required Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Optional Fields Section
                Text(
                  'Optional Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxActiveSessionsController,
                  decoration: const InputDecoration(
                    labelText: 'Max Active Sessions',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter max active sessions';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // User Permissions Section
                Text(
                  'User Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('User can log in to the system'),
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Staff'),
                  subtitle: const Text('User has access to admin features'),
                  value: _isStaff,
                  onChanged: (bool value) {
                    setState(() {
                      _isStaff = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Superuser'),
                  subtitle: const Text('User has full system access'),
                  value: _isSuperuser,
                  onChanged: (bool value) {
                    setState(() {
                      _isSuperuser = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ManageUsersCubit>().createUser(
                              _passwordController.text,
                              _confirmPasswordController.text,
                              _firstNameController.text,
                              _lastNameController.text,
                              _emailController.text,
                              _phoneController.text,
                              _titleController.text,
                              int.tryParse(_maxActiveSessionsController.text),
                              _isActive,
                              _isStaff,
                              _isSuperuser,
                              _selectedImage,
                            );
                      }
                    },
                    child: BlocBuilder<ManageUsersCubit, ManageUsersState>(
                      builder: (context, state) {
                        if (state is ManageUsersCreateUserLoading) {
                          return const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        }
                        return const Text('Create User');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
