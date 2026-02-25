import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/bondhu_controller.dart';
import 'package:test_app/screens/chat_page.dart';
import 'package:test_app/utils/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_app/utils/image_utils.dart';

class BondhuListPage extends StatelessWidget {
  const BondhuListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BondhuController controller = Get.put(BondhuController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VoteBondhu Community'),
          backgroundColor: Colors.green,
          bottom: TabBar(
            tabs: [
              const Tab(text: 'My Bondhus'),
              Obx(() => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Requests'),
                    if (controller.incomingRequests.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('${controller.incomingRequests.length}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                      )
                  ],
                ),
              )),
              const Tab(text: 'Find Bondhu'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Bondhus Tab (Friend List)
            Obx(() {
               if (controller.myBondhus.isEmpty) {
                 return const Center(child: Text('No VoteBondhus added yet.'));
               }
               return ListView.builder(
                 itemCount: controller.myBondhus.length,
                 itemBuilder: (context, index) {
                   var user = controller.myBondhus[index];
                   return Card(
                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: ImageUtils.getProfileImage(user['profileImageUrl']),
                          child: user['profileImageUrl'] == null ? const Icon(Icons.person) : null,
                        ),
                       title: Text(user['username'] ?? 'User'),
                       subtitle: Text(user['area'] ?? 'No Area'),
                       trailing: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           IconButton(
                             icon: const Icon(Icons.chat, color: Colors.blue),
                             onPressed: () => Get.to(() => ChatPage(otherUid: user['uid'], otherName: user['username'] ?? 'User')),
                           ),
                           IconButton(
                             icon: const Icon(Icons.call, color: Colors.green),
                             onPressed: () async {
                               final Uri launchUri = Uri(scheme: 'tel', path: '123456');
                               if (!await launchUrl(launchUri)) {
                                 CustomToast.showError('Could not launch dialer');
                                }
                             },
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               );
            }),

            // Requests Tab
            Obx(() {
              if (controller.incomingRequests.isEmpty) {
                return const Center(child: Text('No pending requests.'));
              }
              return ListView.builder(
                itemCount: controller.incomingRequests.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  var user = controller.incomingRequests[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: ImageUtils.getProfileImage(user['profileImageUrl']),
                        child: user['profileImageUrl'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user['username'] ?? 'User'),
                      subtitle: const Text('wants to be your VoteBondhu'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => controller.acceptFriendRequest(user['uid']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => controller.declineFriendRequest(user['uid']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            // Find Bondhu Search Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by Name or Email...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (val) => controller.searchUsers(val),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: controller.syncContacts,
                        icon: const Icon(Icons.contacts),
                        label: const Text('Sync Contacts to Find Friends'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45)
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                    
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                         if (controller.suggestions.isNotEmpty) ...[
                           const Text('People you might know', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           const SizedBox(height: 10),
                           SizedBox(
                             height: 150,
                             child: ListView.builder(
                               scrollDirection: Axis.horizontal,
                               itemCount: controller.suggestions.length,
                               itemBuilder: (context, index) {
                                 var user = controller.suggestions[index];
                                 bool isPending = controller.outgoingRequestUids.contains(user['uid']);
                                 return Container(
                                   width: 120,
                                   margin: const EdgeInsets.only(right: 10),
                                   child: Card(
                                     child: Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           CircleAvatar(
                                             radius: 25,
                                             backgroundImage: ImageUtils.getProfileImage(user['profileImageUrl']),
                                             child: user['profileImageUrl'] == null ? const Icon(Icons.person) : null,
                                           ),
                                           const SizedBox(height: 5),
                                           Text(user['username'] ?? 'User', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                           const Spacer(),
                                           ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                               minimumSize: const Size(double.infinity, 30), 
                                               padding: EdgeInsets.zero,
                                               backgroundColor: isPending ? Colors.grey : Colors.green,
                                               foregroundColor: Colors.white,
                                             ),
                                             onPressed: isPending ? null : () => controller.sendFriendRequest(user['uid'], user['username'] ?? 'User'),
                                             child: Text(isPending ? 'Pending' : 'Add', style: const TextStyle(fontSize: 11)),
                                           )
                                         ],
                                       ),
                                     ),
                                   ),
                                 );
                               },
                             ),
                           ),
                           const Divider(height: 30),
                         ],

                         const Text('Search Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         if (controller.searchResults.isEmpty) 
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(child: Text('Search above to find more friends')),
                            ),
                             
                         ...controller.searchResults.map((user) {
                           bool isFriend = controller.myBondhus.any((b) => b['uid'] == user['uid']);
                           bool isPending = controller.outgoingRequestUids.contains(user['uid']);
                           
                           return ListTile(
                               leading: CircleAvatar(
                                 backgroundImage: ImageUtils.getProfileImage(user['profileImageUrl']),
                                 child: user['profileImageUrl'] == null ? const Icon(Icons.person_add) : null,
                               ),
                               title: Text(user['username'] ?? 'User'),
                               subtitle: Text(user['area'] ?? 'No Area'),
                               trailing: isFriend 
                                 ? const Text('VoteBondhu', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                 : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isPending ? Colors.grey : Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: isPending ? null : () => controller.sendFriendRequest(user['uid'], user['username'] ?? 'User'),
                                    child: Text(isPending ? 'Requested' : 'Add Bondhu'),
                                  ),
                             );
                         }),
                      ],
                    );
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
