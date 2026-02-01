import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset('assets/images/genvote bd.png', height: 40),
               const SizedBox(width: 8),
               const Text(
                "A GenVote Festival hackathon project",
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/IFES_Logo-removebg-preview.png', height: 30),
              const SizedBox(width: 8),
              const Text(
                "Supported by IFES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
                 textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Developed by",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // If we had a logo, we'd use Image.asset here. 
              // Since we might not have a perfect transparent PNG yet, we use styled text + icon.
              Icon(Icons.code, size: 16, color: Colors.green[700]),
              const SizedBox(width: 5),
              Text(
                "Muktomoncho Innovators",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
