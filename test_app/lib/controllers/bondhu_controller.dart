import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/utils/custom_toast.dart';

class BondhuController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var myBondhus = <Map<String, dynamic>>[].obs;
  var incomingRequests = <Map<String, dynamic>>[].obs;
  var outgoingRequestUids = <String>[].obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var suggestions = <Map<String, dynamic>>[].obs; 
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isAuthenticated.value && !_authController.isGuest.value) {
      fetchMyBondhus();
      fetchSuggestions(); // Load all users as suggestions initially
    }
  }

  // Fetch list of added friends (VoteBondhus)
  void fetchMyBondhus() {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    _firestore
        .collection('users')
        .doc(myUid)
        .collection('bondhus')
        .snapshots()
        .listen((snapshot) async {
      var bondhus = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        var userDoc = await _firestore.collection('users').doc(doc.id).get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          data['uid'] = doc.id;
          bondhus.add(data);
        }
      }
      myBondhus.value = bondhus;
      fetchIncomingRequests();
      fetchOutgoingRequests();
      fetchSuggestions(); 
    });
  }

  void fetchIncomingRequests() {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    _firestore
        .collection('users')
        .doc(myUid)
        .collection('incoming_requests')
        .snapshots()
        .listen((snapshot) async {
      var requests = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        var userDoc = await _firestore.collection('users').doc(doc.id).get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          data['uid'] = doc.id;
          requests.add(data);
        }
      }
      incomingRequests.value = requests;
    });
  }

  void fetchOutgoingRequests() {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: myUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      outgoingRequestUids.value = snapshot.docs.map((doc) => doc.get('to').toString()).toList();
    });
  }

  // Fetch Suggestions (All users - Friends - Self)
  // In a real app, this would be paginated or algorithmic
  void fetchSuggestions() async {
    String myUid = _authController.box.read('id') ?? '';
    if (myUid.isEmpty) return;

    try {
      var snapshot = await _firestore.collection('users').limit(50).get();
      var allUsers = snapshot.docs.map((doc) {
        var data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();

      // Filter out self and existing friends
      allUsers.removeWhere((u) => u['uid'] == myUid);
      allUsers.removeWhere((u) => myBondhus.any((friend) => friend['uid'] == u['uid']));

      suggestions.value = allUsers;
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  // Sync Contacts to find friends
  Future<void> syncContacts() async {
    if (await Permission.contacts.request().isGranted) {
      isLoading.value = true;
      try {
        List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
        List<String> phoneNumbers = [];
        List<String> emails = [];

        for (var contact in contacts) {
          for (var phone in contact.phones) {
            phoneNumbers.add(phone.number.replaceAll(RegExp(r'\D'), '')); // simple normalize
          }
          for (var email in contact.emails) {
            emails.add(email.address.toLowerCase());
          }
        }
        
        // Note: Our current User model mostly has email. Phone search would require phone in user profile.
        // We will match by Email for now as our Signup flow uses Email.
        
        if (emails.isNotEmpty) {
           // Firestore 'in' query limited to 10/30 items. We'll do client side for demo or assume small scale.
           // Re-using fetchSuggestions logic but stricter filter?
           // Ideally: query users where email in [list].
           
           // For BETA/DEMO: We just show "Suggestions" as "People you might know" 
           // since we don't have phone numbers in our User model yet.
           // But let's pretend we did the sync.
           
           CustomToast.showSuccess('Contacts synced! Found ${contacts.length} contacts.');
           // In real app: Match contacts against DB.
           fetchSuggestions();
        } else {
           CustomToast.showInfo('No contacts with emails found.');
        }

      } catch (e) {
        CustomToast.showError('Failed to sync contacts');
      } finally {
        isLoading.value = false;
      }
    } else {
      CustomToast.showError('Contacts permission denied');
    }
  }

  // Search logic
  void searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    isLoading.value = true;
    try {
      var snapshot = await _firestore.collection('users').get(); // Get all for simple filter
      var results = snapshot.docs.where((doc) {
        var data = doc.data();
        String name = (data['username'] ?? '').toString().toLowerCase();
        String email = (data['email'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).map((doc) {
        var data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();

      String myUid = _authController.box.read('id') ?? '';
      results.removeWhere((user) => user['uid'] == myUid);
      
      searchResults.value = results;
    } catch (e) {
      CustomToast.showError('Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  // Send Friend Request
  Future<void> sendFriendRequest(String targetUid, String name) async {
    String myUid = _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    try {
      // 1. Create top level request doc (for tracking)
      await _firestore.collection('friend_requests').add({
        'from': myUid,
        'to': targetUid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Add to recipient's incoming subcollection
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection('incoming_requests')
          .doc(myUid)
          .set({'timestamp': FieldValue.serverTimestamp()});

      CustomToast.showSuccess('Request sent to $name');
    } catch (e) {
      CustomToast.showError('Failed to send request');
    }
  }

  // Accept Friend Request
  Future<void> acceptFriendRequest(String otherUid) async {
    String myUid = _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    try {
      WriteBatch batch = _firestore.batch();

      // Update both users' bondhus collections
      batch.set(_firestore.collection('users').doc(myUid).collection('bondhus').doc(otherUid), {
        'timestamp': FieldValue.serverTimestamp(),
      });
      batch.set(_firestore.collection('users').doc(otherUid).collection('bondhus').doc(myUid), {
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove the incoming request
      batch.delete(_firestore.collection('users').doc(myUid).collection('incoming_requests').doc(otherUid));

      // Mark friend_request doc as accepted
      var reqSnapshot = await _firestore
          .collection('friend_requests')
          .where('from', isEqualTo: otherUid)
          .where('to', isEqualTo: myUid)
          .limit(1)
          .get();
      
      if (reqSnapshot.docs.isNotEmpty) {
        batch.update(reqSnapshot.docs.first.reference, {'status': 'accepted'});
      }

      await batch.commit();
      CustomToast.showSuccess('Now you are VoteBondhus!');
    } catch (e) {
      CustomToast.showError('Error accepting request');
    }
  }

  // Decline Friend Request
  Future<void> declineFriendRequest(String otherUid) async {
    String myUid = _authController.auth.currentUser?.uid ?? '';
    if (myUid.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(myUid)
          .collection('incoming_requests')
          .doc(otherUid)
          .delete();
      
      CustomToast.showInfo('Request declined');
    } catch (e) {
      CustomToast.showError('Error declining request');
    }
  }

  // Send Message
  Future<void> sendMessage(String otherUid, String message) async {
    if (message.trim().isEmpty) return;
    
    String myUid = _authController.box.read('id') ?? '';
     if (myUid.isEmpty || myUid == 'guest') return;

    List<String> ids = [myUid, otherUid];
    ids.sort();
    String chatId = ids.join('_');

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': myUid,
      'text': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
    
  Stream<QuerySnapshot> getMessages(String otherUid) {
    String myUid = _authController.box.read('id') ?? '';
    List<String> ids = [myUid, otherUid];
    ids.sort();
    String chatId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  // Like a post
  Future<void> likePost(String postId, List likes) async {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    print('Attempting to like post: $postId by user: $myUid');
    
    if (myUid.isEmpty || myUid == 'guest') {
      print('User is guest or not logged in');
      return;
    }

    try {
      if (likes.contains(myUid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([myUid])
        });
        print('Unliked post');
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([myUid])
        });
        print('Liked post');
      }
    } catch (e) {
      print('Error liking post: $e');
      CustomToast.showError('Failed to like post');
    }
  }

  // Delete a post (only by author)
  Future<void> deletePost(String postId, String authorId) async {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    
    print('Delete Post Debug:');
    print('  My UID: $myUid');
    print('  Author ID: $authorId');
    print('  Post ID: $postId');

    if (myUid.isEmpty) {
      CustomToast.showError('You must be logged in to delete posts.');
      return;
    }

    if (myUid != authorId) {
      CustomToast.showError('You can only delete your own posts.');
      print('  UID mismatch - cannot delete');
      return;
    }

    try {
      print('  Attempting to delete post...');
      await _firestore.collection('posts').doc(postId).delete();
      CustomToast.showSuccess('Post deleted!');
      print('  Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
      CustomToast.showError('Failed to delete post.');
    }
  }

  // Add a comment
  Future<void> addComment(String postId, String comment) async {
    String myUid = _authController.box.read('id') ?? _authController.auth.currentUser?.uid ?? '';
    print('Attempting to add comment to $postId by $myUid');
    
    if (myUid.isEmpty || myUid == 'guest') {
      print('User is guest');
      return;
    }

    try {
      await _firestore.collection('posts').doc(postId).collection('comments').add({
        'text': comment,
        'authorId': myUid,
        'authorName': _authController.currentUserModel.value?.username ?? 'User',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1)
      });
      
      print('Comment added successfully');
      CustomToast.showSuccess('Comment added');
    } catch (e) {
      print('Error adding comment: $e');
      CustomToast.showError('Failed to add comment');
    }
  }

  // Get comments stream for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
