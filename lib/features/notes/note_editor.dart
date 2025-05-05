import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/note.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;

  const NoteEditor({super.key, this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  String _selectedType = AppConstants.noteTypes.first;
  bool _isLoading = false;
  bool _isPreviewMode = false;
  bool _isMarkdown = false;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagsController = TextEditingController(
      text: widget.note?.tags.join(', ') ?? '',
    );

    if (widget.note != null) {
      _selectedType = widget.note!.type;
      _isMarkdown = widget.note!.isMarkdown;
      _imagePaths = List.from(widget.note!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<String?> _addImage() async {
    try {
      // Request storage permission first
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
        final fileName = const Uuid().v4() + (file.extension != null ? '.${file.extension}' : '.jpg');
        final appDir = await getApplicationDocumentsDirectory();
        final noteImagesDir = Directory('${appDir.path}/note_images');
        
        if (!await noteImagesDir.exists()) {
          await noteImagesDir.create(recursive: true);
        }
        
        // Debug print
        print('File name: ${file.name}, path: ${file.path}, has bytes: ${file.bytes != null}');
        
        final savedImagePath = '${noteImagesDir.path}/$fileName';
        
        if (file.bytes != null) {
          // Web platform or macOS with withData=true returns bytes directly
          final savedImage = File(savedImagePath);
          await savedImage.writeAsBytes(file.bytes!);
          print('Saved image to: ${savedImage.path}');
          return savedImage.path;
        } else if (file.path != null) {
          // Mobile/desktop platforms return file path
          try {
            final sourceFile = File(file.path!);
            if (await sourceFile.exists()) {
              print('Source file exists at: ${file.path}');
              
              // Read bytes and write to new location (works on all platforms)
              final bytes = await sourceFile.readAsBytes();
              final savedImage = File(savedImagePath);
              await savedImage.writeAsBytes(bytes);
              
              print('Saved image to: ${savedImage.path}');
              return savedImage.path;
            } else {
              print('Source file does not exist at: ${file.path}');
              throw Exception('Source file does not exist: ${file.path}');
            }
          } catch (copyError) {
            print('Error handling file: $copyError');
            throw copyError;
          }
        } else {
          print('No file data available');
          throw Exception('No file data available from picked file');
        }
      } else {
        print('No file selected or result is null');
      }
    } catch (e) {
      print('Error adding image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding image: $e')),
        );
      }
    }
    return null;
  }
  
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();
      
      print("Permission statuses: $statuses");
      
      if (Platform.isAndroid) {
        if (statuses[Permission.storage] != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required to select images')),
            );
          }
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
          if (mounted) {
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

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      Note note;
      if (widget.note == null) {
        // Create new note
        note = Note.create(
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType,
          tags: tagsList,
          imagePaths: _imagePaths,
          isMarkdown: _isMarkdown,
        );
      } else {
        // Update existing note
        note = widget.note!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType,
          tags: tagsList,
          imagePaths: _imagePaths,
          isMarkdown: _isMarkdown,
        );
      }

      await DatabaseService().saveNote(note);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Widget _buildContentField() {
    if (_isMarkdown && _isPreviewMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: MarkdownBody(
          data: _contentController.text,
          shrinkWrap: true,
        ),
      );
    } else if (_selectedType == 'Code Snippet') {
      return TextFormField(
        controller: _contentController,
        decoration: const InputDecoration(
          labelText: 'Code',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
          hintText: 'Enter your code snippet here',
        ),
        maxLines: 15,
        style: const TextStyle(
          fontFamily: 'monospace',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
          }
          return null;
        },
      );
    } else if (_selectedType == 'Checklist') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checklist Items (one per line):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText: '- Item 1\n- Item 2\n- [x] Completed item',
            ),
            maxLines: 15,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter content';
              }
              return null;
            },
          ),
        ],
      );
    } else {
      return TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          labelText: 'Content',
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
          hintText: _isMarkdown 
              ? 'Use Markdown to format your content.\n# Heading\n**Bold text**\n- List item' 
              : 'Enter your note content here',
        ),
        maxLines: 15,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
          }
          return null;
        },
      );
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Image'),
              onPressed: () async {
                final imagePath = await _addImage();
                if (imagePath != null) {
                  setState(() {
                    _imagePaths.add(imagePath);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_imagePaths.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No images added yet.'),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_imagePaths[index]),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _imagePaths.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.note == null ? 'Add Note' : 'Edit Note',
        actions: [
          if (_isMarkdown)
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
              onPressed: () {
                setState(() {
                  _isPreviewMode = !_isPreviewMode;
                });
              },
              tooltip: _isPreviewMode ? 'Edit' : 'Preview',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
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
                    
                    // Type dropdown and Markdown toggle
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Note Type',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedType,
                            items: AppConstants.noteTypes
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                  _isPreviewMode = false;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a note type';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: SwitchListTile(
                            title: const Text('Markdown'),
                            value: _isMarkdown,
                            onChanged: (value) {
                              setState(() {
                                _isMarkdown = value;
                                if (!value) {
                                  _isPreviewMode = false;
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Content
                    _buildContentField(),
                    
                    // Images
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'flutter, dart, notes',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveNote,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.note == null ? 'Add Note' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 