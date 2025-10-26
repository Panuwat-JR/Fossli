import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../data/app_db.dart';
import '../models/fossli.dart';

class FossliProvider extends ChangeNotifier {
  final _dbi = AppDatabase.instance;

  List<Fossli> _items = [];
  List<Fossli> _filtered = [];
  String _keyword = '';
  bool _sortByRarityDesc = false;

  List<Fossli> get items => _filtered;
  bool get sortByRarityDesc => _sortByRarityDesc;
  String get keyword => _keyword;

  Future<void> load() async {
    final db = await _dbi.database;
    final rows = await db.query(AppDatabase.table, orderBy: 'id DESC');
    _items = rows.map((e) => Fossli.fromMap(e)).toList();
    _rebuildFiltered();
    notifyListeners();
  }

  Future<int> add(Fossli f) async {
    final db = await _dbi.database;
    final id = await db.insert(AppDatabase.table, f.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort);
    final inserted = f.copyWith(id: id);
    _items.insert(0, inserted);
    _rebuildFiltered();
    notifyListeners();
    return id;
  }

  Future<void> update(Fossli f) async {
    if (f.id == null) return;
    final db = await _dbi.database;
    await db.update(
      AppDatabase.table,
      f.toMap()..remove('id'),
      where: 'id=?',
      whereArgs: [f.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final i = _items.indexWhere((e) => e.id == f.id);
    if (i != -1) _items[i] = f;
    _rebuildFiltered();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await _dbi.database;
    await db.delete(AppDatabase.table, where: 'id=?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    _rebuildFiltered();
    notifyListeners();
  }

  void search(String keyword) {
    _keyword = keyword.trim();
    _rebuildFiltered();
    notifyListeners();
  }

  void toggleSortByRarityDesc([bool? v]) {
    _sortByRarityDesc = v ?? !_sortByRarityDesc;
    _rebuildFiltered();
    notifyListeners();
  }

  void _rebuildFiltered() {
    Iterable<Fossli> data = _items;
    if (_keyword.isNotEmpty) {
      final k = _keyword.toLowerCase();
      data = data.where((f) =>
          f.title.toLowerCase().contains(k) ||
          f.species.toLowerCase().contains(k) ||
          f.era.toLowerCase().contains(k) ||
          f.foundAt.toLowerCase().contains(k) ||
          f.history.toLowerCase().contains(k));
    }
    final list = data.toList();
    if (_sortByRarityDesc) {
      list.sort((a, b) => b.rarity.compareTo(a.rarity));
    }
    _filtered = list;
  }
}
