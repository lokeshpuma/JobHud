import 'package:jobhud/models/culture_preference_model.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String description;
  final String logoUrl;
  final String url;
  final bool isFavorite;
  final DateTime postedDate;
  final List<CultureTag> cultureTags;
  final int? cultureMatchScore;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
    required this.logoUrl,
    this.url = 'https://remotive.com/remote-jobs',
    this.isFavorite = false,
    DateTime? postedDate,
    List<CultureTag>? cultureTags,
    this.cultureMatchScore,
  })  : postedDate = postedDate ?? DateTime.now(),
        cultureTags = cultureTags ?? [];

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? type,
    String? salary,
    String? description,
    String? logoUrl,
    String? url,
    bool? isFavorite,
    DateTime? postedDate,
    List<CultureTag>? cultureTags,
    int? cultureMatchScore,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      postedDate: postedDate ?? this.postedDate,
      cultureTags: cultureTags ?? this.cultureTags,
      cultureMatchScore: cultureMatchScore ?? this.cultureMatchScore,
    );
  }

  // Helper method to format the posted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(postedDate);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Convert Job to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'salary': salary,
      'description': description,
      'logoUrl': logoUrl,
      'isFavorite': isFavorite,
      'postedDate': postedDate.toIso8601String(),
      'cultureTags': cultureTags.map((tag) => tag.name).toList(),
      'cultureMatchScore': cultureMatchScore,
    };
  }

  // Create Job from Map
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      salary: map['salary'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      postedDate: map['postedDate'] != null 
          ? DateTime.parse(map['postedDate'])
          : null,
      cultureTags: (map['cultureTags'] as List<dynamic>?)
              ?.map((name) => CultureTag.values.firstWhere(
                    (tag) => tag.name == name,
                    orElse: () => CultureTag.workLifeBalance,
                  ))
              .toList() ??
          [],
      cultureMatchScore: map['cultureMatchScore'],
    );
  }
}
