import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
        );
      },
    );
  }

  static Future<int> signup(String user, String pass) async {
    var dbClient = await db;
    return await dbClient.insert('users', {'username': user, 'password': pass});
  }

  static Future<Map<String, dynamic>?> login(String user, String pass) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    var dbClient = await db;
    return await dbClient.query('users');
  }

  static Future<int> deleteUser(int id) async {
    var dbClient = await db;
    return await dbClient.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
