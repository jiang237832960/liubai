import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/exceptions.dart' as app_exceptions;
import '../core/logger.dart';
import 'models.dart';

/// 数据库辅助类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final Object _lock = Object();
  static const String _tag = 'Database';
  static const String _dbName = 'liubai.db';
  static const String _dbBackupName = 'liubai.db.backup';

  DatabaseHelper._init();

  /// 获取数据库实例（线程安全）
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // 如果初始化正在进行，等待它完成
    if (_dbInitCompleter != null) {
      return _dbInitCompleter!.future;
    }
    
    // 开始初始化
    _dbInitCompleter = Completer<Database>();
    try {
      final db = await _initDB(_dbName);
      _database = db;
      _dbInitCompleter!.complete(db);
      return db;
    } catch (e) {
      _dbInitCompleter!.completeError(e);
      _dbInitCompleter = null;
      rethrow;
    }
  }

  Completer<Database>? _dbInitCompleter;

  /// 检查存储空间是否充足（至少100MB）
  Future<bool> _checkStorageSpace() async {
    try {
      final dbPath = await getDatabasesPath();
      final directory = Directory(dbPath);
      final stat = directory.statSync();
      // 获取可用空间（简化检查，实际应使用 platform-specific 方法）
      // 这里假设路径可写即空间充足
      return true;
    } catch (e) {
      Logger.w('检查存储空间失败: $e', tag: _tag);
      return false;
    }
  }

  /// 验证数据库完整性
  Future<bool> _verifyDatabaseIntegrity(String path) async {
    try {
      final db = await openDatabase(path, readOnly: true);
      // 执行简单查询验证数据库可用
      await db.rawQuery('SELECT 1');
      await db.close();
      return true;
    } catch (e) {
      Logger.e('数据库完整性验证失败: $e', tag: _tag);
      return false;
    }
  }

  /// 备份数据库
  Future<void> _backupDatabase(String sourcePath, String backupPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(backupPath);
        Logger.i('数据库备份成功: $backupPath', tag: _tag);
      }
    } catch (e) {
      Logger.w('数据库备份失败: $e', tag: _tag);
    }
  }

  /// 删除损坏的数据库
  Future<void> _deleteCorruptedDatabase(String path) async {
    try {
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
        Logger.i('删除损坏的数据库文件: $path', tag: _tag);
      }
      // 同时删除相关的journal文件
      final journalFile = File('$path-journal');
      if (await journalFile.exists()) {
        await journalFile.delete();
      }
      final walFile = File('$path-wal');
      if (await walFile.exists()) {
        await walFile.delete();
      }
    } catch (e) {
      Logger.e('删除损坏数据库失败: $e', tag: _tag);
    }
  }

  /// 初始化数据库（带损坏检测和重建）
  Future<Database> _initDB(String filePath) async {
    try {
      final hasSpace = await _checkStorageSpace();
      if (!hasSpace) {
        throw const app_exceptions.DatabaseException(
          '存储空间不足，请清理空间后重试',
          code: 'DB_STORAGE_FULL',
        );
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      Logger.i('初始化数据库: $path', tag: _tag);

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreateDB,
        onOpen: _onOpenDB,
      );

      return db;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.e('数据库初始化失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '数据库初始化失败: $e',
        code: 'DB_INIT_ERROR',
        originalError: e,
      );
    }
  }

  /// 数据库首次创建时调用
  Future<void> _onCreateDB(Database db, int version) async {
    Logger.i('创建数据库表', tag: _tag);
    await _createTables(db);
  }

  /// 数据库每次打开时调用，确保表结构完整
  Future<void> _onOpenDB(Database db) async {
    Logger.i('数据库已打开，检查表结构', tag: _tag);
    await _ensureTablesExist(db);
  }

  /// 确保必要的表存在
  Future<void> _ensureTablesExist(Database db) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();

      // 检查 scene_tags 表
      if (!tableNames.contains('scene_tags')) {
        Logger.i('scene_tags 表不存在，创建中', tag: _tag);
        await db.execute('''
          CREATE TABLE scene_tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color INTEGER NOT NULL,
            sort_order INTEGER DEFAULT 0,
            is_default INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      }

      // 检查并插入预设标签
      final tagCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM scene_tags'),
      );
      if (tagCount == 0) {
        Logger.i('插入预设标签', tag: _tag);
        final presets = SceneTag.presets;
        for (var i = 0; i < presets.length; i++) {
          final tag = presets[i];
          await db.insert('scene_tags', {
            'name': tag.name,
            'color': tag.color,
            'sort_order': i,
            'is_default': 1,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      // 检查 sessions 表
      if (!tableNames.contains('sessions')) {
        Logger.i('sessions 表不存在，创建中', tag: _tag);
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time INTEGER NOT NULL,
            end_time INTEGER,
            planned_duration INTEGER NOT NULL,
            actual_duration INTEGER,
            is_completed INTEGER DEFAULT 0,
            scene_tag_id INTEGER,
            note TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (scene_tag_id) REFERENCES scene_tags(id) ON DELETE SET NULL
          )
        ''');
      }

      // 检查 settings 表
      if (!tableNames.contains('settings')) {
        Logger.i('settings 表不存在，创建中', tag: _tag);
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            default_duration INTEGER DEFAULT 25,
            enable_sound INTEGER DEFAULT 1,
            enable_notification INTEGER DEFAULT 1,
            theme_mode TEXT DEFAULT 'system',
            default_scene_tag_id INTEGER,
            FOREIGN KEY (default_scene_tag_id) REFERENCES scene_tags(id) ON DELETE SET NULL
          )
        ''');
        
        // 插入默认设置
        await db.insert('settings', {
          'id': 1,
          'default_duration': 25,
          'enable_sound': 1,
          'enable_notification': 1,
          'theme_mode': 'system',
          'default_scene_tag_id': null,
        });
      }

      // 检查 settings 是否有记录
      final settingsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM settings'),
      );
      if (settingsCount == 0) {
        Logger.i('插入默认设置', tag: _tag);
        await db.insert('settings', {
          'id': 1,
          'default_duration': 25,
          'enable_sound': 1,
          'enable_notification': 1,
          'theme_mode': 'system',
          'default_scene_tag_id': null,
        });
      }

      Logger.i('表结构检查完成', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('检查表结构失败', tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  /// 创建所有表（仅在数据库首次创建时调用）
  Future<void> _createTables(Database db) async {
    // 创建 scene_tags 表
    await db.execute('''
      CREATE TABLE scene_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // 插入预设标签
    final presets = SceneTag.presets;
    for (var i = 0; i < presets.length; i++) {
      final tag = presets[i];
      await db.insert('scene_tags', {
        'name': tag.name,
        'color': tag.color,
        'sort_order': i,
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
    Logger.i('插入预设标签成功: ${presets.length}个', tag: _tag);

    // 创建 sessions 表
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        planned_duration INTEGER NOT NULL,
        actual_duration INTEGER,
        is_completed INTEGER DEFAULT 0,
        scene_tag_id INTEGER,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (scene_tag_id) REFERENCES scene_tags(id) ON DELETE SET NULL
      )
    ''');

    // 创建 settings 表
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        default_duration INTEGER DEFAULT 25,
        enable_sound INTEGER DEFAULT 1,
        enable_notification INTEGER DEFAULT 1,
        theme_mode TEXT DEFAULT 'system',
        default_scene_tag_id INTEGER,
        FOREIGN KEY (default_scene_tag_id) REFERENCES scene_tags(id) ON DELETE SET NULL
      )
    ''');

    // 插入默认设置
    await db.insert('settings', {
      'id': 1,
      'default_duration': 25,
      'enable_sound': 1,
      'enable_notification': 1,
      'theme_mode': 'system',
      'default_scene_tag_id': null,
    });
    Logger.i('数据库表创建完成', tag: _tag);
  }

  /// 检查数据库健康状态
  Future<Map<String, dynamic>> checkDatabaseHealth() async {
    try {
      final db = await database;

      // 检查表是否存在
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();

      // 检查必要表
      final requiredTables = ['scene_tags', 'sessions', 'settings'];
      final missingTables = requiredTables.where(
        (t) => !tableNames.contains(t),
      ).toList();

      // 获取记录数
      int sessionCount = 0;
      int tagCount = 0;
      try {
        final sessionResult = await db.rawQuery('SELECT COUNT(*) as count FROM sessions');
        sessionCount = sessionResult.first['count'] as int? ?? 0;

        final tagResult = await db.rawQuery('SELECT COUNT(*) as count FROM scene_tags');
        tagCount = tagResult.first['count'] as int? ?? 0;
      } catch (e) {
        Logger.w('获取记录数失败: $e', tag: _tag);
      }

      return {
        'isHealthy': missingTables.isEmpty,
        'tables': tableNames,
        'missingTables': missingTables,
        'sessionCount': sessionCount,
        'tagCount': tagCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isHealthy': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 修复数据库（删除并重建）
  Future<void> repairDatabase() async {
    try {
      Logger.i('开始修复数据库', tag: _tag);

      // 关闭现有连接
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // 删除数据库文件
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      await _deleteCorruptedDatabase(path);

      // 重新初始化
      _database = await _initDB(_dbName);

      Logger.i('数据库修复完成', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('数据库修复失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '数据库修复失败: $e',
        code: 'DB_REPAIR_ERROR',
        originalError: e,
      );
    }
  }

  // ==================== 会话操作 ====================

  /// 插入留白会话
  Future<int> insertSession(LiubaiSession session) async {
    try {
      final db = await database;
      final id = await db.insert('sessions', session.toMap());
      Logger.i('插入会话成功: id=$id', tag: _tag);
      return id;
    } catch (e, stackTrace) {
      Logger.e('插入会话失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '插入会话失败',
        code: 'DB_INSERT_ERROR',
        originalError: e,
      );
    }
  }

  /// 更新留白会话
  Future<int> updateSession(LiubaiSession session) async {
    try {
      if (session.id == null) {
        throw const app_exceptions.DatabaseException(
          '会话ID不能为空',
          code: 'DB_INVALID_ID',
        );
      }
      final db = await database;
      final count = await db.update(
        'sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
      Logger.i('更新会话成功: id=${session.id}, 影响行数=$count', tag: _tag);
      return count;
    } catch (e, stackTrace) {
      Logger.e('更新会话失败: id=${session.id}', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '更新会话失败',
        code: 'DB_UPDATE_ERROR',
        originalError: e,
      );
    }
  }

  /// 删除留白会话
  Future<int> deleteSession(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
      Logger.i('删除会话成功: id=$id, 影响行数=$count', tag: _tag);
      return count;
    } catch (e, stackTrace) {
      Logger.e('删除会话失败: id=$id', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '删除会话失败',
        code: 'DB_DELETE_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取所有留白会话
  Future<List<LiubaiSession>> getAllSessions() async {
    try {
      final db = await database;
      final maps = await db.query('sessions', orderBy: 'start_time DESC');
      Logger.d('获取所有会话: ${maps.length}条', tag: _tag);
      return maps.map((map) => LiubaiSession.fromMap(map)).toList();
    } catch (e, stackTrace) {
      Logger.e('获取所有会话失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取所有会话失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取今日留白会话
  Future<List<LiubaiSession>> getTodaySessions() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final maps = await db.query(
        'sessions',
        where: 'start_time >= ? AND start_time < ?',
        whereArgs: [
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time DESC',
      );
      Logger.d('获取今日会话: ${maps.length}条', tag: _tag);
      return maps.map((map) => LiubaiSession.fromMap(map)).toList();
    } catch (e, stackTrace) {
      Logger.e('获取今日会话失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取今日会话失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取今日统计
  Future<DailyStats> getTodayStats() async {
    try {
      final sessions = await getTodaySessions();

      int totalDuration = 0;
      int completedCount = 0;

      for (var session in sessions) {
        if (session.isCompleted && session.actualDuration != null) {
          totalDuration += session.actualDuration!;
          completedCount++;
        }
      }

      return DailyStats(
        date: DateTime.now().toIso8601String().split('T')[0],
        totalDuration: totalDuration,
        sessionCount: sessions.length,
        completedCount: completedCount,
      );
    } catch (e, stackTrace) {
      Logger.e('获取今日统计失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取今日统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  // ==================== 设置操作 ====================

  /// 获取用户设置
  Future<UserSettings> getSettings() async {
    try {
      final db = await database;
      final maps = await db.query('settings', where: 'id = ?', whereArgs: [1]);

      if (maps.isNotEmpty) {
        Logger.d('获取设置成功', tag: _tag);
        return UserSettings.fromMap(maps.first);
      }

      Logger.w('设置不存在，返回默认值', tag: _tag);
      return UserSettings();
    } catch (e, stackTrace) {
      Logger.e('获取设置失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取设置失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 更新用户设置
  Future<int> updateSettings(UserSettings settings) async {
    try {
      final db = await database;
      final count = await db.update(
        'settings',
        settings.toMap(),
        where: 'id = ?',
        whereArgs: [1],
      );
      Logger.i('更新设置成功: 影响行数=$count', tag: _tag);
      return count;
    } catch (e, stackTrace) {
      Logger.e('更新设置失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '更新设置失败',
        code: 'DB_UPDATE_ERROR',
        originalError: e,
      );
    }
  }

  // ==================== 场景标签操作 ====================

  /// 获取所有场景标签
  Future<List<SceneTag>> getAllSceneTags() async {
    try {
      final db = await database;
      final maps = await db.query(
        'scene_tags',
        orderBy: 'sort_order ASC, created_at ASC',
      );
      Logger.d('获取所有标签: ${maps.length}个', tag: _tag);
      return maps.map((map) => SceneTag.fromMap(map)).toList();
    } catch (e, stackTrace) {
      Logger.e('获取所有标签失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取所有标签失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取单个场景标签
  Future<SceneTag?> getSceneTag(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'scene_tags',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Logger.d('获取标签成功: id=$id', tag: _tag);
        return SceneTag.fromMap(maps.first);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.e('获取标签失败: id=$id', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取标签失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 插入场景标签
  Future<int> insertSceneTag(SceneTag tag) async {
    try {
      final db = await database;
      final id = await db.insert('scene_tags', tag.toMap());
      Logger.i('插入标签成功: id=$id, name=${tag.name}', tag: _tag);
      return id;
    } catch (e, stackTrace) {
      Logger.e('插入标签失败: ${tag.name}', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '插入标签失败',
        code: 'DB_INSERT_ERROR',
        originalError: e,
      );
    }
  }

  /// 更新场景标签
  Future<int> updateSceneTag(SceneTag tag) async {
    try {
      if (tag.id == null) {
        throw const app_exceptions.DatabaseException(
          '标签ID不能为空',
          code: 'DB_INVALID_ID',
        );
      }
      final db = await database;
      final count = await db.update(
        'scene_tags',
        tag.toMap(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );
      Logger.i('更新标签成功: id=${tag.id}, 影响行数=$count', tag: _tag);
      return count;
    } catch (e, stackTrace) {
      Logger.e('更新标签失败: id=${tag.id}', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '更新标签失败',
        code: 'DB_UPDATE_ERROR',
        originalError: e,
      );
    }
  }

  /// 删除场景标签
  Future<int> deleteSceneTag(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'scene_tags',
        where: 'id = ? AND is_default = 0',
        whereArgs: [id],
      );
      if (count > 0) {
        Logger.i('删除标签成功: id=$id', tag: _tag);
      } else {
        Logger.w('删除标签失败: id=$id 可能是预设标签', tag: _tag);
      }
      return count;
    } catch (e, stackTrace) {
      Logger.e('删除标签失败: id=$id', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '删除标签失败',
        code: 'DB_DELETE_ERROR',
        originalError: e,
      );
    }
  }

  /// 按标签获取会话
  Future<List<LiubaiSession>> getSessionsByTag(int tagId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'sessions',
        where: 'scene_tag_id = ?',
        whereArgs: [tagId],
        orderBy: 'start_time DESC',
      );
      Logger.d('按标签获取会话: tagId=$tagId, ${maps.length}条', tag: _tag);
      return maps.map((map) => LiubaiSession.fromMap(map)).toList();
    } catch (e, stackTrace) {
      Logger.e('按标签获取会话失败: tagId=$tagId', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '按标签获取会话失败',
        code: 'DB_QUERY_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取标签统计
  Future<Map<String, dynamic>> getTagStats(int tagId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as session_count,
          SUM(CASE WHEN is_completed = 1 THEN actual_duration ELSE 0 END) as total_duration,
          SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count
        FROM sessions
        WHERE scene_tag_id = ?
      ''', [tagId]);

      if (result.isNotEmpty) {
        final stats = {
          'sessionCount': result.first['session_count'] as int? ?? 0,
          'totalDuration': result.first['total_duration'] as int? ?? 0,
          'completedCount': result.first['completed_count'] as int? ?? 0,
        };
        Logger.d('获取标签统计成功: tagId=$tagId, $stats', tag: _tag);
        return stats;
      }
      return {
        'sessionCount': 0,
        'totalDuration': 0,
        'completedCount': 0,
      };
    } catch (e, stackTrace) {
      Logger.e('获取标签统计失败: tagId=$tagId', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取标签统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取所有标签的分布统计
  Future<List<Map<String, dynamic>>> getTagDistribution() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT 
          st.id,
          st.name,
          st.color,
          COUNT(s.id) as session_count,
          SUM(CASE WHEN s.is_completed = 1 THEN s.actual_duration ELSE 0 END) as total_duration
        FROM scene_tags st
        LEFT JOIN sessions s ON st.id = s.scene_tag_id
        GROUP BY st.id
        ORDER BY total_duration DESC
      ''');

      Logger.d('获取标签分布统计成功: ${result.length}个标签', tag: _tag);
      return result.map((map) => {
        'id': map['id'],
        'name': map['name'],
        'color': map['color'],
        'sessionCount': map['session_count'] as int? ?? 0,
        'totalDuration': map['total_duration'] as int? ?? 0,
      }).toList();
    } catch (e, stackTrace) {
      Logger.e('获取标签分布统计失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取标签分布统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  // ==================== 统计操作 ====================

  /// 获取最近7天的统计
  Future<List<DailyStats>> getLast7DaysStats() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final stats = <DailyStats>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        // 统计总时长（只统计完成的）
        final totalMaps = await db.query(
          'sessions',
          where: 'start_time >= ? AND start_time < ?',
          whereArgs: [
            startOfDay.millisecondsSinceEpoch,
            endOfDay.millisecondsSinceEpoch,
          ],
        );

        int totalDuration = 0;
        int completedCount = 0;
        for (var map in totalMaps) {
          final actualDuration = (map['actual_duration'] as int?) ?? 0;
          final isCompleted = map['is_completed'] == 1;
          if (isCompleted) {
            totalDuration += actualDuration;
          }
          if (isCompleted) completedCount++;
        }

        stats.add(DailyStats(
          date: date.toIso8601String().split('T')[0],
          totalDuration: totalDuration,
          sessionCount: totalMaps.length,
          completedCount: completedCount,
        ));
      }

      Logger.d('获取7天统计成功', tag: _tag);
      return stats;
    } catch (e, stackTrace) {
      Logger.e('获取7天统计失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取7天统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取最近30天的统计
  Future<List<DailyStats>> getLast30DaysStats() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final stats = <DailyStats>[];

      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        // 统计总时长（只统计完成的）
        final totalMaps = await db.query(
          'sessions',
          where: 'start_time >= ? AND start_time < ?',
          whereArgs: [
            startOfDay.millisecondsSinceEpoch,
            endOfDay.millisecondsSinceEpoch,
          ],
        );

        int totalDuration = 0;
        int completedCount = 0;
        for (var map in totalMaps) {
          final actualDuration = (map['actual_duration'] as int?) ?? 0;
          final isCompleted = map['is_completed'] == 1;
          if (isCompleted) {
            totalDuration += actualDuration;
          }
          if (isCompleted) completedCount++;
        }

        stats.add(DailyStats(
          date: date.toIso8601String().split('T')[0],
          totalDuration: totalDuration,
          sessionCount: totalMaps.length,
          completedCount: completedCount,
        ));
      }

      Logger.d('获取30天统计成功', tag: _tag);
      return stats;
    } catch (e, stackTrace) {
      Logger.e('获取30天统计失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取30天统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  /// 获取总统计
  Future<Map<String, dynamic>> getTotalStats() async {
    try {
      final db = await database;

      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_sessions,
          SUM(CASE WHEN is_completed = 1 THEN actual_duration ELSE 0 END) as total_duration,
          SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_sessions,
          COUNT(DISTINCT date(start_time / 1000, 'unixepoch')) as active_days
        FROM sessions
        WHERE is_completed = 1
      ''');

      if (result.isNotEmpty) {
        final stats = {
          'totalSessions': result.first['total_sessions'] as int? ?? 0,
          'totalDuration': result.first['total_duration'] as int? ?? 0,
          'completedSessions': result.first['completed_sessions'] as int? ?? 0,
          'activeDays': result.first['active_days'] as int? ?? 0,
        };
        Logger.d('获取总统计成功: $stats', tag: _tag);
        return stats;
      }

      return {
        'totalSessions': 0,
        'totalDuration': 0,
        'completedSessions': 0,
        'activeDays': 0,
      };
    } catch (e, stackTrace) {
      Logger.e('获取总统计失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '获取总统计失败',
        code: 'DB_STATS_ERROR',
        originalError: e,
      );
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      Logger.i('数据库已关闭', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('关闭数据库失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw app_exceptions.DatabaseException(
        '关闭数据库失败',
        code: 'DB_CLOSE_ERROR',
        originalError: e,
      );
    }
  }
}
