class MovieModel {
  final int id;
  final String title;
  final String url;
  final String mediumCoverImage;
  final String year;
  final double rating;
  final int runtime;
  final String poster;
  final String description;
  final String trailerCode;

  MovieModel({
    required this.id,
    required this.title,
    required this.url,
    required this.mediumCoverImage,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.poster,
    required this.description,
    required this.trailerCode,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      year: json['year']?.toString() ?? 'N/A',
      url: json['url'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      runtime: json['runtime'] ?? 0,
      poster: json['medium_cover_image'] ?? json['large_cover_image'] ?? '',
      description: json['description_full'] ?? '',
      trailerCode: json['yt_trailer_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'rating': rating,
      'runtime': runtime,
      'description_full': description,
      'yt_trailer_code': trailerCode,
      'url': url,
      'medium_cover_image': mediumCoverImage,
    };
  }
}
