import 'package:flutter/material.dart';
import 'settings_view.dart';
import 'albums_view.dart' as albums_view;
import 'totals_view.dart';
import '../utils/api.dart';
import '../models/artist.dart';
import '../widgets/music_cards.dart';
import '../widgets/modern_app_bar.dart';

/// Displays a list of SampleItems.
class ArtistListView extends StatefulWidget {
  const ArtistListView({super.key});

  static const routeName = '/artist';

  @override
  State<ArtistListView> createState() => _ArtistListViewState();
}

class _ArtistListViewState extends State<ArtistListView> {
  final api = API();
  bool _error = false;
  TextEditingController editingController = TextEditingController();
  List<Artist> artists = [];
  List<Artist> artistsFiltered = [];

  Future<String> _searchArtist() async {
    try {
      if (artists.isEmpty) {
        artists = await api.fetchArtists();
      }
      if (editingController.text.isEmpty) {
        setState(() {
          this.artistsFiltered = artists;
        });
        return "";
      }
    } catch (e) {
      return e.toString();
    }

    List<Artist> artistsFiltered = [];

    for (var _artist in artists) {
      if (_artist.name
          .toLowerCase()
          .contains(editingController.text.toLowerCase())) {
        artistsFiltered.add(_artist);
      }
    }

    setState(() {
      this.artistsFiltered = artistsFiltered;
    });

    return "";
  }

  @override
  void initState() {
    super.initState();
    _searchArtist().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _error = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.wifi_off,
          title: "No Internet Connection",
          subtitle: "Please check your internet connection and try again",
          action: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = false;
              });
              _searchArtist().then((value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _error = true;
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ModernAppBar(
        title: "Music Collection",
        hasSearch: true,
        searchController: editingController,
        searchHint: "Search artists...",
        onSearchChanged: (value) => _searchArtist(),
        onSearchClear: () => _searchArtist(),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: Colors.white,
            onPressed: () {
              Navigator.restorablePushNamed(context, TotalsView.routeName);
            },
            tooltip: "Statistics",
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
            tooltip: "Settings",
          ),
        ],
      ),
      body: artistsFiltered.isEmpty
          ? artists.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingCard(),
                      SizedBox(height: 8),
                      LoadingCard(),
                      SizedBox(height: 8),
                      LoadingCard(),
                    ],
                  ),
                )
              : EmptyState(
                  icon: Icons.search_off,
                  title: "No Artists Found",
                  subtitle: "Try adjusting your search terms",
                )
          : Container(
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
                itemCount: artistsFiltered.length,
                itemBuilder: (BuildContext context, int index) {
                  final artist = artistsFiltered[index];
                  return ArtistCard(
                    artistName: artist.name,
                    onTap: () {
                      Navigator.restorablePushNamed(
                        context,
                        albums_view.AlbumsItemDetailsView.routeName,
                        arguments: artist.name,
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
