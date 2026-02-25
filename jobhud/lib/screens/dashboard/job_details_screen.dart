import 'package:flutter/material.dart';
import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/services/saved_jobs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Job _job;
  final SavedJobsService _savedJobsService = SavedJobsService();

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _checkIfJobIsSaved();
  }

  void _checkIfJobIsSaved() {
    final savedJob = _savedJobsService.getSavedJob(_job.id);
    if (savedJob != null) {
      setState(() {
        _job = savedJob;
      });
    }
  }

  void _toggleSave() {
    setState(() {
      _savedJobsService.toggleSave(_job);
      _job = _job.copyWith(isFavorite: !_job.isFavorite);
    });
  }

  Future<void> _launchUrl(String url) async {
    try {
      // Ensure URL has a scheme
      String processedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        processedUrl = 'https://$url';
      }
      
      final Uri uri = Uri.parse(processedUrl);
      
      // Check if URL is launchable
      if (!await canLaunchUrl(uri)) {
        throw 'Could not launch $processedUrl';
      }
      
      // Try to launch URL with platform default
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to any application that can handle the URL
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (e) {
      if (!mounted) return;
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the job application page'),
          action: SnackBarAction(
            label: 'Copy Link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard')),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _job.isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: _job.isFavorite ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _launchUrl(_job.url),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Apply Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _job.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _job.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_rounded),
                          ),
                        )
                      : const Icon(Icons.business_rounded, size: 32, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                // Job Title and Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _job.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _job.company,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _job.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Job Type and Salary
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.work_outline,
                  text: _job.type,
                ),
                const SizedBox(width: 8),
                if (_job.salary.toLowerCase() != 'not specified')
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    text: _job.salary,
                  ),
                const Spacer(),
                Text(
                  'Posted ${_job.formattedDate}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Job Description
            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Html(
                data: _job.description,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(16),
                    lineHeight: const LineHeight(1.6),
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "em": Style(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  "strong": Style(
                    fontWeight: FontWeight.bold,
                  ),
                  "a": Style(
                    color: Colors.blue[700],
                    textDecoration: TextDecoration.underline,
                  ),
                  "ul": Style(
                    margin: Margins.only(left: 16, bottom: 12),
                  ),
                  "li": Style(
                    margin: Margins.only(bottom: 8),
                  ),
                },
                onLinkTap: (url, attributes, element) {
                  if (url != null) {
                    _launchUrl(url);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}
