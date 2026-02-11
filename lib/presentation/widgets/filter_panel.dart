// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../providers/catalog_provider.dart';

class FilterPanel extends StatefulWidget {
  final FilterParams currentFilters;
  final Function(FilterParams) onApply;

  const FilterPanel({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late FilterParams _tempFilters;

  // Basic Genre Map (Hardcoded for demo, usually fetched from API)
  final Map<int, String> _genres = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _buildSortSection(),
                const SizedBox(height: 16),
                _buildGenreSection(),
                const SizedBox(height: 16),
                _buildRatingSection(),
                const SizedBox(height: 16),
                _buildDateSection(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_tempFilters);
                // If in drawer/endDrawer, close it?
                // We'll let the parent handle closing or we close here if it was a drawer.
                // Assuming parent closes or this is always visible on desktop.
              },
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: const Text('Popularity Desc'),
          value: 'popularity.desc',
          groupValue: _tempFilters.sortBy,
          onChanged: (v) =>
              setState(() => _tempFilters = _tempFilters.copyWith(sortBy: v)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Release Date Desc'),
          value: 'primary_release_date.desc',
          groupValue: _tempFilters.sortBy,
          onChanged: (v) =>
              setState(() => _tempFilters = _tempFilters.copyWith(sortBy: v)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Rating Desc'),
          value: 'vote_average.desc',
          groupValue: _tempFilters.sortBy,
          onChanged: (v) =>
              setState(() => _tempFilters = _tempFilters.copyWith(sortBy: v)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Genres', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: _genres.entries.map((e) {
            final isSelected = _tempFilters.withGenres.contains(
              e.key.toString(),
            );
            return FilterChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (selected) {
                final current = List<String>.from(_tempFilters.withGenres);
                if (selected) {
                  current.add(e.key.toString());
                } else {
                  current.remove(e.key.toString());
                }
                setState(
                  () =>
                      _tempFilters = _tempFilters.copyWith(withGenres: current),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min Rating: ${(_tempFilters.voteAverageGte ?? 0).toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _tempFilters.voteAverageGte ?? 0,
          min: 0,
          max: 10,
          divisions: 20,
          label: (_tempFilters.voteAverageGte ?? 0).toStringAsFixed(1),
          onChanged: (v) => setState(
            () => _tempFilters = _tempFilters.copyWith(voteAverageGte: v),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    // Simplified Date Picker
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Release Year',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // To make it simple, let's just pick a year, or we can use showDatePicker.
        // For now let's just use "Released this year" toggle or similar?
        // User requested "Desde" and "Hasta".
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _tempFilters.releaseDateGte ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(
                () => _tempFilters = _tempFilters.copyWith(
                  releaseDateGte: picked,
                ),
              );
            }
          },
          child: Text('From: ${_tempFilters.releaseDateGte?.year ?? "Any"}'),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _tempFilters.releaseDateLte ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(
                () => _tempFilters = _tempFilters.copyWith(
                  releaseDateLte: picked,
                ),
              );
            }
          },
          child: Text('To: ${_tempFilters.releaseDateLte?.year ?? "Any"}'),
        ),
      ],
    );
  }
}
