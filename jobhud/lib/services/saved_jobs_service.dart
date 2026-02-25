import 'package:flutter/foundation.dart';
import 'package:jobhud/models/job_model.dart';

class SavedJobsService extends ChangeNotifier {
  static final SavedJobsService _instance = SavedJobsService._internal();
  final List<Job> _savedJobs = [];

  factory SavedJobsService() {
    return _instance;
  }

  SavedJobsService._internal();

  // Get all saved jobs
  List<Job> get savedJobs => List.unmodifiable(_savedJobs);

  // Check if a job is saved
  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }

  // Toggle save status of a job
  void toggleSave(Job job) {
    if (isJobSaved(job.id)) {
      _savedJobs.removeWhere((j) => j.id == job.id);
    } else {
      _savedJobs.add(job.copyWith(isFavorite: true));
    }
    notifyListeners();
  }

  // Get a saved job by ID
  Job? getSavedJob(String jobId) {
    try {
      return _savedJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }
}
