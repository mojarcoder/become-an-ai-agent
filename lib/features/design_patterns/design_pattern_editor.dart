import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/design_pattern.dart';
import 'package:become_an_ai_agent/services/database_service.dart';

class DesignPatternEditor extends StatefulWidget {
  final DesignPattern? pattern;

  const DesignPatternEditor({super.key, this.pattern});

  @override
  State<DesignPatternEditor> createState() => _DesignPatternEditorState();
}

class _DesignPatternEditorState extends State<DesignPatternEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _problemSolvedController;
  late final TextEditingController _codeExampleController;
  late final TextEditingController _implementationController;
  late final TextEditingController _realWorldUsageController;
  late final TextEditingController _additionalNotesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _relatedPatternsController;
  
  String _selectedType = 'Creational';
  String _selectedLanguage = 'dart';
  int _difficulty = 3;
  bool _isLoading = false;

  final List<String> _patternTypes = ['Creational', 'Structural', 'Behavioral'];
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
    'yaml'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pattern?.name ?? '');
    _descriptionController = TextEditingController(text: widget.pattern?.description ?? '');
    _problemSolvedController = TextEditingController(text: widget.pattern?.problemSolved ?? '');
    _codeExampleController = TextEditingController(text: widget.pattern?.codeExample ?? '');
    _implementationController = TextEditingController(text: widget.pattern?.implementation ?? '');
    _realWorldUsageController = TextEditingController(text: widget.pattern?.realWorldUsage ?? '');
    _additionalNotesController = TextEditingController(text: widget.pattern?.additionalNotes ?? '');
    _tagsController = TextEditingController(
      text: widget.pattern?.tags.join(', ') ?? '',
    );
    _relatedPatternsController = TextEditingController(
      text: widget.pattern?.relatedPatterns.join(', ') ?? '',
    );

    if (widget.pattern != null) {
      _selectedType = widget.pattern!.type;
      _selectedLanguage = widget.pattern!.language;
      _difficulty = widget.pattern!.difficulty;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _problemSolvedController.dispose();
    _codeExampleController.dispose();
    _implementationController.dispose();
    _realWorldUsageController.dispose();
    _additionalNotesController.dispose();
    _tagsController.dispose();
    _relatedPatternsController.dispose();
    super.dispose();
  }

  Future<void> _savePattern() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse comma-separated fields
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
          
      final relatedPatternsList = _relatedPatternsController.text
          .split(',')
          .map((pattern) => pattern.trim())
          .where((pattern) => pattern.isNotEmpty)
          .toList();

      DesignPattern pattern;
      if (widget.pattern == null) {
        // Create new pattern
        pattern = DesignPattern.create(
          name: _nameController.text,
          type: _selectedType,
          description: _descriptionController.text,
          problemSolved: _problemSolvedController.text,
          codeExample: _codeExampleController.text,
          language: _selectedLanguage,
          implementation: _implementationController.text,
          realWorldUsage: _realWorldUsageController.text,
          additionalNotes: _additionalNotesController.text,
          relatedPatterns: relatedPatternsList,
          tags: tagsList,
          difficulty: _difficulty,
        );
      } else {
        // Update existing pattern
        pattern = widget.pattern!.copyWith(
          name: _nameController.text,
          type: _selectedType,
          description: _descriptionController.text,
          problemSolved: _problemSolvedController.text,
          codeExample: _codeExampleController.text,
          language: _selectedLanguage,
          implementation: _implementationController.text,
          realWorldUsage: _realWorldUsageController.text,
          additionalNotes: _additionalNotesController.text,
          relatedPatterns: relatedPatternsList,
          tags: tagsList,
          difficulty: _difficulty,
        );
      }

      await DatabaseService().saveDesignPattern(pattern);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving design pattern: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.pattern == null ? 'Add Design Pattern' : 'Edit Design Pattern',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _savePattern,
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
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pattern Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pattern name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Type dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pattern Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: _patternTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a pattern type';
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
                    
                    // Problem Solved
                    TextFormField(
                      controller: _problemSolvedController,
                      decoration: const InputDecoration(
                        labelText: 'Problem Solved',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'What problem does this pattern solve?',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the problem this pattern solves';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Code Example & Language row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Code Language dropdown
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Language',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedLanguage,
                            items: _languages
                                .map((lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(_getLanguageDisplayName(lang)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Difficulty
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Difficulty',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Slider(
                                value: _difficulty.toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: _difficulty.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _difficulty = value.toInt();
                                  });
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Easy', style: TextStyle(fontSize: 12)),
                                  ...List.generate(5, (i) => Icon(
                                    i < _difficulty ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: i < _difficulty ? Colors.amber : Colors.grey,
                                  )),
                                  const Text('Hard', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Code Example
                    TextFormField(
                      controller: _codeExampleController,
                      decoration: const InputDecoration(
                        labelText: 'Code Example',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Paste example code here...',
                      ),
                      maxLines: 10,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a code example';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Implementation
                    TextFormField(
                      controller: _implementationController,
                      decoration: const InputDecoration(
                        labelText: 'Implementation Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'How would you implement this pattern?',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Real World Usage
                    TextFormField(
                      controller: _realWorldUsageController,
                      decoration: const InputDecoration(
                        labelText: 'Real World Usage',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Examples of this pattern in real world applications',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Additional Notes
                    TextFormField(
                      controller: _additionalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Related Patterns
                    TextFormField(
                      controller: _relatedPatternsController,
                      decoration: const InputDecoration(
                        labelText: 'Related Patterns (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'Factory, Builder, Singleton',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'creation, object, instantiation',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePattern,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.pattern == null ? 'Add Pattern' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Add a helper method to get display names for languages
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
      default: return langCode;
    }
  }
} 