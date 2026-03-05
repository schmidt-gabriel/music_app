import 'package:flutter/material.dart';
import '../utils/api.dart';
import 'settings_view.dart';

enum SortOption { 
  countDesc, 
  countAsc
}

/// Displays totals statistics for buy years, media types, and release years.
class TotalsView extends StatefulWidget {
  const TotalsView({super.key});

  static const routeName = '/totals';

  @override
  State<TotalsView> createState() => _TotalsViewState();
}

class _TotalsViewState extends State<TotalsView> {
  final api = API();
  Map<String, dynamic>? totalsData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  SortOption _currentSort = SortOption.countDesc;

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    try {
      final data = await api.fetchTotals();
      setState(() {
        totalsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<MapEntry<String, dynamic>> _sortMediaData(Map<String, dynamic> mediaData) {
    List<MapEntry<String, dynamic>> sortedEntries = mediaData.entries.toList();
    
    switch (_currentSort) {
      case SortOption.countDesc:
        sortedEntries.sort((a, b) => (b.value as int).compareTo(a.value as int));
        break;
      case SortOption.countAsc:
        sortedEntries.sort((a, b) => (a.value as int).compareTo(b.value as int));
        break;
    }
    
    return sortedEntries;
  }

  Widget _buildMediaCard(String mediaType, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(2)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Totals'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: Theme.of(context).hintColor,
              onPressed: () {
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading totals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  _loadTotals();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Totals'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort options',
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: SortOption.countDesc,
                child: Text('Highest count first'),
              ),
              const PopupMenuItem(
                value: SortOption.countAsc,
                child: Text('Lowest count first'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Theme.of(context).hintColor,
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadTotals();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: Theme.of(context).hintColor,
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalsData == null
              ? const Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (totalsData!['media'] != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Totais por Tipo de Mídia',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final mediaData = totalsData!['media'] as Map<String, dynamic>;
                              final totalCount = mediaData.values
                                  .cast<int>()
                                  .fold<int>(0, (sum, count) => sum + count);
                              
                              final sortedEntries = _sortMediaData(mediaData);
                              
                              return ListView(
                                children: sortedEntries
                                    .map((entry) => _buildMediaCard(
                                          entry.key,
                                          entry.value as int,
                                          totalCount,
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
