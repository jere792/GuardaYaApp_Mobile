import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'guardaya.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_ventas (
        id TEXT PRIMARY KEY,
        empresa_id TEXT NOT NULL,
        usuario_id TEXT NOT NULL,
        cliente_id TEXT,
        codigo_yape TEXT,
        monto REAL NOT NULL,
        cliente_nombre TEXT,
        cliente_telefono TEXT,
        fecha_yape TEXT,
        descripcion TEXT,
        estado TEXT DEFAULT 'pendiente',
        imagen_yape_local_path TEXT,
        imagen_entrega_local_path TEXT,
        created_at TEXT,
        sync_status TEXT DEFAULT 'pending',
        sync_error TEXT,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_venta_productos (
        id TEXT PRIMARY KEY,
        pending_venta_id TEXT NOT NULL,
        producto_id TEXT,
        nombre TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL,
        FOREIGN KEY (pending_venta_id) REFERENCES pending_ventas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_ventas (
        id TEXT PRIMARY KEY,
        empresa_id TEXT NOT NULL,
        cliente_nombre TEXT,
        cliente_telefono TEXT,
        codigo_yape TEXT,
        monto REAL,
        estado TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_pending_ventas_sync ON pending_ventas(sync_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_cache_ventas_telefono ON cache_ventas(cliente_telefono)
    ''');

    await db.execute('''
      CREATE INDEX idx_cache_ventas_codigo ON cache_ventas(codigo_yape)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Framework para migraciones futuras.
    // Ejemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE pending_ventas ADD COLUMN updated_at TEXT');
    // }
    // if (oldVersion < 3) {
    //   await db.execute('CREATE TABLE ...');
    // }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
