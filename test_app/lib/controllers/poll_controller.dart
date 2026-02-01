import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/controllers/games_controller.dart';
import 'package:test_app/utils/custom_toast.dart';

class PollController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final GamesController _gamesController = Get.find<GamesController>();

  var currentPoll = Rxn<Map<String, dynamic>>();
  var hasVoted = false.obs;
  var isLoading = true.obs;
  var selectedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailyPoll();
  }

  Future<void> fetchDailyPoll() async {
    try {
      isLoading.value = true;
      String? uid = _authController.auth.currentUser?.uid;

      // 1. Fetch current active poll
      var pollSnapshot = await _firestore
          .collection('daily_polls')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (pollSnapshot.docs.isNotEmpty) {
        var doc = pollSnapshot.docs.first;
        currentPoll.value = {'id': doc.id, ...doc.data()};

        // 2. Check if user already voted
        if (uid != null) {
          var voteSnapshot = await _firestore
              .collection('daily_polls')
              .doc(doc.id)
              .collection('votes')
              .doc(uid)
              .get();
          
          hasVoted.value = voteSnapshot.exists;
          if (hasVoted.value) {
            selectedIndex.value = voteSnapshot.data()?['optionIndex'] ?? -1;
          }
        }
      } else {
        // Fallback or Create a dummy one if empty (for first time dev)
        await _createFallbackPoll();
      }
    } catch (e) {
      print('Poll Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> castVote(int optionIndex) async {
    String? uid = _authController.auth.currentUser?.uid;
    if (uid == null) {
      CustomToast.showError('Please login to vote');
      return;
    }

    if (hasVoted.value) return;

    try {
      String pollId = currentPoll.value!['id'];
      
      // Update totals in transaction
      await _firestore.runTransaction((transaction) async {
        DocumentReference pollRef = _firestore.collection('daily_polls').doc(pollId);
        DocumentSnapshot pollDoc = await transaction.get(pollRef);
        
        if (!pollDoc.exists) return;

        List<dynamic> results = List.from(pollDoc.get('results') ?? [0, 0, 0, 0]);
        results[optionIndex] = (results[optionIndex] as int) + 1;
        
        transaction.update(pollRef, {'results': results});
        
        // Record user's vote
        transaction.set(_firestore.collection('daily_polls').doc(pollId).collection('votes').doc(uid), {
          'optionIndex': optionIndex,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      hasVoted.value = true;
      selectedIndex.value = optionIndex;
      
      // Refresh local results for UI
      _refreshLocalResults(optionIndex);
      
      // Award points
      _gamesController.addPoints(10);
      CustomToast.showSuccess('Vote cast! +10 Points');
      
    } catch (e) {
      CustomToast.showError('Failed to cast vote');
    }
  }

  void _refreshLocalResults(int votedIndex) {
    if (currentPoll.value != null) {
      var data = Map<String, dynamic>.from(currentPoll.value!);
      List<int> res = List<int>.from(data['results'] ?? [0, 0, 0, 0]);
      res[votedIndex]++;
      data['results'] = res;
      currentPoll.value = data;
    }
  }

  Future<void> _createFallbackPoll() async {
    // This creates an initial poll if none exists in Firestore
    try {
      await _firestore.collection('daily_polls').add({
        'question': 'Are you ready for the upcoming General Election?',
        'options': ['Completely Ready', 'Still Learning', 'Need More Info', 'Not Sure'],
        'results': [0, 0, 0, 0],
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      fetchDailyPoll();
    } catch (e) {
      print('Fallback Poll Error: $e');
    }
  }
}
