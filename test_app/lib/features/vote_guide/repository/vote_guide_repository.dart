import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/vote_guide_dto.dart';

class VoteGuideRepository{
  Future<List<VoteGuideDTO>> fetchSteps() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('vote_guide').get().timeout(const Duration(seconds: 3));
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          return VoteGuideDTO(
            title: data['title'] ?? '',
            description: data['description'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      print('Firestore vote_guide fetch failed, using fallback.');
    }

    return [
      VoteGuideDTO(
        title: "ভোটার হিসেবে নিবন্ধন",
        description: "আপনি যদি নতুন ভোটার হন, তবে প্রথমে অনলাইন বা নিকটস্থ নির্বাচন অফিসে গিয়ে নিবন্ধন সম্পন্ন করুন এবং এনআইডি সংগ্রহ করুন।",
      ),
      VoteGuideDTO(
        title: "ভোট কেন্দ্রে উপস্থিতি",
        description: "ভোটের দিন সকাল ৮টা থেকে বিকাল ৪টার মধ্যে আপনার নির্ধারিত কেন্দ্রে উপস্থিত হন। সাথে এনআইডি বা স্মার্ট কার্ড আনলে সুবিধা হবে।",
      ),
      VoteGuideDTO(
        title: "পরিচয় নিশ্চিতকরণ",
        description: "পোলিং অফিসারের কাছে আপনার নাম ও ভোটার নম্বর যাচাই করুন। আঙ্গুলের ছাপ দিয়ে পরিচয় নিশ্চিত হলে আপনাকে ব্যালট পেপার দেয়া হবে।",
      ),
      VoteGuideDTO(
        title: "ব্যালট সংগ্রহ",
        description: "জাতীয় নির্বাচনের জন্য সাধারণত একটি ব্যালট পেপার থাকে। স্থানীয় নির্বাচনে একাধিক পদের জন্য আলাদা রঙের ব্যালট থাকতে পারে।",
      ),
      VoteGuideDTO(
        title: "গোপন কক্ষে ভোটদান",
        description: "ব্যালট পেপার নিয়ে গোপন কক্ষে যান। আপনার পছন্দের প্রার্থীর প্রতীকের ওপর সীল মারুন। খেয়াল রাখবেন সীল যেন অন্য বক্সে না লাগে।",
      ),
      VoteGuideDTO(
        title: "ব্যালট ভাঁজ ও জমা",
        description: "সীল শুকানোর পর ব্যালটটি নির্দেশিত নিয়মে ভাঁজ করুন এবং প্রিসাইডিং অফিসারের সামনে রাখা স্বচ্ছ ব্যালট বাক্সে ফেলুন।",
      ),
      VoteGuideDTO(
        title: "কালি ও বেরিয়ে আসা",
        description: "ভোট দেয়া শেষ হলে আপনার আঙ্গুলে অমোচনীয় কালি লাগিয়ে দেয়া হবে। এরপর শান্তিপূর্ণভাবে কেন্দ্র ত্যাগ করুন।",
      ),
    ];
  }
}
