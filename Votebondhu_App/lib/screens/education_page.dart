import 'package:flutter/material.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildArticleCard(
          context,
          'How to Vote?',
          'Step-by-step guide on the voting process.',
          Icons.how_to_vote,
        ),
        _buildArticleCard(
          context,
          'Know Your Rights',
          'Understanding your constitutional rights as a voter.',
          Icons.gavel,
        ),
        _buildArticleCard(
          context,
          'Election Rules 2026',
          'Latest updates on election commission rules.',
          Icons.rule,
        ),
        _buildArticleCard(
          context,
          'Why Voting Matters',
          'The impact of your vote on national development.',
          Icons.public,
        ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
