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
