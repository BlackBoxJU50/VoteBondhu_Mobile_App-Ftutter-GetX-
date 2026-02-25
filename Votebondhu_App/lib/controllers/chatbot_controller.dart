import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatbotController extends GetxController {
  var messages = <ChatMessage>[].obs;
  var textController = TextEditingController();
  var isExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial greeting
    messages.add(ChatMessage(
      text: "Hello! I am your VoteBondhu AI Assistant. Ask me anything about voting rules, regulations, or procedures in Bangladesh.",
      isUser: false,
      time: DateTime.now(),
    ));
  }

  void toggleChat() {
    isExpanded.value = !isExpanded.value;
  }

  void sendMessage() async {
    String text = textController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      time: DateTime.now(),
    ));
    textController.clear();

    // Simulate thinking delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate response
    String response = _generateResponse(text.toLowerCase());

    messages.add(ChatMessage(
      text: response,
      isUser: false,
      time: DateTime.now(),
    ));
  }

  String _generateResponse(String input) {
    if (_isPersonalOrCandidateQuestion(input)) {
      return "I apologize, but I cannot answer personal questions or give opinions on specific candidates or parties. My purpose is to help you with voting procedures and rules.";
    }

    if (input.contains('how to vote') || input.contains('process')) {
      return "To vote, follow these steps:\n1. Go to your designated polling center on election day (8 AM - 4 PM).\n2. Bring your NID or Smart Card.\n3. Verify your identity with the Polling Officer.\n4. Receive your ballot paper.\n5. Mark your choice in the secret booth.\n6. Drop the ballot in the transparent box.";
    }
    
    if (input.contains('nid') || input.contains('document') || input.contains('id card')) {
      return "You should bring your NID (National ID) card or Smart Card to the polling center to verify your identity easily. If you don't have it, you may still vote if your name is on the voter list, but bringing the ID is highly recommended.";
    }

    if (input.contains('time') || input.contains('open') || input.contains('close')) {
      return "Polling centers are typically open from 8:00 AM to 4:00 PM on Election Day without any break.";
    }

    if (input.contains('rules') || input.contains('regulation')) {
      return "Key Voting Rules:\n- No mobile phones inside the polling booth.\n- No campaigning within 400 yards of the center.\n- Maintain peace and queue orderly.\n- Double voting is a criminal offense.";
    }

    if (input.contains('news') || input.contains('update')) {
      return "For authentic news, please check the 'News' tab in this app. We aggregate updates from Prothom Alo, The Daily Star, and other verified sources.";
    }
    
    if (input.contains('center') || input.contains('where')) {
      return "You can check your voting center using these methods:\n1. SMS: Type 'PC <Space> NID Number' and send to 105.\n2. Online: Visit the EC website (services.nidw.gov.bd).\n3. App: Check the 'Candidate List' tab for area-specific info.";
    }

    if (input.contains('candidate') || input.contains('requirement')) {
      return "Candidate Requirements:\n- Must be a citizen of Bangladesh.\n- Minimum age: 25 years.\n- Name must be on the voter list.\n- Must not be a loan defaulter or convicted of a criminal offense with 2+ years jail.";
    }

    if (input.contains('spoiled') || input.contains('ballot') || input.contains('cancel')) {
      return "A ballot is considered spoiled if:\n- Stamped on more than one symbol.\n- Stamped outside the boxes.\n- Any writing or signs are made on the paper.\n- No stamp is visible at all.";
    }

    if (input.contains('overseas') || input.contains('expat') || input.contains('probashi')) {
      return "Expatriate Bangladeshis can vote but must be present in their designated polling center in Bangladesh on election day. Postal voting is currently very limited.";
    }
    
    // New Content
    if (input.contains('member') || input.contains('mp') || input.contains('seats')) {
      return "The National Parliament (Jatiya Sangsad) consists of 350 seats: 300 elected directly in single-member constituencies, and 50 reserved for women, distributed based on proportional representation.";
    }

    if (input.contains('commission') || input.contains('ec') || input.contains('head')) {
      return "The Election Commission of Bangladesh is a constitutional body. It is headed by the Chief Election Commissioner (CEC) and four other Election Commissioners.";
    }

    if (input.contains('complaint') || input.contains('help') || input.contains('emergency')) {
      return "For any election-related complaints or emergencies, contact the Election Commission hotline at 105 or reach out to the presiding officer at your polling center.";
    }

    // Default Fallback
    return "I am here to help with voting information. You can ask me about:\n- How to vote\n- Voting time\n- Center location\n- Documents needed\n- Candidate rules\n- Election Commission info";
  }

  bool _isPersonalOrCandidateQuestion(String input) {
    List<String> forbidden = ['who is good', 'who to vote', 'best candidate', 'bad candidate', 'my name', 'your name', 'love', 'hate', 'awami', 'bnp', 'jamaat', 'jatiya'];
    
    for (var word in forbidden) {
      if (input.contains(word)) return true;
    }
    return false;
  }
}
