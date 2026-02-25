import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/interview_prep_service.dart';

class InterviewPrepScreen extends StatefulWidget {
  final String companyName;
  final String position;
  final DateTime? interviewDate;

  const InterviewPrepScreen({
    Key? key,
    required this.companyName,
    required this.position,
    this.interviewDate,
  }) : super(key: key);

  @override
  _InterviewPrepScreenState createState() => _InterviewPrepScreenState();
}

enum ChecklistCategory {
  research('Research', Icons.business, 0xFF4CAF50),
  technical('Technical', Icons.code, 0xFF2196F3),
  questions('Questions', Icons.question_answer, 0xFF9C27B0),
  documents('Documents', Icons.description, 0xFFFF9800),
  preparation('Preparation', Icons.check_circle, 0xFFE91E63);

  final String title;
  final IconData icon;
  final int color;
  const ChecklistCategory(this.title, this.icon, this.color);
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> with SingleTickerProviderStateMixin {
  static const _storageKey = 'interview_checklist';
  // State variables
  final InterviewPrepService _interviewPrepService = InterviewPrepService();
  List<ChecklistItem> _checklistItems = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  String _error = '';
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  List<NoteItem> _notes = [];  
  int? _editingNoteIndex;
  int _selectedCategoryIndex = 0;
  final _scrollController = ScrollController();
  
  final List<ChecklistCategory> _categories = ChecklistCategory.values.toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _noteTitleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList('${_storageKey}_${widget.companyName}_${widget.position}');
    final savedNotes = prefs.getStringList('${_storageKey}_notes_list_${widget.companyName}_${widget.position}') ?? [];
    
    if (mounted) {
      setState(() {
        if (savedItems != null && savedItems.isNotEmpty) {
          _checklistItems = savedItems
              .map((item) => ChecklistItem.fromJson(item))
              .toList();
        }
        
        _notes = savedNotes
            .map((note) => NoteItem.fromJson(jsonDecode(note)))
            .toList();
            
        _isLoading = false;
      });
    }
    
    if (_checklistItems.isEmpty) {
      await _generateNewChecklist();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save checklist items
    await prefs.setStringList(
      '${_storageKey}_${widget.companyName}_${widget.position}',
      _checklistItems.map((item) => jsonEncode(item.toJson())).toList(),
    );
    
    // Save notes
    await prefs.setStringList(
      '${_storageKey}_notes_list_${widget.companyName}_${widget.position}',
      _notes.map((note) => jsonEncode(note.toJson())).toList(),
    );
  }

  List<ChecklistItem> _getDefaultChecklist() {
    return [
      ChecklistItem(
        id: '1',
        text: 'Research ${widget.companyName} company culture',
        category: ChecklistCategory.research,
      ),
      ChecklistItem(
        id: '2',
        text: 'Review common ${widget.position} interview questions',
        category: ChecklistCategory.questions,
      ),
      ChecklistItem(
        id: '3',
        text: 'Prepare your portfolio and resume',
        category: ChecklistCategory.documents,
      ),
      ChecklistItem(
        id: '4',
        text: 'Practice coding problems',
        category: ChecklistCategory.technical,
      ),
      ChecklistItem(
        id: '5',
        text: 'Prepare questions to ask the interviewer',
        category: ChecklistCategory.questions,
      ),
    ];
  }

  Future<void> _generateNewChecklist() async {
    if (_isGenerating) return;
    
    setState(() {
      _isLoading = true;
      _isGenerating = true;
      _error = '';
    });

    try {
      final items = await _interviewPrepService.generateInterviewChecklist(
        companyName: widget.companyName,
        position: widget.position,
      );

      setState(() {
        _checklistItems = items.map((item) {
          final category = _categorizeItem(item);
          return ChecklistItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_${items.indexOf(item)}',
            text: item,
            category: category,
          );
        }).toList();
      });
      await _saveData();
      return;
    } catch (e) {
      debugPrint('Error generating checklist: $e');
      setState(() {
        _error = 'Using default checklist';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isGenerating = false;
      });
      await _saveData();
    }
  }

