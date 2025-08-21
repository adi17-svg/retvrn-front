// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart' as record;
// import 'package:path/path.dart' as path;
// import 'package:http_parser/http_parser.dart';
// import 'package:just_audio/just_audio.dart';

// import '../data/bg_data.dart';
// import '../main.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;
//   final firestore = FirebaseFirestore.instance;
//   bool isLoading = false;
//   bool _isInitializing = true;
//   List<Map<String, dynamic>> messages = [];
//   String? lastStage;
//   Map<String, dynamic>? selectedMessage;
//   bool _isSelecting = false;
//   List<String> selectedMessageIds = [];
//   final ScrollController _scrollController = ScrollController();

//   final record.AudioRecorder _recorder = record.AudioRecorder();
//   bool _isRecording = false;
//   DateTime? _lastTaskCheck;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _requestPermissions();
//     await _loadMessages();
//     await _checkAndAddDailyTask();
//     setState(() => _isInitializing = false);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.microphone, Permission.storage].request();
//   }

//   Future<void> _checkAndAddDailyTask() async {
//     final now = DateTime.now();
//     if (_lastTaskCheck != null &&
//         now.difference(_lastTaskCheck!) < Duration(minutes: 5)) {
//       return;
//     }
//     _lastTaskCheck = now;

//     final today = DateTime.now();
//     final todayStr = DateFormat('yyyy-MM-dd').format(today);

//     try {
//       final querySnapshot =
//           await firestore
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'daily-task')
//               .where(
//                 'timestamp',
//                 isGreaterThanOrEqualTo: DateTime(
//                   today.year,
//                   today.month,
//                   today.day,
//                 ),
//               )
//               .where(
//                 'timestamp',
//                 isLessThan: DateTime(today.year, today.month, today.day + 1),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isEmpty) {
//         await _addDailyTaskMessage();
//       }
//     } catch (e) {
//       debugPrint('Error checking for daily task: $e');
//       final hasDailyTask = messages.any((msg) {
//         if (msg['type'] == 'daily-task') {
//           DateTime timestamp;
//           if (msg['timestamp'] is Timestamp) {
//             timestamp = (msg['timestamp'] as Timestamp).toDate();
//           } else if (msg['timestamp'] is String) {
//             timestamp = DateTime.parse(msg['timestamp']);
//           } else {
//             timestamp = msg['timestamp'];
//           }
//           return DateFormat('yyyy-MM-dd').format(timestamp) == todayStr;
//         }
//         return false;
//       });

//       if (!hasDailyTask) {
//         await _addDailyTaskMessage();
//       }
//     }
//   }

//   Future<void> _addDailyTaskMessage() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.206.190.126:5000/daily_task?user_id=${user!.uid}'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         final taskMessage = {
//           'type': 'daily-task',
//           'message': data['task'] ?? 'Your daily reflection task',
//           'timestamp': today,
//           'task_id': data['timestamp'],
//           'completed': data['completed'] ?? false,
//         };

//         await _storeMessage(taskMessage);
//         await _loadMessages();
//       }
//     } catch (e) {
//       debugPrint('Error loading daily task: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     final snapshot =
//         await firestore
//             .collection('users')
//             .doc(user!.uid)
//             .collection('mergedMessages')
//             .orderBy('timestamp')
//             .get();

//     setState(() {
//       messages =
//           snapshot.docs
//               .map((doc) => doc.data()..['id'] = doc.id)
//               .cast<Map<String, dynamic>>()
//               .toList();

//       for (final msg in messages.reversed) {
//         if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
//           lastStage = msg['stage'];
//           break;
//         }
//       }
//     });
//   }

//   Future<void> sendEntry(String entry) async {
//     if (entry.trim().isEmpty) return;
//     setState(() => isLoading = true);
//     final url = Uri.parse("http://10.206.190.126:5000/merged");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "text": entry,
//           "last_stage": lastStage ?? "",
//           "reply_to":
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//           "is_spiral_reply":
//               selectedMessage != null && selectedMessage?['type'] == 'spiral',
//         }),
//       );

//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final base = {
//           'user': entry,
//           'timestamp': now,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         if (data['mode'] == 'chat') {
//           final msg = {
//             ...base,
//             'type': 'chat',
//             'response': data['response'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         } else if (data['mode'] == 'spiral') {
//           final newStage = data['stage'] ?? '';
//           lastStage = newStage;

//           final msg = {
//             ...base,
//             'type': 'spiral',
//             'stage': newStage,
//             'question': data['question'] ?? '',
//             'evolution': data['evolution'] ?? '',
//             'growth': data['growth'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         }

//         selectedMessage = null;
//       } else {
//         setState(() {
//           messages.add({
//             'type': 'error',
//             'message':
//                 'Server error: ${response.statusCode} - ${response.body}',
//             'timestamp': now,
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Network error: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//         _controller.clear();
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _storeMessage(Map<String, dynamic> msg) async {
//     final docRef = await firestore
//         .collection('users')
//         .doc(user!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     setState(() => messages.add({...msg, 'id': docRef.id}));
//   }

//   Future<String> _getTempFilePath() async {
//     final dir = await getTemporaryDirectory();
//     return path.join(dir.path, 'journal.wav');
//   }

//   Future<void> _startRecording() async {
//     final filePath = await _getTempFilePath();
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) return;

//     try {
//       await _recorder.start(
//         const record.RecordConfig(
//           encoder: record.AudioEncoder.wav,
//           sampleRate: 16000,
//           numChannels: 1,
//         ),
//         path: filePath,
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("❌ Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       setState(() => _isRecording = false);

//       if (filePath != null) {
//         final file = File(filePath);
//         if (await file.exists() && await file.length() > 0) {
//           await _sendVoiceToBackend(file);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to stop recording: $e");
//     }
//   }

//   Future<void> _sendVoiceToBackend(File file) async {
//     setState(() => isLoading = true);
//     final uri = Uri.parse("http://10.206.190.126:5000/reflect_transcription");

//     final request = http.MultipartRequest('POST', uri);
//     request.fields['last_stage'] = lastStage ?? '';
//     request.fields['reply_to'] =
//         selectedMessage != null
//             ? (selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "")
//             : "";
//     request.fields['is_spiral_reply'] =
//         (selectedMessage != null && selectedMessage?['type'] == 'spiral')
//             .toString();
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         file.path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);
//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         if (data['ask_speaker_pick'] == true) {
//           // Show speaker selection dialog
//           await _showSpeakerSelectionDialog(data);
//           return;
//         }

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': file.path,
//           'transcription': data['transcription'] ?? '',
//           'type': data['mode'],
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//           'diarized': data['diarized'] ?? false,
//           'speaker_stages': data['speaker_stages'] ?? {},
//         };

//         if (data['mode'] == 'chat') {
//           msg['response'] = data['response'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//         } else {
//           msg['stage'] = data['stage'] ?? '';
//           msg['question'] = data['question'] ?? '';
//           msg['growth'] = data['growth'] ?? '';
//           msg['evolution'] = data['evolution'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//           lastStage = data['stage'];
//         }

//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Voice processing failed: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _showSpeakerSelectionDialog(Map<String, dynamic> data) async {
//     final speakerStages = Map<String, dynamic>.from(data['speaker_stages']);
//     final transcription = data['transcription'] ?? '';

//     final selectedSpeaker = await showDialog<String>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Speaker'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '“Hey! I heard more than one person in this audio. Could you tell me which voice is yours so I can reflect the right insights?”',
//                   ),
//                   const SizedBox(height: 16),
//                   ...speakerStages.entries.map((entry) {
//                     return ListTile(
//                       title: Text('${entry.key} (${entry.value['stage']})'),
//                       subtitle: Text(
//                         entry.value['text'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () => Navigator.pop(context, entry.key),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );

