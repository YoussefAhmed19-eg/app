import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> genres = [
    "Action",
    "Adventure",
    "Animation",
    "Biography",
    "Comedy",
    "Crime",
    "Drama",
  ];
  String selectedGenre = "Action";

  Future<void> _playMovie(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("could_not_open_link".tr())),
      );
    }
  }

  void _addToWatchlist(MovieModel movie) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchlist')
          .doc(movie.id.toString())
          .set(movie.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${movie.title} ${"added_to_watchlist".tr()}"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error saving movie: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      body: Column(
        children: [
          const SizedBox(height: 50),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedGenre == genres[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedGenre = genres[index]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFBB3B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFBB3B)),
                    ),
                    child: Text(
                      genres[index].toLowerCase().tr(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<MovieModel>>(
              future: ApiService().fetchMoviesByCategory(selectedGenre),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFBB3B)),
                  );
                }

                final movies = snapshot.data ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _playMovie(movie.url),
                          child: MovieCard(movie: movie),
                        ),

                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () => _addToWatchlist(movie),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bookmark_add_outlined,
                                color: Color(0xFFFFBB3B),
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () => _playMovie(movie.url),
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white.withOpacity(0.8),
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
