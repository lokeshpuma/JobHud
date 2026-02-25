import 'package:flutter/material.dart';
import 'package:jobhud/models/culture_preference_model.dart';
import 'package:jobhud/services/culture_preference_service.dart';

class CultureQuizScreen extends StatefulWidget {
  final bool isOnboarding;
  final CulturePreference? existingPreferences;

  const CultureQuizScreen({
    super.key,
    this.isOnboarding = false,
    this.existingPreferences,
  });

  @override
  State<CultureQuizScreen> createState() => _CultureQuizScreenState();
}

class _CultureQuizScreenState extends State<CultureQuizScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Quiz answers
  String? _workLocation;
  String? _schedule;
  String? _companyType;
  String? _workStyle;
  String? _pace;
  String? _structure;
  String? _priority;
  String? _teamSize;
  String? _communication;
  String? _growth;

  @override
  void initState() {
    super.initState();
    // Load existing preferences if updating
    if (widget.existingPreferences != null) {
      _workLocation = widget.existingPreferences!.workLocation;
      _schedule = widget.existingPreferences!.schedule;
      _companyType = widget.existingPreferences!.companyType;
      _workStyle = widget.existingPreferences!.workStyle;
      _pace = widget.existingPreferences!.pace;
      _structure = widget.existingPreferences!.structure;
      _priority = widget.existingPreferences!.priority;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuiz() async {
    // Validate all required answers
    if (_workLocation == null ||
        _schedule == null ||
        _companyType == null ||
        _workStyle == null ||
        _pace == null ||
        _structure == null ||
        _priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    try {
      final preferences = CulturePreference(
        workLocation: _workLocation!,
        schedule: _schedule!,
        companyType: _companyType!,
        workStyle: _workStyle!,
        pace: _pace!,
        structure: _structure!,
        priority: _priority!,
        preferredTags: [],
      );

      final service = CulturePreferenceService();
      await service.savePreferences(preferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Culture preferences saved!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to dashboard
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding
            ? 'Culture Fit Quiz'
            : 'Update Culture Preferences'),
        centerTitle: true,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Quiz pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildQuestionPage(
                  question: '1. Where do you prefer to work?',
                  icon: Icons.location_on,
                  options: [
                    _QuizOption('Remote', 'remote', '🏠', 'Work from anywhere'),
                    _QuizOption('Hybrid', 'hybrid', '🔄', 'Mix of remote and office'),
                    _QuizOption('Office', 'office', '🏢', 'In-person workplace'),
                  ],
                  selectedValue: _workLocation,
                  onSelect: (value) => setState(() => _workLocation = value),
                ),
                _buildQuestionPage(
                  question: '2. What schedule do you prefer?',
                  icon: Icons.schedule,
                  options: [
                    _QuizOption('Flexible', 'flexible', '⏰', 'Set your own hours'),
                    _QuizOption('Structured', 'structured', '📅', 'Fixed schedule'),
                  ],
                  selectedValue: _schedule,
                  onSelect: (value) => setState(() => _schedule = value),
                ),
                _buildQuestionPage(
                  question: '3. What type of company appeals to you?',
                  icon: Icons.business,
                  options: [
                    _QuizOption('Startup', 'startup', '🚀', 'Fast-moving, innovative'),
                    _QuizOption('Corporate', 'corporate', '🏛️', 'Established, stable'),
                  ],
                  selectedValue: _companyType,
                  onSelect: (value) => setState(() => _companyType = value),
                ),
                _buildQuestionPage(
                  question: '4. How do you prefer to work?',
                  icon: Icons.people,
                  options: [
                    _QuizOption('Collaborative', 'collaborative', '🤝', 'Team-based projects'),
                    _QuizOption('Independent', 'independent', '🎯', 'Solo work'),
                  ],
                  selectedValue: _workStyle,
                  onSelect: (value) => setState(() => _workStyle = value),
                ),
                _buildQuestionPage(
                  question: '5. What work pace suits you best?',
                  icon: Icons.speed,
                  options: [
                    _QuizOption('Fast-Paced', 'fast', '⚡', 'Quick decisions, rapid changes'),
                    _QuizOption('Steady', 'steady', '🌊', 'Measured, consistent'),
                  ],
                  selectedValue: _pace,
                  onSelect: (value) => setState(() => _pace = value),
                ),
                _buildQuestionPage(
                  question: '6. What organizational structure do you prefer?',
                  icon: Icons.account_tree,
                  options: [
                    _QuizOption('Flat', 'flat', '🟰', 'Minimal hierarchy'),
                    _QuizOption('Hierarchical', 'hierarchical', '📊', 'Clear chain of command'),
                  ],
                  selectedValue: _structure,
                  onSelect: (value) => setState(() => _structure = value),
                ),
                _buildQuestionPage(
                  question: '7. What\'s most important to you?',
                  icon: Icons.star,
                  options: [
                    _QuizOption('Innovation', 'innovation', '💡', 'Cutting-edge work'),
                    _QuizOption('Work-Life Balance', 'balance', '⚖️', 'Time for life outside work'),
                    _QuizOption('Results', 'results', '🎯', 'Achievement-focused'),
                  ],
                  selectedValue: _priority,
                  onSelect: (value) => setState(() => _priority = value),
                ),
                _buildQuestionPage(
                  question: '8. What team size do you prefer?',
                  icon: Icons.groups,
                  options: [
                    _QuizOption('Small Team', 'small', '👥', '5-15 people'),
                    _QuizOption('Medium Team', 'medium', '👨‍👩‍👧‍👦', '15-50 people'),
                    _QuizOption('Large Team', 'large', '🏟️', '50+ people'),
                  ],
                  selectedValue: _teamSize,
                  onSelect: (value) => setState(() => _teamSize = value),
                ),
                _buildQuestionPage(
                  question: '9. How do you prefer to communicate?',
                  icon: Icons.chat,
                  options: [
                    _QuizOption('Async', 'async', '💬', 'Messages, emails'),
                    _QuizOption('Sync', 'sync', '📞', 'Meetings, calls'),
                    _QuizOption('Mixed', 'mixed', '🔄', 'Both equally'),
                  ],
                  selectedValue: _communication,
                  onSelect: (value) => setState(() => _communication = value),
                ),
                _buildQuestionPage(
                  question: '10. What growth path interests you?',
                  icon: Icons.trending_up,
                  options: [
                    _QuizOption('Management', 'management', '👔', 'Lead teams'),
                    _QuizOption('Technical', 'technical', '💻', 'Deep expertise'),
                    _QuizOption('Flexible', 'flexible', '🔀', 'Open to both'),
                  ],
                  selectedValue: _growth,
                  onSelect: (value) => setState(() => _growth = value),
                ),
              ],
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage == 9 ? _submitQuiz : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_currentPage == 9 ? 'Complete Quiz' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage({
    required String question,
    required IconData icon,
    required List<_QuizOption> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          
          // Icon
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          
          // Question
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Options
          ...options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(
                  option: option,
                  isSelected: selectedValue == option.value,
                  onTap: () => onSelect(option.value),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required _QuizOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              option.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizOption {
  final String label;
  final String value;
  final String emoji;
  final String description;

  _QuizOption(this.label, this.value, this.emoji, this.description);
}
