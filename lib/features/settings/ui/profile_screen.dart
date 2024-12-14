import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/theming/app_styles.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/features/settings/cubit/settings_cubit.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final SettingsCubit _cubit = sl<SettingsCubit>();

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dateJoinedController = TextEditingController();

  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    _cubit.getUserDetails();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _titleController.dispose();
    _lastNameController.dispose();
    _dateJoinedController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        final fileExtension = image.path.split('.').last.toLowerCase();

        if (!allowedExtensions.contains(fileExtension)) {
          return;
        }

        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {}
  }

  

  @override
  Widget build(BuildContext context) {
    String email = '';

    return BlocConsumer<SettingsCubit, SettingsState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is UserDetailsSuccess) {
          email = state.userDetails.email;
          _firstNameController =
              TextEditingController(text: state.userDetails.firstName);
          _titleController =
              TextEditingController(text: state.userDetails.title);
          _lastNameController =
              TextEditingController(text: state.userDetails.lastName);
          _emailController =
              TextEditingController(text: state.userDetails.email);
          _dateJoinedController = TextEditingController(
              text: state.userDetails.dateJoined.toString().split(' ')[0]);
        }
      },
      builder: (context, state) {
        return state is UserDetailsLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton.filled(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                         const  Spacer(),
                        Tooltip(
                          message: 'Change Password',
                          child: IconButton.filled(
                            icon: const Icon(Icons.password),
                            onPressed: () {
                             _onResetPassword(context);
                            },
                          ),
                        ),
                      ],
                 

                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: _pickImage,
                      child: ProfileImageAvatar(selectedImage: _selectedImage),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: customInputDecoration(
                        email,
                        Icons.email,
                        true,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _firstNameController,
                      decoration: customInputDecoration(
                          "First Name", Icons.person, true),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _lastNameController,
                      decoration: customInputDecoration(
                          "Last Name", Icons.person, true),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _titleController,
                      decoration:
                          customInputDecoration("Title", Icons.title, true),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _dateJoinedController,
                      enabled: false,
                      decoration: customInputDecoration(
                          "Date Joined", Icons.date_range, true),
                    ),
                    const SizedBox(height: 28.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _cubit.updateProfile(
                            email,
                            _firstNameController.text,
                            _lastNameController.text,
                            _titleController.text,
                            _cubit.userDetails!.pictureUrl,
                            _cubit.userDetails!.mode,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              );
      },
    );
  }
    _onResetPassword(BuildContext context){

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController(); // New password field


    WoltModalSheet.show(
      modalDecorator: (child) {
        return BlocProvider(
          create: (context) => sl<SettingsCubit>(),
          child: child,
        );
      },
      context: context,
      pageListBuilder: (modalSheetContext) => [

        WoltModalSheetPage(
          useSafeArea: true,
          pageTitle: const Center(
              child: Text("Reset Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  endIndent: 60,
                  indent: 60,
                ),
                TextField(
                  controller: oldPasswordController,
                  decoration: customInputDecoration("Old Password", Icons.password, true),
                ),
                const SizedBox(height: 16),
                  TextField(
                  controller: newPasswordController,
                  decoration: customInputDecoration("New Password", Icons.password_outlined, true),
                ),
                const SizedBox(height: 16),  TextField(
                  controller: confirmNewPasswordController,
                  decoration: customInputDecoration("Confirm new Password", Icons.password_outlined, true),
                ),
                const SizedBox(height: 16), 
                BlocConsumer<SettingsCubit, SettingsState>(
                  listener: (context, state) {
                            if (state is ResetPasswordSuccess){
                  Fluttertoast.showToast(
                        msg: "Password reset successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                    if (state is ResetPasswordError){
                  Fluttertoast.showToast(
                        msg: "Password reset failed, try again later!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  builder: (context, state) {
                    return 
                    state is ResetPasswordLoading ? CircularProgressIndicator() 
                    :
                     SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                  context.read<SettingsCubit>().resetPassword(oldPasswordController.text, newPasswordController.text, confirmNewPasswordController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text("Reset Passwrod"),
                            ),
                          );
                  },
                )
              ],
            ),
          ),
        ),

   ],
    );

  }

}

class ProfileImageAvatar extends StatelessWidget {
  final XFile? selectedImage;

  const ProfileImageAvatar({super.key, this.selectedImage});

  @override
  Widget build(BuildContext context) {
    final user = UserManager().user!;

    return SizedBox(
      height: 120.0,
      width: 120.0,
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              height: 120.0,
              width: 120.0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: selectedImage == null
                  ? (_isValidUrl(user.pictureUrl)
                      ? Image.network(
                          user.pictureUrl,
                          fit: BoxFit.cover,
                          height: 120.0,
                          width: 120.0,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 48.0);
                          },
                        )
                      : const Icon(Icons.person, size: 48.0))
                  : Image.file(
                      File(selectedImage!.path),
                      fit: BoxFit.cover,
                      height: 120.0,
                      width: 120.0,
                    ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: CircleAvatar(
              backgroundColor: Colors.green[400],
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String? url) {
    return url != null && Uri.tryParse(url)?.hasAbsolutePath == true;
  }

}
