import 'package:flutter/material.dart';
import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/screens/dashboard/job_details_screen.dart';
import 'package:jobhud/services/saved_jobs_service.dart';
import 'package:jobhud/widgets/job_card.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final SavedJobsService _savedJobsService = SavedJobsService();
  late List<Job> _savedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
    _savedJobsService.addListener(_loadSavedJobs);
  }
  
  @override
  void dispose() {
    _savedJobsService.removeListener(_loadSavedJobs);
    super.dispose();
  }

  Future<void> _loadSavedJobs() async {
    if (mounted) {
      setState(() {
        _savedJobs = _savedJobsService.savedJobs;
        _isLoading = false;
      });
    }
  }

  void _removeJob(String jobId) {
    final jobToRemove = _savedJobs.firstWhere((job) => job.id == jobId);
    _savedJobsService.toggleSave(jobToRemove);
    
    if (mounted) {
      setState(() {
        _savedJobs = _savedJobsService.savedJobs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved jobs yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon to save jobs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                        // Navigate to explore screen (home screen with index 0)
                        if (mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                        child: const Text('Browse Jobs'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _savedJobs.length,
                  itemBuilder: (context, index) {
                    final job = _savedJobs[index];
                    return Dismissible(
                      key: Key(job.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Job'),
                            content: const Text(
                                'Are you sure you want to remove this job from saved?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('REMOVE'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => _removeJob(job.id),
                      child: JobCard(
                        job: job,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(job: job),
                            ),
                          ).then((_) => _loadSavedJobs());
                        },
                        onFavoriteTap: () {
                          _removeJob(job.id);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
