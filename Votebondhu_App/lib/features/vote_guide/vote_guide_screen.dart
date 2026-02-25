import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/features/vote_guide/vote_guide_controller.dart';
import 'package:test_app/widgets/ballot_simulation_widget.dart';
import 'package:test_app/widgets/custom_card.dart';

import 'package:test_app/widgets/animated_title.dart';

class VoteGuideStepPage extends StatefulWidget {
  const VoteGuideStepPage({super.key});

  @override
  State<VoteGuideStepPage> createState() => _VoteGuideStepPageState();
}

class _VoteGuideStepPageState extends State<VoteGuideStepPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final VoteGuideController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const AnimatedTitle(text: "Voter Journey"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  onStepContinue: () {
                    if (_currentStep < controller.steps.length) {
                      setState(() => _currentStep++);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  steps: [
                    ...controller.steps.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var step = entry.value;
                      return Step(
                        title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.description),
                            const SizedBox(height: 15),
                            // Inject Interactive elements based on step
                            if (idx == 0) _buildRegistrationHelper(),
                          if (step.title.contains("সিল দিন")) // Show only on the "Mark Seal" step
                            const BallotSimulationWidget(),
                            if (idx == controller.steps.length - 1) _buildCompletionBadge(),
                          ],
                        ),
                        isActive: _currentStep >= idx,
                        state: _currentStep > idx ? StepState.complete : StepState.indexed,
                      );
                    }),
                    Step(
                      title: const Text("Complete Journey"),
                      content: _buildCompletionBadge(),
                      isActive: _currentStep == controller.steps.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRegistrationHelper() {
    return CustomCard(
      color: Colors.blue[50],
      child: Column(
        children: [
          const Text("Quick Check: Are you registered?", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.search), 
            label: const Text("Verify NID Status"),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge() {
    return CustomCard(
      color: Colors.green[50],
      child: const Column(
        children: [
          Icon(Icons.verified, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text(
            "Ready to Vote!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text("You've completed the interactive guide. Share this with your friends to educate them too!", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
