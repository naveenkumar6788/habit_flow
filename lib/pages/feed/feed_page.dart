import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/feed_provider.dart';
import 'package:paceai/providers/auth_provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final postCtrl = TextEditingController();
  final commentCtrls = <String, TextEditingController>{};

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: postCtrl,
                    decoration: const InputDecoration(hintText: "Share your progress..."),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final text = postCtrl.text.trim();
                          if (text.isEmpty) return;
                          try {
                            await context.read<FeedProvider>().createPost(text);
                            postCtrl.clear();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post published')));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to publish: $e')));
                            }
                          }
                        },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Post'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final p in feed.posts)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.content),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            p.likes.contains(context.read<AuthProvider>().userId ?? 'none')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => feed.toggleLike(p.id),
                        ),
                        Text('${p.likes.length}'),
                        const SizedBox(width: 4),
                        const Text('likes'),
                        const SizedBox(width: 16),
                        const Icon(Icons.mode_comment_outlined, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('${(feed.comments[p.id]?.length ?? 0)}'),
                        const SizedBox(width: 4),
                        const Text('comments'),
                      ],
                    ),
                    const Divider(),
                    for (final c in feed.comments[p.id] ?? [])
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(c.text),
                        subtitle: Text(c.createdAt.toLocal().toString()),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentCtrls.putIfAbsent(p.id, () => TextEditingController()),
                            decoration: const InputDecoration(hintText: 'Add a comment'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.green),
                          onPressed: () async {
                            final text = commentCtrls[p.id]!.text.trim();
                            if (text.isEmpty) return;
                            await context.read<FeedProvider>().addComment(p.id, text);
                            commentCtrls[p.id]!.clear();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
