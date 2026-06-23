import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/demo_data.dart';
import '../models/message.dart';
import '../widgets/app_scaffold.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<List<Message>> _messages;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messages = _load();
  }

  Future<List<Message>> _load() async {
    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/messages');
      final messageList = response['data'] as List<dynamic>? ??
          response['messages'] as List<dynamic>? ??
          response['items'] as List<dynamic>? ?? [];
      final messages = messageList
          .map((item) => Message.fromJson(item as Map<String, dynamic>))
          .toList();
      if (messages.isEmpty) {
        return DemoData.messages;
      }
      return messages;
    } catch (e) {
      if (!mounted) return DemoData.messages;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading messages: $e'), backgroundColor: Colors.red),
      );
      return DemoData.messages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat',
      onRefresh: () async {
        setState(_loadMessages);
        await _messages;
      },
      children: [
        FutureBuilder<List<Message>>(
          future: _messages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final messages = snapshot.data ?? [];
            if (messages.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No messages yet', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: messages
                  .map((message) => _MessageCard(
                        message,
                        onReplySent: _reloadMessages,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _reloadMessages() {
    if (!mounted) return;
    setState(_loadMessages);
  }
}

class _MessageCard extends StatefulWidget {
  const _MessageCard(this.message, {this.onReplySent});

  final Message message;
  final VoidCallback? onReplySent;

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMessageDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text((widget.message.senderName ?? 'U').substring(0, 1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.senderName ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _formatDate(widget.message.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.message.bookingId != null)
                    const Chip(
                      label: Text('Booking'),
                      avatar: Icon(Icons.event, size: 14),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.message.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: 'chatReplyButton',
                  button: true,
                  child: FilledButton(
                    onPressed: () => _showReplyDialog(context),
                    child: const Text('Reply'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _showMessageDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.message.senderName ?? 'Unknown', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(_formatDate(widget.message.createdAt), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            Text(widget.message.content),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.reply),
              label: const Text('Reply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context) {
    final replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to message'),
        content: TextField(
          controller: replyCtrl,
          decoration: const InputDecoration(labelText: 'Your message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Semantics(
            label: 'chatReplySendButton',
            button: true,
            child: FilledButton(
              onPressed: () async {
                final content = replyCtrl.text.trim();
                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a reply message before sending.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                if (content.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply message is too short.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                await _sendReply(context, content);
              },
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply(BuildContext context, String content) async {
    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.post('/messages', {
        'recipient_id': widget.message.senderId,
        'content': content,
        'body': content,
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      widget.onReplySent?.call();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to send reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
