import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/journal_entry.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class JournalEditor extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEditor({super.key, this.entry});

  @override
  State<JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<JournalEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  late final TextEditingController _learningPointsController;
  late final TextEditingController _challengesController;
  late final TextEditingController _nextGoalsController;
  late final TextEditingController _relatedProjectsController;
  late final TextEditingController _resourcesController;
  
  DateTime _selectedDate = DateTime.now();
  double _productivityRating = 3.0;
  int _hoursSpent = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _tagsController = TextEditingController(
      text: widget.entry?.tags.join(', ') ?? '',
    );
    _learningPointsController = TextEditingController(
      text: widget.entry?.learningPoints.join('\n') ?? '',
    );
    _challengesController = TextEditingController(
      text: widget.entry?.challenges.join('\n') ?? '',
    );
    _nextGoalsController = TextEditingController(
      text: widget.entry?.nextGoals.join('\n') ?? '',
    );
    _relatedProjectsController = TextEditingController(
      text: widget.entry?.relatedProjects.join(', ') ?? '',
    );
    _resourcesController = TextEditingController(
      text: widget.entry?.resources.join('\n') ?? '',
    );

    if (widget.entry != null) {
      _selectedDate = widget.entry!.date;
      _productivityRating = widget.entry!.productivityRating;
      _hoursSpent = widget.entry!.hoursSpent;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _learningPointsController.dispose();
    _challengesController.dispose();
    _nextGoalsController.dispose();
    _relatedProjectsController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
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
          
      final relatedProjectsList = _relatedProjectsController.text
          .split(',')
          .map((project) => project.trim())
          .where((project) => project.isNotEmpty)
          .toList();
      
      // Parse newline-separated fields
      final learningPoints = _learningPointsController.text
          .split('\n')
          .map((point) => point.trim())
          .where((point) => point.isNotEmpty)
          .toList();
          
      final challenges = _challengesController.text
          .split('\n')
          .map((challenge) => challenge.trim())
          .where((challenge) => challenge.isNotEmpty)
          .toList();
          
      final nextGoals = _nextGoalsController.text
          .split('\n')
          .map((goal) => goal.trim())
          .where((goal) => goal.isNotEmpty)
          .toList();
          
      final resources = _resourcesController.text
          .split('\n')
          .map((resource) => resource.trim())
          .where((resource) => resource.isNotEmpty)
          .toList();

      JournalEntry entry;
      if (widget.entry == null) {
        // Create new entry
        entry = JournalEntry.create(
          date: _selectedDate,
          title: _titleController.text,
          content: _contentController.text,
          learningPoints: learningPoints,
          challenges: challenges,
          nextGoals: nextGoals,
          productivityRating: _productivityRating,
          hoursSpent: _hoursSpent,
          tags: tagsList,
          relatedProjects: relatedProjectsList,
          resources: resources,
        );
      } else {
        // Update existing entry
        entry = widget.entry!.copyWith(
          date: _selectedDate,
          title: _titleController.text,
          content: _contentController.text,
          learningPoints: learningPoints,
          challenges: challenges,
          nextGoals: nextGoals,
          productivityRating: _productivityRating,
          hoursSpent: _hoursSpent,
          tags: tagsList,
          relatedProjects: relatedProjectsList,
          resources: resources,
        );
      }

      await DatabaseService().saveJournalEntry(entry);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving journal entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entry == null ? 'Add Journal Entry' : 'Edit Journal Entry',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveEntry,
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
                    // Date and Title row
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat.yMMMd().format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Hours spent
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Hours',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _hoursSpent.toString(),
                            onChanged: (value) {
                              setState(() {
                                _hoursSpent = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
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
                    
                    // Productivity rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Productivity Rating: ${_productivityRating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating: _productivityRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: theme.colorScheme.primary,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _productivityRating = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Main content
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Journal Entry',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your journal entry';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Learning points
                    TextFormField(
                      controller: _learningPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Learning Points (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'What did you learn today?',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Challenges
                    TextFormField(
                      controller: _challengesController,
                      decoration: const InputDecoration(
                        labelText: 'Challenges (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'What challenges did you face?',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Next goals
                    TextFormField(
                      controller: _nextGoalsController,
                      decoration: const InputDecoration(
                        labelText: 'Next Goals (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'What are your next goals?',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Related projects
                    TextFormField(
                      controller: _relatedProjectsController,
                      decoration: const InputDecoration(
                        labelText: 'Related Projects (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'Project A, Project B, Project C',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Resources
                    TextFormField(
                      controller: _resourcesController,
                      decoration: const InputDecoration(
                        labelText: 'Resources (one per line)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'https://example.com\nBook: Flutter in Action',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'flutter, mobile, learning',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveEntry,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.entry == null ? 'Add Entry' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 