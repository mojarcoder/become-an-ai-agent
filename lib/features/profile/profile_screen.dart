import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:become_an_ai_agent/features/auth/auth_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.userEmail);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await _requestPermissions();
      
      // Configure file picker for macOS compatibility
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select a profile image',
        allowCompression: true,
        lockParentWindow: true, // Important for macOS to prevent window focus issues
        withData: Platform.isMacOS, // For macOS, always load data directly
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Debug prints
        print('File picked: ${file.name}, path: ${file.path}, has bytes: ${file.bytes != null}');
        
        if (file.bytes != null) {
          // Web platform or macOS with withData=true returns bytes directly
          await _updateProfileImage(file.bytes!);
        } else if (file.path != null) {
          try {
            // Mobile/desktop platforms return file path
            final imageFile = File(file.path!);
            if (await imageFile.exists()) {
              print('File exists at path: ${file.path}');
              final bytes = await imageFile.readAsBytes();
              await _updateProfileImage(bytes);
            } else {
              print('File does not exist at path: ${file.path}');
              throw Exception('File not found at path: ${file.path}');
            }
          } catch (fileError) {
            print('Error reading file: $fileError');
            setState(() {
              _errorMessage = 'Error reading image file: $fileError';
            });
          }
        }
      } else {
        print('No file selected or picker was cancelled');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image file: $e';
      });
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();
      
      print("Permission statuses: $statuses");
      
      // Inform user if permission is denied
      if (mounted) {
        if (Platform.isAndroid) {
          if (statuses[Permission.storage] != PermissionStatus.granted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission required for selecting images')),
            );
          }
          
          // Check Android version for proper handling
          final sdkInt = await _getAndroidSdkVersion();
          print('Android SDK version: $sdkInt');
          
          if (sdkInt >= 30) { // Android 11+
            final status = await Permission.manageExternalStorage.request();
            print('Manage external storage permission: $status');
            
            // Check for media permissions on Android 13+
            if (sdkInt >= 33) {
              final photoStatus = await Permission.photos.request();
              print('Media images permission: $photoStatus');
            }
          }
        } else if (Platform.isIOS) {
          if (statuses[Permission.photos] != PermissionStatus.granted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photos permission is required')),
            );
          }
        }
      }
    }
    // For macOS, permissions are handled through entitlements
    else if (Platform.isMacOS) {
      print("macOS: File access permissions are handled through entitlements");
    }
  }
  
  // Helper method to get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        final String release = Platform.operatingSystemVersion;
        // Extract SDK version from the release string
        final List<String> parts = release.split(' ');
        for (final part in parts) {
          if (part.contains('SDK')) {
            final sdkPart = part.replaceAll(RegExp(r'[^0-9]'), '');
            return int.tryParse(sdkPart) ?? 0;
          }
        }
        
        // Fallback method: try to parse first number
        final firstNumber = int.tryParse(release.split('.')[0]);
        return firstNumber ?? 0;
      }
    } catch (e) {
      print('Error getting Android SDK version: $e');
    }
    return 0;
  }

  Future<void> _updateProfileImage(Uint8List bytes) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.setProfileImage(bytes);
    
    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Failed to update profile image';
      });
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.removeProfileImage();
      
      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Failed to remove profile image';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error removing profile image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isEditingProfile = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to update profile';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error updating profile: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'New passwords do not match';
          _isLoading = false;
        });
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isChangingPassword = false;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to change password. Please check your current password.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error changing password: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please confirm that you want to delete your account.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deleteAccount,
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    Navigator.pop(context); // Close the dialog

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteAccount();

      if (mounted) {
        if (success) {
          // Navigate back to login or home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          setState(() {
            _errorMessage = 'Failed to delete account';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error deleting account: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Profile',
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                        ),
                        child: authProvider.profileImage != null
                            ? Hero(
                                tag: 'profile-avatar-150',
                                child: ClipOval(
                                  child: Image.memory(
                                    authProvider.profileImage!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 80,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.surface,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            color: theme.colorScheme.primary,
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (authProvider.profileImage != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove Photo'),
                      onPressed: _removeProfileImage,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // User info card
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingProfile ? Icons.close : Icons.edit,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditingProfile = !_isEditingProfile;
                                    if (!_isEditingProfile) {
                                      // Reset the fields if canceling edit
                                      _nameController.text = authProvider.userName ?? '';
                                      _emailController.text = authProvider.userEmail ?? '';
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isEditingProfile
                              ? _buildEditProfileForm()
                              : _buildProfileInfo(authProvider),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Security card
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: theme.colorScheme.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Security',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  _isChangingPassword ? Icons.close : Icons.edit,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isChangingPassword = !_isChangingPassword;
                                    if (!_isChangingPassword) {
                                      // Reset password fields if canceling
                                      _currentPasswordController.clear();
                                      _newPasswordController.clear();
                                      _confirmPasswordController.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isChangingPassword
                              ? _buildChangePasswordForm()
                              : ListTile(
                                  leading: Icon(
                                    Icons.lock,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  title: const Text('Password'),
                                  subtitle: const Text('••••••••'),
                                  contentPadding: EdgeInsets.zero,
                                  minVerticalPadding: 10,
                                  onTap: () {
                                    setState(() {
                                      _isChangingPassword = true;
                                    });
                                  },
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Delete Account Card
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Account Management',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.error.withOpacity(0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_forever,
                                color: theme.colorScheme.error,
                              ),
                              title: const Text('Delete Account'),
                              subtitle: const Text('Permanently delete your account and all data'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              minVerticalPadding: 10,
                              isThreeLine: true,
                              onTap: _showDeleteAccountDialog,
                              textColor: theme.colorScheme.error,
                              trailing: Icon(
                                Icons.warning_amber,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(AuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.person,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Name'),
          subtitle: Text(authProvider.userName ?? 'Not set'),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.email,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Email'),
          subtitle: Text(authProvider.userEmail ?? 'Not set'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildEditProfileForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordForm() {
    return Column(
      children: [
        TextFormField(
          controller: _currentPasswordController,
          decoration: const InputDecoration(
            labelText: 'Current Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your current password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a new password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirm New Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your new password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change Password'),
          ),
        ),
      ],
    );
  }
} 