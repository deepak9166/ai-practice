import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/blog/blog_article.dart';

class DropdownCacheRepository {
  static const _articleTypesKey = 'cached_article_types';
  static const _tagsKey = 'cached_tags';

  /// Load cached article types. Returns empty list if nothing cached.
  Future<List<DropdownItem>> getArticleTypes() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadList(prefs, _articleTypesKey);
  }

  /// Load cached tags. Returns empty list if nothing cached.
  Future<List<DropdownItem>> getTags() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadList(prefs, _tagsKey);
  }

  /// Save article types to cache.
  Future<void> saveArticleTypes(List<DropdownItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveList(prefs, _articleTypesKey, items);
  }

  /// Save tags to cache.
  Future<void> saveTags(List<DropdownItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveList(prefs, _tagsKey, items);
  }

  /// Check if cache has data.
  Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final at = prefs.getStringList(_articleTypesKey);
    final tags = prefs.getStringList(_tagsKey);
    return (at != null && at.isNotEmpty) || (tags != null && tags.isNotEmpty);
  }

  // -- Internal --

  List<DropdownItem> _loadList(SharedPreferences prefs, String key) {
    final raw = prefs.getStringList(key) ?? [];
    return raw
        .map((s) {
          try {
            final json = jsonDecode(s) as Map<String, dynamic>;
            return DropdownItem(
              text: json['text'] ?? '',
              value: json['value'] ?? 0,
              slugUrl: json['slugUrl'],
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<DropdownItem>()
        .toList();
  }

  Future<void> _saveList(
      SharedPreferences prefs, String key, List<DropdownItem> items) async {
    final raw = items
        .map((e) => jsonEncode({
              'text': e.text,
              'value': e.value,
              'slugUrl': e.slugUrl,
            }))
        .toList();
    await prefs.setStringList(key, raw);
  }
}
