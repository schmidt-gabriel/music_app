import 'package:flutter/material.dart';
import 'settings_view.dart';
import 'albums_view.dart';
import 'totals_view.dart';
import '../utils/api.dart';
import '../models/artist.dart';

/// Displays a list of SampleItems.
class ArtistListView extends StatefulWidget {
  const ArtistListView({super.key});

  static const routeName = '/artist';

  @override
  State<ArtistListView> createState() => _ArtistListViewState();
}

class _ArtistListViewState extends State<ArtistListView> {
  final api = API();
  bool _searchBar = false;
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
    return _error
        ? const Scaffold(
            body: Center(
              child: Text("No Internet"),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).hoverColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _searchBar == false ? 0 : 500,
                height: 50,
                child: TextField(
                  controller: editingController,
                  decoration: InputDecoration(
                    hintText: "Digite o Artista",
                    hintStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      style: ButtonStyle(
                        iconSize: WidgetStatePropertyAll(
                            _searchBar == false ? 0 : 20),
                      ),
                      onPressed: () {
                        setState(() {
                          editingController.clear();
                          _searchArtist();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  autofocus: _searchBar == true ? true : false,
                  enableSuggestions: false,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    setState(() {
                      _searchArtist();
                    });
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Theme.of(context).hintColor,
                  onPressed: () {
                    setState(() {
                      if (_searchBar == true) {
                        FocusScope.of(context).unfocus();
                        editingController.clear();
                        _searchArtist();
                      }
                      _searchBar = !_searchBar;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  color: Theme.of(context).hintColor,
                  onPressed: () {
                    Navigator.restorablePushNamed(
                        context, TotalsView.routeName);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: Theme.of(context).hintColor,
                  onPressed: () {
                    // Navigate to the settings page. If the user leaves and returns
                    // to the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: artistsFiltered == []
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).canvasColor),
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: artistsFiltered.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            color: Colors.black38,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final item = artistsFiltered[index];

                            return ListTile(
                                title: Text(item.name),
                                leading: const IconButton(
                                  iconSize: 50,
                                  icon: Icon(Icons.person),
                                  onPressed: null,
                                ),
                                onTap: () {
                                  // Navigate to the details page. If the user leaves and returns to
                                  // the app after it has been killed while running in the
                                  // background, the navigation stack is restored.
                                  Navigator.restorablePushNamed(
                                    context,
                                    AlbumsItemDetailsView.routeName,
                                    arguments: item.name,
                                  );
                                });
                          },
                        ),
                      )),
          );
  }
}
