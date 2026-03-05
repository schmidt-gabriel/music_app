import 'package:flutter/material.dart';
import 'package:music_app/src/views/handle_album.dart';
import '../settings/settings_controller.dart';
import '../models/album.dart';
import '../utils/api.dart';
import '../widgets/music_cards.dart';
import '../widgets/modern_app_bar.dart';
import 'album_view.dart';

/// Displays detailed information about a SampleItem.
class AlbumsItemDetailsView extends StatefulWidget {
  final Object artist;
  const AlbumsItemDetailsView({super.key, required this.artist, required this.controller});

  static const routeName = '/discograpy';
  final SettingsController controller;

  @override
  State<AlbumsItemDetailsView> createState() => _AlbumsItemDetailsViewState();
}

enum SortOption { 
  none, 
  releaseYearAsc, 
  releaseYearDesc, 
  titleAsc, 
  titleDesc 
}

class _AlbumsItemDetailsViewState extends State<AlbumsItemDetailsView> {
  final api = API();
  SortOption _currentSort = SortOption.releaseYearAsc;

  List<Album> _sortAlbums(List<Album> albums) {
    List<Album> sortedAlbums = List.from(albums);
    
    switch (_currentSort) {
      case SortOption.releaseYearAsc:
        sortedAlbums.sort((a, b) {
          // Handle albums with no release year (put them at the end)
          if (a.releaseYear <= 0 && b.releaseYear <= 0) return 0;
          if (a.releaseYear <= 0) return 1;
          if (b.releaseYear <= 0) return -1;
          return a.releaseYear.compareTo(b.releaseYear);
        });
        break;
      case SortOption.releaseYearDesc:
        sortedAlbums.sort((a, b) {
          // Handle albums with no release year (put them at the end)
          if (a.releaseYear <= 0 && b.releaseYear <= 0) return 0;
          if (a.releaseYear <= 0) return 1;
          if (b.releaseYear <= 0) return -1;
          return b.releaseYear.compareTo(a.releaseYear);
        });
        break;
      case SortOption.titleAsc:
        sortedAlbums.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        sortedAlbums.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.none:
        break;
    }
    
    return sortedAlbums;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: widget.artist as String,
        centerTitle: false,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort albums',
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: SortOption.releaseYearAsc,
                child: Text('Release year (oldest first)'),
              ),
              const PopupMenuItem(
                value: SortOption.releaseYearDesc,
                child: Text('Release year (newest first)'),
              ),
              const PopupMenuItem(
                value: SortOption.titleAsc,
                child: Text('Title (A-Z)'),
              ),
              const PopupMenuItem(
                value: SortOption.titleDesc,
                child: Text('Title (Z-A)'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: api.fetchAlbumByArtist(widget.artist as String),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: const Column(
                children: [
                  SizedBox(height: 16),
                  LoadingCard(),
                  SizedBox(height: 8),
                  LoadingCard(),
                  SizedBox(height: 8),
                  LoadingCard(),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: "Something went wrong",
              subtitle: "Unable to load albums. Please try again.",
              action: ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyState(
              icon: Icons.album_outlined,
              title: "No Albums Found",
              subtitle: "This artist doesn't have any albums in the collection yet.",
            );
          }

          final albums = _sortAlbums(snapshot.data!.cast<Album>());

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: albums.length,
              itemBuilder: (BuildContext context, int index) {
                final Album album = albums[index];
                return AlbumCard(
                  title: album.title,
                  imageUrl: album.discogs.coverImage.isNotEmpty 
                      ? album.discogs.coverImage 
                      : null,
                  year: album.releaseYear > 0 ? album.releaseYear.toString() : null,
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AlbumItemDetailsView.routeName,
                      arguments: album.toJson(),
                    );
                    if (result != null) {
                      setState(() {
                        if (result == "updated") {
                          return;
                        }
                        albums.removeWhere((a) => a.id == result);
                      });
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            HandleAlbumView.routeName,
            arguments: Album.fromJSON({"artist": widget.artist}),
          );
          if (result != null) {
            setState(() {});
          }
        },
        tooltip: 'Add Album',
        child: const Icon(Icons.add),
      ),
    );
  }
}
