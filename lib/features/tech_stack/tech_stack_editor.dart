import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/tech_stack_item.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TechStackEditor extends StatefulWidget {
  final TechStackItem? item;

  const TechStackEditor({super.key, this.item});

  @override
  State<TechStackEditor> createState() => _TechStackEditorState();
}

class _TechStackEditorState extends State<TechStackEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _notesController;
  String _selectedCategory = AppConstants.knowledgeCategories.first;
  int _proficiency = 50;
  double _skillLevel = 3.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _tagsController = TextEditingController(
      text: widget.item?.tags.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');

    if (widget.item != null) {
      _selectedCategory = widget.item!.category;
      _proficiency = widget.item!.proficiency;
      _skillLevel = widget.item!.skillLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
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

      TechStackItem item;
      if (widget.item == null) {
        // Create new item
        item = TechStackItem.create(
          name: _nameController.text,
          category: _selectedCategory,
          description: _descriptionController.text,
          tags: tagsList,
          proficiency: _proficiency,
          skillLevel: _skillLevel,
          notes: _notesController.text,
        );
      } else {
        // Update existing item
        item = widget.item!.copyWith(
          name: _nameController.text,
          category: _selectedCategory,
          description: _descriptionController.text,
          tags: tagsList,
          proficiency: _proficiency,
          skillLevel: _skillLevel,
          notes: _notesController.text,
        );
      }

      await DatabaseService().saveTechStackItem(item);
      
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
        title: widget.item == null ? 'Add Tech Stack Item' : 'Edit Tech Stack Item',
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
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Technology Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
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
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
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
                    
                    // Proficiency slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proficiency: $_proficiency%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _proficiency.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '$_proficiency%',
                          onChanged: (value) {
                            setState(() {
                              _proficiency = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Skill Level rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Skill Level (1-5)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _skillLevel,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _skillLevel = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
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
                        child: Text(widget.item == null ? 'Add Item' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 