import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/admin_controller.dart';

class AdminPage extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Obx(() {
        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            var user = controller.users[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${user['id']}')),
              title: Text('User: ${user['username']}'),
              subtitle: Text('Pass: ${user['password']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => controller.deleteUser(user['id']),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.fetchUsers,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
