import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart' as record;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ReflectAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final record.AudioRecorder _recorder = record.AudioRecorder();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentlyPlayingUrl;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingUrl => _currentlyPlayingUrl;

  void init({required void Function() onPlayerStateChanged}) {
    _audioPlayer.onPlayerStateChanged.listen((_) => onPlayerStateChanged());
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _recorder.dispose();
  }

  Future<String> getCurrentRecordingPath() async {
    return _currentRecordingPath ?? await _getTempFilePath();
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    _currentRecordingPath = path.join(dir.path, 'journal.wav');
    return _currentRecordingPath!;
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.storage].request();
  }

  Future<void> startRecording() async {
    await _requestPermissions();
    final filePath = await _getTempFilePath();
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    _isRecording = true;
    try {
      await _recorder.start(
        const record.RecordConfig(
          encoder: record.AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    try {
      final filePath = await _recorder.stop();
      _isRecording = false;
      if (filePath == null || !await File(filePath).exists()) {
        throw Exception("Recording file not found");
      }
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> playAudio(String? audioPath) async {
    if (audioPath == null) return;

    if (_isPlaying && _currentlyPlayingUrl == audioPath) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentlyPlayingUrl = null;
      return;
    }

    if (_isPlaying) await _audioPlayer.stop();

    _isPlaying = true;
    _currentlyPlayingUrl = audioPath;

    try {
      if (audioPath.startsWith('http')) {
        await _audioPlayer.play(UrlSource(audioPath));
      } else {
        await _audioPlayer.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      _isPlaying = false;
      _currentlyPlayingUrl = null;
      rethrow;
    }
  }
}
