import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CommentSheet extends StatelessWidget {
  final Stream<QuerySnapshot> commentStream;
  final Function(String) onSubmit;

  const CommentSheet({
    super.key,
    required this.commentStream,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentCtrl = TextEditingController();

    return Container(
      // Dynamic padding based on keyboard height
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Limit height of list to avoid taking up full screen if few comments
          // But allow expanding. Flexible/Expanded works if parent has constraints.
          // Get.bottomSheet with isScrollControlled gives us full height potential.
          SizedBox(
            height: 300, // Fixed height for the list area, or use constrained box
            child: StreamBuilder<QuerySnapshot>(
              stream: commentStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var comments = snapshot.data!.docs;
                if (comments.isEmpty) return const Center(child: Text('No comments yet.'));

                return ListView.builder(
                  itemCount: comments.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    var data = comment.data() as Map<String, dynamic>?;
                    String text = data?['text'] ?? '';
                    String author = data?['authorName'] ?? 'Anonymous';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?'),
                      ),
                      title: Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(text),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  if (commentCtrl.text.trim().isNotEmpty) {
                    onSubmit(commentCtrl.text.trim());
                    commentCtrl.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
