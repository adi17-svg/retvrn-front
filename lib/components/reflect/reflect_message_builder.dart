// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.grey[300],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMM d, yyyy').format(date),
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.blue.withOpacity(0.5)
//                       : isReply
//                       ? Colors.blue.withOpacity(0.2)
//                       : Colors.blue.withOpacity(0.3),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   msg['user'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🌀 Stage: ${msg['stage'] ?? ''}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "❓ ${msg['question'] ?? ''}",
//                   style: const TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if ((msg['growth'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       '"${msg['growth']}"',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if ((msg['evolution'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['evolution'],
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.grey[300],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMM d, yyyy').format(date),
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.blue.withOpacity(0.5)
//                       : isReply
//                       ? Colors.blue.withOpacity(0.2)
//                       : Colors.blue.withOpacity(0.3),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   msg['user'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🌀 Stage: ${msg['stage'] ?? ''}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "❓ ${msg['question'] ?? ''}",
//                   style: const TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if ((msg['growth'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       '"${msg['growth']}"',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if ((msg['evolution'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['evolution'],
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildSpiralMessage(
//   //   BuildContext context,
//   //   Map<String, dynamic> msg,
//   //   DateTime timestamp,
//   //   bool isSelected,
//   //   bool isReply,
//   // ) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//   //     child: Align(
//   //       alignment: Alignment.centerLeft,
//   //       child: ConstrainedBox(
//   //         constraints: BoxConstraints(
//   //           maxWidth: MediaQuery.of(context).size.width * 0.8,
//   //         ),
//   //         child: Container(
//   //           padding: const EdgeInsets.all(14),
//   //           decoration: BoxDecoration(
//   //             color:
//   //                 isSelected
//   //                     ? Colors.orange[200]!
//   //                     : isReply
//   //                     ? Colors.orange[50]!
//   //                     : Colors.orange[100]!,
//   //             borderRadius: const BorderRadius.only(
//   //               topLeft: Radius.circular(16),
//   //               topRight: Radius.circular(16),
//   //               bottomRight: Radius.circular(16),
//   //             ),
//   //           ),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 "🌀 Stage: ${msg['stage'] ?? ''}",
//   //                 style: const TextStyle(
//   //                   fontWeight: FontWeight.bold,
//   //                   fontSize: 16,
//   //                   color: Colors.black87,
//   //                 ),
//   //               ),
//   //               if (msg['diarized'] == true && msg['speaker_stages'] != null)
//   //                 _buildSpeakerStages(
//   //                   Map<String, dynamic>.from(msg['speaker_stages']),
//   //                 ),
//   //               const SizedBox(height: 6),
//   //               Text(
//   //                 "❓ ${msg['question'] ?? ''}",
//   //                 style: const TextStyle(
//   //                   fontStyle: FontStyle.italic,
//   //                   fontSize: 14,
//   //                   color: Colors.black87,
//   //                 ),
//   //               ),
//   //               if ((msg['growth'] ?? '').isNotEmpty)
//   //                 Padding(
//   //                   padding: const EdgeInsets.only(top: 8),
//   //                   child: Text(
//   //                     '"${msg['growth']}"',
//   //                     style: const TextStyle(
//   //                       fontSize: 13,
//   //                       fontStyle: FontStyle.italic,
//   //                       color: Colors.black87,
//   //                       fontWeight: FontWeight.bold,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               if ((msg['evolution'] ?? '').isNotEmpty)
//   //                 Padding(
//   //                   padding: const EdgeInsets.only(top: 8),
//   //                   child: Text(
//   //                     msg['evolution'],
//   //                     style: const TextStyle(
//   //                       color: Colors.green,
//   //                       fontWeight: FontWeight.w600,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               const SizedBox(height: 4),
//   //               Text(
//   //                 DateFormat('hh:mm a').format(timestamp),
//   //                 style: TextStyle(fontSize: 10, color: Colors.black54),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   // Update the _buildSpiralMessage method to use the growth field for the gamified prompt
//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🌀 Stage: ${msg['stage'] ?? ''}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "❓ ${msg['question'] ?? ''}",
//                   style: const TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if ((msg['growth'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['growth'],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if ((msg['evolution'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['evolution'],
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//             if (msg['streak'] != null || msg['rewards'] != null)
//               _buildRewardIndicator(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🌀 Stage: ${msg['stage'] ?? ''}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "❓ ${msg['question'] ?? ''}",
//                   style: const TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if ((msg['growth'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['growth'],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 if ((msg['evolution'] ?? '').isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['evolution'],
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRewardIndicator(BuildContext context, Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('🔥 ${msg['streak']} day streak'),
//           backgroundColor: Colors.orange[100],
//         ),
//       );
//     }

//     if (msg['rewards'] != null && msg['rewards'] is List) {
//       for (final reward in msg['rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.green[100]),
//         );
//       }
//     }

//     if (msg['message_rewards'] != null && msg['message_rewards'] is List) {
//       for (final reward in msg['message_rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.blue[100]),
//         );
//       }
//     }

//     if (msg['xp_gained'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('+${msg['xp_gained']} XP'),
//           backgroundColor: Colors.purple[100],
//         ),
//       );
//     }

//     if (msg['badges_earned'] != null && msg['badges_earned'] is List) {
//       for (final badge in msg['badges_earned']) {
//         rewards.add(
//           Chip(label: Text(badge), backgroundColor: Colors.yellow[100]),
//         );
//       }
//     }

//     if (rewards.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
//       child: Wrap(spacing: 8, runSpacing: 8, children: rewards),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//             if (msg['streak'] != null || msg['rewards'] != null)
//               _buildRewardIndicator(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any)
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "❓ $question",
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "💡 $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 // Timestamp
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRewardIndicator(BuildContext context, Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('🔥 ${msg['streak']} day streak'),
//           backgroundColor: Colors.orange[100],
//         ),
//       );
//     }

//     if (msg['rewards'] != null && msg['rewards'] is List) {
//       for (final reward in msg['rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.green[100]),
//         );
//       }
//     }

//     if (msg['message_rewards'] != null && msg['message_rewards'] is List) {
//       for (final reward in msg['message_rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.blue[100]),
//         );
//       }
//     }

//     if (msg['xp_gained'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('+${msg['xp_gained']} XP'),
//           backgroundColor: Colors.purple[100],
//         ),
//       );
//     }

//     if (msg['badges_earned'] != null && msg['badges_earned'] is List) {
//       for (final badge in msg['badges_earned']) {
//         rewards.add(
//           Chip(label: Text(badge), backgroundColor: Colors.yellow[100]),
//         );
//       }
//     }

//     if (rewards.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
//       child: Wrap(spacing: 8, runSpacing: 8, children: rewards),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//             if (msg['streak'] != null || msg['rewards'] != null)
//               _buildRewardIndicator(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];
//     final growth = msg['growth'] ?? '';

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any)
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "❓ $question",
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt (from gamified)
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "💡 $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Growth Message (direct from msg)
//                 if (growth.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "🌱 $growth",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 // Timestamp
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRewardIndicator(BuildContext context, Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('🔥 ${msg['streak']} day streak'),
//           backgroundColor: Colors.orange[100],
//         ),
//       );
//     }

//     if (msg['rewards'] != null && msg['rewards'] is List) {
//       for (final reward in msg['rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.green[100]),
//         );
//       }
//     }

//     if (msg['message_rewards'] != null && msg['message_rewards'] is List) {
//       for (final reward in msg['message_rewards']) {
//         rewards.add(
//           Chip(label: Text(reward), backgroundColor: Colors.blue[100]),
//         );
//       }
//     }

//     if (msg['xp_gained'] != null) {
//       rewards.add(
//         Chip(
//           label: Text('+${msg['xp_gained']} XP'),
//           backgroundColor: Colors.purple[100],
//         ),
//       );
//     }

//     if (msg['badges_earned'] != null && msg['badges_earned'] is List) {
//       for (final badge in msg['badges_earned']) {
//         rewards.add(
//           Chip(label: Text(badge), backgroundColor: Colors.yellow[100]),
//         );
//       }
//     }

//     if (rewards.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
//       child: Wrap(spacing: 8, runSpacing: 8, children: rewards),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//             if (msg['streak'] != null || msg['rewards'] != null)
//               _buildRewardIndicator(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];
//     final growth = msg['growth'] ?? '';

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any)
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "❓ $question",
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt (from gamified)
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "💡 $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Growth Message (direct from msg)
//                 if (growth.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "🌱 $growth",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 // Timestamp
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRewardIndicator(BuildContext context, Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.orange[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '🔥 ${msg['streak']} day streak',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     // Only show XP if it's not already shown in the main message
//     if (msg['xp_gained'] != null && msg['type'] != 'spiral') {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.purple[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '✨ +${msg['xp_gained']} XP',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     if (rewards.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
//       child: Wrap(spacing: 8, runSpacing: 4, children: rewards),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Play',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final rewards = _buildRewardIndicator(msg);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];
//     final growth = msg['growth'] ?? '';
//     final rewards = _buildRewardIndicator(msg);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "Badge: ${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any)
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mind Mirror: $question",
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt (from gamified)
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission: $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Growth Message (direct from msg)
//                 if (growth.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission $growth",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],

//                 // Timestamp
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('hh:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget? _buildRewardIndicator(Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.orange[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '🔥 ${msg['streak']} day streak',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     // Only show XP if it's not already shown in the main message (for spiral messages)
//     if (msg['xp_gained'] != null && msg['type'] != 'spiral') {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.purple[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '✨ +${msg['xp_gained']} XP',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     if (rewards.isEmpty) return null;

//     return Wrap(spacing: 8, runSpacing: 4, children: rewards);
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Reflect',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final rewards = _buildRewardIndicator(msg);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];
//     final growth = msg['growth'] ?? '';
//     final rewards = _buildRewardIndicator(msg);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "Badge: ${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any)
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text.rich(
//                       TextSpan(
//                         children: [
//                           const TextSpan(
//                             text: "Mind Mirror 🧠🔍 : ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: question,
//                             style: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt (from gamified)
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission: $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Growth Message (direct from msg)
//                 if (growth.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission: $growth",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],

//                 // Timestamp
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('hh:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget? _buildRewardIndicator(Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.orange[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '🔥 ${msg['streak']} day streak',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     // Only show XP if it's not already shown in the main message (for spiral messages)
//     if (msg['xp_gained'] != null && msg['type'] != 'spiral') {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.purple[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '✨ +${msg['xp_gained']} XP',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     if (rewards.isEmpty) return null;

//     return Wrap(spacing: 8, runSpacing: 4, children: rewards);
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reflect_audio_handler.dart';

// class ReflectMessageBuilder {
//   Widget buildChatBubble(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     bool isSelectingMode,
//     bool isSelected,
//     ReflectAudioHandler audioHandler, {
//     required VoidCallback onLongPress,
//     required VoidCallback onTap,
//   }) {
//     if (msg['type'] == 'date-header') {
//       return _buildDateHeader(context, msg['date']);
//     }

//     if (msg['is_notification'] == true) {
//       return _buildNotificationMessage(context, msg, onTap);
//     }

//     final timestamp = _parseTimestamp(msg['timestamp']);
//     final isCurrentPlaying =
//         audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
//         audioHandler.currentlyPlayingUrl == msg['audio_url'];
//     final isReply = msg['reply_to_id'] != null;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             if (isReply && msg['reply_to'] != null)
//               _buildReplyIndicator(context, msg['reply_to']),
//             if (msg['type'] == 'daily-task')
//               _buildDailyTaskMessage(context, msg, timestamp),
//             if (msg['user'] != null && msg['user'] != '[Voice]')
//               _buildUserMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['user'] == '[Voice]' &&
//                 (msg['audioPath'] != null || msg['audio_url'] != null))
//               _buildVoiceMessage(
//                 context,
//                 msg,
//                 timestamp,
//                 audioHandler,
//                 isCurrentPlaying,
//               ),
//             if (msg['type'] == 'chat')
//               _buildChatResponse(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'spiral')
//               _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
//             if (msg['type'] == 'error') _buildErrorMessage(context, msg),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildNotificationMessage(
//   //   BuildContext context,
//   //   Map<String, dynamic> msg,
//   //   VoidCallback onTap,
//   // ) {
//   //   final timestamp = _parseTimestamp(msg['timestamp']);

//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//   //     child: Align(
//   //       alignment: Alignment.centerLeft,
//   //       child: ConstrainedBox(
//   //         constraints: BoxConstraints(
//   //           maxWidth: MediaQuery.of(context).size.width * 0.8,
//   //         ),
//   //         child: Container(
//   //           padding: const EdgeInsets.all(14),
//   //           decoration: BoxDecoration(
//   //             color: Colors.purple[100],
//   //             borderRadius: const BorderRadius.only(
//   //               topLeft: Radius.circular(16),
//   //               topRight: Radius.circular(16),
//   //               bottomRight: Radius.circular(16),
//   //             ),
//   //             border: Border.all(color: Colors.purple[300]!),
//   //           ),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Row(
//   //                 children: [
//   //                   const Icon(Icons.notifications, color: Colors.purple),
//   //                   const SizedBox(width: 8),
//   //                   const Text(
//   //                     "Daily Reflection",
//   //                     style: TextStyle(
//   //                       fontWeight: FontWeight.bold,
//   //                       fontSize: 16,
//   //                       color: Colors.purple,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 8),
//   //               Text(
//   //                 msg['message'] ?? '',
//   //                 style: const TextStyle(color: Colors.black87),
//   //               ),
//   //               const SizedBox(height: 12),
//   //               ElevatedButton(
//   //                 onPressed: onTap,
//   //                 style: ElevatedButton.styleFrom(
//   //                   backgroundColor: Colors.purple[200],
//   //                   foregroundColor: Colors.white,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(20),
//   //                   ),
//   //                 ),
//   //                 child: const Text('Reply to this prompt'),
//   //               ),
//   //               const SizedBox(height: 8),
//   //               Text(
//   //                 DateFormat('hh:mm a').format(timestamp),
//   //                 style: TextStyle(fontSize: 10, color: Colors.black54),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   Widget _buildNotificationMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     VoidCallback onTap,
//   ) {
//     final timestamp = _parseTimestamp(msg['timestamp']);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//               border: Border.all(color: Colors.purple[300]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.notifications, color: Colors.purple),
//                     const SizedBox(width: 8),
//                     const Text(
//                       "Daily Reflection",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.purple,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: onTap,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple[200],
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: const Text('Reply to this prompt'),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is String) return DateTime.parse(timestamp);
//     return timestamp ?? DateTime.now();
//   }

//   Widget _buildDateHeader(BuildContext context, DateTime date) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           DateFormat('EEEE, MMMM d, yyyy').format(date),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyIndicator(BuildContext context, String replyText) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 4,
//               height: 40,
//               color: Colors.grey,
//               margin: const EdgeInsets.only(right: 8),
//             ),
//             Expanded(
//               child: Text(
//                 replyText,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDailyTaskMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.purple[100],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "📝 Inner Compass",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   msg['message'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isSelected
//                           ? Colors.blue.withOpacity(0.5)
//                           : isReply
//                           ? Colors.blue.withOpacity(0.2)
//                           : Colors.blue.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                     bottomLeft: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       msg['user'] ?? '',
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   DateFormat('h:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     ReflectAudioHandler audioHandler,
//     bool isCurrentPlaying,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomLeft: Radius.circular(12),
//               ),
//               border: Border.all(color: Colors.blueGrey[100]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Voice Message",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey[800],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 if (msg['transcription'] != null &&
//                     msg['transcription'].isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 8),
//                       Text(
//                         "Transcription:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '"${msg['transcription']}"',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   icon: Icon(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? Icons.stop
//                         : Icons.play_arrow,
//                     size: 20,
//                   ),
//                   label: Text(
//                     isCurrentPlaying && audioHandler.isPlaying
//                         ? 'Stop'
//                         : 'Reflect',
//                   ),
//                   onPressed:
//                       () => audioHandler.playAudio(
//                         msg['audio_url'] ?? msg['audioPath'],
//                       ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[100],
//                     foregroundColor: Colors.blueGrey[800],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                 ),
//                 if (msg['ask_speaker_pick'] == true)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       "Please select which speaker is you",
//                       style: TextStyle(
//                         color: Colors.orange[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('h:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChatResponse(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final rewards = _buildRewardIndicator(msg);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.grey[300]!
//                       : isReply
//                       ? Colors.grey[100]!
//                       : Colors.grey[200]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   msg['response'] ?? '',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(fontSize: 10, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiralMessage(
//     BuildContext context,
//     Map<String, dynamic> msg,
//     DateTime timestamp,
//     bool isSelected,
//     bool isReply,
//   ) {
//     final stage = msg['stage'] ?? 'Unknown';
//     final stageMeta = _getStageMeta(stage);
//     final gamified = msg['gamified'] ?? {};
//     final question = msg['question'] ?? '';
//     final evolution = msg['evolution'] ?? '';
//     final growthPrompt = gamified['gamified_prompt'] ?? '';
//     final xpGained = msg['xp_gained'] ?? 0;
//     final badgesEarned = msg['badges_earned'] ?? [];
//     final growth = msg['growth'] ?? '';
//     final rewards = _buildRewardIndicator(msg);

//     // Get color based on stage
//     final stageColor = _getStageColor(stage);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color:
//                   isSelected
//                       ? Colors.orange[200]!
//                       : isReply
//                       ? Colors.orange[50]!
//                       : Colors.orange[100]!,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Stage Name with Emoji
//                 Text(
//                   "🌀 Stage: $stage",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Stage Meta (Name and Emoji)
//                 if (stageMeta != null)
//                   Text(
//                     "Badge: ${stageMeta['emoji']} ${stageMeta['name']}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 const SizedBox(height: 8),

//                 // Evolution Message (if any) - Now with stage-specific color
//                 if (evolution.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       evolution,
//                       style: TextStyle(
//                         color: stageColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),

//                 // Badges Earned
//                 if (badgesEarned.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "🏆 Badges Earned:",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         ...badgesEarned.map(
//                           (badge) => Text(
//                             "• $badge",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Deep Reflective Question
//                 if (question.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text.rich(
//                       TextSpan(
//                         children: [
//                           const TextSpan(
//                             text: "Mind Mirror 🧠🔍 : ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: question,
//                             style: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),

//                 // Growth Prompt (from gamified)
//                 if (growthPrompt.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission: $growthPrompt",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Growth Message (direct from msg)
//                 if (growth.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Mission: $growth",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // XP Gained
//                 if (xpGained > 0)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "✨ +$xpGained XP",
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                 // Speaker Stages (if diarized)
//                 if (msg['diarized'] == true && msg['speaker_stages'] != null)
//                   _buildSpeakerStages(
//                     Map<String, dynamic>.from(msg['speaker_stages']),
//                   ),

//                 // Confidence and Note
//                 if (msg['confidence'] != null && msg['confidence'] < 0.7)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
//                       style: TextStyle(color: Colors.blueGrey, fontSize: 12),
//                     ),
//                   ),
//                 if (msg['note'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       msg['note'],
//                       style: TextStyle(
//                         color: Colors.blueGrey,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                 if (rewards != null) ...[const SizedBox(height: 8), rewards],

//                 // Timestamp
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     DateFormat('hh:mm a').format(timestamp),
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStageColor(String stage) {
//     switch (stage) {
//       case 'Beige':
//         return Colors.brown;
//       case 'Purple':
//         return Colors.purple;
//       case 'Red':
//         return Colors.red;
//       case 'Blue':
//         return Colors.blue;
//       case 'Orange':
//         return Colors.orange;
//       case 'Green':
//         return Colors.green;
//       case 'Yellow':
//         return Colors.yellow.shade700;
//       case 'Turquoise':
//         return Colors.teal;
//       default:
//         return Colors.green;
//     }
//   }

//   Map<String, dynamic>? _getStageMeta(String stage) {
//     const stageMeta = {
//       "Beige": {
//         "emoji": "🏕️",
//         "name": "Survival Basecamp",
//         "reward": "+5 XP (🌱 Survivalist)",
//       },
//       "Purple": {
//         "emoji": "🪄",
//         "name": "Tribe Mystic",
//         "reward": "+10 XP (🧙 Tribal Keeper)",
//       },
//       "Red": {
//         "emoji": "🔥",
//         "name": "Dragon's Lair",
//         "reward": "+15 XP (🐉 Force Master)",
//       },
//       "Blue": {
//         "emoji": "📜",
//         "name": "Order Temple",
//         "reward": "+20 XP (🛡️ Virtue Guardian)",
//       },
//       "Orange": {
//         "emoji": "🚀",
//         "name": "Achiever's Arena",
//         "reward": "+25 XP (🏆 Success Champion)",
//       },
//       "Green": {
//         "emoji": "🌀",
//         "name": "Harmony Nexus",
//         "reward": "+30 XP (🌍 Community Builder)",
//       },
//       "Yellow": {
//         "emoji": "🔄",
//         "name": "Flow Integrator",
//         "reward": "+35 XP (🌀 Complexity Dancer)",
//       },
//       "Turquoise": {
//         "emoji": "🌌",
//         "name": "Cosmic Weave",
//         "reward": "+40 XP (♾️ Holon Seer)",
//       },
//     };
//     return stageMeta[stage];
//   }

//   Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
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

//   Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.red[100]!,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "❌ ${msg['message'] ?? 'Error'}",
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget? _buildRewardIndicator(Map<String, dynamic> msg) {
//     final rewards = <Widget>[];

//     if (msg['streak'] != null) {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.orange[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '🔥 ${msg['streak']} day streak',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     // Only show XP if it's not already shown in the main message (for spiral messages)
//     if (msg['xp_gained'] != null && msg['type'] != 'spiral') {
//       rewards.add(
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.purple[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '✨ +${msg['xp_gained']} XP',
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       );
//     }

//     if (rewards.isEmpty) return null;

//     return Wrap(spacing: 8, runSpacing: 4, children: rewards);
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reflect_audio_handler.dart';

class ReflectMessageBuilder {
  Widget buildChatBubble(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isSelectingMode,
    bool isSelected,
    ReflectAudioHandler audioHandler, {
    required VoidCallback onLongPress,
    required VoidCallback onTap,
  }) {
    if (msg['type'] == 'date-header') {
      return _buildDateHeader(context, msg['date']);
    }

    if (msg['is_notification'] == true) {
      return _buildNotificationMessage(context, msg, onTap);
    }
    if (msg['type'] == 'welcome') {
      return _buildWelcomeMessage(context, msg);
    }

    final timestamp = _parseTimestamp(msg['timestamp']);
    final isCurrentPlaying =
        audioHandler.currentlyPlayingUrl == msg['audioPath'] ||
        audioHandler.currentlyPlayingUrl == msg['audio_url'];
    final isReply = msg['reply_to_id'] != null;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            if (isReply && msg['reply_to'] != null)
              _buildReplyIndicator(context, msg['reply_to']),
            if (msg['type'] == 'daily-task')
              _buildDailyTaskMessage(context, msg, timestamp),
            if (msg['user'] != null && msg['user'] != '[Voice]')
              _buildUserMessage(context, msg, timestamp, isSelected, isReply),
            if (msg['user'] == '[Voice]' &&
                (msg['audioPath'] != null || msg['audio_url'] != null))
              _buildVoiceMessage(
                context,
                msg,
                timestamp,
                audioHandler,
                isCurrentPlaying,
              ),
            if (msg['type'] == 'chat')
              _buildChatResponse(context, msg, timestamp, isSelected, isReply),
            if (msg['type'] == 'spiral')
              _buildSpiralMessage(context, msg, timestamp, isSelected, isReply),
            if (msg['type'] == 'error') _buildErrorMessage(context, msg),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    VoidCallback onTap,
  ) {
    final timestamp = _parseTimestamp(msg['timestamp']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.purple[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.purple),
                    const SizedBox(width: 8),
                    const Text(
                      "Daily Reflection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  msg['message'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Reply to this prompt'),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return timestamp ?? DateTime.now();
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          DateFormat('EEEE, MMMM d, yyyy').format(date),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyIndicator(BuildContext context, String replyText) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              color: Colors.grey,
              margin: const EdgeInsets.only(right: 8),
            ),
            Expanded(
              child: Text(
                replyText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTaskMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    DateTime timestamp,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📝 Inner Compass",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  msg['message'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    DateTime timestamp,
    bool isSelected,
    bool isReply,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.blue.withOpacity(0.5)
                          : isReply
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg['user'] ?? '',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('h:mm a').format(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    DateTime timestamp,
    ReflectAudioHandler audioHandler,
    bool isCurrentPlaying,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              border: Border.all(color: Colors.blueGrey[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, color: Colors.blueGrey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Voice Message",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (msg['transcription'] != null &&
                    msg['transcription'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Transcription:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${msg['transcription']}"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(
                    isCurrentPlaying && audioHandler.isPlaying
                        ? Icons.stop
                        : Icons.play_arrow,
                    size: 20,
                  ),
                  label: Text(
                    isCurrentPlaying && audioHandler.isPlaying
                        ? 'Stop'
                        : 'Reflect',
                  ),
                  onPressed:
                      () => audioHandler.playAudio(
                        msg['audio_url'] ?? msg['audioPath'],
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[100],
                    foregroundColor: Colors.blueGrey[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                if (msg['ask_speaker_pick'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Please select which speaker is you",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatResponse(
    BuildContext context,
    Map<String, dynamic> msg,
    DateTime timestamp,
    bool isSelected,
    bool isReply,
  ) {
    final rewards = _buildRewardIndicator(msg);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.grey[300]!
                      : isReply
                      ? Colors.grey[100]!
                      : Colors.grey[200]!,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg['response'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
                if (rewards != null) ...[const SizedBox(height: 8), rewards],
                const SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpiralMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    DateTime timestamp,
    bool isSelected,
    bool isReply,
  ) {
    final stage = msg['stage'] ?? 'Unknown';
    final stageMeta = _getStageMeta(stage);
    final gamified = msg['gamified'] ?? {};
    final question = msg['question'] ?? '';
    final evolution = msg['evolution'] ?? '';
    final growthPrompt = gamified['gamified_prompt'] ?? '';
    final xpGained = msg['xp_gained'] ?? 0;
    final badgesEarned = msg['badges_earned'] ?? [];
    final growth = msg['growth'] ?? '';
    final rewards = _buildRewardIndicator(msg);

    // Get color based on stage
    final stageColor = _getStageColor(stage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.orange[200]!
                      : isReply
                      ? Colors.orange[50]!
                      : Colors.orange[100]!,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stage Name with Emoji
                Text(
                  "🌀 Stage: $stage",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Stage Meta (Name and Emoji)
                if (stageMeta != null)
                  Text(
                    "Badge: ${stageMeta['emoji']} ${stageMeta['name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 8),

                // Evolution Message (if any) - Now with stage-specific color
                if (evolution.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      evolution,
                      style: TextStyle(
                        color: stageColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Badges Earned
                if (badgesEarned.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🏆 Badges Earned:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        ...badgesEarned.map(
                          (badge) => Text(
                            "• $badge",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Deep Reflective Question
                if (question.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Mind Mirror 🧠🔍 : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: question,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Growth Prompt (from gamified)
                if (growthPrompt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Mission: $growthPrompt",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Growth Message (direct from msg)
                if (growth.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Mission: $growth",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // XP Gained
                if (xpGained > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "✨ +$xpGained XP",
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Speaker Stages (if diarized)
                if (msg['diarized'] == true && msg['speaker_stages'] != null)
                  _buildSpeakerStages(
                    Map<String, dynamic>.from(msg['speaker_stages']),
                  ),

                // Confidence and Note
                if (msg['confidence'] != null && msg['confidence'] < 0.7)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Confidence: ${(msg['confidence'] * 100).toStringAsFixed(1)}%",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ),
                if (msg['note'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      msg['note'],
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                if (rewards != null) ...[const SizedBox(height: 8), rewards],

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('hh:mm a').format(timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'Beige':
        return Colors.brown;
      case 'Purple':
        return Colors.purple;
      case 'Red':
        return Colors.red;
      case 'Blue':
        return Colors.blue;
      case 'Orange':
        return Colors.orange;
      case 'Green':
        return Colors.green;
      case 'Yellow':
        return Colors.yellow.shade700;
      case 'Turquoise':
        return Colors.teal;
      default:
        return Colors.green;
    }
  }

  Map<String, dynamic>? _getStageMeta(String stage) {
    const stageMeta = {
      "Beige": {
        "emoji": "🏕️",
        "name": "Survival Basecamp",
        "reward": "+5 XP (🌱 Survivalist)",
      },
      "Purple": {
        "emoji": "🪄",
        "name": "Tribe Mystic",
        "reward": "+10 XP (🧙 Tribal Keeper)",
      },
      "Red": {
        "emoji": "🔥",
        "name": "Dragon's Lair",
        "reward": "+15 XP (🐉 Force Master)",
      },
      "Blue": {
        "emoji": "📜",
        "name": "Order Temple",
        "reward": "+20 XP (🛡️ Virtue Guardian)",
      },
      "Orange": {
        "emoji": "🚀",
        "name": "Achiever's Arena",
        "reward": "+25 XP (🏆 Success Champion)",
      },
      "Green": {
        "emoji": "🌀",
        "name": "Harmony Nexus",
        "reward": "+30 XP (🌍 Community Builder)",
      },
      "Yellow": {
        "emoji": "🔄",
        "name": "Flow Integrator",
        "reward": "+35 XP (🌀 Complexity Dancer)",
      },
      "Turquoise": {
        "emoji": "🌌",
        "name": "Cosmic Weave",
        "reward": "+40 XP (♾️ Holon Seer)",
      },
    };
    return stageMeta[stage];
  }

  Widget _buildSpeakerStages(Map<String, dynamic> speakerStages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...speakerStages.entries.map((entry) {
          final speaker = entry.key;
          final stage = entry.value['stage'] ?? 'Unknown';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(
                    text: "$speaker: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  TextSpan(
                    text: stage,
                    style: TextStyle(color: Colors.blueGrey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.red[100]!,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "❌ ${msg['message'] ?? 'Error'}",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildRewardIndicator(Map<String, dynamic> msg) {
    final rewards = <Widget>[];

    if (msg['streak'] != null) {
      rewards.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '🔥 ${msg['streak']} day streak',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    // Only show XP if it's not already shown in the main message (for spiral messages)
    if (msg['xp_gained'] != null && msg['type'] != 'spiral') {
      rewards.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '✨ +${msg['xp_gained']} XP',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (rewards.isEmpty) return null;

    return Wrap(spacing: 8, runSpacing: 4, children: rewards);
  }

  Widget _buildWelcomeMessage(BuildContext context, Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            msg['message'] ?? "Welcome!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
