// Culture tags that can be assigned to jobs and matched with user preferences
enum CultureTag {
  remoteFriendly('Remote-Friendly', '🏠'),
  hybridWork('Hybrid Work', '🔄'),
  officeFirst('Office-First', '🏢'),
  flexibleHours('Flexible Hours', '⏰'),
  structuredSchedule('Structured Schedule', '📅'),
  startupEnergy('Startup Energy', '🚀'),
  corporateStability('Corporate Stability', '🏛️'),
  collaborative('Collaborative', '🤝'),
  independent('Independent Work', '🎯'),
  fastPaced('Fast-Paced', '⚡'),
  steadyWorkflow('Steady Workflow', '🌊'),
  innovationFocused('Innovation-Focused', '💡'),
  processOriented('Process-Oriented', '📋'),
  workLifeBalance('Work-Life Balance', '⚖️'),
  highIntensity('High Intensity', '🔥'),
  flatStructure('Flat Structure', '🟰'),
  hierarchical('Hierarchical', '📊'),
  learningCulture('Learning Culture', '📚'),
  resultsDriven('Results-Driven', '🎯'),
  teamOriented('Team-Oriented', '👥');

  final String label;
  final String emoji;
  
  const CultureTag(this.label, this.emoji);
  
  String get displayName => '$emoji $label';
}

// User's culture preferences from the quiz
class CulturePreference {
  final String workLocation; // remote, hybrid, office
  final String schedule; // flexible, structured
  final String companyType; // startup, corporate
  final String workStyle; // collaborative, independent
  final String pace; // fast, steady
  final String structure; // flat, hierarchical
  final String priority; // innovation, stability, balance
  final List<CultureTag> preferredTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  CulturePreference({
    required this.workLocation,
    required this.schedule,
    required this.companyType,
    required this.workStyle,
    required this.pace,
    required this.structure,
    required this.priority,
    required this.preferredTags,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert preferences to culture tags
  List<CultureTag> get derivedTags {
    List<CultureTag> tags = [];

    // Work location preferences
    if (workLocation == 'remote') {
      tags.add(CultureTag.remoteFriendly);
    } else if (workLocation == 'hybrid') {
      tags.add(CultureTag.hybridWork);
    } else if (workLocation == 'office') {
      tags.add(CultureTag.officeFirst);
    }

    // Schedule preferences
    if (schedule == 'flexible') {
      tags.add(CultureTag.flexibleHours);
    } else {
      tags.add(CultureTag.structuredSchedule);
    }

    // Company type preferences
    if (companyType == 'startup') {
      tags.add(CultureTag.startupEnergy);
    } else {
      tags.add(CultureTag.corporateStability);
    }

    // Work style preferences
    if (workStyle == 'collaborative') {
      tags.add(CultureTag.collaborative);
    } else {
      tags.add(CultureTag.independent);
    }

    // Pace preferences
    if (pace == 'fast') {
      tags.add(CultureTag.fastPaced);
    } else {
      tags.add(CultureTag.steadyWorkflow);
    }

    // Structure preferences
    if (structure == 'flat') {
      tags.add(CultureTag.flatStructure);
    } else {
      tags.add(CultureTag.hierarchical);
    }

    // Priority preferences
    if (priority == 'innovation') {
      tags.add(CultureTag.innovationFocused);
    } else if (priority == 'balance') {
      tags.add(CultureTag.workLifeBalance);
    } else if (priority == 'results') {
      tags.add(CultureTag.resultsDriven);
    }

    return tags;
  }

  // Calculate match score with a job's culture tags
  int calculateMatchScore(List<CultureTag> jobTags) {
    if (jobTags.isEmpty) return 50; // Default score if no tags

    final userTags = derivedTags;
    int matches = 0;

    for (var tag in userTags) {
      if (jobTags.contains(tag)) {
        matches++;
      }
    }

    // Calculate percentage based on user's preferred tags
    return ((matches / userTags.length) * 100).round();
  }

  // Get matching and mismatching tags
  Map<String, List<CultureTag>> getMatchBreakdown(List<CultureTag> jobTags) {
    final userTags = derivedTags;
    final matches = <CultureTag>[];
    final mismatches = <CultureTag>[];

    for (var tag in userTags) {
      if (jobTags.contains(tag)) {
        matches.add(tag);
      } else {
        mismatches.add(tag);
      }
    }

    return {
      'matches': matches,
      'mismatches': mismatches,
    };
  }

  CulturePreference copyWith({
    String? workLocation,
    String? schedule,
    String? companyType,
    String? workStyle,
    String? pace,
    String? structure,
    String? priority,
    List<CultureTag>? preferredTags,
    DateTime? updatedAt,
  }) {
    return CulturePreference(
      workLocation: workLocation ?? this.workLocation,
      schedule: schedule ?? this.schedule,
      companyType: companyType ?? this.companyType,
      workStyle: workStyle ?? this.workStyle,
      pace: pace ?? this.pace,
      structure: structure ?? this.structure,
      priority: priority ?? this.priority,
      preferredTags: preferredTags ?? this.preferredTags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workLocation': workLocation,
      'schedule': schedule,
      'companyType': companyType,
      'workStyle': workStyle,
      'pace': pace,
      'structure': structure,
      'priority': priority,
      'preferredTags': preferredTags.map((tag) => tag.name).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CulturePreference.fromMap(Map<String, dynamic> map) {
    return CulturePreference(
      workLocation: map['workLocation'] ?? 'remote',
      schedule: map['schedule'] ?? 'flexible',
      companyType: map['companyType'] ?? 'startup',
      workStyle: map['workStyle'] ?? 'collaborative',
      pace: map['pace'] ?? 'steady',
      structure: map['structure'] ?? 'flat',
      priority: map['priority'] ?? 'balance',
      preferredTags: (map['preferredTags'] as List<dynamic>?)
              ?.map((name) => CultureTag.values.firstWhere(
                    (tag) => tag.name == name,
                    orElse: () => CultureTag.workLifeBalance,
                  ))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }
}
