import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/incident.dart';

final incidentQueueDbProvider = Provider<IncidentQueueDb>((ref) {
  return IncidentQueueDb();
});

class IncidentQueueDb {
  static const String tableName = 'incident_queue';
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'campussafe_queue.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> enqueueIncident(Map<String, dynamic> payload) async {
    final database = await db;
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    await database.insert(tableName, {
      'id': id,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingIncidents() async {
    final database = await db;
    final maps = await database.query(tableName, orderBy: 'created_at ASC');
    
    return maps.map((row) {
      final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      // Inject the local queue ID so we can delete it later
      payload['_local_id'] = row['id'];
      return payload;
    }).toList();
  }

  Future<void> removeIncident(String localId) async {
    final database = await db;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> clearQueue() async {
    final database = await db;
    await database.delete(tableName);
  }
}
