import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comparison_model.dart';
import '../utils/constants.dart';

/// Local persistence for comparison history.
/// All data stays on device. No cloud. No account.
class StorageService {
  static const String _key = 'beforeafter_comparisons_v1';
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Saves a comparison. If one with the same ID exists, it is replaced.
  Future<void> saveComparison(ComparisonModel comparison) async {
    final storage = await _storage;
    final list = await getComparisons();
    final index = list.indexWhere((c) => c.id == comparison.id);
    if (index >= 0) {
      list[index] = comparison;
    } else {
      list.add(comparison);
    }
    // Enforce free limit if not Pro (checked by provider, not here).
    // This service stores everything it's asked to store.
    await _writeList(list);
  }

  /// Deletes a single comparison by ID.
  Future<void> deleteComparison(String id) async {
    final storage = await _storage;
    final list = await getComparisons();
    list.removeWhere((c) => c.id == id);
    await _writeList(list);
  }

  /// Deletes multiple comparisons by ID.
  Future<void> deleteComparisons(List<String> ids) async {
    final storage = await _storage;
    final list = await getComparisons();
    list.removeWhere((c) => ids.contains(c.id));
    await _writeList(list);
  }

  /// Returns all comparisons, newest first.
  Future<List<ComparisonModel>> getComparisons() async {
    final storage = await _storage;
    final String? jsonStr = storage.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .map((e) => ComparisonModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      // Corrupted data — reset to empty.
      await storage.remove(_key);
      return [];
    }
  }

  /// Returns the count of stored comparisons.
  Future<int> getComparisonCount() async {
    final list = await getComparisons();
    return list.length;
  }

  /// Checks if the free limit has been reached.
  Future<bool> isAtFreeLimit() async {
    final count = await getComparisonCount();
    return count >= AppLimits.freeComparisons;
  }

  /// Clears all history. Irreversible.
  Future<void> clearAll() async {
    final storage = await _storage;
    await storage.remove(_key);
  }

  Future<void> _writeList(List<ComparisonModel> list) async {
    final storage = await _storage;
    final encoded = jsonEncode(list.map((c) => c.toJson()).toList());
    await storage.setString(_key, encoded);
  }
}