  void _toggleItem(String id) {
    setState(() {
      final index = _checklistItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _checklistItems[index] = _checklistItems[index].copyWith(
          isCompleted: !_checklistItems[index].isCompleted,
          completedAt: !_checklistItems[index].isCompleted ? DateTime.now() : null,
        );
        _saveData();
      }
    });
  }

  void _saveNote() {
    final title = _noteTitleController.text.trim();
    final content = _noteController.text.trim();
    
    if (title.isEmpty && content.isEmpty) return;
    
    setState(() {
      if (_editingNoteIndex != null) {
        // Update existing note
        _notes[_editingNoteIndex!] = _notes[_editingNoteIndex!].copyWith(
          title: title,
          content: content,
        );
        _editingNoteIndex = null;
      } else if (title.isNotEmpty || content.isNotEmpty) {
        // Add new note
        _notes.insert(0, NoteItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          content: content,
        ));
      }
      
      // Clear fields
      _noteTitleController.clear();
      _noteController.clear();
    });
    
    _saveData();
  }
  
  void _editNote(NoteItem note, int index) {
    setState(() {
      _editingNoteIndex = index;
      _noteTitleController.text = note.title;
      _noteController.text = note.content;
    });
  }
  
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      if (_editingNoteIndex == index) {
        _editingNoteIndex = null;
        _noteTitleController.clear();
        _noteController.clear();
      } else if (_editingNoteIndex != null && _editingNoteIndex! > index) {
        _editingNoteIndex = _editingNoteIndex! - 1;
      }
    });
    _saveData();
  }

  void _addCustomItem() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Custom Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Item text',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _addItem(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChecklistCategory>(
                  value: _categories[_selectedCategoryIndex],
                  items: _categories.map((category) {
                    return DropdownMenuItem<ChecklistCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, color: Color(category.color)),
                          const SizedBox(width: 8),
                          Text(category.title),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategoryIndex = _categories.indexOf(value);
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isNotEmpty) {
                    _addItem(text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addItem(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _checklistItems.insert(0, ChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        category: _categories[_selectedCategoryIndex],
      ));
    });
    _saveData();
    
    // Scroll to top to show the newly added item
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item.id == id);
    });
    _saveData();
  }

  ChecklistCategory _categorizeItem(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('research') || lowerText.contains('company')) {
      return ChecklistCategory.research;
    } else if (lowerText.contains('technical') || lowerText.contains('skill')) {
      return ChecklistCategory.technical;
    } else if (lowerText.contains('question') || lowerText.contains('ask')) {
      return ChecklistCategory.questions;
    } else if (lowerText.contains('document') || lowerText.contains('resume')) {
      return ChecklistCategory.documents;
    }
    return ChecklistCategory.preparation;
  }

  String _formatTimeLeft() {
    if (widget.interviewDate == null) return '';
    final now = DateTime.now();
    final difference = widget.interviewDate!.difference(now);
    
    if (difference.isNegative) return 'Interview passed';
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else {
      return 'Less than an hour left';
    }
  }

  double get _completionPercentage {
    if (_checklistItems.isEmpty) return 0.0;
    final completed = _checklistItems.where((item) => item.isCompleted).length;
    return completed / _checklistItems.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '${widget.position} at ${widget.companyName}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.interviewDate != null) ...[
                        Text(
                          'Interview ${DateFormat('MMM d, y').format(widget.interviewDate!)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeLeft(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      LinearProgressIndicator(
                        value: _completionPercentage,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _completionPercentage == 1.0 ? Colors.green : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_completionPercentage * 100).toStringAsFixed(0)}% Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading || _isGenerating ? null : _generateNewChecklist,
                  tooltip: 'Regenerate',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'add_custom') {
                      _addCustomItem();
                    } else if (value == 'clear_completed') {
                      setState(() {
                        _checklistItems = _checklistItems.where((item) => !item.isCompleted).toList();
                        _saveData();
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_custom',
                      child: Text('Add Custom Item'),
                    ),
                    const PopupMenuItem(
                      value: 'clear_completed',
                      child: Text('Clear Completed'),
                    ),
                  ],
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(icon: Icon(Icons.checklist), text: 'Checklist'),
                    Tab(icon: Icon(Icons.notes), text: 'Notes'),
                  ],
                ),
              ),
            ),
            if (_tabController.index == 0)
              SliverToBoxAdapter(
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.asMap().entries.map((entry) {
                        final category = entry.value;
                        final isSelected = _selectedCategoryIndex == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category.title),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategoryIndex = isSelected ? 0 : entry.key;
                              });
                            },
                            backgroundColor: Color(category.color).withOpacity(0.1),
                            selectedColor: Color(category.color).withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: isSelected ? Color(category.color) : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                            avatar: Icon(category.icon, color: Color(category.color)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Checklist Tab
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _generateNewChecklist,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _checklistItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.checklist_rtl_outlined,
                                  size: 64,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No items yet',
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _addCustomItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add your first item'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _checklistItems.length,
                            itemBuilder: (context, index) {
                              final item = _checklistItems[index];
                              final category = item.category;
                              final categoryColor = Color(category.color);
                              
                              if (_selectedCategoryIndex > 0 && 
                                  category != _categories[_selectedCategoryIndex]) {
                                return const SizedBox.shrink();
                              }

                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  color: theme.colorScheme.error,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text('Are you sure you want to delete this item?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('DELETE'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  _deleteItem(item.id);
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(category.icon, color: categoryColor),
                                    ),
                                    title: Text(
                                      item.text,
                                      style: TextStyle(
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isCompleted
                                            ? Colors.grey
                                            : theme.textTheme.bodyLarge?.color,
                                        fontWeight: item.isCompleted
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      value: item.isCompleted,
                                      onChanged: (_) => _toggleItem(item.id),
                                      activeColor: categoryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onTap: () => _toggleItem(item.id),
                                  ),
                                ),
                              );
                            },
                          ),
            
            // Notes Tab
            Expanded(
              child: Column(
                children: [
                  // Note Editor (always visible for new note)
                  if (_editingNoteIndex != null || _noteTitleController.text.isNotEmpty || _noteController.text.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Note Title
                            TextField(
                              controller: _noteTitleController,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Title',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 8.0),
                                isDense: true,
                              ),
                            ),
                            const Divider(height: 24, thickness: 1),
                            // Note Content
                            TextField(
                              controller: _noteController,
                              maxLines: 5,
                              minLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Write your notes here...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _editingNoteIndex = null;
                                      _noteTitleController.clear();
                                      _noteController.clear();
                                    });
                                  },
                                  child: const Text('CANCEL'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _saveNote();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_editingNoteIndex != null 
                                            ? 'Note updated' 
                                            : 'Note added'),
                                      ),
                                    );
                                  },
                                  child: Text(_editingNoteIndex != null ? 'UPDATE' : 'SAVE'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Notes List
                  Expanded(
                    child: _notes.isEmpty && (_editingNoteIndex == null && _noteTitleController.text.isEmpty && _noteController.text.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_add_outlined,
                                  size: 64,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No notes yet. Tap + to add a new note.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: ListTile(
                                  title: Text(
                                    note.title.isNotEmpty
                                        ? note.title
                                        : 'Untitled Note',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: note.content.isNotEmpty
                                      ? Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _editNote(note, index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => _deleteNote(index),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _editNote(note, index),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _addCustomItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              elevation: 2,
            )
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _editingNoteIndex = null;
                  _noteTitleController.clear();
                  _noteController.clear();
                  // Scroll to top to show the new note editor
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
              elevation: 2,
            ),
    );
  }
}

class NoteItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  NoteItem copyWith({
    String? title,
    String? content,
  }) {
    return NoteItem(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ChecklistItem {
  final String id;
  final String text;
  final bool isCompleted;
  final ChecklistCategory category;
  final DateTime? completedAt;
  final DateTime createdAt;

  ChecklistItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    ChecklistCategory? category,
    this.completedAt,
    DateTime? createdAt,
  }) : 
    category = category ?? ChecklistCategory.preparation,
    createdAt = createdAt ?? DateTime.now();
    
  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    ChecklistCategory? category,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
        'category': category.toString(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChecklistItem.fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ChecklistItem(
        id: map['id'] as String,
        text: map['text'] as String,
        isCompleted: (map['isCompleted'] as bool?) ?? false,
        category: ChecklistCategory.values.firstWhere(
          (e) => e.toString() == (map['category'] as String? ?? ''),
          orElse: () => ChecklistCategory.preparation,
        ),
        completedAt: map['completedAt'] != null 
            ? DateTime.parse(map['completedAt'] as String) 
            : null,
        createdAt: map['createdAt'] != null 
            ? DateTime.parse(map['createdAt'] as String) 
            : DateTime.now(),
      );
    } catch (e) {
      return ChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error loading item',
        isCompleted: false,
      );
    }
  }
}
