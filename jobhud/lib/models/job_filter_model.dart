class JobFilter {
  final String? location;
  final String? jobType;
  final String? searchQuery;
  final List<String>? categories;

  JobFilter({
    this.location,
    this.jobType,
    this.searchQuery,
    this.categories,
  });

  JobFilter copyWith({
    String? location,
    String? jobType,
    String? searchQuery,
    List<String>? categories,
  }) {
    return JobFilter(
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
    );
  }

  bool get hasActiveFilters =>
      location != null ||
      jobType != null ||
      (categories != null && categories!.isNotEmpty);

  void clear() {
    // This will be handled by creating a new empty filter
  }

  Map<String, dynamic> toMap() {
    return {
      if (location != null && location!.isNotEmpty) 'location': location,
      if (jobType != null && jobType!.isNotEmpty) 'type': jobType,
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
      if (categories != null && categories!.isNotEmpty) 'categories': categories,
    };
  }
}
