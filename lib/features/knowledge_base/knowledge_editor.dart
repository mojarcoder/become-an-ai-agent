import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/knowledge_item.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:flutter/material.dart';

class KnowledgeEditor extends StatefulWidget {
  final KnowledgeItem? item;

  const KnowledgeEditor({super.key, this.item});

  @override
  State<KnowledgeEditor> createState() => _KnowledgeEditorState();
}

class _KnowledgeEditorState extends State<KnowledgeEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _tagsController;
  String _selectedCategory = AppConstants.knowledgeCategories.first;
  String _selectedSkillLevel = AppConstants.skillLevels.first;
  bool _isMastered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _detailsController = TextEditingController(text: widget.item?.details ?? '');
    _tagsController = TextEditingController(
      text: widget.item?.tags.join(', ') ?? '',
    );

    if (widget.item != null) {
      _selectedCategory = widget.item!.category;
      _selectedSkillLevel = widget.item!.skillLevel;
      _isMastered = widget.item!.isMastered;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
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

      KnowledgeItem item;
      if (widget.item == null) {
        // Create new item
        item = KnowledgeItem.create(
          title: _titleController.text,
          category: _selectedCategory,
          details: _detailsController.text,
          tags: tagsList,
          skillLevel: _selectedSkillLevel,
          isMastered: _isMastered,
        );
      } else {
        // Update existing item
        item = widget.item!.copyWith(
          title: _titleController.text,
          category: _selectedCategory,
          details: _detailsController.text,
          tags: tagsList,
          skillLevel: _selectedSkillLevel,
          isMastered: _isMastered,
        );
      }

      await DatabaseService().saveKnowledgeItem(item);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.item == null ? 'Add Knowledge Item' : 'Edit Knowledge Item',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveItem,
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
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: AppConstants.knowledgeCategories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Details
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'flutter, dart, state management',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Skill level dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Skill Level',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSkillLevel,
                      items: AppConstants.skillLevels
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSkillLevel = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a skill level';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Mastered checkbox
                    SwitchListTile(
                      title: const Text('Mastered'),
                      value: _isMastered,
                      onChanged: (value) {
                        setState(() {
                          _isMastered = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.item == null ? 'Add Item' : 'Save Changes',
                          style: const TextStyle(
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
    );
  }
} 