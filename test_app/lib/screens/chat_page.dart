import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/controllers/bondhu_controller.dart';
import 'package:test_app/controllers/auth_controller.dart';

class ChatPage extends StatelessWidget {
  final String otherUid;
  final String otherName;

  ChatPage({super.key, required this.otherUid, required this.otherName});

  final BondhuController bondhuController = Get.find();
  final AuthController authController = Get.find();
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String myUid = authController.box.read('id') ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(otherName),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bondhuController.getMessages(otherUid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;
                
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == myUid;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(data['text'] ?? '', style: const TextStyle(fontSize: 16)),
                            // const SizedBox(height: 4),
                            // Text(
                            //   data['timestamp'] != null 
                            //     ? DateFormat('h:mm a').format((data['timestamp'] as Timestamp).toDate())
                            //     : 'Just now',
                            //   style: TextStyle(fontSize: 10, color: Colors.grey[600])
                            // )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {
                    if (_msgCtrl.text.isNotEmpty) {
                      bondhuController.sendMessage(otherUid, _msgCtrl.text);
                      _msgCtrl.clear();
                    }
                  },
                )
              ],
            ),
          ),
          // Spacer for keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20),
        ],
      ),
    );
  }
}
