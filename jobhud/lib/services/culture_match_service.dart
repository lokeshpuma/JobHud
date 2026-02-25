import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/models/culture_preference_model.dart';

class CultureMatchService {
  // Auto-detect culture tags from job description and metadata
  static List<CultureTag> detectCultureTags(Job job) {
    final tags = <CultureTag>[];
    final description = job.description.toLowerCase();
    final location = job.location.toLowerCase();
    final type = job.type.toLowerCase();

    // Work location detection
    if (location.contains('remote') ||
        location.contains('anywhere') ||
        location.contains('worldwide') ||
        description.contains('remote-first') ||
        description.contains('fully remote')) {
      tags.add(CultureTag.remoteFriendly);
    }

    if (description.contains('hybrid') || location.contains('hybrid')) {
      tags.add(CultureTag.hybridWork);
    }

    if (description.contains('on-site') ||
        description.contains('office') ||
        location.contains('office')) {
      tags.add(CultureTag.officeFirst);
    }

    // Schedule flexibility
    if (description.contains('flexible hours') ||
        description.contains('flexible schedule') ||
        description.contains('work-life balance')) {
      tags.add(CultureTag.flexibleHours);
      tags.add(CultureTag.workLifeBalance);
    }

    if (description.contains('9-5') ||
        description.contains('9 to 5') ||
        description.contains('structured schedule')) {
      tags.add(CultureTag.structuredSchedule);
    }

    // Company type indicators
    if (description.contains('startup') ||
        description.contains('fast-growing') ||
        description.contains('early stage')) {
      tags.add(CultureTag.startupEnergy);
      tags.add(CultureTag.fastPaced);
    }

    if (description.contains('enterprise') ||
        description.contains('established') ||
        description.contains('fortune') ||
        description.contains('corporate')) {
      tags.add(CultureTag.corporateStability);
      tags.add(CultureTag.processOriented);
    }

    // Work style
    if (description.contains('collaborative') ||
        description.contains('team player') ||
        description.contains('cross-functional') ||
        description.contains('team-oriented')) {
      tags.add(CultureTag.collaborative);
      tags.add(CultureTag.teamOriented);
    }

    if (description.contains('independent') ||
        description.contains('self-motivated') ||
        description.contains('autonomous') ||
        description.contains('self-starter')) {
      tags.add(CultureTag.independent);
    }

    // Pace indicators
    if (description.contains('fast-paced') ||
        description.contains('rapid') ||
        description.contains('agile') ||
        description.contains('dynamic')) {
      tags.add(CultureTag.fastPaced);
    }

    if (description.contains('steady') ||
        description.contains('stable') ||
        description.contains('consistent')) {
      tags.add(CultureTag.steadyWorkflow);
    }

    // Innovation and learning
    if (description.contains('innovation') ||
        description.contains('cutting-edge') ||
        description.contains('bleeding edge') ||
        description.contains('latest technologies')) {
      tags.add(CultureTag.innovationFocused);
    }

    if (description.contains('learning') ||
        description.contains('professional development') ||
        description.contains('growth opportunities') ||
        description.contains('mentorship')) {
      tags.add(CultureTag.learningCulture);
    }

    // Structure
    if (description.contains('flat structure') ||
        description.contains('flat organization') ||
        description.contains('minimal hierarchy')) {
      tags.add(CultureTag.flatStructure);
    }

    if (description.contains('hierarchical') ||
        description.contains('chain of command') ||
        description.contains('reporting structure')) {
      tags.add(CultureTag.hierarchical);
    }

    // Results and intensity
    if (description.contains('results-driven') ||
        description.contains('performance-based') ||
        description.contains('goal-oriented') ||
        description.contains('metrics-driven')) {
      tags.add(CultureTag.resultsDriven);
    }

    if (description.contains('high-intensity') ||
        description.contains('demanding') ||
        description.contains('challenging')) {
      tags.add(CultureTag.highIntensity);
    }

    // Default tags if none detected
    if (tags.isEmpty) {
      // Add some reasonable defaults based on job type
      if (type.contains('full-time')) {
        tags.add(CultureTag.workLifeBalance);
      }
      tags.add(CultureTag.collaborative);
      tags.add(CultureTag.learningCulture);
    }

    return tags.toSet().toList(); // Remove duplicates
  }

  // Enrich job with culture tags and match score
  static Job enrichJobWithCulture(
    Job job,
    CulturePreference? userPreferences,
  ) {
    final cultureTags = detectCultureTags(job);
    
    int? matchScore;
    if (userPreferences != null) {
      matchScore = userPreferences.calculateMatchScore(cultureTags);
    }

    return job.copyWith(
      cultureTags: cultureTags,
      cultureMatchScore: matchScore,
    );
  }

  // Enrich multiple jobs
  static List<Job> enrichJobsWithCulture(
    List<Job> jobs,
    CulturePreference? userPreferences,
  ) {
    return jobs
        .map((job) => enrichJobWithCulture(job, userPreferences))
        .toList();
  }

  // Sort jobs by culture match score
  static List<Job> sortByMatchScore(List<Job> jobs, {bool descending = true}) {
    final jobsCopy = List<Job>.from(jobs);
    jobsCopy.sort((a, b) {
      final scoreA = a.cultureMatchScore ?? 50;
      final scoreB = b.cultureMatchScore ?? 50;
      return descending ? scoreB.compareTo(scoreA) : scoreA.compareTo(scoreB);
    });
    return jobsCopy;
  }

  // Filter jobs by minimum match score
  static List<Job> filterByMinMatchScore(List<Job> jobs, int minScore) {
    return jobs
        .where((job) => (job.cultureMatchScore ?? 50) >= minScore)
        .toList();
  }
}
