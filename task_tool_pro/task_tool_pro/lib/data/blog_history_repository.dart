import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/blog/blog_history_entry.dart';

class BlogHistoryRepository {
  static const _key = 'blog_writer_history';
  static const _maxEntries = 500;

  /// Get all history entries, newest first.
  Future<List<BlogHistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entries = raw
        .map((s) {
          try {
            return BlogHistoryEntry.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<BlogHistoryEntry>()
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Check if a normalized URL already exists.
  Future<bool> urlExists(String url) async {
    final normalized = BlogHistoryEntry.normalizeUrl(url);
    final entries = await getAll();
    return entries
        .any((e) => BlogHistoryEntry.normalizeUrl(e.url) == normalized);
  }

  /// Add a new entry. Caps at [_maxEntries].
  Future<void> addEntry(BlogHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.insert(0, jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) {
      raw.removeRange(_maxEntries, raw.length);
    }
    await prefs.setStringList(_key, raw);
  }

  /// Update the status of an entry matching the given URL.
  Future<void> updateStatus(String url, String newStatus) async {
    final normalized = BlogHistoryEntry.normalizeUrl(url);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final updated = raw.map((s) {
      try {
        final json = jsonDecode(s) as Map<String, dynamic>;
        final entry = BlogHistoryEntry.fromJson(json);
        if (BlogHistoryEntry.normalizeUrl(entry.url) == normalized) {
          return jsonEncode(entry.copyWith(status: newStatus).toJson());
        }
        return s;
      } catch (_) {
        return s;
      }
    }).toList();
    await prefs.setStringList(_key, updated);
  }

  /// Clear all history.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
