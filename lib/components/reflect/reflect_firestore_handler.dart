import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'reflect_audio_handler.dart';

class ReflectFirestoreHandler {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ReflectAudioHandler audioHandler;
  List<Map<String, dynamic>> messages = [];
  String? lastStage;
  int currentStreak = 0;
  DateTime? lastActiveDate;

  ReflectFirestoreHandler({required this.audioHandler});

  Future<void> initialize({required String userId}) async {
    await _loadMessages(userId);
    _addDateHeaders();
    await _calculateCurrentStreak(userId);
  }

  /// Store daily notification message, prevent duplicates for today
  Future<void> storeNotificationMessage(
    String messageText,
    void Function(void Function()) setState,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // Check if a notification with same messageText exists today
    final existing =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('mergedMessages')
            .where('is_notification', isEqualTo: true)
            .where('message', isEqualTo: messageText)
            .get();

    bool alreadySentToday = existing.docs.any((doc) {
      final ts = doc['timestamp'];
      final date = ts is Timestamp ? ts.toDate() : DateTime.parse(ts);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      return dateStr == todayStr;
    });

    if (!alreadySentToday) {
      final msg = {
        'type': 'daily-task',
        'message': messageText,
        'timestamp': now,
        'is_notification': true,
        'id': 'notification-${now.millisecondsSinceEpoch}',
      };

      await _storeMessage(msg);
      _addDateHeaders();
      setState(() {});
    }
  }

  Future<void> _calculateCurrentStreak(String userId) async {
    try {
      final snapshot =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('mergedMessages')
              .orderBy('timestamp', descending: true)
              .get();

      final allMessages = snapshot.docs.map((doc) => doc.data()).toList();

      final activeDates = <DateTime>[];
      final dateSet = <String>{};

      for (final msg in allMessages) {
        final timestamp =
            msg['timestamp'] is Timestamp
                ? (msg['timestamp'] as Timestamp).toDate()
                : DateTime.parse(msg['timestamp']);
        final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

        if (!dateSet.contains(dateStr)) {
          dateSet.add(dateStr);
          activeDates.add(
            DateTime(timestamp.year, timestamp.month, timestamp.day),
          );
        }
      }

      currentStreak = 0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (activeDates.isEmpty) {
        lastActiveDate = null;
        return;
      }

      if (activeDates.first.isAtSameMomentAs(today)) {
        currentStreak = 1;
        DateTime previousDate = today.subtract(const Duration(days: 1));

        for (int i = 1; i < activeDates.length; i++) {
          if (activeDates[i].isAtSameMomentAs(previousDate)) {
            currentStreak++;
            previousDate = previousDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }

      lastActiveDate = activeDates.first;
    } catch (e) {
      if (kDebugMode) print('Error calculating streak: $e');
      currentStreak = 0;
      lastActiveDate = null;
    }
  }

  Future<void> _loadMessages(String userId) async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('mergedMessages')
            .orderBy('timestamp')
            .get();

    messages = snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();

    for (final msg in messages.reversed) {
      if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
        lastStage = msg['stage'];
        break;
      }
    }
  }

  void _addDateHeaders() {
    if (messages.isEmpty) return;

    final Map<String, List<Map<String, dynamic>>> groupedMessages = {};
    for (final message in messages) {
      final date = DateFormat('yyyy-MM-dd').format(
        message['timestamp'] is Timestamp
            ? (message['timestamp'] as Timestamp).toDate()
            : DateTime.parse(message['timestamp']),
      );
      groupedMessages.putIfAbsent(date, () => []).add(message);
    }

    final List<Map<String, dynamic>> newMessages = [];
    groupedMessages.forEach((date, msgs) {
      final firstMsg = msgs.first;
      final timestamp =
          firstMsg['timestamp'] is Timestamp
              ? (firstMsg['timestamp'] as Timestamp).toDate()
              : DateTime.parse(firstMsg['timestamp']);

      newMessages.add({
        'type': 'date-header',
        'date': DateTime(timestamp.year, timestamp.month, timestamp.day),
      });

      newMessages.addAll(msgs);
    });

    messages = newMessages;
  }

