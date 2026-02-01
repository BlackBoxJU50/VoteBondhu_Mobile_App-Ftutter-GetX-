import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';
import 'package:test_app/utils/bangladesh_data.dart';
import 'package:test_app/widgets/custom_card.dart';

class RedemptionPage extends StatelessWidget {
  const RedemptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GamesController controller = Get.find<GamesController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem Tickets')),
      body: Column(
        children: [
          // Header showing points
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                Obx(() => Text(
                  'Your Balance: ${controller.userPoints.value} Points',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: BangladeshData.historicalPlaces.length,
              itemBuilder: (context, index) {
                var place = BangladeshData.historicalPlaces[index];
                return CustomCard(
                  child: Column(
                    children: [
                      Image.network(
                        place['image'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey),
                      ),
                      ListTile(
                        title: Text(place['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(place['location']),
                        trailing: Text('${place['cost']} Pts', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(place['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            backgroundColor: controller.userPoints.value >= (place['cost'] as int) ? Colors.green : Colors.grey,
                          ),
                          onPressed: controller.isLoading.value 
                            ? null 
                            : () => controller.redeemTicket(place['name'], place['cost'] as int),
                          child: controller.isLoading.value 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Redeem Ticket'),
                        )),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
