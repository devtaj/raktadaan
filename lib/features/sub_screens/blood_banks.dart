import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:raktadan/blood_banks_data.dart';
import 'package:raktadan/core/models/bloodBanks_model.dart';

List<BloodBank> getBloodBanks() {
  final List<BloodBank> list = [];
  bloodBankRawData.forEach((province, banks) {
    for (var bank in banks) {
      list.add(BloodBank.fromMap(province, bank));
    }
  });
  return list;
}

class BloodBanksScreen extends StatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  State<BloodBanksScreen> createState() => _BloodBanksScreenState();
}

class _BloodBanksScreenState extends State<BloodBanksScreen> {
  late List<BloodBank> allBanks;
  late Map<String, List<BloodBank>> provinceMap;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    allBanks = getBloodBanks();
    _buildProvinceMap(allBanks);
  }

  void _buildProvinceMap(List<BloodBank> banks) {
    provinceMap = {};
    for (var bank in banks) {
      provinceMap.putIfAbsent(bank.province, () => []);
      provinceMap[bank.province]!.add(bank);
    }
  }

  void _onSearchChanged(String query) {
    final filtered = allBanks.where((bank) {
      final lowerQuery = query.toLowerCase();
      return bank.province.toLowerCase().contains(lowerQuery) ||
          bank.district.toLowerCase().contains(lowerQuery) ||
          bank.name.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      searchQuery = query;
      _buildProvinceMap(filtered);
    });
  }

  void _copyPhoneNumber(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $phone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Banks of Nepal'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // Search bar below the AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by province, district, or name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // List of blood banks fills the remaining space
          Expanded(
            child: provinceMap.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView(
                    children: provinceMap.entries.map((entry) {
                      final province = entry.key;
                      final banks = entry.value;

                      return ExpansionTile(
                        key: PageStorageKey(province),
                        title: Text(
                          province,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        children: banks.map((bank) {
                          return ListTile(
                            title: Text(bank.name),
                            subtitle: Text('District: ${bank.district}'),
                            trailing: GestureDetector(
                              onTap: () => _copyPhoneNumber(bank.phone),
                              child: Text(
                                bank.phone,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