  String getReplyToText(Map<String, dynamic> message) {
    return message['question'] ??
        message['response'] ??
        message['user'] ??
        message['message'] ??
        "";
  }

  Future<void> sendEntry(
    String entry,
    Map<String, dynamic>? selectedMessage,
    void Function(void Function()) setState,
  ) async {
    if (entry.trim().isEmpty) return;

    final now = DateTime.now();
    const url = "https://ret-vrn.onrender.com/merged";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": entry,
          "last_stage": lastStage ?? "",
          "reply_to":
              selectedMessage != null ? getReplyToText(selectedMessage) : "",
          "is_spiral_reply":
              selectedMessage != null && selectedMessage['type'] == 'spiral',
          "user_id": FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final base = {
          'user': entry,
          'timestamp': now,
          if (selectedMessage != null) 'reply_to_id': selectedMessage['id'],
          if (selectedMessage != null)
            'reply_to': getReplyToText(selectedMessage),
        };

        await _calculateCurrentStreak(FirebaseAuth.instance.currentUser!.uid);

        if (data['mode'] == 'chat') {
          final msg = {
            ...base,
            'type': 'chat',
            'response': data['response'] ?? '',
            'audio_url': data['audio_url'] ?? '',
            'streak': currentStreak,
            if (data['rewards'] != null) 'rewards': data['rewards'],
            if (data['message_rewards'] != null)
              'message_rewards': data['message_rewards'],
          };
          await _storeMessage(msg);
        } else if (data['mode'] == 'spiral') {
          final newStage = data['stage'] ?? '';
          lastStage = newStage;

          final msg = {
            ...base,
            'type': 'spiral',
            'stage': newStage,
            'question': data['question'] ?? '',
            'evolution': data['evolution'] ?? '',
            'growth': data['gamified']?['gamified_prompt'] ?? '',
            'audio_url': data['audio_url'] ?? '',
            'confidence': data['confidence'] ?? 0,
            'reason': data['reason'] ?? '',
            'streak': currentStreak,
            if (data['xp_gained'] != null) 'xp_gained': data['xp_gained'],
            if (data['badges_earned'] != null)
              'badges_earned': data['badges_earned'],
            if (data['streak_rewards'] != null)
              'streak_rewards': data['streak_rewards'],
            if (data['message_rewards'] != null)
              'message_rewards': data['message_rewards'],
            if (data['note'] != null) 'note': data['note'],
          };
          await _storeMessage(msg);
        }
        setState(() {});
      }
    } catch (e) {
      messages.add({
        'type': 'error',
        'message': 'Error: ${e.toString()}',
        'timestamp': DateTime.now(),
      });
      setState(() {});
    }
  }

  Future<void> processVoiceMessage(
    Map<String, dynamic>? selectedMessage,
    void Function(void Function()) setState,
  ) async {
    try {
      const uri = "https://ret-vrn.onrender.com/reflect_transcription";
      final request = http.MultipartRequest('POST', Uri.parse(uri));

      request.fields['last_stage'] = lastStage ?? '';
      request.fields['reply_to'] =
          selectedMessage != null ? getReplyToText(selectedMessage) : "";
      request.fields['is_spiral_reply'] =
          (selectedMessage != null && selectedMessage['type'] == 'spiral')
              .toString();
      request.fields['user_id'] = FirebaseAuth.instance.currentUser!.uid;

      final audioFile = await http.MultipartFile.fromPath(
        'audio',
        await audioHandler.getCurrentRecordingPath(),
        contentType: MediaType('audio', 'wav'),
      );
      request.files.add(audioFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200) {
        final now = DateTime.now();
        final msg = {
          'user': '[Voice]',
          'timestamp': now,
          'audioPath': await audioHandler.getCurrentRecordingPath(),
          'transcription': data['transcription'] ?? '',
          'type': data['mode'],
          if (selectedMessage != null) 'reply_to_id': selectedMessage['id'],
          if (selectedMessage != null)
            'reply_to': getReplyToText(selectedMessage),
          'diarized': data['diarized'] ?? false,
          'speaker_stages': data['speaker_stages'] ?? {},
          'ask_speaker_pick': data['ask_speaker_pick'] ?? false,
          'streak': currentStreak,
          if (data['rewards'] != null) 'rewards': data['rewards'],
          if (data['message_rewards'] != null)
            'message_rewards': data['message_rewards'],
        };

        if (data['mode'] == 'chat') {
          msg['response'] = data['response'] ?? '';
          msg['audio_url'] = data['audio_url'] ?? '';
          await _storeMessage(msg);
          setState(() {});
        } else if (data['ask_speaker_pick'] == true) {
          await _storeMessage(msg);
          setState(() {});
        } else {
          msg['stage'] = data['stage'] ?? '';
          msg['question'] = data['question'] ?? '';
          msg['growth'] = data['gamified']?['gamified_prompt'] ?? '';
          msg['evolution'] = data['evolution'] ?? '';
          msg['audio_url'] = data['audio_url'] ?? '';
          lastStage = data['stage'];
          await _storeMessage(msg);
          setState(() {});
        }
      }
    } catch (e) {
      messages.add({
        'type': 'error',
        'message': 'Voice processing failed: ${e.toString()}',
        'timestamp': DateTime.now(),
      });
      setState(() {});
    }
  }

  Future<void> finalizeSpeakerStage(
    String messageId,
    String speakerId,
    Map<String, dynamic> speakerStages,
    Map<String, dynamic>? selectedMessage,
    void Function(void Function()) setState,
  ) async {
    try {
      const url = "https://ret-vrn.onrender.com/finalize_stage";
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "speaker_id": speakerId,
          "speaker_stages": speakerStages,
          "last_stage": lastStage ?? "",
          "reply_to":
              selectedMessage != null ? getReplyToText(selectedMessage) : "",
          "user_id": FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messageIndex = messages.indexWhere(
          (msg) => msg['id'] == messageId,
        );
        if (messageIndex != -1) {
          messages[messageIndex] = {
            ...messages[messageIndex],
            'type': 'spiral',
            'stage': data['stage'],
            'question': data['question'],
            'growth': data['gamified']?['gamified_prompt'] ?? '',
            'evolution': data['evolution'],
            'audio_url': data['audio_url'],
            'ask_speaker_pick': false,
            'streak': currentStreak,
            if (data['xp_gained'] != null) 'xp_gained': data['xp_gained'],
            if (data['badges_earned'] != null)
              'badges_earned': data['badges_earned'],
          };

          lastStage = data['stage'];

          await firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('mergedMessages')
              .doc(messageId)
              .update({
                'type': 'spiral',
                'stage': data['stage'],
                'question': data['question'],
                'growth': data['gamified']?['gamified_prompt'] ?? '',
                'evolution': data['evolution'],
                'audio_url': data['audio_url'],
                'ask_speaker_pick': false,
                'streak': currentStreak,
                if (data['xp_gained'] != null) 'xp_gained': data['xp_gained'],
                if (data['badges_earned'] != null)
                  'badges_earned': data['badges_earned'],
              });

          setState(() {});
        }
      }
    } catch (e) {
      messages.add({
        'type': 'error',
        'message': 'Error finalizing stage: ${e.toString()}',
        'timestamp': DateTime.now(),
      });
      setState(() {});
    }
  }

  Future<void> _storeMessage(Map<String, dynamic> msg) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('mergedMessages')
        .add(msg);
    messages.add({...msg, 'id': docRef.id});
  }
}
