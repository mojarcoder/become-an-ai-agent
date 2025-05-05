import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/code_comparison.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CodeCompareEditor extends StatefulWidget {
  final CodeComparison? comparison;

  const CodeCompareEditor({super.key, this.comparison});

  @override
  State<CodeCompareEditor> createState() => _CodeCompareEditorState();
}

class _CodeCompareEditorState extends State<CodeCompareEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _leftCodeController;
  late final TextEditingController _rightCodeController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _keyDifferencesController;
  late final TextEditingController _similaritiesController;
  bool _isLoading = false;
  bool _isMarkdown = false;
  String _leftLanguage = 'dart';
  String _rightLanguage = 'kotlin';
  final List<String> _screenshotPaths = [];
  final ImagePicker _imagePicker = ImagePicker();
  
  final List<String> _languages = [
    'dart', 
    'kotlin', 
    'swift', 
    'javascript',
    'typescript', 
    'python', 
    'java', 
    'cpp',
    'c',
    'rust',
    'lua',
    'yaml',
    'html',
    'css',
    'json',
    'xml',
    'sql',
    'shell',
    'go',
    'php',
    'ruby'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comparison?.title ?? '');
    _descriptionController = TextEditingController(text: widget.comparison?.description ?? '');
    _leftCodeController = TextEditingController(text: widget.comparison?.leftCode ?? '');
    _rightCodeController = TextEditingController(text: widget.comparison?.rightCode ?? '');
    _notesController = TextEditingController(text: widget.comparison?.notes ?? '');
    _tagsController = TextEditingController(
      text: widget.comparison?.tags.join(', ') ?? '',
    );
    _keyDifferencesController = TextEditingController(
      text: widget.comparison?.keyDifferences.join('\n') ?? '',
    );
    _similaritiesController = TextEditingController(
      text: widget.comparison?.similaritiesNotes.join('\n') ?? '',
    );
    
    if (widget.comparison != null) {
      _leftLanguage = widget.comparison!.leftLanguage;
      _rightLanguage = widget.comparison!.rightLanguage;
      _isMarkdown = widget.comparison!.isMarkdown;
      _screenshotPaths.addAll(widget.comparison!.screenshotPaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _leftCodeController.dispose();
    _rightCodeController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _keyDifferencesController.dispose();
    _similaritiesController.dispose();
    super.dispose();
  }
  
  Future<void> _captureScreenshot() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory(path.join(directory.path, 'screenshots'));
        
        // Ensure the screenshots directory exists
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }
        
        final fileName = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = path.join(screenshotsDir.path, fileName);
        
        try {
          // Copy the file to app's document directory
          final File sourceFile = File(image.path);
          if (await sourceFile.exists()) {
            final bytes = await sourceFile.readAsBytes();
            final File savedFile = File(savedPath);
            await savedFile.writeAsBytes(bytes);
            
            setState(() {
              _screenshotPaths.add(savedPath);
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Screenshot added successfully')),
              );
            }
          } else {
            throw Exception('Source file does not exist: ${image.path}');
          }
        } catch (fileError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing screenshot file: $fileError')),
            );
          }
          print('Error handling screenshot file: $fileError');
          print('Image path was: ${image.path}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing screenshot: $e')),
        );
      }
      print('Screenshot capture error: $e');
    }
  }
  
  Future<void> _pickGalleryImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory(path.join(directory.path, 'screenshots'));
        
        // Ensure the screenshots directory exists
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }
        
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = path.join(screenshotsDir.path, fileName);
        
        try {
          // Copy the file to app's document directory
          final File sourceFile = File(image.path);
          if (await sourceFile.exists()) {
            final bytes = await sourceFile.readAsBytes();
            final File savedFile = File(savedPath);
            await savedFile.writeAsBytes(bytes);
            
            setState(() {
              _screenshotPaths.add(savedPath);
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image added successfully')),
              );
            }
          } else {
            throw Exception('Source file does not exist: ${image.path}');
          }
        } catch (fileError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing image file: $fileError')),
            );
          }
          print('Error handling image file: $fileError');
          print('Image path was: ${image.path}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding image: $e')),
        );
      }
      print('Gallery image picker error: $e');
    }
  }
  
  Future<void> _addScreenshot() async {
    try {
      await _requestPermissions();
      
      // Configure file picker for macOS compatibility
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select an image',
        allowCompression: true,
        lockParentWindow: true, // Important for macOS to prevent window focus issues
        withData: Platform.isMacOS, // For macOS, always load data directly
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final directory = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory(path.join(directory.path, 'screenshots'));
        
        // Ensure the screenshots directory exists
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }
        
        // Debug print
        print('File picked: ${file.name}, path: ${file.path}, has bytes: ${file.bytes != null}');
        
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}${file.extension != null ? '.${file.extension}' : '.jpg'}';
        final savedPath = path.join(screenshotsDir.path, fileName);
        
        try {
          if (file.bytes != null) {
            // Web platform or macOS with withData=true returns bytes directly
            final savedFile = File(savedPath);
            await savedFile.writeAsBytes(file.bytes!);
            
            setState(() {
              _screenshotPaths.add(savedPath);
            });
            
            print('Saved image to: $savedPath');
          } else if (file.path != null) {
            // Mobile/desktop platforms return file path
            final sourceFile = File(file.path!);
            if (await sourceFile.exists()) {
              print('Source file exists at: ${file.path}');
              
              // Read bytes and write to new location (works on all platforms)
              final bytes = await sourceFile.readAsBytes();
              final savedFile = File(savedPath);
              await savedFile.writeAsBytes(bytes);
              
              setState(() {
                _screenshotPaths.add(savedPath);
              });
              
              print('Saved image to: $savedPath');
            } else {
              print('Source file does not exist at: ${file.path}');
              throw Exception('Source file does not exist: ${file.path}');
            }
          } else {
            print('No file data available');
            return;
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image added successfully')),
            );
          }
        } catch (fileError) {
          print('Error handling image file: $fileError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing image file: $fileError')),
            );
          }
        }
      } else {
        print('No file selected or result is null');
      }
    } catch (e) {
      print('File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }
  
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();
      
      print("Permission statuses: $statuses");
      
      if (mounted) {
        if (Platform.isAndroid) {
          if (statuses[Permission.storage] != PermissionStatus.granted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required')),
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
  
  void _removeImage(int index) {
    setState(() {
      _screenshotPaths.removeAt(index);
    });
  }

  String _getLanguageDisplayName(String langCode) {
    switch(langCode) {
      case 'dart': return 'Dart (Flutter)';
      case 'kotlin': return 'Kotlin (Android)';
      case 'swift': return 'Swift (iOS)';
      case 'javascript': return 'JavaScript';
      case 'typescript': return 'TypeScript';
      case 'python': return 'Python';
      case 'java': return 'Java';
      case 'cpp': return 'C++';
      case 'c': return 'C';
      case 'rust': return 'Rust';
      case 'lua': return 'Lua';
      case 'yaml': return 'YAML';
      case 'html': return 'HTML';
      case 'css': return 'CSS';
      case 'json': return 'JSON';
      case 'xml': return 'XML';
      case 'sql': return 'SQL';
      case 'shell': return 'Shell/Bash';
      case 'go': return 'Go';
      case 'php': return 'PHP';
      case 'ruby': return 'Ruby';
      default: return langCode;
    }
  }

  Future<void> _saveComparison() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse comma-separated tags
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
          
      // Parse newline-separated lists
      final keyDifferencesList = _keyDifferencesController.text
          .split('\n')
          .map((diff) => diff.trim())
          .where((diff) => diff.isNotEmpty)
          .toList();
          
      final similaritiesList = _similaritiesController.text
          .split('\n')
          .map((sim) => sim.trim())
          .where((sim) => sim.isNotEmpty)
          .toList();

      CodeComparison comparison;
      if (widget.comparison == null) {
        // Create new comparison
        comparison = CodeComparison.create(
          title: _titleController.text,
          description: _descriptionController.text,
          leftCode: _leftCodeController.text,
          rightCode: _rightCodeController.text,
          leftLanguage: _leftLanguage,
          rightLanguage: _rightLanguage,
          notes: _notesController.text,
          tags: tagsList,
          keyDifferences: keyDifferencesList,
          similaritiesNotes: similaritiesList,
          screenshotPaths: _screenshotPaths,
          isMarkdown: _isMarkdown,
        );
      } else {
        // Update existing comparison
        comparison = widget.comparison!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          leftCode: _leftCodeController.text,
          rightCode: _rightCodeController.text,
          leftLanguage: _leftLanguage,
          rightLanguage: _rightLanguage,
          notes: _notesController.text,
          tags: tagsList,
          keyDifferences: keyDifferencesList,
          similaritiesNotes: similaritiesList,
          screenshotPaths: _screenshotPaths,
          isMarkdown: _isMarkdown,
        );
      }

      await DatabaseService().saveCodeComparison(comparison);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving comparison: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.comparison == null ? 'Add Code Comparison' : 'Edit Code Comparison',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveComparison,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Left code with language selector
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Left Side:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Language',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: _leftLanguage,
                                items: _languages
                                    .map((lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(_getLanguageDisplayName(lang)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _leftLanguage = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Right Side:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Language',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: _rightLanguage,
                                items: _languages
                                    .map((lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(_getLanguageDisplayName(lang)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _rightLanguage = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Left code
                    TextFormField(
                      controller: _leftCodeController,
                      decoration: InputDecoration(
                        labelText: 'Left Code (${_getLanguageDisplayName(_leftLanguage)})',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Enter code here...',
                      ),
                      maxLines: 10,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter code for left side';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Right code
                    TextFormField(
                      controller: _rightCodeController,
                      decoration: InputDecoration(
                        labelText: 'Right Code (${_getLanguageDisplayName(_rightLanguage)})',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Enter code here...',
                      ),
                      maxLines: 10,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter code for right side';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Markdown toggle
                    SwitchListTile(
                      title: const Text('Use Markdown in Notes'),
                      subtitle: const Text('Enable markdown formatting for notes'),
                      value: _isMarkdown,
                      onChanged: (value) {
                        setState(() {
                          _isMarkdown = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    // Key differences
                    TextFormField(
                      controller: _keyDifferencesController,
                      decoration: const InputDecoration(
                        labelText: 'Key Differences (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'List the key differences, one per line',
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    
                    // Similarities
                    TextFormField(
                      controller: _similaritiesController,
                      decoration: const InputDecoration(
                        labelText: 'Similarities (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'List similarities, one per line',
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes with markdown preview
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes${_isMarkdown ? ' (Markdown)' : ''}:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: _isMarkdown 
                                ? '# Heading\n**Bold** and *italic* text\n- List item\n- Another item\n\n```dart\nvar code = true;\n```' 
                                : 'Add your detailed notes here...',
                          ),
                          maxLines: 10,
                        ),
                        
                        if (_isMarkdown && _notesController.text.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Markdown Preview:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: MarkdownBody(
                              data: _notesController.text,
                              extensionSet: md.ExtensionSet.gitHubWeb,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                codeblockDecoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Screenshots section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Screenshots & Images:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tip: If gallery images don\'t work, try using "From Files" instead.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Screenshot'),
                              onPressed: _captureScreenshot,
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library),
                              label: const Text('From Gallery'),
                              onPressed: _pickGalleryImage,
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.file_upload),
                              label: const Text('From Files'),
                              onPressed: _addScreenshot,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_screenshotPaths.isNotEmpty) ...[
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _screenshotPaths.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: theme.dividerColor),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(_screenshotPaths[index]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No images added yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'dart, kotlin, ui, networking, etc.',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveComparison,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.comparison == null ? 'Add Comparison' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 