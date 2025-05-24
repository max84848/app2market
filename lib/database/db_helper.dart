import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/compra.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app2market.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE compras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT,
        total REAL,
        productos TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE presupuesto (
        id INTEGER PRIMARY KEY,
        cantidad REAL
      )
    ''');

    // Insertar presupuesto inicial
    await db.insert('presupuesto', {'id': 1, 'cantidad': 500.0}); // 💰 Presupuesto inicial
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE presupuesto (
          id INTEGER PRIMARY KEY,
          cantidad REAL
        )
      ''');

      await db.insert('presupuesto', {'id': 1, 'cantidad': 500.0});
    }
  }

  Future<void> insertarCompra(Compra compra) async {
    final db = await database;
    await db.insert(
      'compras',
      compra.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Compra>> obtenerHistorial() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) => Compra.fromMap(maps[i]));
  }

  Future<void> actualizarCompra(Compra compra) async {
    final db = await database;
    await db.update(
      'compras',
      compra.toMap(),
      where: 'id = ?',
      whereArgs: [compra.id],
    );
  }

  Future<void> eliminarCompra(int id) async {
    final db = await database;
    await db.delete(
      'compras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔽 Nuevo: Obtener presupuesto actual
  Future<double> obtenerPresupuesto() async {
    final db = await database;
    final result = await db.query('presupuesto', where: 'id = 1');
    if (result.isNotEmpty) {
      return result.first['cantidad'] as double;
    }
    return 0.0;
  }

  // 🔄 Nuevo: Actualizar presupuesto manualmente
  Future<void> actualizarPresupuesto(double nuevoMonto) async {
    final db = await database;
    await db.update(
      'presupuesto',
      {'cantidad': nuevoMonto},
      where: 'id = 1',
    );
  }

  // ➖ Nuevo: Descontar gasto del presupuesto
  Future<void> descontarDelPresupuesto(double gasto) async {
    final actual = await obtenerPresupuesto();
    final nuevo = actual - gasto;
    await actualizarPresupuesto(nuevo);
  }
}
