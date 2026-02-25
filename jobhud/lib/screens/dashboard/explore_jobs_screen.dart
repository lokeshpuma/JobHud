import 'package:flutter/material.dart';
import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/models/job_filter_model.dart';
import 'package:jobhud/services/job_service.dart';
import 'package:jobhud/services/saved_jobs_service.dart';
import 'package:jobhud/services/culture_preference_service.dart';
import 'package:jobhud/services/culture_match_service.dart';
import 'package:jobhud/widgets/job_card.dart';
import 'package:jobhud/widgets/job_filter_sheet.dart';
import 'package:jobhud/screens/dashboard/job_details_screen.dart';
import 'package:jobhud/screens/dashboard/culture_match_breakdown_screen.dart';
import 'package:jobhud/screens/dashboard/culture_quiz_screen.dart';

class ExploreJobsScreen extends StatefulWidget {
  const ExploreJobsScreen({super.key});

  @override
  State<ExploreJobsScreen> createState() => _ExploreJobsScreenState();
}

class _ExploreJobsScreenState extends State<ExploreJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SavedJobsService _savedJobsService = SavedJobsService();
  final CulturePreferenceService _cultureService = CulturePreferenceService();

  List<Job> _jobs = [];
  List<Job> _allJobs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _jobsPerPage = 50;
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  JobFilter _currentFilter = JobFilter();
  bool _sortByCultureMatch = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cultureService.initialize();
    await _loadJobs();
    _scrollController.addListener(_onScroll);
    _savedJobsService.addListener(_onSavedChange);
  }

  void _onSavedChange() => setState(() {});

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _savedJobsService.removeListener(_onSavedChange);
    super.dispose();
  }

  // Load jobs from the API with filters and pagination
  Future<void> _loadJobs() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      List<Job> fetched;
      
      if (_searchQuery.isNotEmpty) {
        // Use search with filters
        fetched = await JobService.searchJobs(
          _searchQuery,
          filter: _currentFilter,
        );
        // Reset pagination for new searches
        if (_currentPage == 1) {
          _allJobs.clear();
        }
      } else {
        // Fetch with filters and pagination
        fetched = await JobService.fetchJobs(
          limit: _jobsPerPage,
          offset: (_currentPage - 1) * _jobsPerPage,
          filter: _currentFilter,
        );
      }

      // Enrich jobs with culture match data
      final enriched = await CultureMatchService.enrichJobsWithCulture(
        fetched,
        _cultureService.preferences,
      );

      setState(() {
        if (_currentPage == 1) {
          _allJobs = enriched;
        } else {
          _allJobs.addAll(enriched);
        }
        
        _applyFilters();
        _currentPage++;
        _hasMore = fetched.length == _jobsPerPage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Apply local filters to the job list
  void _applyFilters() {
    var list = List<Job>.from(_allJobs);
    final filter = _currentFilter;

    // Apply local filters that aren't handled by the API
    if (filter.jobType != null && filter.jobType!.isNotEmpty) {
      final type = filter.jobType!.toLowerCase();
      list = list.where((job) => 
        job.type.toLowerCase().contains(type) ||
        (type == 'remote' && job.location.toLowerCase().contains('remote'))
      ).toList();
    }

    // Apply culture match sorting if enabled
    if (_sortByCultureMatch) {
      list.sort((a, b) => (b.cultureMatchScore ?? 0).compareTo(a.cultureMatchScore ?? 0));
    }

    // Apply search query filter (only if not already filtered by API)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      final queryTerms = query.split(' ').where((term) => term.length >= 2).toList();
      
      if (queryTerms.isNotEmpty) {
        list = list.where((job) {
          final title = job.title.toLowerCase();
          final company = job.company.toLowerCase();
          final description = job.description.toLowerCase();
          final location = job.location.toLowerCase();
          final jobType = job.type.toLowerCase();
          
          // Check all terms against all relevant fields
          for (final term in queryTerms) {
            final hasMatch = 
                title.contains(term) ||
                company.contains(term) ||
                description.contains(term) ||
                location.contains(term) ||
                jobType.contains(term);
                
            if (!hasMatch) return false;
          }
          return true;
        }).toList();
      }
    }

    // Apply location filter
    if (_currentFilter.location?.isNotEmpty == true && _currentFilter.location != 'All Locations') {
      final loc = _currentFilter.location!.toLowerCase();
      list = list.where((j) {
        final l = j.location.toLowerCase();
        return loc == 'remote'
            ? l.contains('remote') || l.contains('anywhere') || l.contains('worldwide')
            : l.contains(loc);
      }).toList();
    }

    // Apply job type filter
    if (_currentFilter.jobType?.isNotEmpty == true && _currentFilter.jobType != 'All Types') {
      final t = _currentFilter.jobType!.toLowerCase();
      list = list.where((j) => j.type.toLowerCase().contains(t)).toList();
    }

    // Sort by culture match if enabled and user has completed the quiz
    if (_sortByCultureMatch && _cultureService.hasCompletedQuiz) {
      list = CultureMatchService.sortByMatchScore(list);
    } 
    // Otherwise, sort by posted date (newest first)
    else {
      list.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    }

    setState(() => _jobs = list);
  }

  // Handle scroll events for infinite loading
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadJobs();
    }
  }

  // Handle filter changes
  Future<void> _handleFilterChanged(JobFilter newFilter) async {
    setState(() {
      _currentFilter = newFilter;
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
    });
    
    try {
      await _loadJobs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying filters: $e')),
        );
      }
    }
  }

  // Handle search
  void _onSearch() {
    _searchQuery = _searchController.text.trim();
    _allJobs.clear();
    _jobs.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _loadJobs();
  }

  // Clear all filters
  void _clearFilters() {
    _currentFilter = JobFilter();
    _applyFilters();
  }

  // Show filter bottom sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => JobFilterSheet(
          currentFilter: _currentFilter,
          onApplyFilter: (filter) {
            setState(() {
              _currentFilter = filter;
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  // Toggle job favorite status
  void _toggleFavorite(Job job) {
    _savedJobsService.toggleSave(job);
    final isSaved = _savedJobsService.isJobSaved(job.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Job saved' : 'Job removed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Toggle culture match sorting
  void _toggleSortByCultureMatch() {
    setState(() {
      _sortByCultureMatch = !_sortByCultureMatch;
      _currentPage = 1;
      _hasMore = true;
      _allJobs.clear();
    });
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'), 
        centerTitle: true
      ),
      body: Column(children: [
        // Search bar
        _buildSearchBar(context),
        
        // Culture quiz banner (shown if quiz not completed)
        if (!_cultureService.hasCompletedQuiz) _buildQuizBanner(context),
        
        // Active filters chips
        if (_currentFilter.hasActiveFilters) _buildActiveFilters(),
        
        // Job list
        Expanded(child: _buildJobList()),
      ]),
    );
  }

  // Build search bar with filter and sort buttons
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        // Search field
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for jobs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () { 
                        _searchController.clear(); 
                        _onSearch(); 
                      })
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: BorderSide.none
              ),
              filled: true,
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Sort by culture match button (only shown if quiz completed)
        if (_cultureService.hasCompletedQuiz) _buildSortButton(context),
        
        const SizedBox(width: 8),
        
        // Filter button
        _buildFilterButton(context),
      ]),
    );
  }

  // Build sort button
  Widget _buildSortButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sortByCultureMatch 
            ? Theme.of(context).colorScheme.secondary 
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.favorite, 
          color: _sortByCultureMatch ? Colors.white : Colors.grey[700]
        ),
        tooltip: 'Toggle culture match sorting',
        onPressed: _toggleSortByCultureMatch,
      ),
    );
  }

  // Build filter button
  Widget _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _currentFilter.hasActiveFilters 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.filter_list, 
          color: _currentFilter.hasActiveFilters ? Colors.white : Colors.grey[700]
        ),
        tooltip: 'Filter jobs',
        onPressed: _showFilterSheet,
      ),
    );
  }

  // Build culture quiz banner
  Widget _buildQuizBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        ]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.quiz, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: const [
            Text(
              'Find Your Culture Match', 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 4),
            Text(
              'Take 2-min quiz to see match scores', 
              style: TextStyle(fontSize: 12)
            ),
          ]
        )),
        TextButton(
          onPressed: () async {
            final completed = await Navigator.push<bool>(
              context, 
              MaterialPageRoute(builder: (_) => const CultureQuizScreen())
            );
            if (completed == true) {
              await _cultureService.initialize();
              _allJobs.clear();
              _jobs.clear();
              _currentPage = 1;
              _hasMore = true;
              _loadJobs();
            }
          },
          child: const Text("Start"),
        ),
      ]),
    );
  }

  // Build active filters chips
  Widget _buildActiveFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal, 
        children: [
          // Location filter chip
          if (_currentFilter.location != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_currentFilter.location!),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(location: null);
                    _applyFilters();
                  });
                },
              ),
            ),
          
          // Job type filter chip
          if (_currentFilter.jobType != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_currentFilter.jobType!),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(jobType: null);
                    _applyFilters();
                  });
                },
              ),
            ),
          
          // Clear all filters button
          TextButton.icon(
            onPressed: _clearFilters, 
            icon: const Icon(Icons.clear_all, size: 18), 
            label: const Text('Clear All')
          ),
        ]
      ),
    );
  }

  // Build job list
  Widget _buildJobList() {
    // Show loading indicator if loading and no jobs
    if (_jobs.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show empty state if no jobs found
    if (_jobs.isEmpty) {
      return const Center(child: Text('No jobs found.'));
    }
    
    // Build the list of jobs
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _jobs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom when loading more
        if (index >= _jobs.length) {
          _loadJobs();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16), 
              child: CircularProgressIndicator()
            )
          );
        }
        
        // Get job and its saved status
        final job = _jobs[index];
        final saved = _savedJobsService.isJobSaved(job.id);
        
        // Return job card
        return JobCard(
          job: job.copyWith(isFavorite: saved),
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job))
          ),
          onFavoriteTap: () => _toggleFavorite(job),
          onCultureMatchTap: job.cultureMatchScore != null
              ? () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => CultureMatchBreakdownScreen(job: job)
                    )
                  )
              : null,
        );
      },
    );
  }
}
