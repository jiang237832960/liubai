import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../core/logger.dart';
import '../data/models/scene_template.dart';

class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  static const String _tag = 'TemplateService';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/templates.db';
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE templates (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            cycles INTEGER NOT NULL DEFAULT 1,
            work_duration_ms INTEGER NOT NULL,
            rest_duration_ms INTEGER NOT NULL,
            audio_tracks TEXT,
            segments TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<SceneTemplate>> getAllTemplates() async {
    try {
      final db = await database;
      final maps = await db.query('templates', orderBy: 'created_at DESC');
      return maps.map((map) => _templateFromMap(map)).toList();
    } catch (e, stackTrace) {
      Logger.e('获取模板列表失败', tag: _tag, error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<SceneTemplate?> getTemplateById(String id) async {
    try {
      final db = await database;
      final maps = await db.query('templates', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return _templateFromMap(maps.first);
    } catch (e, stackTrace) {
      Logger.e('获取模板失败: $id', tag: _tag, error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveTemplate(SceneTemplate template) async {
    try {
      final db = await database;
      final map = _templateToMap(template);
      
      await db.insert(
        'templates',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      Logger.i('保存模板成功: ${template.name}', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('保存模板失败', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      final db = await database;
      await db.delete('templates', where: 'id = ?', whereArgs: [id]);
      Logger.i('删除模板: $id', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('删除模板失败: $id', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Map<String, dynamic> _templateToMap(SceneTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'emoji': template.emoji,
      'cycles': template.cycles,
      'work_duration_ms': template.workDurationMs,
      'rest_duration_ms': template.restDurationMs,
      'audio_tracks': jsonEncode(template.audioTracks.map((t) => t.toMap()).toList()),
      'segments': jsonEncode(template.segments.map((s) => s.toMap()).toList()),
      'created_at': template.createdAt.millisecondsSinceEpoch,
      'updated_at': template.updatedAt.millisecondsSinceEpoch,
    };
  }

  SceneTemplate _templateFromMap(Map<String, dynamic> map) {
    final audioTracksJson = map['audio_tracks'] as String?;
    final segmentsJson = map['segments'] as String?;

    List<AudioTrack> audioTracks = [];
    List<TimeSegment> segments = [];

    if (audioTracksJson != null && audioTracksJson.isNotEmpty) {
      final audioTracksList = jsonDecode(audioTracksJson) as List;
      audioTracks = audioTracksList
          .map((t) => AudioTrack.fromMap(t as Map<String, dynamic>))
          .toList();
    }

    if (segmentsJson != null && segmentsJson.isNotEmpty) {
      final segmentsList = jsonDecode(segmentsJson) as List;
      segments = segmentsList
          .map((s) => TimeSegment.fromMap(s as Map<String, dynamic>))
          .toList();
    }

    return SceneTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      cycles: map['cycles'] as int,
      workDurationMs: map['work_duration_ms'] as int,
      restDurationMs: map['rest_duration_ms'] as int,
      audioTracks: audioTracks,
      segments: segments,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }
}
