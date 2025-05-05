import 'package:flutter/material.dart';
import 'package:become_an_ai_agent/core/constants/app_constants.dart';
import 'package:become_an_ai_agent/core/widgets/custom_app_bar.dart';
import 'package:become_an_ai_agent/models/project.dart';
import 'package:become_an_ai_agent/services/database_service.dart';
import 'package:intl/intl.dart';

class ProjectEditor extends StatefulWidget {
  final Project? project;

  const ProjectEditor({super.key, this.project});

  @override
  State<ProjectEditor> createState() => _ProjectEditorState();
}

class _ProjectEditorState extends State<ProjectEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _technologiesController;
  late final TextEditingController _notesController;
  String _selectedStatus = AppConstants.projectStatuses.first;
  int _progress = 0;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _technologiesController = TextEditingController(
      text: widget.project?.technologies.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: widget.project?.notes ?? '');

    if (widget.project != null) {
      _selectedStatus = widget.project!.status;
      _progress = widget.project!.progress.toInt();
      _dueDate = widget.project!.dueDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse technologies
      final techList = _technologiesController.text
          .split(',')
          .map((tech) => tech.trim())
          .where((tech) => tech.isNotEmpty)
          .toList();

      Project project;
      if (widget.project == null) {
        // Create new project
        project = Project.create(
          name: _nameController.text,
          description: _descriptionController.text,
          status: _selectedStatus,
          technologies: techList,
          notes: _notesController.text,
          progress: _progress.toDouble(),
          dueDate: _dueDate,
        );
      } else {
        // Update existing project
        project = widget.project!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          status: _selectedStatus,
          technologies: techList,
          notes: _notesController.text,
          progress: _progress.toDouble(),
          dueDate: _dueDate,
        );
      }

      await DatabaseService().saveProject(project);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.project == null ? 'Add Project' : 'Edit Project',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProject,
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
                        labelText: 'Project Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Status dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      items: AppConstants.projectStatuses
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a status';
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
                    
                    // Due Date
                    GestureDetector(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dueDate != null
                                  ? DateFormat.yMMMd().format(_dueDate!)
                                  : 'No due date',
                            ),
                            IconButton(
                              icon: Icon(
                                _dueDate != null
                                    ? Icons.clear
                                    : Icons.calendar_today,
                              ),
                              onPressed: () {
                                if (_dueDate != null) {
                                  setState(() {
                                    _dueDate = null;
                                  });
                                } else {
                                  _selectDueDate();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Technologies
                    TextFormField(
                      controller: _technologiesController,
                      decoration: const InputDecoration(
                        labelText: 'Technologies (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'flutter, dart, firebase',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress: $_progress%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _progress.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '$_progress%',
                          onChanged: (value) {
                            setState(() {
                              _progress = value.round();
                            });
                          },
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
                        onPressed: _isLoading ? null : _saveProject,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.project == null ? 'Add Project' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 