//     if (selectedSpeaker != null) {
//       await _finalizeVoiceMessage(
//         speakerId: selectedSpeaker,
//         speakerStages: speakerStages,
//         transcription: transcription,
//         audioPath: data['audio_url'] ?? '',
//       );
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _finalizeVoiceMessage({
//     required String speakerId,
//     required Map<String, dynamic> speakerStages,
//     required String transcription,
//     required String audioPath,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.206.190.126:5000/finalize_stage'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'speaker_id': speakerId,
//           'speaker_stages': speakerStages,
//           'last_stage': lastStage ?? '',
//           'reply_to':
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': audioPath,
//           'transcription': transcription,
//           'type': 'spiral',
//           'stage': data['stage'] ?? '',
//           'question': data['question'] ?? '',
//           'growth': data['growth'] ?? '',
//           'evolution': data['evolution'] ?? '',
//           'audio_url': data['audio_url'] ?? '',
//           'diarized': true,
//           'speaker_stages': speakerStages,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         lastStage = data['stage'];
//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Error finalizing voice message: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> getMessagesWithDateHeaders() {
//     List<Map<String, dynamic>> processed = [];
//     String? lastDate;

//     for (final msg in messages) {
//       final timestamp =
//           msg['timestamp'] is Timestamp
//               ? (msg['timestamp'] as Timestamp).toDate()
//               : msg['timestamp'] is String
//               ? DateTime.parse(msg['timestamp'])
//               : DateTime.now();
//       final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

//       if (lastDate != dateStr) {
//         processed.add({'type': 'date-header', 'date': timestamp});
//         lastDate = dateStr;
//       }

//       processed.add(msg);
//     }

//     return processed;
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//       ),
//       title: Text('${selectedMessageIds.length} selected'),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.reply),
//           onPressed: () {
//             if (selectedMessageIds.length == 1) {
//               final message = messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//                 orElse: () => {},
//               );
//               if (message.isNotEmpty) {
//                 _setReplyToMessage(message);
//               }
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText =
//         selectedMessage?['question'] ??
//         selectedMessage?['response'] ??
//         selectedMessage?['user'] ??
//         selectedMessage?['message'] ??
//         "";

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(
//           left: BorderSide(
//             color:
//                 selectedMessage?['type'] == 'spiral'
//                     ? Colors.orange
//                     : Colors.blue,
//             width: 4,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 selectedMessage?['type'] == 'spiral'
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color:
//                       selectedMessage?['type'] == 'spiral'
//                           ? Colors.orange
//                           : Colors.blue,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     selectedMessage = null;
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(replyText, style: const TextStyle(fontSize: 14)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
//     if (speakerStages.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         ...speakerStages.entries.map((entry) {
//           final speaker = entry.key;
//           final stage = entry.value['stage'] ?? 'Unknown';
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 12),
//                 children: [
//                   TextSpan(
//                     text: "$speaker: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey[800],
//                     ),
//                   ),
//                   TextSpan(
//                     text: stage,
//                     style: TextStyle(color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildChatBubble(Map<String, dynamic> msg) {
//     if (msg['type'] == 'date-header') {
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             DateFormat('EEEE, MMM d, yyyy').format(msg['date']),
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     final timestamp =
//         msg['timestamp'] is Timestamp
//             ? (msg['timestamp'] as Timestamp).toDate()
//             : msg['timestamp'] is String
//             ? DateTime.parse(msg['timestamp'])
//             : DateTime.now();
//     final isSelected = selectedMessageIds.contains(msg['id']);
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: () {
//         if (!_isSelecting) {
//           setState(() {
//             _isSelecting = true;
//             selectedMessageIds.add(msg['id']);
//           });
//         }
//       },
//       onTap: () {
//         if (_isSelecting) {
//           _toggleMessageSelection(msg['id']);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 40,
//                         color: Colors.grey,
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Expanded(
//                         child: Text(
//                           msg['reply_to'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'daily-task')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "📝 Inner Compass",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(msg['message'] ?? ''),
//                           const SizedBox(height: 8),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.blue[300]
//                                 : isReply
//                                 ? Colors.blue[100]
//                                 : Colors.blue[200],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             msg['user'] ?? '',
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] == '[Voice]' && msg['audioPath'] != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                         border: Border.all(color: Colors.blueGrey[100]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.mic,
//                                 color: Colors.blueGrey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Voice Message",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           AudioPlayerWidget(filePath: msg['audioPath']),
//                           if (msg['transcription'] != null &&
//                               msg['transcription'].isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Transcription:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueGrey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '"${msg['transcription']}"',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'chat')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.grey[300]
//                                 : isReply
//                                 ? Colors.grey[100]
//                                 : Colors.grey[200],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(msg['response'] ?? ''),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'spiral')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.orange[200]
//                                 : isReply
//                                 ? Colors.orange[50]
//                                 : Colors.orange[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "🌀 Stage: ${msg['stage'] ?? ''}",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           if (msg['diarized'] == true &&
//                               msg['speaker_stages'] != null)
//                             _buildSpeakerStages(
//                               Map<String, dynamic>.from(msg['speaker_stages']),
//                             ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "❓ ${msg['question'] ?? ''}",
//                             style: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontSize: 14,
//                             ),
//                           ),
//                           if ((msg['growth'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 '"${msg['growth']}"',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if ((msg['evolution'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 msg['evolution'],
//                                 style: const TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'error')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "❌ ${msg['message'] ?? 'Error'}",
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('Loading your reflections...'),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const SpiralEvolutionChartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       body: ValueListenableBuilder<int>(
//         valueListenable: selectedBgIndex,
//         builder: (context, index, _) {
//           final displayMessages = getMessagesWithDateHeaders();
//           return Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(bgList[index]),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: displayMessages.length,
//                     itemBuilder:
//                         (context, index) =>
//                             buildChatBubble(displayMessages[index]),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _isRecording ? Icons.stop_circle_outlined : Icons.mic,
//                           color: _isRecording ? Colors.red : Colors.black,
//                         ),
//                         onPressed:
//                             _isRecording ? _stopRecording : _startRecording,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             isLoading
//                                 ? null
//                                 : () => sendEntry(_controller.text),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class AudioPlayerWidget extends StatefulWidget {
//   final String filePath;
//   const AudioPlayerWidget({super.key, required this.filePath});

//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   Duration? _duration;
//   Duration? _position;

//   @override
//   void initState() {
//     super.initState();
//     _player.durationStream.listen((duration) {
//       setState(() => _duration = duration);
//     });
//     _player.positionStream.listen((position) {
//       setState(() => _position = position);
//     });
//     _player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         setState(() => _isPlaying = false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   Future<void> _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//     } else {
//       try {
//         if (widget.filePath.startsWith('http')) {
//           await _player.setUrl(widget.filePath);
//         } else {
//           await _player.setFilePath(widget.filePath);
//         }
//         await _player.play();
//       } catch (e) {
//         debugPrint('Error playing audio: $e');
//       }
//     }
//     setState(() => _isPlaying = !_isPlaying);
//   }

//   String _formatDuration(Duration? duration) {
//     if (duration == null) return '--:--';
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             color: Colors.blueGrey[800],
//             size: 24,
//           ),
//           onPressed: _togglePlayPause,
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SliderTheme(
//                 data: SliderTheme.of(context).copyWith(
//                   activeTrackColor: Colors.blueGrey[600],
//                   inactiveTrackColor: Colors.blueGrey[200],
//                   trackHeight: 2,
//                   thumbColor: Colors.blueGrey[600],
//                   thumbShape: const RoundSliderThumbShape(
//                     enabledThumbRadius: 6,
//                   ),
//                   overlayColor: Colors.blueGrey.withAlpha(32),
//                   overlayShape: const RoundSliderOverlayShape(
//                     overlayRadius: 12,
//                   ),
//                 ),
//                 child: Slider(
//                   value: (_position ?? Duration.zero).inMilliseconds.toDouble(),
//                   min: 0,
//                   max: _duration?.inMilliseconds.toDouble() ?? 1,
//                   onChanged: (value) {
//                     _player.seek(Duration(milliseconds: value.toInt()));
//                   },
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _formatDuration(_position),
//                     style: TextStyle(fontSize: 10, color: Colors.blueGrey[600]),
//                   ),
//                   Text(
//                     _formatDuration(_duration),
//                     style: TextStyle(fontSize: 10, color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart' as record;
// import 'package:path/path.dart' as path;
// import 'package:http_parser/http_parser.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// import '../data/bg_data.dart';
// import '../main.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;
//   final firestore = FirebaseFirestore.instance;
//   bool isLoading = false;
//   bool _isInitializing = true;
//   List<Map<String, dynamic>> messages = [];
//   String? lastStage;
//   Map<String, dynamic>? selectedMessage;
//   bool _isSelecting = false;
//   List<String> selectedMessageIds = [];
//   final ScrollController _scrollController = ScrollController();

//   final record.AudioRecorder _recorder = record.AudioRecorder();
//   bool _isRecording = false;
//   DateTime? _lastTaskCheck;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _requestPermissions();
//     await _loadMessages();
//     await _checkAndAddDailyTask();
//     setState(() => _isInitializing = false);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.microphone, Permission.storage].request();
//   }

//   Future<void> _checkAndAddDailyTask() async {
//     final now = DateTime.now();
//     if (_lastTaskCheck != null &&
//         now.difference(_lastTaskCheck!) < Duration(minutes: 5)) {
//       return;
//     }
//     _lastTaskCheck = now;

//     final today = DateTime.now();
//     final todayStr = DateFormat('yyyy-MM-dd').format(today);

//     try {
//       final querySnapshot =
//           await firestore
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'daily-task')
//               .where(
//                 'timestamp',
//                 isGreaterThanOrEqualTo: DateTime(
//                   today.year,
//                   today.month,
//                   today.day,
//                 ),
//               )
//               .where(
//                 'timestamp',
//                 isLessThan: DateTime(today.year, today.month, today.day + 1),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isEmpty) {
//         await _addDailyTaskMessage();
//       }
//     } catch (e) {
//       debugPrint('Error checking for daily task: $e');
//       final hasDailyTask = messages.any((msg) {
//         if (msg['type'] == 'daily-task') {
//           DateTime timestamp;
//           if (msg['timestamp'] is Timestamp) {
//             timestamp = (msg['timestamp'] as Timestamp).toDate();
//           } else if (msg['timestamp'] is String) {
//             timestamp = DateTime.parse(msg['timestamp']);
//           } else {
//             timestamp = msg['timestamp'];
//           }
//           return DateFormat('yyyy-MM-dd').format(timestamp) == todayStr;
//         }
//         return false;
//       });

//       if (!hasDailyTask) {
//         await _addDailyTaskMessage();
//       }
//     }
//   }

//   Future<void> _addDailyTaskMessage() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.59.3.126:5000/daily_task?user_id=${user!.uid}'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         final taskMessage = {
//           'type': 'daily-task',
//           'message': data['task'] ?? 'Your daily reflection task',
//           'timestamp': today,
//           'task_id': data['timestamp'],
//           'completed': data['completed'] ?? false,
//         };

//         await _storeMessage(taskMessage);
//         await _loadMessages();
//       }
//     } catch (e) {
//       debugPrint('Error loading daily task: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     final snapshot =
//         await firestore
//             .collection('users')
//             .doc(user!.uid)
//             .collection('mergedMessages')
//             .orderBy('timestamp')
//             .get();

//     setState(() {
//       messages =
//           snapshot.docs
//               .map((doc) => doc.data()..['id'] = doc.id)
//               .cast<Map<String, dynamic>>()
//               .toList();

//       for (final msg in messages.reversed) {
//         if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
//           lastStage = msg['stage'];
//           break;
//         }
//       }
//     });
//   }

//   Future<void> sendEntry(String entry) async {
//     if (entry.trim().isEmpty) return;
//     setState(() => isLoading = true);
//     final url = Uri.parse("http://10.59.3.126:5000/merged");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "text": entry,
//           "last_stage": lastStage ?? "",
//           "reply_to":
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//           "is_spiral_reply":
//               selectedMessage != null && selectedMessage?['type'] == 'spiral',
//         }),
//       );

//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final base = {
//           'user': entry,
//           'timestamp': now,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         if (data['mode'] == 'chat') {
//           final msg = {
//             ...base,
//             'type': 'chat',
//             'response': data['response'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         } else if (data['mode'] == 'spiral') {
//           final newStage = data['stage'] ?? '';
//           lastStage = newStage;

//           final msg = {
//             ...base,
//             'type': 'spiral',
//             'stage': newStage,
//             'question': data['question'] ?? '',
//             'evolution': data['evolution'] ?? '',
//             'growth': data['growth'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         }

//         selectedMessage = null;
//       } else {
//         setState(() {
//           messages.add({
//             'type': 'error',
//             'message':
//                 'Server error: ${response.statusCode} - ${response.body}',
//             'timestamp': now,
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Network error: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//         _controller.clear();
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _storeMessage(Map<String, dynamic> msg) async {
//     final docRef = await firestore
//         .collection('users')
//         .doc(user!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     setState(() => messages.add({...msg, 'id': docRef.id}));
//   }

//   Future<String> _getTempFilePath() async {
//     final dir = await getTemporaryDirectory();
//     return path.join(dir.path, 'journal.wav');
//   }

//   Future<void> _startRecording() async {
//     final filePath = await _getTempFilePath();
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) return;

//     try {
//       await _recorder.start(
//         const record.RecordConfig(
//           encoder: record.AudioEncoder.wav,
//           sampleRate: 16000,
//           numChannels: 1,
//         ),
//         path: filePath,
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("❌ Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       setState(() => _isRecording = false);

//       if (filePath != null) {
//         final file = File(filePath);
//         if (await file.exists() && await file.length() > 0) {
//           await _sendVoiceToBackend(file);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to stop recording: $e");
//     }
//   }

//   Future<void> _sendVoiceToBackend(File file) async {
//     setState(() => isLoading = true);
//     final uri = Uri.parse("http://10.59.3.126:5000/reflect_transcription");

//     final request = http.MultipartRequest('POST', uri);
//     request.fields['last_stage'] = lastStage ?? '';
//     request.fields['reply_to'] =
//         selectedMessage != null
//             ? (selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "")
//             : "";
//     request.fields['is_spiral_reply'] =
//         (selectedMessage != null && selectedMessage?['type'] == 'spiral')
//             .toString();
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         file.path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);
//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         if (data['ask_speaker_pick'] == true) {
//           await _showSpeakerSelectionDialog(data);
//           return;
//         }

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': file.path,
//           'transcription': data['transcription'] ?? '',
//           'type': data['mode'],
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//           'diarized': data['diarized'] ?? false,
//           'speaker_stages': data['speaker_stages'] ?? {},
//         };

//         if (data['mode'] == 'chat') {
//           msg['response'] = data['response'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//         } else {
//           msg['stage'] = data['stage'] ?? '';
//           msg['question'] = data['question'] ?? '';
//           msg['growth'] = data['growth'] ?? '';
//           msg['evolution'] = data['evolution'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//           lastStage = data['stage'];
//         }

//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Voice processing failed: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _showSpeakerSelectionDialog(Map<String, dynamic> data) async {
//     final speakerStages = Map<String, dynamic>.from(data['speaker_stages']);
//     final transcription = data['transcription'] ?? '';

//     final selectedSpeaker = await showDialog<String>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Speaker'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '“Hey! I heard more than one person in this audio. Could you tell me which voice is yours so I can reflect the right insights?”',
//                   ),
//                   const SizedBox(height: 16),
//                   ...speakerStages.entries.map((entry) {
//                     return ListTile(
//                       title: Text('${entry.key} (${entry.value['stage']})'),
//                       subtitle: Text(
//                         entry.value['text'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () => Navigator.pop(context, entry.key),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );

//     if (selectedSpeaker != null) {
//       await _finalizeVoiceMessage(
//         speakerId: selectedSpeaker,
//         speakerStages: speakerStages,
//         transcription: transcription,
//         audioPath: data['audio_url'] ?? '',
//       );
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _finalizeVoiceMessage({
//     required String speakerId,
//     required Map<String, dynamic> speakerStages,
//     required String transcription,
//     required String audioPath,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.59.3.126:5000/finalize_stage'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'speaker_id': speakerId,
//           'speaker_stages': speakerStages,
//           'last_stage': lastStage ?? '',
//           'reply_to':
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': audioPath,
//           'transcription': transcription,
//           'type': 'spiral',
//           'stage': data['stage'] ?? '',
//           'question': data['question'] ?? '',
//           'growth': data['growth'] ?? '',
//           'evolution': data['evolution'] ?? '',
//           'audio_url': data['audio_url'] ?? '',
//           'diarized': true,
//           'speaker_stages': speakerStages,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         lastStage = data['stage'];
//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Error finalizing voice message: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> getMessagesWithDateHeaders() {
//     List<Map<String, dynamic>> processed = [];
//     String? lastDate;

//     for (final msg in messages) {
//       final timestamp =
//           msg['timestamp'] is Timestamp
//               ? (msg['timestamp'] as Timestamp).toDate()
//               : msg['timestamp'] is String
//               ? DateTime.parse(msg['timestamp'])
//               : DateTime.now();
//       final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

//       if (lastDate != dateStr) {
//         processed.add({'type': 'date-header', 'date': timestamp});
//         lastDate = dateStr;
//       }

//       processed.add(msg);
//     }

//     return processed;
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//       ),
//       title: Text('${selectedMessageIds.length} selected'),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.reply),
//           onPressed: () {
//             if (selectedMessageIds.length == 1) {
//               final message = messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//                 orElse: () => {},
//               );
//               if (message.isNotEmpty) {
//                 _setReplyToMessage(message);
//               }
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText =
//         selectedMessage?['question'] ??
//         selectedMessage?['response'] ??
//         selectedMessage?['user'] ??
//         selectedMessage?['message'] ??
//         "";

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(
//           left: BorderSide(
//             color:
//                 selectedMessage?['type'] == 'spiral'
//                     ? Colors.orange
//                     : Colors.blue,
//             width: 4,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 selectedMessage?['type'] == 'spiral'
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color:
//                       selectedMessage?['type'] == 'spiral'
//                           ? Colors.orange
//                           : Colors.blue,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     selectedMessage = null;
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(replyText, style: const TextStyle(fontSize: 14)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
//     if (speakerStages.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         ...speakerStages.entries.map((entry) {
//           final speaker = entry.key;
//           final stage = entry.value['stage'] ?? 'Unknown';
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 12),
//                 children: [
//                   TextSpan(
//                     text: "$speaker: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey[800],
//                     ),
//                   ),
//                   TextSpan(
//                     text: stage,
//                     style: TextStyle(color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildChatBubble(Map<String, dynamic> msg) {
//     if (msg['type'] == 'date-header') {
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             DateFormat('EEEE, MMM d, yyyy').format(msg['date']),
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     final timestamp =
//         msg['timestamp'] is Timestamp
//             ? (msg['timestamp'] as Timestamp).toDate()
//             : msg['timestamp'] is String
//             ? DateTime.parse(msg['timestamp'])
//             : DateTime.now();
//     final isSelected = selectedMessageIds.contains(msg['id']);
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: () {
//         if (!_isSelecting) {
//           setState(() {
//             _isSelecting = true;
//             selectedMessageIds.add(msg['id']);
//           });
//         }
//       },
//       onTap: () {
//         if (_isSelecting) {
//           _toggleMessageSelection(msg['id']);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 40,
//                         color: Colors.grey,
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Expanded(
//                         child: Text(
//                           msg['reply_to'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'daily-task')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "📝 Inner Compass",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(msg['message'] ?? ''),
//                           const SizedBox(height: 8),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.blue[300]
//                                 : isReply
//                                 ? Colors.blue[100]
//                                 : Colors.blue[200],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             msg['user'] ?? '',
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] == '[Voice]' && msg['audioPath'] != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                         border: Border.all(color: Colors.blueGrey[100]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.mic,
//                                 color: Colors.blueGrey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Voice Message",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           AudioPlayerWidget(filePath: msg['audioPath']),
//                           if (msg['transcription'] != null &&
//                               msg['transcription'].isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Transcription:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueGrey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '"${msg['transcription']}"',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'chat')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.grey[300]
//                                 : isReply
//                                 ? Colors.grey[100]
//                                 : Colors.grey[200],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(msg['response'] ?? ''),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'spiral')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.orange[200]
//                                 : isReply
//                                 ? Colors.orange[50]
//                                 : Colors.orange[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "🌀 Stage: ${msg['stage'] ?? ''}",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           if (msg['diarized'] == true &&
//                               msg['speaker_stages'] != null)
//                             _buildSpeakerStages(
//                               Map<String, dynamic>.from(msg['speaker_stages']),
//                             ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "❓ ${msg['question'] ?? ''}",
//                             style: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontSize: 14,
//                             ),
//                           ),
//                           if ((msg['growth'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 '"${msg['growth']}"',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if ((msg['evolution'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 msg['evolution'],
//                                 style: const TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'error')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "❌ ${msg['message'] ?? 'Error'}",
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('Loading your reflections...'),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const SpiralEvolutionChartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       body: ValueListenableBuilder<int>(
//         valueListenable: selectedBgIndex,
//         builder: (context, index, _) {
//           final displayMessages = getMessagesWithDateHeaders();
//           return Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(bgList[index]),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: displayMessages.length,
//                     itemBuilder:
//                         (context, index) =>
//                             buildChatBubble(displayMessages[index]),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _isRecording ? Icons.stop_circle_outlined : Icons.mic,
//                           color: _isRecording ? Colors.red : Colors.black,
//                         ),
//                         onPressed:
//                             _isRecording ? _stopRecording : _startRecording,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             isLoading
//                                 ? null
//                                 : () => sendEntry(_controller.text),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class AudioPlayerWidget extends StatefulWidget {
//   final String filePath;
//   const AudioPlayerWidget({super.key, required this.filePath});

//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   Duration? _duration;
//   Duration? _position;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioSession();
//     _player.durationStream.listen((duration) {
//       setState(() => _duration = duration);
//     });
//     _player.positionStream.listen((position) {
//       setState(() => _position = position);
//     });
//     _player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         setState(() => _isPlaying = false);
//       }
//     });
//   }

//   Future<void> _initAudioSession() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   Future<void> _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//     } else {
//       try {
//         if (widget.filePath.startsWith('http')) {
//           await _player.setUrl(widget.filePath);
//         } else {
//           await _player.setFilePath(widget.filePath);
//         }
//         await _player.play();
//       } catch (e) {
//         debugPrint('Error playing audio: $e');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
//       }
//     }
//     setState(() => _isPlaying = !_isPlaying);
//   }

//   String _formatDuration(Duration? duration) {
//     if (duration == null) return '--:--';
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         IconButton(
//           icon: Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             color: Colors.blueGrey[800],
//             size: 24,
//           ),
//           onPressed: _togglePlayPause,
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SliderTheme(
//                 data: SliderTheme.of(context).copyWith(
//                   activeTrackColor: Colors.blueGrey[600],
//                   inactiveTrackColor: Colors.blueGrey[200],
//                   trackHeight: 2,
//                   thumbColor: Colors.blueGrey[600],
//                   thumbShape: const RoundSliderThumbShape(
//                     enabledThumbRadius: 6,
//                   ),
//                   overlayColor: Colors.blueGrey.withAlpha(32),
//                   overlayShape: const RoundSliderOverlayShape(
//                     overlayRadius: 12,
//                   ),
//                 ),
//                 child: Slider(
//                   value: (_position ?? Duration.zero).inMilliseconds.toDouble(),
//                   min: 0,
//                   max: _duration?.inMilliseconds.toDouble() ?? 1,
//                   onChanged: (value) {
//                     _player.seek(Duration(milliseconds: value.toInt()));
//                   },
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _formatDuration(_position),
//                     style: TextStyle(fontSize: 10, color: Colors.blueGrey[600]),
//                   ),
//                   Text(
//                     _formatDuration(_duration),
//                     style: TextStyle(fontSize: 10, color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart' as record;
// import 'package:path/path.dart' as path;
// import 'package:http_parser/http_parser.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// import '../data/bg_data.dart';
// import '../main.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;
//   final firestore = FirebaseFirestore.instance;
//   bool isLoading = false;
//   bool _isInitializing = true;
//   List<Map<String, dynamic>> messages = [];
//   String? lastStage;
//   Map<String, dynamic>? selectedMessage;
//   bool _isSelecting = false;
//   List<String> selectedMessageIds = [];
//   final ScrollController _scrollController = ScrollController();

//   final record.AudioRecorder _recorder = record.AudioRecorder();
//   bool _isRecording = false;
//   DateTime? _lastTaskCheck;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _requestPermissions();
//     await _loadMessages();
//     await _checkAndAddDailyTask();
//     setState(() => _isInitializing = false);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.microphone, Permission.storage].request();
//   }

//   Future<void> _checkAndAddDailyTask() async {
//     final now = DateTime.now();
//     if (_lastTaskCheck != null &&
//         now.difference(_lastTaskCheck!) < Duration(minutes: 5)) {
//       return;
//     }
//     _lastTaskCheck = now;

//     final today = DateTime.now();
//     final todayStr = DateFormat('yyyy-MM-dd').format(today);

//     try {
//       final querySnapshot =
//           await firestore
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'daily-task')
//               .where(
//                 'timestamp',
//                 isGreaterThanOrEqualTo: DateTime(
//                   today.year,
//                   today.month,
//                   today.day,
//                 ),
//               )
//               .where(
//                 'timestamp',
//                 isLessThan: DateTime(today.year, today.month, today.day + 1),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isEmpty) {
//         await _addDailyTaskMessage();
//       }
//     } catch (e) {
//       debugPrint('Error checking for daily task: $e');
//       final hasDailyTask = messages.any((msg) {
//         if (msg['type'] == 'daily-task') {
//           DateTime timestamp;
//           if (msg['timestamp'] is Timestamp) {
//             timestamp = (msg['timestamp'] as Timestamp).toDate();
//           } else if (msg['timestamp'] is String) {
//             timestamp = DateTime.parse(msg['timestamp']);
//           } else {
//             timestamp = msg['timestamp'];
//           }
//           return DateFormat('yyyy-MM-dd').format(timestamp) == todayStr;
//         }
//         return false;
//       });

//       if (!hasDailyTask) {
//         await _addDailyTaskMessage();
//       }
//     }
//   }

//   Future<void> _addDailyTaskMessage() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.59.3.126:5000/daily_task?user_id=${user!.uid}'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         final taskMessage = {
//           'type': 'daily-task',
//           'message': data['task'] ?? 'Your daily reflection task',
//           'timestamp': today,
//           'task_id': data['timestamp'],
//           'completed': data['completed'] ?? false,
//         };

//         await _storeMessage(taskMessage);
//         await _loadMessages();
//       }
//     } catch (e) {
//       debugPrint('Error loading daily task: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     final snapshot =
//         await firestore
//             .collection('users')
//             .doc(user!.uid)
//             .collection('mergedMessages')
//             .orderBy('timestamp')
//             .get();

//     setState(() {
//       messages =
//           snapshot.docs
//               .map((doc) => doc.data()..['id'] = doc.id)
//               .cast<Map<String, dynamic>>()
//               .toList();

//       for (final msg in messages.reversed) {
//         if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
//           lastStage = msg['stage'];
//           break;
//         }
//       }
//     });
//   }

//   Future<void> sendEntry(String entry) async {
//     if (entry.trim().isEmpty) return;
//     setState(() => isLoading = true);
//     final url = Uri.parse("http://10.59.3.126:5000/merged");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "text": entry,
//           "last_stage": lastStage ?? "",
//           "reply_to":
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//           "is_spiral_reply":
//               selectedMessage != null && selectedMessage?['type'] == 'spiral',
//         }),
//       );

//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final base = {
//           'user': entry,
//           'timestamp': now,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         if (data['mode'] == 'chat') {
//           final msg = {
//             ...base,
//             'type': 'chat',
//             'response': data['response'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         } else if (data['mode'] == 'spiral') {
//           final newStage = data['stage'] ?? '';
//           lastStage = newStage;

//           final msg = {
//             ...base,
//             'type': 'spiral',
//             'stage': newStage,
//             'question': data['question'] ?? '',
//             'evolution': data['evolution'] ?? '',
//             'growth': data['growth'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         }

//         selectedMessage = null;
//       } else {
//         setState(() {
//           messages.add({
//             'type': 'error',
//             'message':
//                 'Server error: ${response.statusCode} - ${response.body}',
//             'timestamp': now,
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Network error: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//         _controller.clear();
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _storeMessage(Map<String, dynamic> msg) async {
//     final docRef = await firestore
//         .collection('users')
//         .doc(user!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     setState(() => messages.add({...msg, 'id': docRef.id}));
//   }

//   Future<String> _getTempFilePath() async {
//     final dir = await getTemporaryDirectory();
//     return path.join(dir.path, 'journal.wav');
//   }

//   Future<void> _startRecording() async {
//     final filePath = await _getTempFilePath();
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) return;

//     try {
//       await _recorder.start(
//         const record.RecordConfig(
//           encoder: record.AudioEncoder.wav,
//           sampleRate: 16000,
//           numChannels: 1,
//         ),
//         path: filePath,
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("❌ Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       setState(() => _isRecording = false);

//       if (filePath != null) {
//         final file = File(filePath);
//         if (await file.exists() && await file.length() > 0) {
//           await _sendVoiceToBackend(file);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to stop recording: $e");
//     }
//   }

//   Future<void> _sendVoiceToBackend(File file) async {
//     setState(() => isLoading = true);
//     final uri = Uri.parse("http://10.59.3.126:5000/reflect_transcription");

//     final request = http.MultipartRequest('POST', uri);
//     request.fields['last_stage'] = lastStage ?? '';
//     request.fields['reply_to'] =
//         selectedMessage != null
//             ? (selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "")
//             : "";
//     request.fields['is_spiral_reply'] =
//         (selectedMessage != null && selectedMessage?['type'] == 'spiral')
//             .toString();
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         file.path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);
//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         if (data['ask_speaker_pick'] == true) {
//           await _showSpeakerSelectionDialog(data);
//           return;
//         }

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': file.path,
//           'transcription': data['transcription'] ?? '',
//           'type': data['mode'],
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//           'diarized': data['diarized'] ?? false,
//           'speaker_stages': data['speaker_stages'] ?? {},
//         };

//         if (data['mode'] == 'chat') {
//           msg['response'] = data['response'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//         } else {
//           msg['stage'] = data['stage'] ?? '';
//           msg['question'] = data['question'] ?? '';
//           msg['growth'] = data['growth'] ?? '';
//           msg['evolution'] = data['evolution'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//           lastStage = data['stage'];
//         }

//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Voice processing failed: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _showSpeakerSelectionDialog(Map<String, dynamic> data) async {
//     final speakerStages = Map<String, dynamic>.from(data['speaker_stages']);
//     final transcription = data['transcription'] ?? '';

//     final selectedSpeaker = await showDialog<String>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Speaker'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '“Hey! I heard more than one person in this audio. Could you tell me which voice is yours so I can reflect the right insights?”',
//                   ),
//                   const SizedBox(height: 16),
//                   ...speakerStages.entries.map((entry) {
//                     return ListTile(
//                       title: Text('${entry.key} (${entry.value['stage']})'),
//                       subtitle: Text(
//                         entry.value['text'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () => Navigator.pop(context, entry.key),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );

//     if (selectedSpeaker != null) {
//       await _finalizeVoiceMessage(
//         speakerId: selectedSpeaker,
//         speakerStages: speakerStages,
//         transcription: transcription,
//         audioPath: data['audio_url'] ?? '',
//       );
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _finalizeVoiceMessage({
//     required String speakerId,
//     required Map<String, dynamic> speakerStages,
//     required String transcription,
//     required String audioPath,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.59.3.126:5000/finalize_stage'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'speaker_id': speakerId,
//           'speaker_stages': speakerStages,
//           'last_stage': lastStage ?? '',
//           'reply_to':
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': audioPath,
//           'transcription': transcription,
//           'type': 'spiral',
//           'stage': data['stage'] ?? '',
//           'question': data['question'] ?? '',
//           'growth': data['growth'] ?? '',
//           'evolution': data['evolution'] ?? '',
//           'audio_url': data['audio_url'] ?? '',
//           'diarized': true,
//           'speaker_stages': speakerStages,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         lastStage = data['stage'];
//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Error finalizing voice message: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> getMessagesWithDateHeaders() {
//     List<Map<String, dynamic>> processed = [];
//     String? lastDate;

//     for (final msg in messages) {
//       final timestamp =
//           msg['timestamp'] is Timestamp
//               ? (msg['timestamp'] as Timestamp).toDate()
//               : msg['timestamp'] is String
//               ? DateTime.parse(msg['timestamp'])
//               : DateTime.now();
//       final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

//       if (lastDate != dateStr) {
//         processed.add({'type': 'date-header', 'date': timestamp});
//         lastDate = dateStr;
//       }

//       processed.add(msg);
//     }

//     return processed;
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.reply),
//           onPressed: () {
//             if (selectedMessageIds.length == 1) {
//               final message = messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//                 orElse: () => {},
//               );
//               if (message.isNotEmpty) {
//                 _setReplyToMessage(message);
//               }
//             }
//           },
//           color: Colors.black,
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText =
//         selectedMessage?['question'] ??
//         selectedMessage?['response'] ??
//         selectedMessage?['user'] ??
//         selectedMessage?['message'] ??
//         "";

//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     selectedMessage = null;
//                   });
//                 },
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
//     if (speakerStages.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         ...speakerStages.entries.map((entry) {
//           final speaker = entry.key;
//           final stage = entry.value['stage'] ?? 'Unknown';
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 12),
//                 children: [
//                   TextSpan(
//                     text: "$speaker: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey[800],
//                     ),
//                   ),
//                   TextSpan(
//                     text: stage,
//                     style: TextStyle(color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildChatBubble(Map<String, dynamic> msg) {
//     if (msg['type'] == 'date-header') {
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             DateFormat('EEEE, MMM d, yyyy').format(msg['date']),
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     final timestamp =
//         msg['timestamp'] is Timestamp
//             ? (msg['timestamp'] as Timestamp).toDate()
//             : msg['timestamp'] is String
//             ? DateTime.parse(msg['timestamp'])
//             : DateTime.now();
//     final isSelected = selectedMessageIds.contains(msg['id']);
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: () {
//         if (!_isSelecting) {
//           setState(() {
//             _isSelecting = true;
//             selectedMessageIds.add(msg['id']);
//           });
//         }
//       },
//       onTap: () {
//         if (_isSelecting) {
//           _toggleMessageSelection(msg['id']);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 40,
//                         color: Colors.grey,
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Expanded(
//                         child: Text(
//                           msg['reply_to'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'daily-task')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "📝 Inner Compass",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             msg['message'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 8),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.blue.withOpacity(0.5)
//                                 : isReply
//                                 ? Colors.blue.withOpacity(0.2)
//                                 : Colors.blue.withOpacity(0.3),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             msg['user'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] == '[Voice]' && msg['audioPath'] != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                         border: Border.all(color: Colors.blueGrey[100]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.mic,
//                                 color: Colors.blueGrey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Voice Message",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           AudioPlayerWidget(filePath: msg['audioPath']),
//                           if (msg['transcription'] != null &&
//                               msg['transcription'].isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Transcription:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueGrey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '"${msg['transcription']}"',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'chat')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.grey[300]!
//                                 : isReply
//                                 ? Colors.grey[100]!
//                                 : Colors.grey[200]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             msg['response'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'spiral')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.orange[200]!
//                                 : isReply
//                                 ? Colors.orange[50]!
//                                 : Colors.orange[100]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "🌀 Stage: ${msg['stage'] ?? ''}",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if (msg['diarized'] == true &&
//                               msg['speaker_stages'] != null)
//                             _buildSpeakerStages(
//                               Map<String, dynamic>.from(msg['speaker_stages']),
//                             ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "❓ ${msg['question'] ?? ''}",
//                             style: TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if ((msg['growth'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 '"${msg['growth']}"',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if ((msg['evolution'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 msg['evolution'],
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           if (msg['audio_url'] != null &&
//                               msg['audio_url'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: AudioPlayerWidget(
//                                 filePath: msg['audio_url'],
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'error')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100]!,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "❌ ${msg['message'] ?? 'Error'}",
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const SpiralEvolutionChartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       body: Container(
//         decoration: BoxDecoration(color: theme.colorScheme.background),
//         child: Column(
//           children: [
//             _buildReplyPreview(),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(12),
//                 itemCount: getMessagesWithDateHeaders().length,
//                 itemBuilder:
//                     (context, index) =>
//                         buildChatBubble(getMessagesWithDateHeaders()[index]),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 12,
//                 right: 12,
//                 top: 10,
//                 bottom: 20,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText:
//                             selectedMessage != null
//                                 ? "Replying..."
//                                 : "Type your reflection...",
//                         filled: true,
//                         fillColor: theme.colorScheme.surface,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       minLines: 1,
//                       maxLines: 5,
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(
//                       _isRecording ? Icons.stop_circle_outlined : Icons.mic,
//                       color:
//                           _isRecording
//                               ? Colors.red
//                               : theme.colorScheme.onSurface,
//                     ),
//                     onPressed: _isRecording ? _stopRecording : _startRecording,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed:
//                         isLoading ? null : () => sendEntry(_controller.text),
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AudioPlayerWidget extends StatefulWidget {
//   final String filePath;
//   const AudioPlayerWidget({super.key, required this.filePath});

//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   Duration? _duration;
//   Duration? _position;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioSession();
//     _player.durationStream.listen((duration) {
//       setState(() => _duration = duration);
//     });
//     _player.positionStream.listen((position) {
//       setState(() => _position = position);
//     });
//     _player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         setState(() => _isPlaying = false);
//       }
//     });
//   }

//   Future<void> _initAudioSession() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   Future<void> _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//     } else {
//       try {
//         if (widget.filePath.startsWith('http')) {
//           await _player.setUrl(widget.filePath);
//         } else {
//           await _player.setFilePath(widget.filePath);
//         }
//         await _player.play();
//       } catch (e) {
//         debugPrint('Error playing audio: $e');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
//       }
//     }
//     setState(() => _isPlaying = !_isPlaying);
//   }

//   String _formatDuration(Duration? duration) {
//     if (duration == null) return '--:--';
//     final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final activeColor = Colors.blueGrey[600];
//     final inactiveColor = Colors.blueGrey[200];
//     final textColor = Colors.blueGrey[600];

//     return Row(
//       children: [
//         IconButton(
//           icon: Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             color: activeColor,
//             size: 24,
//           ),
//           onPressed: _togglePlayPause,
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SliderTheme(
//                 data: SliderTheme.of(context).copyWith(
//                   activeTrackColor: activeColor,
//                   inactiveTrackColor: inactiveColor,
//                   trackHeight: 2,
//                   thumbColor: activeColor,
//                   thumbShape: const RoundSliderThumbShape(
//                     enabledThumbRadius: 6,
//                   ),
//                   overlayColor: Colors.blueGrey.withAlpha(32),
//                   overlayShape: const RoundSliderOverlayShape(
//                     overlayRadius: 12,
//                   ),
//                 ),
//                 child: Slider(
//                   value: (_position ?? Duration.zero).inMilliseconds.toDouble(),
//                   min: 0,
//                   max: _duration?.inMilliseconds.toDouble() ?? 1,
//                   onChanged: (value) {
//                     _player.seek(Duration(milliseconds: value.toInt()));
//                   },
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _formatDuration(_position),
//                     style: TextStyle(fontSize: 10, color: textColor),
//                   ),
//                   Text(
//                     _formatDuration(_duration),
//                     style: TextStyle(fontSize: 10, color: textColor),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart' as record;
// import 'package:path/path.dart' as path;
// import 'package:http_parser/http_parser.dart';
// import 'package:audioplayers/audioplayers.dart'; // Added for audio playback

// import '../data/bg_data.dart';
// import '../main.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;
//   final firestore = FirebaseFirestore.instance;
//   bool isLoading = false;
//   bool _isInitializing = true;
//   List<Map<String, dynamic>> messages = [];
//   String? lastStage;
//   Map<String, dynamic>? selectedMessage;
//   bool _isSelecting = false;
//   List<String> selectedMessageIds = [];
//   final ScrollController _scrollController = ScrollController();
//   final AudioPlayer _audioPlayer = AudioPlayer(); // Added for audio playback
//   bool _isPlaying = false; // Added to track playback state

//   final record.AudioRecorder _recorder = record.AudioRecorder();
//   bool _isRecording = false;
//   DateTime? _lastTaskCheck;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioPlayer.dispose(); // Dispose audio player
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _requestPermissions();
//     await _loadMessages();
//     await _checkAndAddDailyTask();
//     setState(() => _isInitializing = false);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.microphone, Permission.storage].request();
//   }

//   Future<void> _checkAndAddDailyTask() async {
//     final now = DateTime.now();
//     if (_lastTaskCheck != null &&
//         now.difference(_lastTaskCheck!) < Duration(minutes: 5)) {
//       return;
//     }
//     _lastTaskCheck = now;

//     final today = DateTime.now();
//     final todayStr = DateFormat('yyyy-MM-dd').format(today);

//     try {
//       final querySnapshot =
//           await firestore
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'daily-task')
//               .where(
//                 'timestamp',
//                 isGreaterThanOrEqualTo: DateTime(
//                   today.year,
//                   today.month,
//                   today.day,
//                 ),
//               )
//               .where(
//                 'timestamp',
//                 isLessThan: DateTime(today.year, today.month, today.day + 1),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isEmpty) {
//         await _addDailyTaskMessage();
//       }
//     } catch (e) {
//       debugPrint('Error checking for daily task: $e');
//       final hasDailyTask = messages.any((msg) {
//         if (msg['type'] == 'daily-task') {
//           DateTime timestamp;
//           if (msg['timestamp'] is Timestamp) {
//             timestamp = (msg['timestamp'] as Timestamp).toDate();
//           } else if (msg['timestamp'] is String) {
//             timestamp = DateTime.parse(msg['timestamp']);
//           } else {
//             timestamp = msg['timestamp'];
//           }
//           return DateFormat('yyyy-MM-dd').format(timestamp) == todayStr;
//         }
//         return false;
//       });

//       if (!hasDailyTask) {
//         await _addDailyTaskMessage();
//       }
//     }
//   }

//   Future<void> _addDailyTaskMessage() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.59.3.126:5000/daily_task?user_id=${user!.uid}'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         final taskMessage = {
//           'type': 'daily-task',
//           'message': data['task'] ?? 'Your daily reflection task',
//           'timestamp': today,
//           'task_id': data['timestamp'],
//           'completed': data['completed'] ?? false,
//         };

//         await _storeMessage(taskMessage);
//         await _loadMessages();
//       }
//     } catch (e) {
//       debugPrint('Error loading daily task: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     final snapshot =
//         await firestore
//             .collection('users')
//             .doc(user!.uid)
//             .collection('mergedMessages')
//             .orderBy('timestamp')
//             .get();

//     setState(() {
//       messages =
//           snapshot.docs
//               .map((doc) => doc.data()..['id'] = doc.id)
//               .cast<Map<String, dynamic>>()
//               .toList();

//       for (final msg in messages.reversed) {
//         if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
//           lastStage = msg['stage'];
//           break;
//         }
//       }
//     });
//   }

//   Future<void> sendEntry(String entry) async {
//     if (entry.trim().isEmpty) return;
//     setState(() => isLoading = true);
//     final url = Uri.parse("http://10.59.3.126:5000/merged");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "text": entry,
//           "last_stage": lastStage ?? "",
//           "reply_to":
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//           "is_spiral_reply":
//               selectedMessage != null && selectedMessage?['type'] == 'spiral',
//         }),
//       );

//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final base = {
//           'user': entry,
//           'timestamp': now,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         if (data['mode'] == 'chat') {
//           final msg = {
//             ...base,
//             'type': 'chat',
//             'response': data['response'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         } else if (data['mode'] == 'spiral') {
//           final newStage = data['stage'] ?? '';
//           lastStage = newStage;

//           final msg = {
//             ...base,
//             'type': 'spiral',
//             'stage': newStage,
//             'question': data['question'] ?? '',
//             'evolution': data['evolution'] ?? '',
//             'growth': data['growth'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         }

//         selectedMessage = null;
//       } else {
//         setState(() {
//           messages.add({
//             'type': 'error',
//             'message':
//                 'Server error: ${response.statusCode} - ${response.body}',
//             'timestamp': now,
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Network error: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//         _controller.clear();
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _storeMessage(Map<String, dynamic> msg) async {
//     final docRef = await firestore
//         .collection('users')
//         .doc(user!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     setState(() => messages.add({...msg, 'id': docRef.id}));
//   }

//   Future<String> _getTempFilePath() async {
//     final dir = await getTemporaryDirectory();
//     return path.join(dir.path, 'journal.wav');
//   }

//   Future<void> _startRecording() async {
//     final filePath = await _getTempFilePath();
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) return;

//     try {
//       await _recorder.start(
//         const record.RecordConfig(
//           encoder: record.AudioEncoder.wav,
//           sampleRate: 16000,
//           numChannels: 1,
//         ),
//         path: filePath,
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("❌ Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       setState(() => _isRecording = false);

//       if (filePath != null) {
//         final file = File(filePath);
//         if (await file.exists() && await file.length() > 0) {
//           await _sendVoiceToBackend(file);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to stop recording: $e");
//     }
//   }

//   Future<void> _sendVoiceToBackend(File file) async {
//     setState(() => isLoading = true);
//     final uri = Uri.parse("http://10.59.3.126:5000/reflect_transcription");

//     final request = http.MultipartRequest('POST', uri);
//     request.fields['last_stage'] = lastStage ?? '';
//     request.fields['reply_to'] =
//         selectedMessage != null
//             ? (selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "")
//             : "";
//     request.fields['is_spiral_reply'] =
//         (selectedMessage != null && selectedMessage?['type'] == 'spiral')
//             .toString();
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         file.path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);
//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         if (data['ask_speaker_pick'] == true) {
//           await _showSpeakerSelectionDialog(data);
//           return;
//         }

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': file.path,
//           'transcription': data['transcription'] ?? '',
//           'type': data['mode'],
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//           'diarized': data['diarized'] ?? false,
//           'speaker_stages': data['speaker_stages'] ?? {},
//         };

//         if (data['mode'] == 'chat') {
//           msg['response'] = data['response'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//         } else {
//           msg['stage'] = data['stage'] ?? '';
//           msg['question'] = data['question'] ?? '';
//           msg['growth'] = data['growth'] ?? '';
//           msg['evolution'] = data['evolution'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//           lastStage = data['stage'];
//         }

//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Voice processing failed: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _showSpeakerSelectionDialog(Map<String, dynamic> data) async {
//     final speakerStages = Map<String, dynamic>.from(data['speaker_stages']);
//     final transcription = data['transcription'] ?? '';

//     final selectedSpeaker = await showDialog<String>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Speaker'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '“Hey! I heard more than one person in this audio. Could you tell me which voice is yours so I can reflect the right insights?”',
//                   ),
//                   const SizedBox(height: 16),
//                   ...speakerStages.entries.map((entry) {
//                     return ListTile(
//                       title: Text('${entry.key} (${entry.value['stage']})'),
//                       subtitle: Text(
//                         entry.value['text'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () => Navigator.pop(context, entry.key),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );

//     if (selectedSpeaker != null) {
//       await _finalizeVoiceMessage(
//         speakerId: selectedSpeaker,
//         speakerStages: speakerStages,
//         transcription: transcription,
//         audioPath: data['audio_url'] ?? '',
//       );
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _finalizeVoiceMessage({
//     required String speakerId,
//     required Map<String, dynamic> speakerStages,
//     required String transcription,
//     required String audioPath,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.59.3.126:5000/finalize_stage'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'speaker_id': speakerId,
//           'speaker_stages': speakerStages,
//           'last_stage': lastStage ?? '',
//           'reply_to':
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': audioPath,
//           'transcription': transcription,
//           'type': 'spiral',
//           'stage': data['stage'] ?? '',
//           'question': data['question'] ?? '',
//           'growth': data['growth'] ?? '',
//           'evolution': data['evolution'] ?? '',
//           'audio_url': data['audio_url'] ?? '',
//           'diarized': true,
//           'speaker_stages': speakerStages,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         lastStage = data['stage'];
//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Error finalizing voice message: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> getMessagesWithDateHeaders() {
//     List<Map<String, dynamic>> processed = [];
//     String? lastDate;

//     for (final msg in messages) {
//       final timestamp =
//           msg['timestamp'] is Timestamp
//               ? (msg['timestamp'] as Timestamp).toDate()
//               : msg['timestamp'] is String
//               ? DateTime.parse(msg['timestamp'])
//               : DateTime.now();
//       final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

//       if (lastDate != dateStr) {
//         processed.add({'type': 'date-header', 'date': timestamp});
//         lastDate = dateStr;
//       }

//       processed.add(msg);
//     }

//     return processed;
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _playAudio(String? audioPath) async {
//     if (audioPath == null || audioPath.isEmpty) return;

//     try {
//       setState(() => _isPlaying = true);
//       await _audioPlayer.play(UrlSource(audioPath));
//       await _audioPlayer.onPlayerComplete.first;
//     } catch (e) {
//       debugPrint('Error playing audio: $e');
//     } finally {
//       setState(() => _isPlaying = false);
//     }
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.reply),
//           onPressed: () {
//             if (selectedMessageIds.length == 1) {
//               final message = messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//                 orElse: () => {},
//               );
//               if (message.isNotEmpty) {
//                 _setReplyToMessage(message);
//               }
//             }
//           },
//           color: Colors.black,
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText =
//         selectedMessage?['question'] ??
//         selectedMessage?['response'] ??
//         selectedMessage?['user'] ??
//         selectedMessage?['message'] ??
//         "";

//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     selectedMessage = null;
//                   });
//                 },
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
//     if (speakerStages.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         ...speakerStages.entries.map((entry) {
//           final speaker = entry.key;
//           final stage = entry.value['stage'] ?? 'Unknown';
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 12),
//                 children: [
//                   TextSpan(
//                     text: "$speaker: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey[800],
//                     ),
//                   ),
//                   TextSpan(
//                     text: stage,
//                     style: TextStyle(color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildChatBubble(Map<String, dynamic> msg) {
//     if (msg['type'] == 'date-header') {
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             DateFormat('EEEE, MMM d, yyyy').format(msg['date']),
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     final timestamp =
//         msg['timestamp'] is Timestamp
//             ? (msg['timestamp'] as Timestamp).toDate()
//             : msg['timestamp'] is String
//             ? DateTime.parse(msg['timestamp'])
//             : DateTime.now();
//     final isSelected = selectedMessageIds.contains(msg['id']);
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: () {
//         if (!_isSelecting) {
//           setState(() {
//             _isSelecting = true;
//             selectedMessageIds.add(msg['id']);
//           });
//         }
//       },
//       onTap: () {
//         if (_isSelecting) {
//           _toggleMessageSelection(msg['id']);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 40,
//                         color: Colors.grey,
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Expanded(
//                         child: Text(
//                           msg['reply_to'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'daily-task')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "📝 Inner Compass",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             msg['message'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 8),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.blue.withOpacity(0.5)
//                                 : isReply
//                                 ? Colors.blue.withOpacity(0.2)
//                                 : Colors.blue.withOpacity(0.3),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             msg['user'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] == '[Voice]' && msg['audioPath'] != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                         border: Border.all(color: Colors.blueGrey[100]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.mic,
//                                 color: Colors.blueGrey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Voice Message",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           if (msg['transcription'] != null &&
//                               msg['transcription'].isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Transcription:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueGrey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '"${msg['transcription']}"',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           const SizedBox(height: 8),
//                           ElevatedButton.icon(
//                             icon: Icon(
//                               _isPlaying ? Icons.stop : Icons.play_arrow,
//                               size: 20,
//                             ),
//                             label: Text(_isPlaying ? 'Stop' : 'Play'),
//                             onPressed: () => _playAudio(msg['audioPath']),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blueGrey[100],
//                               foregroundColor: Colors.blueGrey[800],
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'chat')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.grey[300]!
//                                 : isReply
//                                 ? Colors.grey[100]!
//                                 : Colors.grey[200]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             msg['response'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'spiral')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.orange[200]!
//                                 : isReply
//                                 ? Colors.orange[50]!
//                                 : Colors.orange[100]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "🌀 Stage: ${msg['stage'] ?? ''}",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if (msg['diarized'] == true &&
//                               msg['speaker_stages'] != null)
//                             _buildSpeakerStages(
//                               Map<String, dynamic>.from(msg['speaker_stages']),
//                             ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "❓ ${msg['question'] ?? ''}",
//                             style: TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if ((msg['growth'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 '"${msg['growth']}"',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if ((msg['evolution'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 msg['evolution'],
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'error')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100]!,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "❌ ${msg['message'] ?? 'Error'}",
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const SpiralEvolutionChartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       body: Container(
//         decoration: BoxDecoration(color: theme.colorScheme.background),
//         child: Column(
//           children: [
//             _buildReplyPreview(),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(12),
//                 itemCount: getMessagesWithDateHeaders().length,
//                 itemBuilder:
//                     (context, index) =>
//                         buildChatBubble(getMessagesWithDateHeaders()[index]),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 12,
//                 right: 12,
//                 top: 10,
//                 bottom: 20,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText:
//                             selectedMessage != null
//                                 ? "Replying..."
//                                 : "Type your reflection...",
//                         filled: true,
//                         fillColor: theme.colorScheme.surface,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       minLines: 1,
//                       maxLines: 5,
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(
//                       _isRecording ? Icons.stop_circle_outlined : Icons.mic,
//                       color:
//                           _isRecording
//                               ? Colors.red
//                               : theme.colorScheme.onSurface,
//                     ),
//                     onPressed: _isRecording ? _stopRecording : _startRecording,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed:
//                         isLoading ? null : () => sendEntry(_controller.text),
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart' as record;
// import 'package:path/path.dart' as path;
// import 'package:http_parser/http_parser.dart';
// import 'package:audioplayers/audioplayers.dart';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;
// import '../data/bg_data.dart';
// import '../main.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;
//   final firestore = FirebaseFirestore.instance;
//   bool isLoading = false;
//   bool _isInitializing = true;
//   List<Map<String, dynamic>> messages = [];
//   String? lastStage;
//   Map<String, dynamic>? selectedMessage;
//   bool _isSelecting = false;
//   List<String> selectedMessageIds = [];
//   final ScrollController _scrollController = ScrollController();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   String? _currentlyPlayingUrl;

//   final record.AudioRecorder _recorder = record.AudioRecorder();
//   bool _isRecording = false;
//   DateTime? _lastTaskCheck;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (state == PlayerState.stopped || state == PlayerState.completed) {
//         setState(() {
//           _isPlaying = false;
//           _currentlyPlayingUrl = null;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _requestPermissions();
//     await _loadMessages();
//     await _checkAndAddDailyTask();
//     setState(() => _isInitializing = false);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.microphone, Permission.storage].request();
//   }

//   Future<void> _checkAndAddDailyTask() async {
//     final now = DateTime.now();
//     if (_lastTaskCheck != null &&
//         now.difference(_lastTaskCheck!) < Duration(minutes: 5)) {
//       return;
//     }
//     _lastTaskCheck = now;

//     final today = DateTime.now();
//     final todayStr = DateFormat('yyyy-MM-dd').format(today);

//     try {
//       final querySnapshot =
//           await firestore
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'daily-task')
//               .where(
//                 'timestamp',
//                 isGreaterThanOrEqualTo: DateTime(
//                   today.year,
//                   today.month,
//                   today.day,
//                 ),
//               )
//               .where(
//                 'timestamp',
//                 isLessThan: DateTime(today.year, today.month, today.day + 1),
//               )
//               .limit(1)
//               .get();

//       if (querySnapshot.docs.isEmpty) {
//         await _addDailyTaskMessage();
//       }
//     } catch (e) {
//       debugPrint('Error checking for daily task: $e');
//       final hasDailyTask = messages.any((msg) {
//         if (msg['type'] == 'daily-task') {
//           DateTime timestamp;
//           if (msg['timestamp'] is Timestamp) {
//             timestamp = (msg['timestamp'] as Timestamp).toDate();
//           } else if (msg['timestamp'] is String) {
//             timestamp = DateTime.parse(msg['timestamp']);
//           } else {
//             timestamp = msg['timestamp'];
//           }
//           return DateFormat('yyyy-MM-dd').format(timestamp) == todayStr;
//         }
//         return false;
//       });

//       if (!hasDailyTask) {
//         await _addDailyTaskMessage();
//       }
//     }
//   }

//   Future<void> _addDailyTaskMessage() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.31.94:5000/daily_task?user_id=${user!.uid}'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         final taskMessage = {
//           'type': 'daily-task',
//           'message': data['task'] ?? 'Your daily reflection task',
//           'timestamp': today,
//           'task_id': data['timestamp'],
//           'completed': data['completed'] ?? false,
//         };

//         await _storeMessage(taskMessage);
//         await _loadMessages();
//       }
//     } catch (e) {
//       debugPrint('Error loading daily task: $e');
//     }
//   }

//   Future<void> _loadMessages() async {
//     final snapshot =
//         await firestore
//             .collection('users')
//             .doc(user!.uid)
//             .collection('mergedMessages')
//             .orderBy('timestamp')
//             .get();

//     setState(() {
//       messages =
//           snapshot.docs
//               .map((doc) => doc.data()..['id'] = doc.id)
//               .cast<Map<String, dynamic>>()
//               .toList();

//       for (final msg in messages.reversed) {
//         if (msg['type'] == 'spiral' && (msg['stage'] ?? '') != '') {
//           lastStage = msg['stage'];
//           break;
//         }
//       }
//     });
//   }

//   Future<void> sendEntry(String entry) async {
//     if (entry.trim().isEmpty) return;
//     setState(() => isLoading = true);
//     final url = Uri.parse("http://192.168.31.94:5000/merged");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "text": entry,
//           "last_stage": lastStage ?? "",
//           "reply_to":
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//           "is_spiral_reply":
//               selectedMessage != null && selectedMessage?['type'] == 'spiral',
//         }),
//       );

//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final base = {
//           'user': entry,
//           'timestamp': now,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         if (data['mode'] == 'chat') {
//           final msg = {
//             ...base,
//             'type': 'chat',
//             'response': data['response'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         } else if (data['mode'] == 'spiral') {
//           final newStage = data['stage'] ?? '';
//           lastStage = newStage;

//           final msg = {
//             ...base,
//             'type': 'spiral',
//             'stage': newStage,
//             'question': data['question'] ?? '',
//             'evolution': data['evolution'] ?? '',
//             'growth': data['growth'] ?? '',
//             'audio_url': data['audio_url'] ?? '',
//           };
//           await _storeMessage(msg);
//         }

//         selectedMessage = null;
//       } else {
//         setState(() {
//           messages.add({
//             'type': 'error',
//             'message':
//                 'Server error: ${response.statusCode} - ${response.body}',
//             'timestamp': now,
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Network error: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//         _controller.clear();
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _storeMessage(Map<String, dynamic> msg) async {
//     final docRef = await firestore
//         .collection('users')
//         .doc(user!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     setState(() => messages.add({...msg, 'id': docRef.id}));
//   }

//   Future<String> _getTempFilePath() async {
//     final dir = await getTemporaryDirectory();
//     return path.join(dir.path, 'journal.wav');
//   }

//   Future<void> _startRecording() async {
//     final filePath = await _getTempFilePath();
//     final hasPermission = await _recorder.hasPermission();
//     if (!hasPermission) return;

//     try {
//       await _recorder.start(
//         const record.RecordConfig(
//           encoder: record.AudioEncoder.wav,
//           sampleRate: 16000,
//           numChannels: 1,
//         ),
//         path: filePath,
//       );
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("❌ Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final filePath = await _recorder.stop();
//       setState(() => _isRecording = false);

//       if (filePath != null) {
//         final file = File(filePath);
//         if (await file.exists() && await file.length() > 0) {
//           await _sendVoiceToBackend(file);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Failed to stop recording: $e");
//     }
//   }

//   Future<void> _sendVoiceToBackend(File file) async {
//     setState(() => isLoading = true);
//     final uri = Uri.parse("http://192.168.31.94:5000/reflect_transcription");

//     final request = http.MultipartRequest('POST', uri);
//     request.fields['last_stage'] = lastStage ?? '';
//     request.fields['reply_to'] =
//         selectedMessage != null
//             ? (selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "")
//             : "";
//     request.fields['is_spiral_reply'] =
//         (selectedMessage != null && selectedMessage?['type'] == 'spiral')
//             .toString();
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'audio',
//         file.path,
//         contentType: MediaType('audio', 'wav'),
//       ),
//     );

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);
//       final now = DateTime.now();

//       if (response.statusCode == 200) {
//         if (data['ask_speaker_pick'] == true) {
//           await _showSpeakerSelectionDialog(data);
//           return;
//         }

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': file.path,
//           'transcription': data['transcription'] ?? '',
//           'type': data['mode'],
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//           'diarized': data['diarized'] ?? false,
//           'speaker_stages': data['speaker_stages'] ?? {},
//         };

//         if (data['mode'] == 'chat') {
//           msg['response'] = data['response'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//         } else {
//           msg['stage'] = data['stage'] ?? '';
//           msg['question'] = data['question'] ?? '';
//           msg['growth'] = data['growth'] ?? '';
//           msg['evolution'] = data['evolution'] ?? '';
//           msg['audio_url'] = data['audio_url'] ?? '';
//           lastStage = data['stage'];
//         }

//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Voice processing failed: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     }
//   }

//   Future<void> _showSpeakerSelectionDialog(Map<String, dynamic> data) async {
//     final speakerStages = Map<String, dynamic>.from(data['speaker_stages']);
//     final transcription = data['transcription'] ?? '';

//     final selectedSpeaker = await showDialog<String>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Speaker'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '“Hey! I heard more than one person in this audio. Could you tell me which voice is yours so I can reflect the right insights?”',
//                   ),
//                   const SizedBox(height: 16),
//                   ...speakerStages.entries.map((entry) {
//                     return ListTile(
//                       title: Text('${entry.key} (${entry.value['stage']})'),
//                       subtitle: Text(
//                         entry.value['text'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () => Navigator.pop(context, entry.key),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );

//     if (selectedSpeaker != null) {
//       await _finalizeVoiceMessage(
//         speakerId: selectedSpeaker,
//         speakerStages: speakerStages,
//         transcription: transcription,
//         audioPath: data['audio_url'] ?? '',
//       );
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _finalizeVoiceMessage({
//     required String speakerId,
//     required Map<String, dynamic> speakerStages,
//     required String transcription,
//     required String audioPath,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.31.94:5000/finalize_stage'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'speaker_id': speakerId,
//           'speaker_stages': speakerStages,
//           'last_stage': lastStage ?? '',
//           'reply_to':
//               selectedMessage != null
//                   ? (selectedMessage?['question'] ??
//                       selectedMessage?['response'] ??
//                       selectedMessage?['user'] ??
//                       selectedMessage?['message'] ??
//                       "")
//                   : "",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final now = DateTime.now();

//         final msg = {
//           'user': '[Voice]',
//           'timestamp': now,
//           'audioPath': audioPath,
//           'transcription': transcription,
//           'type': 'spiral',
//           'stage': data['stage'] ?? '',
//           'question': data['question'] ?? '',
//           'growth': data['growth'] ?? '',
//           'evolution': data['evolution'] ?? '',
//           'audio_url': data['audio_url'] ?? '',
//           'diarized': true,
//           'speaker_stages': speakerStages,
//           if (selectedMessage != null) 'reply_to_id': selectedMessage?['id'],
//           if (selectedMessage != null)
//             'reply_to':
//                 selectedMessage?['question'] ??
//                 selectedMessage?['response'] ??
//                 selectedMessage?['user'] ??
//                 selectedMessage?['message'] ??
//                 "",
//         };

//         lastStage = data['stage'];
//         await _storeMessage(msg);
//       }
//     } catch (e) {
//       setState(() {
//         messages.add({
//           'type': 'error',
//           'message': 'Error finalizing voice message: ${e.toString()}',
//           'timestamp': DateTime.now(),
//         });
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> getMessagesWithDateHeaders() {
//     List<Map<String, dynamic>> processed = [];
//     String? lastDate;

//     for (final msg in messages) {
//       final timestamp =
//           msg['timestamp'] is Timestamp
//               ? (msg['timestamp'] as Timestamp).toDate()
//               : msg['timestamp'] is String
//               ? DateTime.parse(msg['timestamp'])
//               : DateTime.now();
//       final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);

//       if (lastDate != dateStr) {
//         processed.add({'type': 'date-header', 'date': timestamp});
//         lastDate = dateStr;
//       }

//       processed.add(msg);
//     }

//     return processed;
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _playAudio(String? audioPath) async {
//     if (audioPath == null || audioPath.isEmpty) return;

//     try {
//       // If already playing this audio, stop it
//       if (_isPlaying && _currentlyPlayingUrl == audioPath) {
//         await _audioPlayer.stop();
//         setState(() {
//           _isPlaying = false;
//           _currentlyPlayingUrl = null;
//         });
//         return;
//       }

//       // If playing a different audio, stop it first
//       if (_isPlaying) {
//         await _audioPlayer.stop();
//       }

//       setState(() {
//         _isPlaying = true;
//         _currentlyPlayingUrl = audioPath;
//       });

//       // Check if it's a local file or remote URL
//       if (audioPath.startsWith('http')) {
//         await _audioPlayer.play(UrlSource(audioPath));
//       } else {
//         await _audioPlayer.play(DeviceFileSource(audioPath));
//       }
//     } catch (e) {
//       debugPrint('Error playing audio: $e');
//       setState(() {
//         _isPlaying = false;
//         _currentlyPlayingUrl = null;
//       });
//     }
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.reply),
//           onPressed: () {
//             if (selectedMessageIds.length == 1) {
//               final message = messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//                 orElse: () => {},
//               );
//               if (message.isNotEmpty) {
//                 _setReplyToMessage(message);
//               }
//             }
//           },
//           color: Colors.black,
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText =
//         selectedMessage?['question'] ??
//         selectedMessage?['response'] ??
//         selectedMessage?['user'] ??
//         selectedMessage?['message'] ??
//         "";

//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     selectedMessage = null;
//                   });
//                 },
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
//     if (speakerStages.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         ...speakerStages.entries.map((entry) {
//           final speaker = entry.key;
//           final stage = entry.value['stage'] ?? 'Unknown';
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 12),
//                 children: [
//                   TextSpan(
//                     text: "$speaker: ",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey[800],
//                     ),
//                   ),
//                   TextSpan(
//                     text: stage,
//                     style: TextStyle(color: Colors.blueGrey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildChatBubble(Map<String, dynamic> msg) {
//     if (msg['type'] == 'date-header') {
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             DateFormat('EEEE, MMM d, yyyy').format(msg['date']),
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     final timestamp =
//         msg['timestamp'] is Timestamp
//             ? (msg['timestamp'] as Timestamp).toDate()
//             : msg['timestamp'] is String
//             ? DateTime.parse(msg['timestamp'])
//             : DateTime.now();
//     final isSelected = selectedMessageIds.contains(msg['id']);
//     final isReply = msg['reply_to_id'] != null;
//     final isCurrentPlaying =
//         _currentlyPlayingUrl == msg['audioPath'] ||
//         _currentlyPlayingUrl == msg['audio_url'];

//     return GestureDetector(
//       onLongPress: () {
//         if (!_isSelecting) {
//           setState(() {
//             _isSelecting = true;
//             selectedMessageIds.add(msg['id']);
//           });
//         }
//       },
//       onTap: () {
//         if (_isSelecting) {
//           _toggleMessageSelection(msg['id']);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 40,
//                         color: Colors.grey,
//                         margin: const EdgeInsets.only(right: 8),
//                       ),
//                       Expanded(
//                         child: Text(
//                           msg['reply_to'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'daily-task')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[100],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "📝 Inner Compass",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             msg['message'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 8),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.blue.withOpacity(0.5)
//                                 : isReply
//                                 ? Colors.blue.withOpacity(0.2)
//                                 : Colors.blue.withOpacity(0.3),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             msg['user'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                         border: Border.all(color: Colors.blueGrey[100]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.mic,
//                                 color: Colors.blueGrey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Voice Message",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueGrey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           if (msg['transcription'] != null &&
//                               msg['transcription'].isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Transcription:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blueGrey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '"${msg['transcription']}"',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           const SizedBox(height: 8),
//                           ElevatedButton.icon(
//                             icon: Icon(
//                               isCurrentPlaying && _isPlaying
//                                   ? Icons.stop
//                                   : Icons.play_arrow,
//                               size: 20,
//                             ),
//                             label: Text(
//                               isCurrentPlaying && _isPlaying ? 'Stop' : 'Play',
//                             ),
//                             onPressed:
//                                 () => _playAudio(
//                                   msg['audio_url'] ?? msg['audioPath'],
//                                 ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blueGrey[100],
//                               foregroundColor: Colors.blueGrey[800],
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'chat')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.grey[300]!
//                                 : isReply
//                                 ? Colors.grey[100]!
//                                 : Colors.grey[200]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             msg['response'] ?? '',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'spiral')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected
//                                 ? Colors.orange[200]!
//                                 : isReply
//                                 ? Colors.orange[50]!
//                                 : Colors.orange[100]!,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "🌀 Stage: ${msg['stage'] ?? ''}",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if (msg['diarized'] == true &&
//                               msg['speaker_stages'] != null)
//                             _buildSpeakerStages(
//                               Map<String, dynamic>.from(msg['speaker_stages']),
//                             ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "❓ ${msg['question'] ?? ''}",
//                             style: TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           if ((msg['growth'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 '"${msg['growth']}"',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if ((msg['evolution'] ?? '').isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 msg['evolution'],
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           const SizedBox(height: 4),
//                           Text(
//                             DateFormat('hh:mm a').format(timestamp),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             if (msg['type'] == 'error')
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100]!,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "❌ ${msg['message'] ?? 'Error'}",
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => const SpiralEvolutionChartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//       body: Container(
//         decoration: BoxDecoration(color: theme.colorScheme.background),
//         child: Column(
//           children: [
//             _buildReplyPreview(),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(12),
//                 itemCount: getMessagesWithDateHeaders().length,
//                 itemBuilder:
//                     (context, index) =>
//                         buildChatBubble(getMessagesWithDateHeaders()[index]),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 12,
//                 right: 12,
//                 top: 10,
//                 bottom: 20,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText:
//                             selectedMessage != null
//                                 ? "Replying..."
//                                 : "Type your reflection...",
//                         filled: true,
//                         fillColor: theme.colorScheme.surface,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       minLines: 1,
//                       maxLines: 5,
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(
//                       _isRecording ? Icons.stop_circle_outlined : Icons.mic,
//                       color:
//                           _isRecording
//                               ? Colors.red
//                               : theme.colorScheme.onSurface,
//                     ),
//                     onPressed: _isRecording ? _stopRecording : _startRecording,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed:
//                         isLoading ? null : () => sendEntry(_controller.text),
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/modules/merged_reflect/audio_handler.dart';
// import '../screens/modules/merged_reflect/firebase_handler.dart';
// import '../screens/modules/merged_reflect/message_handler.dart';
// import '../screens/modules/merged_reflect/api_handler.dart';
// import '../screens/modules/merged_reflect/ui_components.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final AudioHandler _audioHandler = AudioHandler();
//   final FirebaseHandler _firebaseHandler = FirebaseHandler();
//   final MessageHandler _messageHandler = MessageHandler();
//   final ApiHandler _apiHandler = ApiHandler();
//   final TextEditingController _controller = TextEditingController();
//   bool _isInitializing = true;

//   DateTime _ensureValidTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime.now();
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String)
//       return DateTime.tryParse(timestamp) ?? DateTime.now();
//     if (timestamp is DateTime) return timestamp;
//     return DateTime.now();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       await _audioHandler.requestPermissions();
//       final messages = await _firebaseHandler.loadMessages();
//       _messageHandler.messages =
//           messages
//               .map(
//                 (msg) => {
//                   ...msg,
//                   'timestamp': _ensureValidTimestamp(msg['timestamp']),
//                 },
//               )
//               .toList()
//               .reversed
//               .toList();
//       _messageHandler.updateLastStage();

//       if (await _firebaseHandler.checkDailyTask()) {
//         await _addDailyTask();
//       }
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Initialization error: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isInitializing = false);
//       }
//     }
//   }

//   Future<void> _addDailyTask() async {
//     try {
//       final userId = _firebaseHandler.user?.uid;
//       if (userId == null) return;

//       final task = await _apiHandler.fetchDailyTask(userId);
//       final newMessage = {
//         'type': 'daily-task',
//         'message': task['task'],
//         'timestamp': DateTime.now(),
//         'completed': false,
//         'id': 'daily-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       _messageHandler.messages =
//           (await _firebaseHandler.loadMessages())
//               .map(
//                 (msg) => {
//                   ...msg,
//                   'timestamp': _ensureValidTimestamp(msg['timestamp']),
//                 },
//               )
//               .toList()
//               .reversed
//               .toList();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Failed to add daily task: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//       if (mounted) setState(() {});
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_controller.text.trim().isEmpty) return;
//     setState(() => _messageHandler.isLoading = true);

//     try {
//       final response = await _apiHandler.sendTextEntry(
//         text: _controller.text,
//         lastStage: _messageHandler.lastStage ?? 'initial',
//         replyTo:
//             _messageHandler.selectedMessage?['question'] ??
//             _messageHandler.selectedMessage?['response'] ??
//             _messageHandler.selectedMessage?['user'] ??
//             _messageHandler.selectedMessage?['message'] ??
//             "",
//         isSpiralReply: _messageHandler.selectedMessage?['type'] == 'spiral',
//       );

//       final newMessage = {
//         ...response,
//         'timestamp': _ensureValidTimestamp(response['timestamp']),
//         'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       _messageHandler.messages =
//           (await _firebaseHandler.loadMessages())
//               .map(
//                 (msg) => {
//                   ...msg,
//                   'timestamp': _ensureValidTimestamp(msg['timestamp']),
//                 },
//               )
//               .toList()
//               .reversed
//               .toList();

//       _messageHandler.selectedMessage = null;
//       _controller.clear();
//       _messageHandler.updateLastStage();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Error sending message: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _messageHandler.isLoading = false);
//       }
//     }
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return _messageHandler.isSelecting
//         ? AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => setState(() => _messageHandler.cancelSelection()),
//           ),
//           title: Text('${_messageHandler.selectedMessageIds.length} selected'),
//         )
//         : AppBar(
//           title: const Text("Reflect & Chat"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.show_chart),
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SpiralEvolutionChartScreen(),
//                     ),
//                   ),
//             ),
//           ],
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           if (_messageHandler.selectedMessage != null)
//             ReplyPreview(
//               replyTo: _messageHandler.selectedMessage!,
//               onCancelReply:
//                   () => setState(() => _messageHandler.selectedMessage = null),
//               isSpiral: _messageHandler.selectedMessage?['type'] == 'spiral',
//             ),
//           Expanded(
//             child: ListView.builder(
//               controller: _messageHandler.scrollController,
//               itemCount: _messageHandler.getMessagesWithDateHeaders().length,
//               itemBuilder: (ctx, idx) {
//                 final message =
//                     _messageHandler.getMessagesWithDateHeaders()[idx];
//                 return MessageBubble(
//                   message: message,
//                   isSelected: _messageHandler.selectedMessageIds.contains(
//                     message['id'],
//                   ),
//                   onTap:
//                       () => setState(
//                         () => _messageHandler.toggleMessageSelection(
//                           message['id'],
//                         ),
//                       ),
//                   onPlayAudio: () {
//                     final audioUrl =
//                         message['audio_url'] ?? message['audioPath'];
//                     if (audioUrl != null) {
//                       _audioHandler.playAudio(audioUrl);
//                     }
//                   },
//                   isPlaying:
//                       _audioHandler.isPlaying &&
//                       _audioHandler.currentlyPlayingUrl ==
//                           (message['audio_url'] ?? message['audioPath']),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText:
//                           _messageHandler.selectedMessage != null
//                               ? "Replying..."
//                               : "Type your reflection...",
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _audioHandler.isRecording
//                         ? Icons.stop_circle_outlined
//                         : Icons.mic,
//                     color: _audioHandler.isRecording ? Colors.red : null,
//                   ),
//                   onPressed: () async {
//                     if (_audioHandler.isRecording) {
//                       final path = await _audioHandler.stopRecording();
//                       if (path != null) {
//                         final file = File(path);
//                         if (await file.exists()) {
//                           try {
//                             setState(() => _messageHandler.isLoading = true);
//                             final response = await _apiHandler
//                                 .sendVoiceRecording(
//                                   file: file,
//                                   lastStage:
//                                       _messageHandler.lastStage ?? 'initial',
//                                   replyTo:
//                                       _messageHandler
//                                           .selectedMessage?['question'] ??
//                                       _messageHandler
//                                           .selectedMessage?['response'] ??
//                                       _messageHandler
//                                           .selectedMessage?['user'] ??
//                                       _messageHandler
//                                           .selectedMessage?['message'] ??
//                                       "",
//                                   isSpiralReply:
//                                       _messageHandler
//                                           .selectedMessage?['type'] ==
//                                       'spiral',
//                                 );
//                             response['timestamp'] = _ensureValidTimestamp(
//                               response['timestamp'],
//                             );
//                             await _firebaseHandler.storeMessage(response);
//                             _messageHandler.messages =
//                                 (await _firebaseHandler.loadMessages())
//                                     .map(
//                                       (msg) => {
//                                         ...msg,
//                                         'timestamp': _ensureValidTimestamp(
//                                           msg['timestamp'],
//                                         ),
//                                       },
//                                     )
//                                     .toList()
//                                     .reversed
//                                     .toList();
//                             _messageHandler.selectedMessage = null;
//                           } catch (e) {
//                             _messageHandler.messages.add({
//                               'type': 'error',
//                               'message': 'Voice message error: ${e.toString()}',
//                               'timestamp': DateTime.now(),
//                               'id':
//                                   'error-${DateTime.now().millisecondsSinceEpoch}',
//                             });
//                           } finally {
//                             if (mounted) {
//                               setState(() => _messageHandler.isLoading = false);
//                             }
//                           }
//                         }
//                       }
//                     } else {
//                       await _audioHandler.startRecording();
//                     }
//                     setState(() {});
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _messageHandler.isLoading ? null : _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _audioHandler.dispose();
//     _controller.dispose();
//     _messageHandler.scrollController.dispose();
//     super.dispose();
//   }
// }
// lib/screens/merged_reflect_screen.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/modules/merged_reflect/audio_handler.dart';
// import '../screens/modules/merged_reflect/firebase_handler.dart';
// import '../screens/modules/merged_reflect/message_handler.dart';
// import '../screens/modules/merged_reflect/api_handler.dart';
// import '../screens/modules/merged_reflect/ui_components.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final AudioHandler _audioHandler = AudioHandler();
//   final FirebaseHandler _firebaseHandler = FirebaseHandler();
//   final MessageHandler _messageHandler = MessageHandler();
//   final ApiHandler _apiHandler = ApiHandler();
//   final TextEditingController _controller = TextEditingController();
//   bool _isInitializing = true;

//   DateTime _ensureValidTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime.now();
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) {
//       final parsed = DateTime.tryParse(timestamp);
//       return parsed ?? DateTime.now();
//     }
//     if (timestamp is DateTime) return timestamp;
//     return DateTime.now();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       await _audioHandler.requestPermissions();

//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();

//       _messageHandler.updateLastStage();

//       if (await _firebaseHandler.checkDailyTask()) {
//         await _addDailyTask();
//       }
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Initialization error: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) setState(() => _isInitializing = false);
//     }
//   }

//   Future<void> _addDailyTask() async {
//     try {
//       final userId = _firebaseHandler.user?.uid;
//       if (userId == null) return;

//       final task = await _apiHandler.fetchDailyTask(userId);
//       final newMessage = {
//         'type': 'daily-task',
//         'message': task['task'],
//         'timestamp': Timestamp.now(),
//         'completed': false,
//         'id': 'daily-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Failed to add daily task: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//       if (mounted) setState(() {});
//     }
//   }

//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     final userMessage = {
//       'text': text,
//       'type': 'user',
//       'timestamp': Timestamp.now(),
//       'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
//     };

//     await _firebaseHandler.storeMessage(userMessage);
//     _controller.clear();
//     setState(() => _messageHandler.isLoading = true);

//     try {
//       final response = await _apiHandler.sendTextEntry(
//         text: text,
//         lastStage: _messageHandler.lastStage ?? 'initial',
//         replyTo:
//             _messageHandler.selectedMessage?['question'] ??
//             _messageHandler.selectedMessage?['response'] ??
//             _messageHandler.selectedMessage?['user'] ??
//             _messageHandler.selectedMessage?['message'] ??
//             "",
//         isSpiralReply: _messageHandler.selectedMessage?['type'] == 'spiral',
//       );

//       final newMessage = {
//         ...response,
//         'timestamp': _ensureValidTimestamp(response['timestamp']),
//         'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();

//       _messageHandler.selectedMessage = null;
//       _messageHandler.updateLastStage();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Error sending message: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) setState(() => _messageHandler.isLoading = false);
//     }
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return _messageHandler.isSelecting
//         ? AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => setState(() => _messageHandler.cancelSelection()),
//           ),
//           title: Text('${_messageHandler.selectedMessageIds.length} selected'),
//         )
//         : AppBar(
//           title: const Text("Reflect & Chat"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.show_chart),
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SpiralEvolutionChartScreen(),
//                     ),
//                   ),
//             ),
//           ],
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           if (_messageHandler.selectedMessage != null)
//             ReplyPreview(
//               replyTo: _messageHandler.selectedMessage!,
//               onCancelReply:
//                   () => setState(() => _messageHandler.selectedMessage = null),
//               isSpiral: _messageHandler.selectedMessage?['type'] == 'spiral',
//             ),
//           Expanded(
//             child: ListView.builder(
//               controller: _messageHandler.scrollController,
//               itemCount: _messageHandler.getMessagesWithDateHeaders().length,
//               itemBuilder: (ctx, idx) {
//                 final message =
//                     _messageHandler.getMessagesWithDateHeaders()[idx];
//                 return MessageBubble(
//                   message: message,
//                   isSelected: _messageHandler.selectedMessageIds.contains(
//                     message['id'],
//                   ),
//                   onTap:
//                       () => setState(
//                         () => _messageHandler.toggleMessageSelection(
//                           message['id'],
//                         ),
//                       ),
//                   onPlayAudio: () {
//                     final audioUrl =
//                         message['audio_url'] ?? message['audioPath'];
//                     if (audioUrl != null) {
//                       _audioHandler.playAudio(audioUrl);
//                     }
//                   },
//                   isPlaying:
//                       _audioHandler.isPlaying &&
//                       _audioHandler.currentlyPlayingUrl ==
//                           (message['audio_url'] ?? message['audioPath']),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText:
//                           _messageHandler.selectedMessage != null
//                               ? "Replying..."
//                               : "Type your reflection...",
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _audioHandler.isRecording
//                         ? Icons.stop_circle_outlined
//                         : Icons.mic,
//                     color: _audioHandler.isRecording ? Colors.red : null,
//                   ),
//                   onPressed: () async {
//                     if (_audioHandler.isRecording) {
//                       final path = await _audioHandler.stopRecording();
//                       if (path != null) {
//                         final file = File(path);
//                         if (await file.exists()) {
//                           try {
//                             setState(() => _messageHandler.isLoading = true);
//                             final response = await _apiHandler
//                                 .sendVoiceRecording(
//                                   file: file,
//                                   lastStage:
//                                       _messageHandler.lastStage ?? 'initial',
//                                   replyTo:
//                                       _messageHandler
//                                           .selectedMessage?['question'] ??
//                                       _messageHandler
//                                           .selectedMessage?['response'] ??
//                                       _messageHandler
//                                           .selectedMessage?['user'] ??
//                                       _messageHandler
//                                           .selectedMessage?['message'] ??
//                                       "",
//                                   isSpiralReply:
//                                       _messageHandler
//                                           .selectedMessage?['type'] ==
//                                       'spiral',
//                                 );
//                             response['timestamp'] = _ensureValidTimestamp(
//                               response['timestamp'],
//                             );
//                             await _firebaseHandler.storeMessage(response);
//                             final messages =
//                                 await _firebaseHandler
//                                     .loadMessagesOrderedByTimestamp();
//                             _messageHandler.messages =
//                                 messages.map((msg) {
//                                   return {
//                                     ...msg,
//                                     'timestamp': _ensureValidTimestamp(
//                                       msg['timestamp'],
//                                     ),
//                                   };
//                                 }).toList();
//                             _messageHandler.selectedMessage = null;
//                           } catch (e) {
//                             _messageHandler.messages.add({
//                               'type': 'error',
//                               'message': 'Voice message error: ${e.toString()}',
//                               'timestamp': DateTime.now(),
//                               'id':
//                                   'error-${DateTime.now().millisecondsSinceEpoch}',
//                             });
//                           } finally {
//                             if (mounted) {
//                               setState(() => _messageHandler.isLoading = false);
//                             }
//                           }
//                         }
//                       }
//                     } else {
//                       await _audioHandler.startRecording();
//                     }
//                     setState(() {});
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _messageHandler.isLoading ? null : _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _audioHandler.dispose();
//     _controller.dispose();
//     _messageHandler.scrollController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/modules/merged_reflect/audio_handler.dart';
// import '../screens/modules/merged_reflect/firebase_handler.dart';
// import '../screens/modules/merged_reflect/message_handler.dart';
// import '../screens/modules/merged_reflect/api_handler.dart';
// import '../screens/modules/merged_reflect/ui_components.dart';
// import '../screens/spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final AudioHandler _audioHandler = AudioHandler();
//   final FirebaseHandler _firebaseHandler = FirebaseHandler();
//   final MessageHandler _messageHandler = MessageHandler();
//   final ApiHandler _apiHandler = ApiHandler();
//   final TextEditingController _controller = TextEditingController();
//   bool _isInitializing = true;

//   DateTime _ensureValidTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime.now();
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) {
//       final parsed = DateTime.tryParse(timestamp);
//       return parsed ?? DateTime.now();
//     }
//     if (timestamp is DateTime) return timestamp;
//     return DateTime.now();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       await _audioHandler.requestPermissions();
//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();
//       _messageHandler.updateLastStage();

//       if (await _firebaseHandler.checkDailyTask()) {
//         await _addDailyTask();
//       }
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Initialization error: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) setState(() => _isInitializing = false);
//     }
//   }

//   Future<void> _addDailyTask() async {
//     try {
//       final userId = _firebaseHandler.user?.uid;
//       if (userId == null) return;

//       final task = await _apiHandler.fetchDailyTask(userId);
//       final newMessage = {
//         'type': 'daily-task',
//         'message': task['task'],
//         'timestamp': Timestamp.now(),
//         'completed': false,
//         'id': 'daily-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Failed to add daily task: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//       if (mounted) setState(() {});
//     }
//   }

//   // Future<void> _sendMessage() async {
//   //   final text = _controller.text.trim();
//   //   if (text.isEmpty) return;

//   //   // Store user message first (change 'user' to 'text')
//   //   final userMessage = {
//   //     'text': text, // <-- changed from 'user': text
//   //     'type': 'user',
//   //     'timestamp': Timestamp.now(),
//   //     'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
//   //   };
//   //   await _firebaseHandler.storeMessage(userMessage);
//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     // Store user message with 'user' field
//     final userMessage = {
//       'user': text, // <-- use 'user' not 'text'
//       'timestamp': Timestamp.now(),
//       'type': 'chat', // or 'user' if you want to distinguish
//       'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
//       if (_messageHandler.selectedMessage != null)
//         'reply_to_id': _messageHandler.selectedMessage?['id'],
//       if (_messageHandler.selectedMessage != null)
//         'reply_to':
//             _messageHandler.selectedMessage?['question'] ??
//             _messageHandler.selectedMessage?['response'] ??
//             _messageHandler.selectedMessage?['user'] ??
//             _messageHandler.selectedMessage?['message'] ??
//             "",
//     };
//     await _firebaseHandler.storeMessage(userMessage);
//     // ...existing code for bot response...

//     _controller.clear();
//     setState(() => _messageHandler.isLoading = true);

//     try {
//       final response = await _apiHandler.sendTextEntry(
//         text: text,
//         lastStage: _messageHandler.lastStage ?? 'initial',
//         replyTo:
//             _messageHandler.selectedMessage?['question'] ??
//             _messageHandler.selectedMessage?['response'] ??
//             _messageHandler
//                 .selectedMessage?['text'] ?? // <-- changed from 'user'
//             _messageHandler.selectedMessage?['message'] ??
//             "",
//         isSpiralReply: _messageHandler.selectedMessage?['type'] == 'spiral',
//       );

//       final newMessage = {
//         ...response,
//         'timestamp': _ensureValidTimestamp(response['timestamp']),
//         'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
//       };

//       await _firebaseHandler.storeMessage(newMessage);
//       final messages = await _firebaseHandler.loadMessagesOrderedByTimestamp();
//       _messageHandler.messages =
//           messages.map((msg) {
//             return {
//               ...msg,
//               'timestamp': _ensureValidTimestamp(msg['timestamp']),
//             };
//           }).toList();

//       _messageHandler.selectedMessage = null;
//       _messageHandler.updateLastStage();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Error sending message: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) setState(() => _messageHandler.isLoading = false);
//     }
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return _messageHandler.isSelecting
//         ? AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => setState(() => _messageHandler.cancelSelection()),
//           ),
//           title: Text('${_messageHandler.selectedMessageIds.length} selected'),
//         )
//         : AppBar(
//           title: const Text("Reflect & Chat"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.show_chart),
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SpiralEvolutionChartScreen(),
//                     ),
//                   ),
//             ),
//           ],
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           if (_messageHandler.selectedMessage != null)
//             ReplyPreview(
//               replyTo: _messageHandler.selectedMessage!,
//               onCancelReply:
//                   () => setState(() => _messageHandler.selectedMessage = null),
//               isSpiral: _messageHandler.selectedMessage?['type'] == 'spiral',
//             ),
//           Expanded(
//             child: ListView.builder(
//               controller: _messageHandler.scrollController,
//               itemCount: _messageHandler.getMessagesWithDateHeaders().length,
//               itemBuilder: (ctx, idx) {
//                 final message =
//                     _messageHandler.getMessagesWithDateHeaders()[idx];
//                 return MessageBubble(
//                   message: message,
//                   isSelected: _messageHandler.selectedMessageIds.contains(
//                     message['id'],
//                   ),
//                   onTap:
//                       () => setState(
//                         () => _messageHandler.toggleMessageSelection(
//                           message['id'],
//                         ),
//                       ),
//                   onPlayAudio: () {
//                     final audioUrl =
//                         message['audio_url'] ?? message['audioPath'];
//                     if (audioUrl != null) {
//                       _audioHandler.playAudio(audioUrl);
//                     }
//                   },
//                   isPlaying:
//                       _audioHandler.isPlaying &&
//                       _audioHandler.currentlyPlayingUrl ==
//                           (message['audio_url'] ?? message['audioPath']),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText:
//                           _messageHandler.selectedMessage != null
//                               ? "Replying..."
//                               : "Type your reflection...",
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _audioHandler.isRecording
//                         ? Icons.stop_circle_outlined
//                         : Icons.mic,
//                     color: _audioHandler.isRecording ? Colors.red : null,
//                   ),

//                   onPressed: () async {
//                     if (_audioHandler.isRecording) {
//                       final path = await _audioHandler.stopRecording();
//                       if (path != null) {
//                         final file = File(path);
//                         if (await file.exists()) {
//                           try {
//                             setState(() => _messageHandler.isLoading = true);

//                             final userVoiceMessage = {
//                               'user': '[Voice]',
//                               'timestamp': Timestamp.now(),
//                               'type':
//                                   'chat', // or 'spiral' depending on context
//                               'audioPath': path,
//                               'id':
//                                   'user-voice-${DateTime.now().millisecondsSinceEpoch}',
//                               if (_messageHandler.selectedMessage != null)
//                                 'reply_to_id':
//                                     _messageHandler.selectedMessage?['id'],
//                               if (_messageHandler.selectedMessage != null)
//                                 'reply_to':
//                                     _messageHandler
//                                         .selectedMessage?['question'] ??
//                                     _messageHandler
//                                         .selectedMessage?['response'] ??
//                                     _messageHandler.selectedMessage?['user'] ??
//                                     _messageHandler
//                                         .selectedMessage?['message'] ??
//                                     "",
//                             };
//                             await _firebaseHandler.storeMessage(
//                               userVoiceMessage,
//                             );

//                             final response = await _apiHandler
//                                 .sendVoiceRecording(
//                                   file: file,
//                                   lastStage:
//                                       _messageHandler.lastStage ?? 'initial',
//                                   replyTo:
//                                       _messageHandler
//                                           .selectedMessage?['question'] ??
//                                       _messageHandler
//                                           .selectedMessage?['response'] ??
//                                       _messageHandler
//                                           .selectedMessage?['user'] ??
//                                       _messageHandler
//                                           .selectedMessage?['message'] ??
//                                       "",
//                                   isSpiralReply:
//                                       _messageHandler
//                                           .selectedMessage?['type'] ==
//                                       'spiral',
//                                 );
//                             response['timestamp'] = _ensureValidTimestamp(
//                               response['timestamp'],
//                             );
//                             await _firebaseHandler.storeMessage(response);
//                             final messages =
//                                 await _firebaseHandler
//                                     .loadMessagesOrderedByTimestamp();
//                             _messageHandler.messages =
//                                 messages.map((msg) {
//                                   return {
//                                     ...msg,
//                                     'timestamp': _ensureValidTimestamp(
//                                       msg['timestamp'],
//                                     ),
//                                   };
//                                 }).toList();
//                             _messageHandler.selectedMessage = null;
//                           } catch (e) {
//                             _messageHandler.messages.add({
//                               'type': 'error',
//                               'message': 'Voice message error: ${e.toString()}',
//                               'timestamp': DateTime.now(),
//                               'id':
//                                   'error-${DateTime.now().millisecondsSinceEpoch}',
//                             });
//                           } finally {
//                             if (mounted)
//                               setState(() => _messageHandler.isLoading = false);
//                           }
//                         }
//                       }
//                     } else {
//                       await _audioHandler.startRecording();
//                     }
//                     setState(() {});
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _messageHandler.isLoading ? null : _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _audioHandler.dispose();
//     _controller.dispose();
//     _messageHandler.scrollController.dispose();
//     super.dispose();
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screens/modules/merged_reflect/audio_handler.dart';
// import '../screens/modules/merged_reflect/firebase_handler.dart';
// import '../screens/modules/merged_reflect/message_handler.dart';
// import '../screens/modules/merged_reflect/api_handler.dart';
// import '../screens/modules/merged_reflect/ui_components.dart';
// import '../screens/spiral_evolution_chart.dart';
//
// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});
//
//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }
//
// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final AudioHandler _audioHandler = AudioHandler();
//   final FirebaseHandler _firebaseHandler = FirebaseHandler();
//   final MessageHandler _messageHandler = MessageHandler();
//   final ApiHandler _apiHandler = ApiHandler();
//   final TextEditingController _controller = TextEditingController();
//   bool _isInitializing = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }
//
//   Future<void> _initializeData() async {
//     try {
//       await _audioHandler.requestPermissions();
//       await _messageHandler.loadMessages();
//
//       if (await _firebaseHandler.checkDailyTask()) {
//         await _addDailyTask();
//       }
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Initialization error: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       if (mounted) setState(() => _isInitializing = false);
//     }
//   }
//
//   Future<void> _addDailyTask() async {
//     try {
//       final userId = _firebaseHandler.user?.uid;
//       if (userId == null) return;
//
//       final task = await _apiHandler.fetchDailyTask(userId);
//       final newMessage = {
//         'type': 'daily-task',
//         'message': task['task'],
//         'timestamp': FieldValue.serverTimestamp(),
//         'completed': false,
//       };
//
//       await _firebaseHandler.storeMessage(newMessage);
//       await _messageHandler.loadMessages();
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Failed to add daily task: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//       if (mounted) setState(() {});
//     }
//   }
//
//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     final userMessage = {
//       'user': text,
//       'timestamp': FieldValue.serverTimestamp(),
//       'type': 'user',
//       if (_messageHandler.selectedMessage != null)
//         'reply_to_id': _messageHandler.selectedMessage?['id'],
//       if (_messageHandler.selectedMessage != null)
//         'reply_to': _getReplyToText(_messageHandler.selectedMessage),
//     };
//
//     await _firebaseHandler.storeMessage(userMessage);
//     _controller.clear();
//     setState(() => _messageHandler.isLoading = true);
//
//     try {
//       await _messageHandler.loadMessages();
//
//       final response = await _apiHandler.sendTextEntry(
//         text: text,
//         lastStage: _messageHandler.lastStage,
//         replyTo: _getReplyToText(_messageHandler.selectedMessage),
//         isSpiralReply: _messageHandler.selectedMessage?['type'] == 'spiral',
//       );
//
//       await _firebaseHandler.storeMessage({
//         ...response,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       await _messageHandler.loadMessages();
//       _messageHandler.selectedMessage = null;
//     } catch (e) {
//       _messageHandler.messages.add({
//         'type': 'error',
//         'message': 'Error: ${e.toString()}',
//         'timestamp': DateTime.now(),
//         'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
//       });
//     } finally {
//       setState(() => _messageHandler.isLoading = false);
//     }
//   }
//
//   String _getReplyToText(Map<String, dynamic>? message) {
//     if (message == null) return '';
//     return message['question'] ??
//         message['response'] ??
//         message['user'] ??
//         message['message'] ??
//         '';
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return _messageHandler.isSelecting
//         ? AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => setState(() => _messageHandler.cancelSelection()),
//           ),
//           title: Text('${_messageHandler.selectedMessageIds.length} selected'),
//         )
//         : AppBar(
//           title: const Text("Reflect & Chat"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.show_chart),
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SpiralEvolutionChartScreen(),
//                     ),
//                   ),
//             ),
//           ],
//         );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           if (_messageHandler.selectedMessage != null)
//             ReplyPreview(
//               replyTo: _messageHandler.selectedMessage!,
//               onCancelReply:
//                   () => setState(() => _messageHandler.selectedMessage = null),
//               isSpiral: _messageHandler.selectedMessage?['type'] == 'spiral',
//             ),
//           Expanded(
//             child: ListView.builder(
//               controller: _messageHandler.scrollController,
//               itemCount: _messageHandler.getMessagesWithDateHeaders().length,
//               itemBuilder: (ctx, idx) {
//                 final message =
//                     _messageHandler.getMessagesWithDateHeaders()[idx];
//                 return MessageBubble(
//                   message: message,
//                   isSelected: _messageHandler.selectedMessageIds.contains(
//                     message['id'],
//                   ),
//                   onTap:
//                       () => setState(
//                         () => _messageHandler.toggleMessageSelection(
//                           message['id'],
//                         ),
//                       ),
//                   onPlayAudio: () {
//                     final audioUrl =
//                         message['audio_url'] ?? message['audioPath'];
//                     if (audioUrl != null) {
//                       _audioHandler.playAudio(audioUrl);
//                     }
//                   },
//                   isPlaying:
//                       _audioHandler.isPlaying &&
//                       _audioHandler.currentlyPlayingUrl ==
//                           (message['audio_url'] ?? message['audioPath']),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText:
//                           _messageHandler.selectedMessage != null
//                               ? "Replying..."
//                               : "Type your reflection...",
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _audioHandler.isRecording
//                         ? Icons.stop_circle_outlined
//                         : Icons.mic,
//                     color: _audioHandler.isRecording ? Colors.red : null,
//                   ),
//                   onPressed: () async {
//                     if (_audioHandler.isRecording) {
//                       final path = await _audioHandler.stopRecording();
//                       if (path != null) {
//                         final file = File(path);
//                         if (await file.exists()) {
//                           try {
//                             setState(() => _messageHandler.isLoading = true);
//
//                             final userVoiceMessage = {
//                               'user': '[Voice]',
//                               'timestamp': FieldValue.serverTimestamp(),
//                               'type': 'user',
//                               'audioPath': path,
//                               if (_messageHandler.selectedMessage != null)
//                                 'reply_to_id':
//                                     _messageHandler.selectedMessage?['id'],
//                               if (_messageHandler.selectedMessage != null)
//                                 'reply_to': _getReplyToText(
//                                   _messageHandler.selectedMessage,
//                                 ),
//                             };
//                             await _firebaseHandler.storeMessage(
//                               userVoiceMessage,
//                             );
//
//                             final response = await _apiHandler
//                                 .sendVoiceRecording(
//                                   file: file,
//                                   lastStage: _messageHandler.lastStage,
//                                   replyTo: _getReplyToText(
//                                     _messageHandler.selectedMessage,
//                                   ),
//                                   isSpiralReply:
//                                       _messageHandler
//                                           .selectedMessage?['type'] ==
//                                       'spiral',
//                                 );
//
//                             await _firebaseHandler.storeMessage({
//                               ...response,
//                               'timestamp': FieldValue.serverTimestamp(),
//                             });
//
//                             await _messageHandler.loadMessages();
//                             _messageHandler.selectedMessage = null;
//                           } catch (e) {
//                             _messageHandler.messages.add({
//                               'type': 'error',
//                               'message': 'Voice message error: ${e.toString()}',
//                               'timestamp': DateTime.now(),
//                               'id':
//                                   'error-${DateTime.now().millisecondsSinceEpoch}',
//                             });
//                           } finally {
//                             setState(() => _messageHandler.isLoading = false);
//                           }
//                         }
//                       }
//                     } else {
//                       await _audioHandler.startRecording();
//                     }
//                     setState(() {});
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _messageHandler.isLoading ? null : _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _audioHandler.dispose();
//     _controller.dispose();
//     _messageHandler.scrollController.dispose();
//     super.dispose();
//   }
// }
// // screens/merged_reflect_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'modules/reflect/reflect_controller.dart';
// import 'modules/reflect/reflect_ui.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();
//   late ReflectController _reflectController;

//   @override
//   void initState() {
//     super.initState();
//     _reflectController = ReflectController();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     await _reflectController.loadMessages();
//     await _reflectController.checkAndAddDailyTask();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _reflectController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: _reflectController,
//       child: Consumer<ReflectController>(
//         builder: (context, controller, child) {
//           return Scaffold(
//             appBar:
//                 controller.isSelecting
//                     ? ReflectUI.buildSelectionAppBar(
//                       onCancel: controller.cancelSelection,
//                       selectedCount: controller.selectedMessageIds.length,
//                       onReply: () => controller.setReplyToSelected(),
//                     )
//                     : AppBar(
//                       title: const Text("Reflect & Chat"),
//                       actions: [
//                         IconButton(
//                           icon: const Icon(Icons.show_chart),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) =>
//                                         const SpiralEvolutionChartScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//             body: _buildBody(context, controller),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context, ReflectController controller) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.background,
//           ),
//           child: Column(
//             children: [
//               ReflectUI.buildReplyPreview(
//                 message: controller.selectedMessage,
//                 onClearReply: () => controller.selectedMessage = null,
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(12),
//                   itemCount: controller.messages.length,
//                   itemBuilder:
//                       (context, index) => ReflectUI.buildMessageBubble(
//                         context: context,
//                         message: controller.messages[index],
//                         isSelected: controller.selectedMessageIds.contains(
//                           controller.messages[index].id,
//                         ),
//                         isPlaying:
//                             controller.isPlaying &&
//                             controller.currentlyPlayingUrl ==
//                                 (controller.messages[index].audioUrl ??
//                                     controller.messages[index].audioPath),
//                         onTap:
//                             () => controller.toggleMessageSelection(
//                               controller.messages[index].id!,
//                             ),
//                         onLongPress:
//                             () => controller.startMessageSelection(
//                               controller.messages[index].id!,
//                             ),
//                         onPlayAudio:
//                             () => controller.playMessageAudio(
//                               controller.messages[index].audioUrl ??
//                                   controller.messages[index].audioPath,
//                             ),
//                       ),
//                 ),
//               ),
//               _buildInputArea(context, controller),
//             ],
//           ),
//         ),
//         if (controller.isProcessing)
//           const Positioned.fill(
//             child: ModalBarrier(color: Colors.black54, dismissible: false),
//           ),
//         if (controller.isProcessing)
//           const Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text(
//                   'Processing...',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildInputArea(BuildContext context, ReflectController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText:
//                     controller.selectedMessage != null
//                         ? "Replying..."
//                         : "Type your reflection...",
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//               minLines: 1,
//               maxLines: 5,
//             ),
//           ),
//           const SizedBox(width: 8),
//           IconButton(
//             icon: Icon(
//               controller.isRecording ? Icons.stop_circle_outlined : Icons.mic,
//               color:
//                   controller.isRecording
//                       ? Colors.red
//                       : Theme.of(context).colorScheme.onSurface,
//             ),
//             onPressed:
//                 controller.isRecording
//                     ? controller.stopRecording
//                     : controller.startRecording,
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed:
//                 controller.isProcessing
//                     ? null
//                     : () {
//                       controller.sendEntry(_controller.text);
//                       _controller.clear();
//                     },
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: _firestoreHandler.messages.length,
//                     itemBuilder:
//                         (context, index) => _messageBuilder.buildChatBubble(
//                           context,
//                           _firestoreHandler.messages[index],
//                           _isSelecting,
//                           selectedMessageIds.contains(
//                             _firestoreHandler.messages[index]['id'],
//                           ),
//                           _audioHandler,
//                           onLongPress:
//                               () => _toggleMessageSelection(
//                                 _firestoreHandler.messages[index]['id'],
//                               ),
//                           onTap:
//                               () => _toggleMessageSelection(
//                                 _firestoreHandler.messages[index]['id'],
//                               ),
//                         ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             setState(() => _isProcessing = true);
//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() => _isProcessing = false);
//                           } else {
//                             await _audioHandler.startRecording();
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   setState(() => _isProcessing = true);
//                                   await _firestoreHandler.sendEntry(
//                                     _controller.text,
//                                     selectedMessage,
//                                     setState,
//                                   );
//                                   _controller.clear();
//                                   setState(() => _isProcessing = false);
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing) _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// // // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() => _isProcessing = false);
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Check if we need to show speaker selection for any voice message
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: _firestoreHandler.messages.length,
//                     itemBuilder:
//                         (context, index) => _messageBuilder.buildChatBubble(
//                           context,
//                           _firestoreHandler.messages[index],
//                           _isSelecting,
//                           selectedMessageIds.contains(
//                             _firestoreHandler.messages[index]['id'],
//                           ),
//                           _audioHandler,
//                           onLongPress:
//                               () => _toggleMessageSelection(
//                                 _firestoreHandler.messages[index]['id'],
//                               ),
//                           onTap:
//                               () => _toggleMessageSelection(
//                                 _firestoreHandler.messages[index]['id'],
//                               ),
//                         ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             setState(() => _isProcessing = true);
//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() => _isProcessing = false);
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   setState(() => _isProcessing = true);
//                                   await _firestoreHandler.sendEntry(
//                                     _controller.text,
//                                     selectedMessage,
//                                     setState,
//                                   );
//                                   _controller.clear();
//                                   setState(() => _isProcessing = false);
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing) _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// }
// merged_reflect_screen.dart (frontend/lib/screens)
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage; // Added for immediate display

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() => _isProcessing = false);
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Check if we need to show speaker selection for any voice message
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount:
//                         _firestoreHandler.messages.length +
//                         (_pendingMessage != null ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (_pendingMessage != null &&
//                           index == _firestoreHandler.messages.length) {
//                         // Show pending message with processing indicator
//                         return Column(
//                           children: [
//                             _messageBuilder.buildChatBubble(
//                               context,
//                               _pendingMessage!,
//                               _isSelecting,
//                               selectedMessageIds.contains(
//                                 _pendingMessage!['id'],
//                               ),
//                               _audioHandler,
//                               onLongPress:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                               onTap:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                             ),
//                             if (_isProcessing)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Processing...',
//                                       style: TextStyle(
//                                         color: theme.colorScheme.onSurface
//                                             .withOpacity(0.7),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         );
//                       }
//                       return _messageBuilder.buildChatBubble(
//                         context,
//                         _firestoreHandler.messages[index],
//                         _isSelecting,
//                         selectedMessageIds.contains(
//                           _firestoreHandler.messages[index]['id'],
//                         ),
//                         _audioHandler,
//                         onLongPress:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                         onTap:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             setState(() => _isProcessing = true);
//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                             });
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   // Create and show pending message immediately
//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   // Scroll to bottom
//                                   WidgetsBinding.instance.addPostFrameCallback((
//                                     _,
//                                   ) {
//                                     if (_scrollController.hasClients) {
//                                       _scrollController.animateTo(
//                                         _scrollController
//                                             .position
//                                             .maxScrollExtent,
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         curve: Curves.easeOut,
//                                       );
//                                     }
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                   });
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// }
// // merged_reflect_screen.dart (frontend/lib/screens)
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() {
//           _isProcessing = false;
//           _pendingMessage = null;
//         });
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount:
//                         _firestoreHandler.messages.length +
//                         (_pendingMessage != null ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (_pendingMessage != null &&
//                           index == _firestoreHandler.messages.length) {
//                         return Column(
//                           children: [
//                             _messageBuilder.buildChatBubble(
//                               context,
//                               _pendingMessage!,
//                               _isSelecting,
//                               selectedMessageIds.contains(
//                                 _pendingMessage!['id'],
//                               ),
//                               _audioHandler,
//                               onLongPress:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                               onTap:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                             ),
//                             if (_isProcessing)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Processing...',
//                                       style: TextStyle(
//                                         color: theme.colorScheme.onSurface
//                                             .withOpacity(0.7),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         );
//                       }
//                       return _messageBuilder.buildChatBubble(
//                         context,
//                         _firestoreHandler.messages[index],
//                         _isSelecting,
//                         selectedMessageIds.contains(
//                           _firestoreHandler.messages[index]['id'],
//                         ),
//                         _audioHandler,
//                         onLongPress:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                         onTap:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             final now = DateTime.now();
//                             setState(() {
//                               _isProcessing = true;
//                               _pendingMessage = {
//                                 'user': 'Voice message',
//                                 'timestamp': now,
//                                 'id': 'pending-${now.millisecondsSinceEpoch}',
//                                 'is_voice': true,
//                                 if (selectedMessage != null)
//                                   'reply_to_id': selectedMessage!['id'],
//                                 if (selectedMessage != null)
//                                   'reply_to': _firestoreHandler.getReplyToText(
//                                     selectedMessage!,
//                                   ),
//                               };
//                             });

//                             // Scroll to bottom
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               if (_scrollController.hasClients) {
//                                 _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut,
//                                 );
//                               }
//                             });

//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                             });
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   // Create and show pending message immediately
//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   // Scroll to bottom
//                                   WidgetsBinding.instance.addPostFrameCallback((
//                                     _,
//                                   ) {
//                                     if (_scrollController.hasClients) {
//                                       _scrollController.animateTo(
//                                         _scrollController
//                                             .position
//                                             .maxScrollExtent,
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         curve: Curves.easeOut,
//                                       );
//                                     }
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                   });
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() {
//           _isProcessing = false;
//           _pendingMessage = null;
//         });
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount:
//                         _firestoreHandler.messages.length +
//                         (_pendingMessage != null ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (_pendingMessage != null &&
//                           index == _firestoreHandler.messages.length) {
//                         return Column(
//                           children: [
//                             _messageBuilder.buildChatBubble(
//                               context,
//                               _pendingMessage!,
//                               _isSelecting,
//                               selectedMessageIds.contains(
//                                 _pendingMessage!['id'],
//                               ),
//                               _audioHandler,
//                               onLongPress:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                               onTap:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                             ),
//                             if (_isProcessing)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Processing...',
//                                       style: TextStyle(
//                                         color: theme.colorScheme.onSurface
//                                             .withOpacity(0.7),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         );
//                       }
//                       return _messageBuilder.buildChatBubble(
//                         context,
//                         _firestoreHandler.messages[index],
//                         _isSelecting,
//                         selectedMessageIds.contains(
//                           _firestoreHandler.messages[index]['id'],
//                         ),
//                         _audioHandler,
//                         onLongPress:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                         onTap:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             final now = DateTime.now();
//                             setState(() {
//                               _isProcessing = true;
//                               _pendingMessage = {
//                                 'user': 'Voice message',
//                                 'timestamp': now,
//                                 'id': 'pending-${now.millisecondsSinceEpoch}',
//                                 'is_voice': true,
//                                 if (selectedMessage != null)
//                                   'reply_to_id': selectedMessage!['id'],
//                                 if (selectedMessage != null)
//                                   'reply_to': _firestoreHandler.getReplyToText(
//                                     selectedMessage!,
//                                   ),
//                               };
//                             });

//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               if (_scrollController.hasClients) {
//                                 _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut,
//                                 );
//                               }
//                             });

//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                             });
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   WidgetsBinding.instance.addPostFrameCallback((
//                                     _,
//                                   ) {
//                                     if (_scrollController.hasClients) {
//                                       _scrollController.animateTo(
//                                         _scrollController
//                                             .position
//                                             .maxScrollExtent,
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         curve: Curves.easeOut,
//                                       );
//                                     }
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                   });
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// // // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//       selectedMessage = null;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() {
//           _isProcessing = false;
//           _pendingMessage = null;
//           selectedMessage = null; // Clear the selected message after processing
//         });
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount:
//                         _firestoreHandler.messages.length +
//                         (_pendingMessage != null ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (_pendingMessage != null &&
//                           index == _firestoreHandler.messages.length) {
//                         return Column(
//                           children: [
//                             _messageBuilder.buildChatBubble(
//                               context,
//                               _pendingMessage!,
//                               _isSelecting,
//                               selectedMessageIds.contains(
//                                 _pendingMessage!['id'],
//                               ),
//                               _audioHandler,
//                               onLongPress:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                               onTap:
//                                   () => _toggleMessageSelection(
//                                     _pendingMessage!['id'],
//                                   ),
//                             ),
//                             if (_isProcessing)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8.0,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Processing...',
//                                       style: TextStyle(
//                                         color: theme.colorScheme.onSurface
//                                             .withOpacity(0.7),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         );
//                       }
//                       return _messageBuilder.buildChatBubble(
//                         context,
//                         _firestoreHandler.messages[index],
//                         _isSelecting,
//                         selectedMessageIds.contains(
//                           _firestoreHandler.messages[index]['id'],
//                         ),
//                         _audioHandler,
//                         onLongPress:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                         onTap:
//                             () => _toggleMessageSelection(
//                               _firestoreHandler.messages[index]['id'],
//                             ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             final now = DateTime.now();
//                             setState(() {
//                               _isProcessing = true;
//                               _pendingMessage = {
//                                 'user': 'Voice message',
//                                 'timestamp': now,
//                                 'id': 'pending-${now.millisecondsSinceEpoch}',
//                                 'is_voice': true,
//                                 if (selectedMessage != null)
//                                   'reply_to_id': selectedMessage!['id'],
//                                 if (selectedMessage != null)
//                                   'reply_to': _firestoreHandler.getReplyToText(
//                                     selectedMessage!,
//                                   ),
//                               };
//                             });

//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               if (_scrollController.hasClients) {
//                                 _scrollController.animateTo(
//                                   _scrollController.position.maxScrollExtent,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOut,
//                                 );
//                               }
//                             });

//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                               selectedMessage =
//                                   null; // Clear selection after sending
//                             });
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   WidgetsBinding.instance.addPostFrameCallback((
//                                     _,
//                                   ) {
//                                     if (_scrollController.hasClients) {
//                                       _scrollController.animateTo(
//                                         _scrollController
//                                             .position
//                                             .maxScrollExtent,
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         curve: Curves.easeOut,
//                                       );
//                                     }
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                     selectedMessage =
//                                         null; // Clear selection after sending
//                                   });
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollToBottom(animated: false);
//       }
//     });
//   }

//   void _scrollToBottom({bool animated = true}) {
//     if (_scrollController.hasClients) {
//       if (animated) {
//         _scrollController.animateTo(
//           0, // Scroll to top since we're showing newest first
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       } else {
//         _scrollController.jumpTo(0); // Jump to top for initial load
//       }
//     }
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//       selectedMessage = null;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() {
//           _isProcessing = false;
//           _pendingMessage = null;
//           selectedMessage = null;
//         });
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: NotificationListener<ScrollNotification>(
//                     onNotification: (notification) {
//                       // Handle scroll events if needed
//                       return false;
//                     },
//                     child: ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(12),
//                       reverse: true, // This makes the list build from bottom
//                       itemCount:
//                           _firestoreHandler.messages.length +
//                           (_pendingMessage != null ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         // Handle pending message (newest message comes first)
//                         if (_pendingMessage != null && index == 0) {
//                           return Column(
//                             children: [
//                               _messageBuilder.buildChatBubble(
//                                 context,
//                                 _pendingMessage!,
//                                 _isSelecting,
//                                 selectedMessageIds.contains(
//                                   _pendingMessage!['id'],
//                                 ),
//                                 _audioHandler,
//                                 onLongPress:
//                                     () => _toggleMessageSelection(
//                                       _pendingMessage!['id'],
//                                     ),
//                                 onTap:
//                                     () => _toggleMessageSelection(
//                                       _pendingMessage!['id'],
//                                     ),
//                               ),
//                               if (_isProcessing)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 8.0,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Processing...',
//                                         style: TextStyle(
//                                           color: theme.colorScheme.onSurface
//                                               .withOpacity(0.7),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           );
//                         }

//                         // Handle regular messages (in reverse order)
//                         final messageIndex =
//                             _pendingMessage != null ? index - 1 : index;
//                         final message =
//                             _firestoreHandler.messages.reversed
//                                 .toList()[messageIndex];

//                         return _messageBuilder.buildChatBubble(
//                           context,
//                           message,
//                           _isSelecting,
//                           selectedMessageIds.contains(message['id']),
//                           _audioHandler,
//                           onLongPress:
//                               () => _toggleMessageSelection(message['id']),
//                           onTap: () => _toggleMessageSelection(message['id']),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             final now = DateTime.now();
//                             setState(() {
//                               _isProcessing = true;
//                               _pendingMessage = {
//                                 'user': 'Voice message',
//                                 'timestamp': now,
//                                 'id': 'pending-${now.millisecondsSinceEpoch}',
//                                 'is_voice': true,
//                                 if (selectedMessage != null)
//                                   'reply_to_id': selectedMessage!['id'],
//                                 if (selectedMessage != null)
//                                   'reply_to': _firestoreHandler.getReplyToText(
//                                     selectedMessage!,
//                                   ),
//                               };
//                             });

//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                               selectedMessage = null;
//                             });
//                             _scrollToBottom();
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                     selectedMessage = null;
//                                   });
//                                   _scrollToBottom();
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../components/reflect/reflect_audio_handler.dart';
// import '../components/reflect/reflect_firestore_handler.dart';
// import '../components/reflect/reflect_message_builder.dart';
// import 'spiral_evolution_chart.dart';

// class MergedReflectScreen extends StatefulWidget {
//   const MergedReflectScreen({super.key});

//   @override
//   State<MergedReflectScreen> createState() => _MergedReflectScreenState();
// }

// class _MergedReflectScreenState extends State<MergedReflectScreen> {
//   final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
//   late ReflectFirestoreHandler _firestoreHandler;
//   final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
//   final _controller = TextEditingController();
//   final _scrollController = ScrollController();

//   bool _isInitializing = true;
//   bool _isSelecting = false;
//   bool _isProcessing = false;
//   List<String> selectedMessageIds = [];
//   Map<String, dynamic>? selectedMessage;
//   String? _voiceMessageIdForSpeakerSelection;
//   Map<String, dynamic>? _pendingMessage;

//   @override
//   void initState() {
//     super.initState();
//     _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
//     _initializeData();
//     _audioHandler.init(
//       onPlayerStateChanged: () {
//         setState(() {});
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _controller.dispose();
//     _audioHandler.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeData() async {
//     setState(() => _isInitializing = true);
//     await _firestoreHandler.initialize(
//       userId: FirebaseAuth.instance.currentUser!.uid,
//     );
//     setState(() => _isInitializing = false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollToBottom(animated: false);
//       }
//     });
//   }

//   void _scrollToBottom({bool animated = true}) {
//     if (_scrollController.hasClients) {
//       if (animated) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       } else {
//         _scrollController.jumpTo(0);
//       }
//     }
//   }

//   void _toggleMessageSelection(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//       _isSelecting = selectedMessageIds.isNotEmpty;
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       selectedMessageIds.clear();
//       _isSelecting = false;
//       selectedMessage = null;
//     });
//   }

//   void _setReplyToMessage(Map<String, dynamic> message) {
//     setState(() {
//       selectedMessage = message;
//       selectedMessageIds.clear();
//       _isSelecting = false;
//     });
//   }

//   Future<void> _showSpeakerSelectionDialog(
//     String messageId,
//     Map<String, dynamic> speakerStages,
//   ) async {
//     final speakers = speakerStages.keys.toList();
//     String? selectedSpeaker;

//     await showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: const Text('Select Your Voice'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children:
//                         speakers.map((speaker) {
//                           final stage =
//                               speakerStages[speaker]['stage'] ?? 'Unknown';
//                           final text = speakerStages[speaker]['text'] ?? '';
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: RadioListTile<String>(
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     speaker,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Stage: $stage',
//                                     style: TextStyle(color: Colors.grey[600]),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     text,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                               value: speaker,
//                               groupValue: selectedSpeaker,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedSpeaker = value;
//                                 });
//                               },
//                             ),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       if (selectedSpeaker != null) {
//                         Navigator.pop(context, selectedSpeaker);
//                       }
//                     },
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     ).then((selected) async {
//       if (selected != null && selected is String) {
//         setState(() => _isProcessing = true);
//         await _firestoreHandler.finalizeSpeakerStage(
//           messageId,
//           selected,
//           speakerStages,
//           selectedMessage,
//           setState,
//         );
//         setState(() {
//           _isProcessing = false;
//           _pendingMessage = null;
//           selectedMessage = null;
//         });
//         _voiceMessageIdForSpeakerSelection = null;
//       }
//     });
//   }

//   PreferredSizeWidget _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.close),
//         onPressed: _cancelSelection,
//         color: Colors.black,
//       ),
//       title: Text(
//         '${selectedMessageIds.length} selected',
//         style: const TextStyle(color: Colors.black),
//       ),
//       backgroundColor: Colors.white,
//       actions: [
//         if (selectedMessageIds.length == 1)
//           IconButton(
//             icon: const Icon(Icons.reply),
//             onPressed: () {
//               final message = _firestoreHandler.messages.firstWhere(
//                 (m) => m['id'] == selectedMessageIds.first,
//               );
//               _setReplyToMessage(message);
//             },
//             color: Colors.black,
//           ),
//       ],
//     );
//   }

//   Widget _buildReplyPreview() {
//     if (selectedMessage == null) return const SizedBox.shrink();

//     final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
//     final isSpiral = selectedMessage?['type'] == 'spiral';
//     final color = isSpiral ? Colors.orange : Colors.blue;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         border: Border(left: BorderSide(color: color, width: 4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isSpiral
//                     ? '🌀 Replying to Spiral Stage'
//                     : '💬 Replying to Message',
//                 style: TextStyle(fontWeight: FontWeight.bold, color: color),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, size: 20),
//                 onPressed: () => setState(() => selectedMessage = null),
//                 color: Colors.black,
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Container(
//             constraints: const BoxConstraints(maxHeight: 150),
//             child: SingleChildScrollView(
//               child: Text(
//                 replyText,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _audioHandler.isRecording
//                     ? 'Processing your voice message...'
//                     : 'Processing your reflection...',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_isInitializing) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading your reflections...',
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final voiceMessageNeedingSelection = _firestoreHandler.messages
//           .firstWhere(
//             (msg) =>
//                 msg['ask_speaker_pick'] == true &&
//                 msg['id'] != _voiceMessageIdForSpeakerSelection,
//             orElse: () => {},
//           );

//       if (voiceMessageNeedingSelection.isNotEmpty &&
//           voiceMessageNeedingSelection['speaker_stages'] != null) {
//         _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
//         _showSpeakerSelectionDialog(
//           voiceMessageNeedingSelection['id'],
//           voiceMessageNeedingSelection['speaker_stages'],
//         );
//       }
//     });

//     return Scaffold(
//       appBar:
//           _isSelecting
//               ? _buildSelectionAppBar()
//               : AppBar(
//                 title: const Text("Reflect & Chat"),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.show_chart),
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => const SpiralEvolutionChartScreen(),
//                           ),
//                         ),
//                   ),
//                 ],
//               ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(color: theme.colorScheme.background),
//             child: Column(
//               children: [
//                 _buildReplyPreview(),
//                 Expanded(
//                   child: NotificationListener<ScrollNotification>(
//                     onNotification: (notification) {
//                       return false;
//                     },
//                     child: ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(12),
//                       reverse: true,
//                       itemCount:
//                           _firestoreHandler.messages.length +
//                           (_pendingMessage != null ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (_pendingMessage != null && index == 0) {
//                           return Column(
//                             children: [
//                               _messageBuilder.buildChatBubble(
//                                 context,
//                                 _pendingMessage!,
//                                 _isSelecting,
//                                 selectedMessageIds.contains(
//                                   _pendingMessage!['id'],
//                                 ),
//                                 _audioHandler,
//                                 onLongPress:
//                                     () => _toggleMessageSelection(
//                                       _pendingMessage!['id'],
//                                     ),
//                                 onTap:
//                                     () => _toggleMessageSelection(
//                                       _pendingMessage!['id'],
//                                     ),
//                               ),
//                               if (_isProcessing)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 8.0,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Processing...',
//                                         style: TextStyle(
//                                           color: theme.colorScheme.onSurface
//                                               .withOpacity(0.7),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           );
//                         }

//                         final messageIndex =
//                             _pendingMessage != null ? index - 1 : index;
//                         final message =
//                             _firestoreHandler.messages.reversed
//                                 .toList()[messageIndex];

//                         return _messageBuilder.buildChatBubble(
//                           context,
//                           message,
//                           _isSelecting,
//                           selectedMessageIds.contains(message['id']),
//                           _audioHandler,
//                           onLongPress:
//                               () => _toggleMessageSelection(message['id']),
//                           onTap: () => _toggleMessageSelection(message['id']),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 12,
//                     right: 12,
//                     top: 10,
//                     bottom: 20,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: InputDecoration(
//                             hintText:
//                                 selectedMessage != null
//                                     ? "Replying..."
//                                     : "Type your reflection...",
//                             filled: true,
//                             fillColor: theme.colorScheme.surface,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           minLines: 1,
//                           maxLines: 5,
//                           style: TextStyle(color: theme.colorScheme.onSurface),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: Icon(
//                           _audioHandler.isRecording
//                               ? Icons.stop_circle_outlined
//                               : Icons.mic,
//                           color:
//                               _audioHandler.isRecording
//                                   ? Colors.red
//                                   : theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           if (_audioHandler.isRecording) {
//                             await _audioHandler.stopRecording();
//                             final now = DateTime.now();
//                             setState(() {
//                               _isProcessing = true;
//                               _pendingMessage = {
//                                 'user': 'Voice message',
//                                 'timestamp': now,
//                                 'id': 'pending-${now.millisecondsSinceEpoch}',
//                                 'is_voice': true,
//                                 if (selectedMessage != null)
//                                   'reply_to_id': selectedMessage!['id'],
//                                 if (selectedMessage != null)
//                                   'reply_to': _firestoreHandler.getReplyToText(
//                                     selectedMessage!,
//                                   ),
//                               };
//                             });

//                             await _firestoreHandler.processVoiceMessage(
//                               selectedMessage,
//                               setState,
//                             );
//                             setState(() {
//                               _isProcessing = false;
//                               _pendingMessage = null;
//                               selectedMessage = null;
//                             });
//                             _scrollToBottom();
//                           } else {
//                             await _audioHandler.startRecording();
//                             setState(() {});
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed:
//                             _isProcessing
//                                 ? null
//                                 : () async {
//                                   if (_controller.text.trim().isEmpty) return;

//                                   final now = DateTime.now();
//                                   final pendingMsg = {
//                                     'user': _controller.text,
//                                     'timestamp': now,
//                                     'id':
//                                         'pending-${now.millisecondsSinceEpoch}',
//                                     if (selectedMessage != null)
//                                       'reply_to_id': selectedMessage!['id'],
//                                     if (selectedMessage != null)
//                                       'reply_to': _firestoreHandler
//                                           .getReplyToText(selectedMessage!),
//                                   };

//                                   setState(() {
//                                     _isProcessing = true;
//                                     _pendingMessage = pendingMsg;
//                                     _controller.clear();
//                                   });

//                                   await _firestoreHandler.sendEntry(
//                                     pendingMsg['user'],
//                                     selectedMessage,
//                                     setState,
//                                   );

//                                   setState(() {
//                                     _isProcessing = false;
//                                     _pendingMessage = null;
//                                     selectedMessage = null;
//                                   });
//                                   _scrollToBottom();
//                                 },
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isProcessing && _pendingMessage == null)
//             _buildProcessingOverlay(),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../components/reflect/reflect_audio_handler.dart';
import '../components/reflect/reflect_firestore_handler.dart';
import '../components/reflect/reflect_message_builder.dart';
import 'spiral_evolution_chart.dart';

class MergedReflectScreen extends StatefulWidget {
  const MergedReflectScreen({super.key});

  @override
  State<MergedReflectScreen> createState() => _MergedReflectScreenState();
}

class _MergedReflectScreenState extends State<MergedReflectScreen> {
  final ReflectAudioHandler _audioHandler = ReflectAudioHandler();
  late ReflectFirestoreHandler _firestoreHandler;
  final ReflectMessageBuilder _messageBuilder = ReflectMessageBuilder();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitializing = true;
  bool _isSelecting = false;
  bool _isProcessing = false;
  List<String> selectedMessageIds = [];
  Map<String, dynamic>? selectedMessage;
  String? _voiceMessageIdForSpeakerSelection;
  Map<String, dynamic>? _pendingMessage;

  @override
  void initState() {
    super.initState();
    _firestoreHandler = ReflectFirestoreHandler(audioHandler: _audioHandler);
    _initializeData();
    _setupFirebaseMessaging();
    _audioHandler.init(
      onPlayerStateChanged: () {
        setState(() {});
      },
    );
  }

  // void _setupFirebaseMessaging() {
  //   _firebaseMessaging.requestPermission();

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //     if (message.notification != null &&
  //         message.data['type'] == 'daily_task') {
  //       final taskText = message.notification?.body ?? '';
  //       final now = DateTime.now();

  //       // Store the message in Firestore first
  //       await _firestoreHandler.storeNotificationMessage(taskText);

  //       // Then update the UI
  //       if (mounted) {
  //         setState(() {
  //           _firestoreHandler.messages.insert(0, {
  //             'type': 'daily-task',
  //             'message': taskText,
  //             'timestamp': now,
  //             'id': 'notification-${now.millisecondsSinceEpoch}',
  //             'is_notification': true,
  //           });
  //         });
  //         _scrollToBottom();
  //       }
  //     }
  //   });
  // }
  void _setupFirebaseMessaging() {
    _firebaseMessaging.requestPermission();

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null &&
          message.data['type'] == 'daily_task') {
        final taskText = message.notification?.body ?? '';
        await _handleNotificationMessage(taskText);
      }
    });

    // Handle notification when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null &&
          message.data['type'] == 'daily_task') {
        final taskText = message.notification?.body ?? '';
        await _handleNotificationMessage(taskText);
      }
    });
  }

  Future<void> _handleNotificationMessage(String taskText) async {
    final now = DateTime.now();

    // Store the message in Firestore
    // await _firestoreHandler.storeNotificationMessage(taskText);
    await _firestoreHandler.storeNotificationMessage(
      taskText,
      (fn) => setState(fn), // <-- pass the state updater
    );
    // Refresh messages from Firestore
    await _firestoreHandler.initialize(
      userId: FirebaseAuth.instance.currentUser!.uid,
    );

    if (mounted) {
      setState(() {
        // Ensure the message is in our local list
        if (!_firestoreHandler.messages.any(
          (m) => m['is_notification'] == true && m['message'] == taskText,
        )) {
          _firestoreHandler.messages.insert(0, {
            'type': 'daily-task',
            'message': taskText,
            'timestamp': now,
            'id': 'notification-${now.millisecondsSinceEpoch}',
            'is_notification': true,
          });
        }
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _audioHandler.dispose();
    super.dispose();
  }

  // Future<void> _initializeData() async {
  //   if (mounted) {
  //     setState(() => _isInitializing = true);
  //   }
  //   await _firestoreHandler.initialize(
  //     userId: FirebaseAuth.instance.currentUser!.uid,
  //   );
  //   if (mounted) {
  //     setState(() => _isInitializing = false);
  //   }
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_scrollController.hasClients) {
  //       _scrollToBottom(animated: false);
  //     }
  //   });
  // }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() => _isInitializing = true);
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Load existing messages
    await _firestoreHandler.initialize(userId: uid);

    // 👇 If no messages exist, add a welcome message
    if (_firestoreHandler.messages.isEmpty) {
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('mergedMessages') // <-- fixed here
          .add({
            'type': 'welcome',
            'message':
                "What’s on your mind right now? Write or speak freely—no filters.",
            'timestamp': now,
          });

      // Reload messages so the welcome appears in list
      await _firestoreHandler.initialize(userId: uid);
    }

    if (mounted) {
      setState(() => _isInitializing = false);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom(animated: false);
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _toggleMessageSelection(String messageId) {
    if (mounted) {
      setState(() {
        if (selectedMessageIds.contains(messageId)) {
          selectedMessageIds.remove(messageId);
        } else {
          selectedMessageIds.add(messageId);
        }
        _isSelecting = selectedMessageIds.isNotEmpty;
      });
    }
  }

  void _cancelSelection() {
    if (mounted) {
      setState(() {
        selectedMessageIds.clear();
        _isSelecting = false;
        selectedMessage = null;
      });
    }
  }

  void _setReplyToMessage(Map<String, dynamic> message) {
    if (mounted) {
      setState(() {
        selectedMessage = message;
        selectedMessageIds.clear();
        _isSelecting = false;
      });
    }
  }

  Future<void> _showSpeakerSelectionDialog(
    String messageId,
    Map<String, dynamic> speakerStages,
  ) async {
    final speakers = speakerStages.keys.toList();
    String? selectedSpeaker;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Your Voice'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        speakers.map((speaker) {
                          final stage =
                              speakerStages[speaker]['stage'] ?? 'Unknown';
                          final text = speakerStages[speaker]['text'] ?? '';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: RadioListTile<String>(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    speaker,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Stage: $stage',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              value: speaker,
                              groupValue: selectedSpeaker,
                              onChanged: (value) {
                                setState(() {
                                  selectedSpeaker = value;
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (selectedSpeaker != null) {
                        Navigator.pop(context, selectedSpeaker);
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          ),
    ).then((selected) async {
      if (selected != null && selected is String) {
        if (mounted) {
          setState(() => _isProcessing = true);
        }
        await _firestoreHandler.finalizeSpeakerStage(
          messageId,
          selected,
          speakerStages,
          selectedMessage,
          setState,
        );
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _pendingMessage = null;
            selectedMessage = null;
          });
        }
        _voiceMessageIdForSpeakerSelection = null;
      }
    });
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _cancelSelection,
        color: Colors.black,
      ),
      title: Text(
        '${selectedMessageIds.length} selected',
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      actions: [
        if (selectedMessageIds.length == 1)
          IconButton(
            icon: const Icon(Icons.reply),
            onPressed: () {
              final message = _firestoreHandler.messages.firstWhere(
                (m) => m['id'] == selectedMessageIds.first,
              );
              _setReplyToMessage(message);
            },
            color: Colors.black,
          ),
      ],
    );
  }

  Widget _buildReplyPreview() {
    if (selectedMessage == null) return const SizedBox.shrink();

    final replyText = _firestoreHandler.getReplyToText(selectedMessage!);
    final isSpiral = selectedMessage?['type'] == 'spiral';
    final color = isSpiral ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSpiral
                    ? '🌀 Replying to Spiral Stage'
                    : '💬 Replying to Message',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  if (mounted) {
                    setState(() => selectedMessage = null);
                  }
                },
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Text(
                replyText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
              const SizedBox(height: 16),
              Text(
                _audioHandler.isRecording
                    ? 'Processing your voice message...'
                    : 'Processing your reflection...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInitializing) {
      // 🔹 Leave this loading Scaffold unchanged
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading your reflections...',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceMessageNeedingSelection = _firestoreHandler.messages
          .firstWhere(
            (msg) =>
                msg['ask_speaker_pick'] == true &&
                msg['id'] != _voiceMessageIdForSpeakerSelection,
            orElse: () => {},
          );

      if (voiceMessageNeedingSelection.isNotEmpty &&
          voiceMessageNeedingSelection['speaker_stages'] != null) {
        _voiceMessageIdForSpeakerSelection = voiceMessageNeedingSelection['id'];
        _showSpeakerSelectionDialog(
          voiceMessageNeedingSelection['id'],
          voiceMessageNeedingSelection['speaker_stages'],
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 makes Scaffold move up with keyboard
      appBar:
          _isSelecting
              ? _buildSelectionAppBar()
              : AppBar(
                title: const Text("Reflect & Chat"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.show_chart),
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const SpiralEvolutionChartScreen(),
                          ),
                        ),
                  ),
                ],
              ),

      body: Scaffold(
        resizeToAvoidBottomInset:
            true, // 👈 lets content shift when keyboard opens
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                color: theme.colorScheme.background,
                child: Column(
                  children: [
                    _buildReplyPreview(),

                    // 🔹 Messages list
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (_) => false,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          reverse: true,
                          itemCount:
                              _firestoreHandler.messages.length +
                              (_pendingMessage != null ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_pendingMessage != null && index == 0) {
                              return Column(
                                children: [
                                  _messageBuilder.buildChatBubble(
                                    context,
                                    _pendingMessage!,
                                    _isSelecting,
                                    selectedMessageIds.contains(
                                      _pendingMessage!['id'],
                                    ),
                                    _audioHandler,
                                    onLongPress:
                                        () => _toggleMessageSelection(
                                          _pendingMessage!['id'],
                                        ),
                                    onTap:
                                        () => _toggleMessageSelection(
                                          _pendingMessage!['id'],
                                        ),
                                  ),
                                  if (_isProcessing)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Processing...',
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }

                            final messageIndex =
                                _pendingMessage != null ? index - 1 : index;
                            final message =
                                _firestoreHandler.messages.reversed
                                    .toList()[messageIndex];

                            return _messageBuilder.buildChatBubble(
                              context,
                              message,
                              _isSelecting,
                              selectedMessageIds.contains(message['id']),
                              _audioHandler,
                              onLongPress:
                                  () => _toggleMessageSelection(message['id']),
                              onTap:
                                  () => _toggleMessageSelection(message['id']),
                            );
                          },
                        ),
                      ),
                    ),

                    // 🔹 Input bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText:
                                    selectedMessage != null
                                        ? "Replying..."
                                        : "Type your reflection...",
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 5,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              _audioHandler.isRecording
                                  ? Icons.stop_circle_outlined
                                  : Icons.mic,
                              color:
                                  _audioHandler.isRecording
                                      ? Colors.red
                                      : theme.colorScheme.onSurface,
                            ),
                            onPressed: () async {
                              if (_audioHandler.isRecording) {
                                await _audioHandler.stopRecording();
                                final now = DateTime.now();
                                if (mounted) {
                                  setState(() {
                                    _isProcessing = true;
                                    _pendingMessage = {
                                      'user': 'Voice message',
                                      'timestamp': now,
                                      'id':
                                          'pending-${now.millisecondsSinceEpoch}',
                                      'is_voice': true,
                                      if (selectedMessage != null)
                                        'reply_to_id': selectedMessage!['id'],
                                      if (selectedMessage != null)
                                        'reply_to': _firestoreHandler
                                            .getReplyToText(selectedMessage!),
                                    };
                                  });
                                }

                                await _firestoreHandler.processVoiceMessage(
                                  selectedMessage,
                                  setState,
                                );
                                if (mounted) {
                                  setState(() {
                                    _isProcessing = false;
                                    _pendingMessage = null;
                                    selectedMessage = null;
                                  });
                                }
                                _scrollToBottom();
                              } else {
                                await _audioHandler.startRecording();
                                if (mounted) {
                                  setState(() {});
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed:
                                _isProcessing
                                    ? null
                                    : () async {
                                      if (_controller.text.trim().isEmpty)
                                        return;

                                      final now = DateTime.now();
                                      final pendingMsg = {
                                        'user': _controller.text,
                                        'timestamp': now,
                                        'id':
                                            'pending-${now.millisecondsSinceEpoch}',
                                        if (selectedMessage != null)
                                          'reply_to_id': selectedMessage!['id'],
                                        if (selectedMessage != null)
                                          'reply_to': _firestoreHandler
                                              .getReplyToText(selectedMessage!),
                                      };

                                      if (mounted) {
                                        setState(() {
                                          _isProcessing = true;
                                          _pendingMessage = pendingMsg;
                                          _controller.clear();
                                        });
                                      }

                                      await _firestoreHandler.sendEntry(
                                        pendingMsg['user'],
                                        selectedMessage,
                                        setState,
                                      );

                                      if (mounted) {
                                        setState(() {
                                          _isProcessing = false;
                                          _pendingMessage = null;
                                          selectedMessage = null;
                                        });
                                      }
                                      _scrollToBottom();
                                    },
                            color: theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_isProcessing && _pendingMessage == null)
                _buildProcessingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
