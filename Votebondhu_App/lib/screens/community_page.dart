import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/controllers/home_controller.dart';
import 'package:test_app/controllers/bondhu_controller.dart';
import 'package:test_app/widgets/custom_card.dart';
import 'package:test_app/utils/custom_toast.dart';
import 'package:test_app/screens/chat_page.dart';
import 'package:test_app/screens/bondhu_list_page.dart';
import 'package:intl/intl.dart';
import 'package:test_app/models/post_model.dart';
import 'package:test_app/widgets/social_action_button.dart';
import 'package:test_app/widgets/comment_sheet.dart';
import 'package:test_app/utils/image_utils.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final TextEditingController _postCtrl = TextEditingController();
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final BondhuController bondhuController = Get.put(BondhuController());

  // Function to create a post
  void _createPost() async {
    if (_postCtrl.text.trim().isEmpty) return;

    var currentUser = authController.currentUserModel.value;

    if (currentUser == null) {
      CustomToast.showError('Guest users cannot post.');
      return;
    }

    try {
      print('Attempting to create post for user: ${currentUser.uid}');
      await FirebaseFirestore.instance.collection('posts').add({
        'content': _postCtrl.text.trim(),
        'authorId': currentUser.uid,
        'authorName': currentUser.username,
        'authorArea': currentUser.area,
        'authorProfileUrl': currentUser.profileImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'commentsCount': 0,
      });
      _postCtrl.clear();
      CustomToast.showSuccess('Post created!');
      print('Post created successfully!');
    } catch (e) {
      print('Error creating post: $e');
      CustomToast.showError('Failed to post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Create Post Box
        if (!authController.isGuest.value)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _postCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts on voting...',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _createPost,
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Post'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Feed
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Error loading posts'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var allPosts = snapshot.data!.docs;
              String myUid = authController.auth.currentUser?.uid ?? '';
              
              // Map to PostModel
              var posts = allPosts.map((doc) => 
                PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
              ).toList();

              // Visibility: Me + My Bondhus
              var filteredPosts = posts.where((post) {
                bool isMe = post.authorId == myUid;
                bool isFriend = bondhuController.myBondhus.any((b) => b['uid'] == post.authorId);
                
                // If user has NO bondhus and is NOT guest, show public posts for discovery
                // Otherwise only show circles
                if (bondhuController.myBondhus.isEmpty && !authController.isGuest.value) {
                   return true; 
                }
                return isMe || isFriend;
              }).toList();

              if (filteredPosts.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                       const SizedBox(height: 16),
                       const Text('Your feed is empty.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       const Text('Add "VoteBondhus" to see their posts here!', textAlign: TextAlign.center),
                       const SizedBox(height: 24),
                       ElevatedButton(
                         onPressed: () => Get.to(() => const BondhuListPage()),
                         child: const Text('Find VoteBondhus'),
                       )
                     ],
                   )
                 );
              }

              return ListView.builder(
                itemCount: filteredPosts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  var post = filteredPosts[index];
                  bool isLiked = post.likes.contains(myUid);
                  
                  bool isFriend = bondhuController.myBondhus.any((b) => b['uid'] == post.authorId);
                  bool isMe = post.authorId == myUid;
                  bool isPending = bondhuController.outgoingRequestUids.contains(post.authorId);

                  return CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage: ImageUtils.getProfileImage(post.authorProfileUrl),
                              child: post.authorProfileUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (post.authorArea.isNotEmpty)
                                    Text(
                                      post.authorArea,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(post.createdAt),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            if (!isFriend && !isMe && !authController.isGuest.value)
                              IconButton(
                                onPressed: isPending ? null : () => bondhuController.sendFriendRequest(post.authorId, post.authorName),
                                icon: Icon(
                                  isPending ? Icons.hourglass_empty : Icons.person_add_alt_1, 
                                  color: isPending ? Colors.grey : Colors.blue
                                ),
                                tooltip: isPending ? 'Request Pending' : 'Add VoteBondhu',
                              ),
                            if (isMe)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Delete Post',
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'Delete Post',
                                    middleText: 'Are you sure you want to delete this post?',
                                    textConfirm: 'Delete',
                                    textCancel: 'Cancel',
                                    confirmTextColor: Colors.white,
                                    buttonColor: Colors.red,
                                    onConfirm: () {
                                      bondhuController.deletePost(post.id, post.authorId);
                                      Get.back();
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Content
                        Text(
                          post.content,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SocialActionButton(
                              icon: Icons.thumb_up_outlined,
                              activeIcon: Icons.thumb_up,
                              label: post.likes.isNotEmpty ? '${post.likes.length}' : 'Like',
                              isActive: isLiked,
                              activeColor: Colors.blue,
                              onTap: () => bondhuController.likePost(post.id, post.likes),
                            ),
                            SocialActionButton(
                              icon: Icons.comment_outlined,
                              label: post.commentsCount > 0 ? '${post.commentsCount}' : 'Comment',
                              isActive: false, // Could be true if user commented
                              activeColor: Colors.green,
                              onTap: () {
                                _showCommentsBottomSheet(context, post.id);
                              },
                            ),
                            if (isFriend || isMe)
                              SocialActionButton(
                                icon: Icons.chat_bubble_outline,
                                label: 'Chat',
                                activeColor: Colors.green,
                                onTap: () {
                                   Get.to(() => ChatPage(otherUid: post.authorId, otherName: post.authorName));
                                },
                              ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  void _showCommentsBottomSheet(BuildContext context, String postId) {
    Get.bottomSheet(
      CommentSheet(
        commentStream: bondhuController.getComments(postId),
        onSubmit: (text) => bondhuController.addComment(postId, text),
      ),
      isScrollControlled: true,
    );
  }
}
