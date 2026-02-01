import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/poll_controller.dart';
import 'package:test_app/widgets/custom_card.dart';

class DailyPollWidget extends StatelessWidget {
  const DailyPollWidget({super.key});

  @override
  Widget build(BuildContext context) {
    PollController controller;
    try {
      controller = Get.find<PollController>();
    } catch (e) {
      controller = Get.put(PollController());
    }

    return Obx(() {
      try {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.currentPoll.value == null) {
          return const SizedBox.shrink();
        }

        var poll = controller.currentPoll.value!;
        List<String> options = List<String>.from(poll['options'] ?? []);
        List<int> results = List<int>.from(poll['results'] ?? []);
        int totalVotes = results.fold(0, (sum, item) => sum + item);

        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: CustomCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Pulse",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  if (controller.hasVoted.value)
                    const Chip(
                      label: Text("Voted", style: TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                poll['question'] ?? 'Poll Question',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...List.generate(options.length, (index) {
                double percentage = totalVotes == 0 ? 0 : (results[index] / totalVotes);
                bool isSelected = controller.selectedIndex.value == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: controller.hasVoted.value
                      ? _buildResultBar(options[index], percentage, isSelected)
                      : _buildVoteButton(options[index], () => controller.castVote(index)),
                );
              }),
              if (controller.hasVoted.value)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      "$totalVotes people have voted",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
          ),
        );
      } catch (e) {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildVoteButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.green, fontSize: 16)),
      ),
    );
  }

  Widget _buildResultBar(String label, double percentage, bool isSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 45,
              width: constraints.maxWidth * percentage,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.withOpacity(0.4) : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.green[900] : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    "${(percentage * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[900] : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
