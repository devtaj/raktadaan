import 'package:raktadan/blood_banks_data.dart';

List<BloodBank> getBloodBanks() {
  final List<BloodBank> list = [];
  bloodBankRawData.forEach((province, banks) {
    for (var bank in banks) {
      list.add(BloodBank.fromMap(province, bank));
    }
  });
  return list;

}
List<BloodBank> getBloodBanksByProvince(String province) {
  final List<BloodBank> list = [];
  if (bloodBankRawData.containsKey(province)) {
    for (var bank in bloodBankRawData[province]!) {
      list.add(BloodBank.fromMap(province, bank));
    }
  }
  return list;
}

class BloodBank {
  final String province;
  final String district;
  final String name;
  final String phone;

  BloodBank({
    required this.province,
    required this.district,
    required this.name,
    required this.phone,
  });

  factory BloodBank.fromMap(String province, Map<String, String> map) {
    return BloodBank(
      province: province,
      district: map['district'] ?? 'Unknown',
      name: map['name'] ?? 'Unknown',
      phone: map['phone'] ?? 'Unknown',
    );
  }
}
