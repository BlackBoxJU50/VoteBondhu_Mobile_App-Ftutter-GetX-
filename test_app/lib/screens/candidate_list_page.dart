import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateListPage extends StatefulWidget {
  const CandidateListPage({super.key});

  @override
  State<CandidateListPage> createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> {
  String? selectedAshon;
  String searchQuery = '';
  List<String> ashonList = [];
  bool isLoadingAshons = true;

  @override
  void initState() {
    super.initState();
    _fetchAshons();
  }

  Future<void> _fetchAshons() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('ashons').get();
      
      if (snapshot.docs.isEmpty) {
        var candidateSnapshot = await FirebaseFirestore.instance.collection('candidates').get();
        if (candidateSnapshot.docs.isNotEmpty) {
          final Set<String> uniqueAshons = candidateSnapshot.docs
              .map((doc) => (doc.data())['ashon']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toSet();
          
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var ashon in uniqueAshons) {
            batch.set(FirebaseFirestore.instance.collection('ashons').doc(ashon), {'name': ashon});
          }
          await batch.commit();
          snapshot = await FirebaseFirestore.instance.collection('ashons').get();
        }
      }

      setState(() {
        ashonList = snapshot.docs.map((doc) => doc.id).toList()..sort();
        isLoadingAshons = false;
      });
    } catch (e) {
      setState(() => isLoadingAshons = false);
    }
  }

  void _showCandidateDetails(Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(candidate['name'] ?? 'Candidate Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.party_mode, 'Party', candidate['party']),
            _detailRow(Icons.location_on, 'Ashon', candidate['ashon']),
            _detailRow(Icons.map, 'Division', candidate['division'] ?? 'N/A'),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Candidate details from official database.', 
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Candidates')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (isLoadingAshons || textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return ashonList.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      selectedAshon = selection;
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Filter by Ashon (Seat)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                             controller.clear();
                             setState(() {
                               selectedAshon = null;
                             });
                          },
                        )
                      ),
                    );
                  },
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Candidate Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('candidates').snapshots(),
              builder: (context, snapshot) {
                List<Map<String, String>> candidatesToShow = [];
                
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  candidatesToShow = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'name': (data['name'] ?? '').toString(),
                      'party': (data['party'] ?? '').toString(),
                      'ashon': (data['ashon'] ?? '').toString(),
                      'division': (data['division'] ?? '').toString(),
                    };
                  }).toList();
                } else {
                  return const Center(child: Text('No candidates found in database. Please Seed Data.'));
                }

                var filteredCandidates = candidatesToShow.where((c) {
                  String cAshon = (c['ashon'] ?? '').toString().trim().toLowerCase();
                  String? sAshon = selectedAshon?.trim().toLowerCase();
                  
                  bool matchesAshon = sAshon == null || cAshon == sAshon;
                  bool matchesSearch = searchQuery.isEmpty || c['name']!.toLowerCase().contains(searchQuery);
                  
                  if (selectedAshon != null && matchesAshon) {
                     // print('DEBUG: Match found for $selectedAshon: ${c['name']}');
                  }
                  
                  return matchesAshon && matchesSearch;
                }).toList();

                if (selectedAshon != null) {
                  print('DEBUG: Filtering by $selectedAshon. Found ${filteredCandidates.length} matches out of ${candidatesToShow.length}');
                }

                if (filteredCandidates.isEmpty) {
                  return const Center(child: Text('No candidates found for this seat.'));
                }

                return ListView.builder(
                  itemCount: filteredCandidates.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    var candidate = filteredCandidates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(candidate['name']!.isNotEmpty ? candidate['name']![0] : '?'),
                        ),
                        title: Text(candidate['name']!),
                        subtitle: Text('${candidate['party']} • ${candidate['ashon']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _showCandidateDetails(candidate),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
