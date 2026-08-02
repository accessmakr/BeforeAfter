import 'package:flutter/material.dart';
import '../models/comparison_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Manages the list of comparisons and enforces free-tier limits.
/// Uses ValueNotifier for efficient, granular rebuilds.
class ComparisonProvider extends ValueNotifier<List<ComparisonModel>> {
  final StorageService _storage = StorageService();
  final bool Function() _isPro;

  ComparisonProvider({required bool Function() isPro}) 
    : _isPro = isPro,
      super([]) {
    _load();
  }

  bool get isAtLimit {
    if (_isPro()) return false;
    return value.length >= AppLimits.freeComparisons;
  }

  int get remainingFreeSlots {
    if (_isPro()) return -1; // unlimited
    final remaining = AppLimits.freeComparisons - value.length;
    return remaining.clamp(0, AppLimits.freeComparisons);
  }

  /// Loads comparisons from local storage.
  Future<void> _load() async {
    final list = await _storage.getComparisons();
    value = list;
  }

  /// Adds a new comparison. Returns true if added, false if at free limit.
  Future<bool> add(ComparisonModel comparison) async {
    if (isAtLimit) return false;
    await _storage.saveComparison(comparison);
    value = [...value, comparison];
    return true;
  }

  /// Updates an existing comparison by ID.
  Future<void> update(ComparisonModel comparison) async {
    await _storage.saveComparison(comparison);
    value = value.map((c) => c.id == comparison.id ? comparison : c).toList();
  }

  /// Deletes a single comparison.
  Future<void> delete(String id) async {
    await _storage.deleteComparison(id);
    value = value.where((c) => c.id != id).toList();
  }

  /// Deletes multiple comparisons.
  Future<void> deleteMultiple(List<String> ids) async {
    await _storage.deleteComparisons(ids);
    value = value.where((c) => !ids.contains(c.id)).toList();
  }

  /// Clears all history.
  Future<void> clearAll() async {
    await _storage.clearAll();
    value = [];
  }

  /// Refreshes the list from storage (useful after Pro upgrade unlocks limit).
  Future<void> refresh() async {
    await _load();
  }
}
