import 'package:sqflite/sqflite.dart';
import 'package:guardaya_app/data/datasources/local/db/database_helper.dart';
import 'package:guardaya_app/data/models/pending_venta_model.dart';

class PendingVentasDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertPendingVenta(PendingVentaModel venta) async {
    final db = await _dbHelper.database;
    return await db.insert('pending_ventas', venta.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PendingVentaModel>> getPendingVentas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pending_ventas',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    return List.generate(maps.length, (i) => PendingVentaModel.fromMap(maps[i]));
  }

  Future<List<PendingVentaModel>> getAllPendingVentas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pending_ventas');
    return List.generate(maps.length, (i) => PendingVentaModel.fromMap(maps[i]));
  }

  Future<int> updateSyncStatus(String id, String status, {String? error, int? retryCount}) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> values = {'sync_status': status};
    if (error != null) values['sync_error'] = error;
    if (retryCount != null) values['retry_count'] = retryCount;
    return await db.update(
      'pending_ventas',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePendingVenta(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pending_ventas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCacheVentas() async {
    final db = await _dbHelper.database;
    await db.delete('cache_ventas');
  }

  Future<void> deleteAllPendingVentas() async {
    final db = await _dbHelper.database;
    await db.delete('pending_ventas');
  }

  Future<void> insertCacheVenta(Map<String, dynamic> venta) async {
    final db = await _dbHelper.database;
    await db.insert('cache_ventas', venta, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> searchCacheVentas({String? telefono, String? codigo, String? nombre}) async {
    final db = await _dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;
    
    if (telefono != null) {
      where = 'cliente_telefono LIKE ?';
      whereArgs = ['%$telefono%'];
    } else if (codigo != null) {
      where = 'codigo_yape LIKE ?';
      whereArgs = ['%$codigo%'];
    } else if (nombre != null) {
      where = 'cliente_nombre LIKE ?';
      whereArgs = ['%$nombre%'];
    }

    return await db.query('cache_ventas', where: where, whereArgs: whereArgs);
  }
}
