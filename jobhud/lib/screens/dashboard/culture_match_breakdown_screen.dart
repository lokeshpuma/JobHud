import 'package:flutter/material.dart';
import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/models/culture_preference_model.dart';
import 'package:jobhud/services/culture_preference_service.dart';

class CultureMatchBreakdownScreen extends StatelessWidget {
  final Job job;

  const CultureMatchBreakdownScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CulturePreference?>(
      future: _loadPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final preferences = snapshot.data;
        if (preferences == null) {
          return _buildNoPreferencesScreen(context);
        }

        final breakdown = preferences.getMatchBreakdown(job.cultureTags);
        final matches = breakdown['matches'] ?? [];
        final mismatches = breakdown['mismatches'] ?? [];
        final score = job.cultureMatchScore ?? 50;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Culture Match Details'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getMatchColor(score),
                        _getMatchColor(score).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getMatchColor(score).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        CulturePreferenceService.getMatchEmoji(score),
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$score%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Culture Match Score',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getScoreDescription(score),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Job Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Matches Section
                if (matches.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'What Matches (${matches.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...matches.map((tag) => _buildTagItem(tag, true)),
                  const SizedBox(height: 32),
                ],

                // Mismatches Section
                if (mismatches.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.orange, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'What Doesn\'t Match (${mismatches.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...mismatches.map((tag) => _buildTagItem(tag, false)),
                  const SizedBox(height: 32),
                ],

                // Company Culture Tags
                if (job.cultureTags.isNotEmpty) ...[
                  const Text(
                    'Company Culture Tags',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.cultureTags.map((tag) {
                      return Chip(
                        label: Text(tag.displayName),
                        backgroundColor: Colors.blue[50],
                        labelStyle: const TextStyle(fontSize: 12),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],

                // Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/culture-preferences');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Update My Preferences'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<CulturePreference?> _loadPreferences() async {
    final service = CulturePreferenceService();
    await service.initialize();
    return service.preferences;
  }

  Widget _buildNoPreferencesScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culture Match Details'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Take the Culture Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete our quick 2-minute quiz to see how well this job matches your work culture preferences.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/culture-quiz');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagItem(CultureTag tag, bool isMatch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMatch ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatch ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Text(
            tag.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tag.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            isMatch ? Icons.check_circle : Icons.info_outline,
            color: isMatch ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) {
      return 'Excellent match! This company culture aligns very well with your preferences.';
    } else if (score >= 60) {
      return 'Good match! Most aspects of this culture fit your preferences.';
    } else if (score >= 40) {
      return 'Moderate match. Some aspects align, but there are differences.';
    } else {
      return 'Low match. This culture may not align well with your preferences.';
    }
  }
}
