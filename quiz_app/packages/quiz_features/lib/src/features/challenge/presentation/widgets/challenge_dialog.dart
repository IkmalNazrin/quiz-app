import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';


import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_domain/quiz_domain.dart';

class ChallengeDialog extends StatefulWidget {
  final Function(String username) onChallenge;
  final Future<List<dynamic>> Function(String query)? onSearch;

  const ChallengeDialog({super.key, required this.onChallenge, this.onSearch});

  @override
  State<ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<ChallengeDialog> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(_searchController.text);
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }
    if (mounted) setState(() => _isLoading = true);

    try {
      final results = widget.onSearch != null
          ? await widget.onSearch!(query)
          : <dynamic>[];

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('Error searching users: $e', category: LogCategory.ui);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        margin: const EdgeInsets.all(AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Challenge a Friend', style: AppTypography.h2),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search for username...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                              _searchController.text.isEmpty
                                  ? 'Search for rivals'
                                  : 'No matches found',
                              style: AppTypography.bodySmall))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final pictureUrl =
                                user['avatar_url'] ?? user['picture'];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                backgroundImage: (pictureUrl != null &&
                                        pictureUrl.isNotEmpty)
                                    ? NetworkImage(pictureUrl)
                                    : null,
                                child:
                                    (pictureUrl == null || pictureUrl.isEmpty)
                                        ? const Icon(Icons.person,
                                            color: AppColors.primary)
                                        : null,
                              ),
                              title: Text(user['username'] ?? 'Unknown',
                                  style: AppTypography.bodyLarge
                                      .copyWith(fontWeight: FontWeight.bold)),
                              trailing: const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary),
                              onTap: () {
                                widget.onChallenge(user['username']);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Close',
              type: AppButtonType.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ).animate().scale(curve: Curves.elasticOut, duration: 600.ms).fadeIn();
  }
}
