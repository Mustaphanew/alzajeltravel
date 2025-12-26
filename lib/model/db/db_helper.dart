import 'package:sqlite3/common.dart';
import 'sqlite_platform.dart';
import 'tables.dart' as t;

class DbHelper {
  DbHelper._internal();
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;

  CommonDatabase? _db;

  Future<CommonDatabase> createDatabase() async {
    if (_db != null) return _db!;

    try {
      final db = await openAppDatabase('db.db');

      // إنشاء الجداول (يفضل أن تكون IF NOT EXISTS داخل tables.dart)
      db.execute(t.notifications);
      db.execute(t.tmp);

      _db = db;
      return db;
    } catch (err) {
      await closeDatabase();
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    try {
      _db?.close();
    } catch (_) {}
    _db = null;
  }

  // تحويل ResultSet إلى List<Map> مثل sqflite
  List<Map<String, Object?>> _rows(ResultSet rs) {
    return rs.map((r) => Map<String, Object?>.from(r)).toList();
  }

  Future<String> maxDate({required bool created_at, required String table}) async {
    final db = await createDatabase();
    final column = created_at ? "created_at" : "updated_at";

    final rs = db.select(
      "SELECT $column FROM $table "
      "WHERE strftime('%s', $column) = (SELECT max(strftime('%s', $column)) FROM $table);",
    );

    if (rs.isNotEmpty) {
      return (rs.first[column]?.toString() ?? "").replaceAll(" ", "T");
    }
    return "2010-01-01T01:01:01";
  }

  // CRUD ____________________________________________________ where 1

  /// تنفيذ SELECT عام (بديل rawQuery)
  Future<List<Map<String, Object?>>> cmd({
    required String cmd,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();
    final sql = cmd.trim().endsWith(';') ? cmd.trim() : '${cmd.trim()};';
    final rs = db.select(sql, params);
    return _rows(rs);
  }

  Future<List<Map<String, Object?>>> select({
    required String column,
    required String table,
    required String condition,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();

    if (condition.endsWith("and") || condition.endsWith("and ")) {
      condition = "$condition 1";
    }
    if (condition.startsWith("and") || condition.startsWith(" and")) {
      condition = "1 $condition";
    }

    final rs = db.select("SELECT $column FROM $table WHERE $condition;", params);
    return _rows(rs);
  }

  /// Insert (بديل db.insert في sqflite)
  /// يرجع lastInsertRowId (يناسب الجداول AUTOINCREMENT)
  Future<int> insert({
    required String table,
    required Map<String, Object?> obj,
  }) async {
    final db = await createDatabase();

    final cols = obj.keys.toList();
    final placeholders = List.filled(cols.length, '?').join(', ');
    final sql = "INSERT INTO $table (${cols.join(', ')}) VALUES ($placeholders);";

    final stmt = db.prepare(sql);
    try {
      stmt.execute(cols.map((c) => obj[c]).toList());
      return db.lastInsertRowId;
    } finally {
      stmt.close();
    }
  }

  /// Update (بديل db.update)
  /// ملاحظة: حتى نحافظ على نفس توقيعك (condition string)
  /// إذا تحتاج params للـ condition استخدم conditionParams
  Future<int> update({
    required String table,
    required Map<String, Object?> obj,
    required String condition,
    List<Object?> conditionParams = const [],
  }) async {
    final db = await createDatabase();

    final cols = obj.keys.toList();
    final setPart = cols.map((c) => "$c = ?").join(', ');
    final sql = "UPDATE $table SET $setPart WHERE $condition;";

    final stmt = db.prepare(sql);
    try {
      stmt.execute([
        ...cols.map((c) => obj[c]),
        ...conditionParams,
      ]);
      return db.updatedRows; // عدد الصفوف المتأثرة
    } finally {
      stmt.close();
    }
  }

  Future<int> delete({
    required String table,
    required String condition,
    List<Object?> conditionParams = const [],
  }) async {
    final db = await createDatabase();

    final stmt = db.prepare("DELETE FROM $table WHERE $condition;");
    try {
      stmt.execute(conditionParams);
      return db.updatedRows;
    } finally {
      stmt.close();
    }
  }

  // end CRUD ______________________________________________________________________

  Future<int> countRows({
    required String table,
    required String condition,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();

    final rs = db.select(
      'SELECT COUNT(*) as c FROM $table WHERE $condition;',
      params,
    );
    if (rs.isEmpty) return 0;
    return (rs.first['c'] as int?) ?? 0;
  }
}
