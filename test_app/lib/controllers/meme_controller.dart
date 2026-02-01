import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/utils/custom_toast.dart';

class MemeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var memes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMemes();
  }

  // Fetch all memes
  void fetchMemes() {
    _firestore
        .collection('memes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      memes.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Create a new meme
  Future<void> createMeme(String content) async {
    var currentUser = _authController.currentUserModel.value;

    if (currentUser == null) {
      CustomToast.showError('Guest users cannot post memes.');
      return;
    }

    if (content.trim().isEmpty) {
      CustomToast.showError('Meme content cannot be empty.');
      return;
    }

    try {
      isLoading.value = true;
      await _firestore.collection('memes').add({
        'content': content.trim(),
        'authorId': currentUser.uid,
        'authorName': currentUser.username,
        'authorProfileUrl': currentUser.profileImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });
      CustomToast.showSuccess('Meme posted!');
    } catch (e) {
      print('Error creating meme: $e');
      CustomToast.showError('Failed to post meme.');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a meme (only by author)
  Future<void> deleteMeme(String memeId, String authorId) async {
    var currentUser = _authController.currentUserModel.value;

    if (currentUser == null || currentUser.uid != authorId) {
      CustomToast.showError('You can only delete your own memes.');
      return;
    }

    try {
      await _firestore.collection('memes').doc(memeId).delete();
      CustomToast.showSuccess('Meme deleted!');
    } catch (e) {
      print('Error deleting meme: $e');
      CustomToast.showError('Failed to delete meme.');
    }
  }

  // Like/Unlike a meme
  Future<void> likeMeme(String memeId, List likes) async {
    var currentUser = _authController.currentUserModel.value;
    if (currentUser == null) return;

    String userId = currentUser.uid;
    bool isLiked = likes.contains(userId);

    try {
      if (isLiked) {
        await _firestore.collection('memes').doc(memeId).update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await _firestore.collection('memes').doc(memeId).update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print('Error liking meme: $e');
    }
  }
  // Add a comment to a meme
  Future<void> addComment(String memeId, String commentText) async {
    var currentUser = _authController.currentUserModel.value;
    if (currentUser == null) {
      CustomToast.showError('Guest users cannot comment.');
      return;
    }

    if (commentText.trim().isEmpty) return;

    try {
      await _firestore.collection('memes').doc(memeId).collection('comments').add({
        'text': commentText.trim(),
        'authorId': currentUser.uid,
        'authorName': currentUser.username,
        'timestamp': FieldValue.serverTimestamp(),
      });
      CustomToast.showSuccess('Comment added!');
    } catch (e) {
      print('Error adding comment: $e');
      CustomToast.showError('Failed to add comment.');
    }
  }

  // Get comments stream for a meme
  Stream<QuerySnapshot> getComments(String memeId) {
    return _firestore
        .collection('memes')
        .doc(memeId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
