import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:become_an_ai_agent/models/dsa_model.dart';
import 'package:become_an_ai_agent/features/dsa/dsa_provider.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/core/widgets/custom_card.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DSAFormScreen extends StatelessWidget {
  final DSAItem? dsaItem;

  const DSAFormScreen({super.key, this.dsaItem});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DSAProvider(),
      child: _DSAFormScreenContent(dsaItem: dsaItem),
    );
  }
}

class _DSAFormScreenContent extends StatefulWidget {
  final DSAItem? dsaItem;

  const _DSAFormScreenContent({this.dsaItem});

  @override
  State<_DSAFormScreenContent> createState() => _DSAFormScreenContentState();
}

class _DSAFormScreenContentState extends State<_DSAFormScreenContent> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _description;
  late DSACategory _category;
  late String _codeExample;
  late String _complexity;
  late int _proficiencyLevel;
  late bool _isFavorite;
  late List<String> _tags;
  late List<String> _relatedProblems;
  late String _notes;
  
  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _codeExampleController;
  late TextEditingController _complexityController;
  late TextEditingController _tagsController;
  late TextEditingController _relatedProblemsController;
  late TextEditingController _notesController;
  
  @override
  void initState() {
    super.initState();
    
    final item = widget.dsaItem;
    
    // Initialize values from existing item or defaults
    _name = item?.name ?? '';
    _description = item?.description ?? '';
    _category = item?.category ?? DSACategory.array;
    _codeExample = item?.codeExample ?? '';
    _complexity = item?.complexity ?? 'Time: O(n), Space: O(1)';
    _proficiencyLevel = item?.proficiencyLevel ?? 1;
    _isFavorite = item?.isFavorite ?? false;
    _tags = List.from(item?.tags ?? []);
    _relatedProblems = List.from(item?.relatedProblems ?? []);
    _notes = item?.notes ?? '';
    
    // Initialize controllers
    _nameController = TextEditingController(text: _name);
    _descriptionController = TextEditingController(text: _description);
    _codeExampleController = TextEditingController(text: _codeExample);
    _complexityController = TextEditingController(text: _complexity);
    _tagsController = TextEditingController();
    _relatedProblemsController = TextEditingController();
    _notesController = TextEditingController(text: _notes);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeExampleController.dispose();
    _complexityController.dispose();
    _tagsController.dispose();
    _relatedProblemsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dsaProvider = Provider.of<DSAProvider>(context, listen: false);
    final isEditing = widget.dsaItem != null;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit DSA Item' : 'Add DSA Item',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter algorithm or data structure name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<DSACategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: DSACategory.values.map((category) {
                  return DropdownMenuItem<DSACategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(DSAItem.getCategoryIcon(category), size: 16),
                        const SizedBox(width: 8),
                        Text(DSAItem.getCategoryName(category)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the algorithm or data structure',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              
              // Code Example Field
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Code Example',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeExampleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter code example',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 10,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a code example';
                          }
                          return null;
                        },
                        onSaved: (value) => _codeExample = value!,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Complexity Field
              TextFormField(
                controller: _complexityController,
                decoration: const InputDecoration(
                  labelText: 'Time & Space Complexity',
                  hintText: 'e.g., Time: O(n), Space: O(1)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter complexity information';
                  }
                  return null;
                },
                onSaved: (value) => _complexity = value!,
              ),
              const SizedBox(height: 24),
              
              // Proficiency Level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proficiency Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: _proficiencyLevel.toDouble(),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _proficiencyLevel = rating.toInt();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_proficiencyLevel/5',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Favorite Switch
              SwitchListTile(
                title: const Text('Mark as Favorite'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Tags Section
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                suffixIcon: Icon(Icons.add),
                              ),
                              onFieldSubmitted: _addTag,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              if (_tagsController.text.isNotEmpty) {
                                _addTag(_tagsController.text);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Related Problems Section
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Related Problems',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _relatedProblemsController,
                              decoration: const InputDecoration(
                                hintText: 'Add a related problem',
                                suffixIcon: Icon(Icons.add),
                              ),
                              onFieldSubmitted: _addRelatedProblem,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              if (_relatedProblemsController.text.isNotEmpty) {
                                _addRelatedProblem(_relatedProblemsController.text);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._relatedProblems.map((problem) {
                        return ListTile(
                          title: Text(problem),
                          leading: const Icon(Icons.code),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _relatedProblems.remove(problem);
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                onSaved: (value) => _notes = value!,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm(dsaProvider);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isEditing ? 'Update' : 'Save',
                      style: const TextStyle(fontSize: 16),
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
  
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }
  
  void _addRelatedProblem(String problem) {
    if (problem.isNotEmpty && !_relatedProblems.contains(problem)) {
      setState(() {
        _relatedProblems.add(problem);
        _relatedProblemsController.clear();
      });
    }
  }
  
  void _submitForm(DSAProvider provider) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (widget.dsaItem == null) {
        // Creating a new item
        final newItem = DSAItem.create(
          name: _name,
          description: _description,
          category: _category,
          codeExample: _codeExample,
          complexity: _complexity,
          proficiencyLevel: _proficiencyLevel,
          isFavorite: _isFavorite,
          tags: _tags,
          relatedProblems: _relatedProblems,
          notes: _notes,
        );
        
        provider.addDSAItem(newItem);
      } else {
        // Updating existing item
        final updatedItem = widget.dsaItem!.copyWith(
          name: _name,
          description: _description,
          category: _category,
          codeExample: _codeExample,
          complexity: _complexity,
          proficiencyLevel: _proficiencyLevel,
          isFavorite: _isFavorite,
          tags: _tags,
          relatedProblems: _relatedProblems,
          notes: _notes,
          lastReviewed: DateTime.now(),
        );
        
        provider.updateDSAItem(updatedItem);
      }
      
      Navigator.pop(context);
    }
  }
} 