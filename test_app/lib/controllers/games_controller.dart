import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/utils/custom_toast.dart';

class GamesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var userPoints = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.currentUserModel.value != null) {
      userPoints.value = _authController.currentUserModel.value!.points;
    }
    // Listen to changes in the current user model
    ever(_authController.currentUserModel, (user) {
      if (user != null) {
        userPoints.value = user.points;
      }
    });
  }

  // Update points after a game or quiz
  Future<void> addPoints(int points) async {
    String? uid = _authController.auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'points': FieldValue.increment(points),
      });
      // The ever listener will update userPoints locally
      CustomToast.showSuccess('You earned $points points!');
    } catch (e) {
      CustomToast.showError('Failed to update points');
    }
  }

  // Redeem points for a ticket/item
  Future<bool> redeemTicket(String placeName, int cost) async {
    String? uid = _authController.auth.currentUser?.uid;
    if (uid == null) {
      CustomToast.showError('Please login to redeem points');
      return false;
    }

    if (userPoints.value < cost) {
      CustomToast.showError('Insufficient points');
      return false;
    }

    try {
      isLoading.value = true;
      
      // 1. Deduct points
      await _firestore.collection('users').doc(uid).update({
        'points': FieldValue.increment(-cost),
      });

      // 2. Add to virtual tickets collection
      await _firestore.collection('users').doc(uid).collection('tickets').add({
        'place': placeName,
        'redeemedAt': FieldValue.serverTimestamp(),
        'cost': cost,
      });

      CustomToast.showSuccess('Redeemed ticket for $placeName!');
      return true;
    } catch (e) {
      CustomToast.showError('Redemption failed');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
