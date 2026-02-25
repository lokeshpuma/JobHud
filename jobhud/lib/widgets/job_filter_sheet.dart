import 'package:flutter/material.dart';
import 'package:jobhud/models/job_filter_model.dart';

class JobFilterSheet extends StatefulWidget {
  final JobFilter currentFilter;
  final Function(JobFilter) onApplyFilter;

  const JobFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  late String? _selectedLocation;
  late String? _selectedJobType;

  final List<String> _locations = [
    'All Locations',
    'Remote',
    'United States',
    'United Kingdom',
    'Europe',
    'Asia',
    'Americas',
    'Africa',
    'Australia',
  ];

  final List<String> _jobTypes = [
    'All Types',
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentFilter.location;
    _selectedJobType = widget.currentFilter.jobType;
  }

  void _applyFilters() {
    final filter = JobFilter(
      location: _selectedLocation == 'All Locations' ? null : _selectedLocation,
      jobType: _selectedJobType == 'All Types' ? null : _selectedJobType,
      searchQuery: widget.currentFilter.searchQuery,
    );
    widget.onApplyFilter(filter);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedLocation = null;
      _selectedJobType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Filter
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _locations.map((location) {
                      final isSelected = _selectedLocation == location ||
                          (_selectedLocation == null && location == 'All Locations');
                      return FilterChip(
                        label: Text(location),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedLocation = selected ? location : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Job Type Filter
                  const Text(
                    'Job Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _jobTypes.map((type) {
                      final isSelected = _selectedJobType == type ||
                          (_selectedJobType == null && type == 'All Types');
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedJobType = selected ? type : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
