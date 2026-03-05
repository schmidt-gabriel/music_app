import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:music_app/src/models/album.dart';
import 'package:music_app/src/utils/discogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'handle_album.dart';
import '../utils/api.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/album_detail_widgets.dart';

/// Displays detailed information about a SampleItem.
class AlbumItemDetailsView extends StatefulWidget {
  final Object album;
  const AlbumItemDetailsView({super.key, required this.album});

  static const routeName = '/album';

  @override
  State<AlbumItemDetailsView> createState() => _AlbumItemDetailsViewState();
}

class _AlbumItemDetailsViewState extends State<AlbumItemDetailsView> {
  final api = API();
  final discogsAPI = DiscogsAPI();

  void returnScreen(String id, String message) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.pop(context, id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController discogsIdController = TextEditingController();
    Album album = Album.fromJSON(widget.album as Map<String, dynamic>);
    return Scaffold(
      appBar: GradientAppBar(
        title: album.title,
        actions: [
          DropdownButton(
            underline: Container(),
            icon: const Icon(Icons.more_vert),
            items: [
              DropdownMenuItem(
                value: "fix_discogs",
                child: TextButton.icon(
                    onPressed: () async {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text("Discogs ID"),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const Text("Insira o ID do álbum no Discogs"),
                                const SizedBox(height: 20),
                                CupertinoTextField(
                                  placeholder: "Discogs ID",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                  controller: discogsIdController,
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("Cancelar"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("Confirmar"),
                                onPressed: () async {
                                  print(discogsIdController.text);
                                  print(album.id);
                                  album.discogs = await discogsAPI
                                      .getById(discogsIdController.text);
                                  await api.handleAlbum(album);
                                  returnScreen(album.id,
                                      "Discogs ID inserido com sucesso!");
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text("Corrigir Discogs")),
              ),
              DropdownMenuItem(
                value: "edit",
                child: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        HandleAlbumView.routeName,
                        arguments: album,
                      );
                      if (result != null) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar")),
              ),
              DropdownMenuItem(
                value: "delte",
                child: TextButton.icon(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text("Deletar"),
                            content:
                                const Text("Tem certeza que deseja deletar?"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("Não"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("Sim"),
                                onPressed: () async {
                                  await api.deleteAlbum(album);
                                  returnScreen(
                                      album.id, "Disco deletado com sucesso!");
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Deletar")),
              ),
            ],
            onChanged: (value) {},
          )
        ],
      ),
      body: Container(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              AlbumHeaderCard(album: album),
              AlbumDetailsSection(album: album),
              DiscsSection(album: album),
              TracklistSection(album: album),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spaceBetweenChildren: 16,
        childPadding: const EdgeInsets.all(8),
        children: [
          SpeedDialChild(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/discogs.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            label: "Open in Discogs",
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            onTap: () async {
              if (album.discogs.urls.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("No Discogs link available"),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Uri discogsUrl = Uri.parse(
                  "https://www.discogs.com${album.discogs.urls[0].uri}");
              if (await canLaunchUrl(discogsUrl)) {
                launchUrl(discogsUrl);
              }
            },
          ),
          SpeedDialChild(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/spotify.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            label: "Open in Spotify",
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            onTap: () async {
              if (album.spotify.externalUrls["spotify"] == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("No Spotify link available"),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Uri spotifyUrl = Uri.parse(album.spotify.externalUrls["spotify"]!);
              if (await canLaunchUrl(spotifyUrl)) {
                launchUrl(spotifyUrl);
              }
            },
          ),
        ],
      ),
    );
  }
}
