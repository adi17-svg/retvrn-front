// frontend/lib/components/reflect/reflect_gamification_handler.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReflectGamificationHandler {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userProgress = {
    'xp': 0,
    'level': 1,
    'streak': 0,
    'badges': [],
    'messageCount': 0,
    'lastActiveDate': null,
  };

  Future<void> initialize({required String userId}) async {
    final doc = await firestore.collection('userProgress').doc(userId).get();
    if (doc.exists) {
      _userProgress = doc.data()!;
    }
  }

  Future<void> updateProgress(Map<String, dynamic> updates) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await firestore.collection('userProgress').doc(userId).set(
      updates,
      SetOptions(merge: true),
    );
    _userProgress = {..._userProgress, ...updates};
  }

  Future<void> handleXpReward(int xp, String? badge) async {
    final newXp = (_userProgress['xp'] ?? 0) + xp;
    final newLevel = (newXp / 100).floor() + 1;

    final updates = {
      'xp': newXp,
      'level': newLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (badge != null) {
      final badges = List<String>.from(_userProgress['badges'] ?? []);
      if (!badges.contains(badge)) {
        badges.add(badge);
        updates['badges'] = badges;
      }
    }

    await updateProgress(updates);
  }

  Future<void> checkDailyStreak() async {
    final now = DateTime.now();
    final lastActive = _userProgress['lastActiveDate']?.toDate();

    if (lastActive == null ||
        lastActive.isBefore(now.subtract(Duration(days: 1)))) {
      // Reset streak if more than 1 day has passed
      await updateProgress({
        'streak': 1,
        'lastActiveDate': now,
      });
    } else if (lastActive.day == now.day) {
      // Already active today
      return;
    } else {
      // Increment streak
      final newStreak = (_userProgress['streak'] ?? 0) + 1;
      await updateProgress({
        'streak': newStreak,
        'lastActiveDate': now,
      });

      // Check for streak rewards
      if (newStreak == 3) {
        await handleXpReward(15, '🔥 3-Day Streak');
      } else if (newStreak == 7) {
        await handleXpReward(30, '🌟 Weekly Explorer');
      } else if (newStreak == 14) {
        await handleXpReward(50, '🌙 Fortnight Champion');
      } else if (newStreak == 30) {
        await handleXpReward(100, '🌕 Monthly Master');
      }
    }
  }

  Future<void> incrementMessageCount() async {
    final newCount = (_userProgress['messageCount'] ?? 0) + 1;
    await updateProgress({'messageCount': newCount});

    if (newCount >= 5) {
      await handleXpReward(20, '💬 Chatterbox');
    }
  }

  Map<String, dynamic> get progress => _userProgress;
}