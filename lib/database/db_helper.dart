import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DBHelper {
  static Database? _db;
  static const String DB_NAME = 'supermercado.db';
  static const String TABLE = 'products';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, DB_NAME);

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $TABLE (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL
        )
      ''');
    });
  }

  static Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(TABLE, product.toMap());
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(TABLE);
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  static Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(TABLE, product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(TABLE, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(TABLE);
  }
}
