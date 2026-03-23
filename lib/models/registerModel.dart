class DoctorModel {
  final String fullName;
  final String email;
  final String address;
  final String governorate;
  final String nationalId;
  final String phone;
  final String licenseNumber;
  final String profileImage;

  DoctorModel({
    required this.fullName,
    required this.email,
    required this.address,
    required this.governorate,
    required this.nationalId,
    required this.phone,
    required this.licenseNumber,
    required this.profileImage,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      fullName: json['full_name'] ?? "",
      email: json['email'] ?? "",
      address: json['address'] ?? "",
      governorate: json['governorate'] ?? "",
      nationalId: json['national_id'] ?? "",
      phone: json['phone'] ?? "",
      licenseNumber: json['license_number'] ?? "",
      profileImage: json['profile_image_url'] ?? "",
    );
  }
}