import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/chatbot_controller.dart';

class AiChatbotWidget extends StatelessWidget {
   AiChatbotWidget({super.key});

  final ChatbotController controller = Get.put(ChatbotController());

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Obx(() {
        if (!controller.isExpanded.value) {
          // Collapsed Floating Button
          return Draggable(
            feedback: _buildFloatingButton(),
            childWhenDragging: Container(),
            child: _buildFloatingButton(),
            onDragEnd: (details) {
              // Logic to update position could go here if we made it fully draggable across screen
              // For now, simpler implementation: fixed position, expandable.
            },
          );
        } else {
          // Expanded Chat Window
          return Container(
            width: 300,
            height: 450,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'VoteBondhu AI',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: controller.toggleChat,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                // Messages List
                Expanded(
                  child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(12),
                    reverse: false, // Normal chat order, scroll to bottom needs handling or use reverse:true and reverse list
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: msg.isUser ? Colors.green[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            msg.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  )),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textController,
                          decoration: const InputDecoration(
                            hintText: 'Ask about voting...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (_) => controller.sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.green),
                        onPressed: controller.sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: controller.toggleChat,
      backgroundColor: Colors.green,
      child: const Icon(Icons.forum, color: Colors.white),
    );
  }
}
