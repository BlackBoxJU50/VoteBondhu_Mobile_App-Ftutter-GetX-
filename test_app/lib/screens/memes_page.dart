import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/meme_controller.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/widgets/social_action_button.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/utils/image_utils.dart';

class MemesPage extends StatelessWidget {
  const MemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MemeController memeController = Get.put(MemeController());
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController memeTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meme Competition',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (memeController.memes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_emotions_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No memes yet!',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to post a meme',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: memeController.memes.length,
                itemBuilder: (context, index) {
                  var meme = memeController.memes[index];
                  String memeId = meme['id'] ?? '';
                  String content = meme['content'] ?? '';
                  String authorName = meme['authorName'] ?? 'Anonymous';
                  String authorId = meme['authorId'] ?? '';
                  String authorProfileUrl = meme['authorProfileUrl'] ?? '';
                  List likes = meme['likes'] ?? [];
                  var timestamp = meme['timestamp'];
      
                  bool isMyMeme = authController.currentUserModel.value?.uid == authorId;
                  bool isLiked = likes.contains(authController.currentUserModel.value?.uid);
      
                  String timeAgo = '';
                  if (timestamp != null) {
                    try {
                      DateTime dateTime = timestamp.toDate();
                      timeAgo = DateFormat('MMM d, h:mm a').format(dateTime);
                    } catch (e) {
                      timeAgo = 'Just now';
                    }
                  }
      
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade50, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.orange.shade200, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: ImageUtils.getProfileImage(authorProfileUrl),
                                backgroundColor: Colors.orange.shade200,
                                child: authorProfileUrl.isEmpty
                                    ? Icon(Icons.person, color: Colors.orange.shade700)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authorName,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    Text(
                                      timeAgo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMyMeme)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Delete Meme',
                                      middleText: 'Are you sure you want to delete this meme?',
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        memeController.deleteMeme(memeId, authorId);
                                        Get.back();
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Meme Content
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade300, width: 2),
                            ),
                            child: Text(
                              content,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Like Button
                          Row(
                            children: [
                              SocialActionButton(
                                icon: Icons.thumb_up_outlined,
                                activeIcon: Icons.thumb_up,
                                label: likes.isNotEmpty ? '${likes.length}' : 'Like',
                                isActive: isLiked,
                                activeColor: Colors.orange,
                                onTap: () => memeController.likeMeme(memeId, likes),
                              ),
                              const SizedBox(width: 16),
                              SocialActionButton(
                                icon: Icons.comment_outlined,
                                activeIcon: Icons.comment,
                                label: 'Comment',
                                isActive: false,
                                activeColor: Colors.blue,
                                onTap: () => _showCommentsBottomSheet(context, memeController, memeId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.defaultDialog(
            title: 'Post a Meme',
            titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: memeTextController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Write something funny...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
              ),
            ),
            textConfirm: 'Post',
            textCancel: 'Cancel',
            confirmTextColor: Colors.white,
            buttonColor: Colors.orange,
            onConfirm: () {
              if (memeTextController.text.trim().isNotEmpty) {
                memeController.createMeme(memeTextController.text);
                memeTextController.clear();
                Get.back();
              }
            },
            onCancel: () {
              memeTextController.clear();
            },
          );
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Post Meme',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, MemeController controller, String memeId) {
    TextEditingController commentCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text('Comments', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.getComments(memeId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var comments = snapshot.data!.docs;
                  if (comments.isEmpty) return const Center(child: Text('No comments yet.'));
                  
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      var data = comment.data() as Map<String, dynamic>?;
                      String text = data?['text'] ?? '';
                      String author = data?['authorName'] ?? 'Anonymous';
                      
                      return ListTile(
                        leading: CircleAvatar(child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?')),
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
                      controller.addComment(memeId, commentCtrl.text);
                      commentCtrl.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
