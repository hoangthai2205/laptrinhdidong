class UserProfile {
  String id;
  String name;
  String phone;
  String address;
  String email;
  String avatar;

  UserProfile({
    required this.id, 
    required this.name, 
    required this.phone, 
    required this.address, 
    required this.email
    , this.avatar = ''
  });

  // Gửi lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'avatar': avatar,
    };
  }

  // Lấy từ Firebase về
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
    );
  }
}