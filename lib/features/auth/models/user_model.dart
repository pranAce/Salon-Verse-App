
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? number;
  final String role;
  final List<String> favoriteSalons;
  final List<String> assignedSalons;
  final List<String> permissions;
  final String status;
  final String? createdAt;
  final String? homeLocationAddress;
  final String? homeLocationCity;
  final double? homeLocationLat;
  final double? homeLocationLng;

  final String? dateOfBirth;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.number,
    this.role = 'user',
    this.favoriteSalons = const [],
    this.assignedSalons = const [],
    this.permissions = const [],
    this.status = 'active',
    this.createdAt,
    this.dateOfBirth,
    this.homeLocationAddress,
    this.homeLocationCity,
    this.homeLocationLat,
    this.homeLocationLng,
  });

  bool get isCustomer => true;
  bool get isSalonStaff => false;
  bool get isSalonAdmin => false;
  bool get isSuperAdmin => false;
  bool get isSalonRole => false;

  String? get salonId => null;

  bool hasPermission(String permission) {
    return permissions.contains('*') || permissions.contains(permission);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? number,
    String? role,
    List<String>? favoriteSalons,
    List<String>? assignedSalons,
    List<String>? permissions,
    String? status,
    String? createdAt,
    String? dateOfBirth,
    String? homeLocationAddress,
    String? homeLocationCity,
    double? homeLocationLat,
    double? homeLocationLng,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      number: number ?? this.number,
      role: role ?? this.role,
      favoriteSalons: favoriteSalons ?? this.favoriteSalons,
      assignedSalons: assignedSalons ?? this.assignedSalons,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      homeLocationAddress: homeLocationAddress ?? this.homeLocationAddress,
      homeLocationCity: homeLocationCity ?? this.homeLocationCity,
      homeLocationLat: homeLocationLat ?? this.homeLocationLat,
      homeLocationLng: homeLocationLng ?? this.homeLocationLng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'number': number,
      'role': role,
      'favoriteSalons': favoriteSalons,
      'assignedSalons': assignedSalons,
      'permissions': permissions,
      'status': status,
      'createdAt': createdAt,
      'dateOfBirth': dateOfBirth,
      'homeLocationAddress': homeLocationAddress,
      'homeLocationCity': homeLocationCity,
      'homeLocationLat': homeLocationLat,
      'homeLocationLng': homeLocationLng,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final hl = json['homeLocation'];

    List<String> parseList(dynamic input) {
      if (input is! List) return [];
      return input
          .map((item) {
            if (item is Map) {
              return (item['_id'] ?? item['id'] ?? '').toString();
            }
            return item.toString();
          })
          .where((str) => str.isNotEmpty)
          .toList();
    }

    String? parseDob(dynamic val) {
      if (val == null) return null;
      final str = val.toString();
      if (str.contains('T')) return str.split('T')[0];
      return str;
    }

    final userId = (json['id'] ?? json['_id'] ?? json['uid'])?.toString() ?? '';
    final model = UserModel(
      id: userId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      number: (json['phone'] ?? json['number'])?.toString(),
      role: json['role'] ?? 'user',
      favoriteSalons: parseList(json['favoriteSalons']),
      assignedSalons: parseList(json['assignedSalons']),
      permissions: parseList(json['permissions']),
      status: json['status'] ?? 'active',
      createdAt: json['createdAt']?.toString(),
      dateOfBirth: parseDob(json['dateOfBirth'] ?? json['dob']),
      homeLocationAddress: hl is Map
          ? hl['address']?.toString()
          : json['homeLocationAddress']?.toString(),
      homeLocationCity: hl is Map
          ? hl['city']?.toString()
          : json['homeLocationCity']?.toString(),
      homeLocationLat: hl is Map
          ? (hl['latitude'] as num?)?.toDouble()
          : (json['homeLocationLat'] as num?)?.toDouble(),
      homeLocationLng: hl is Map
          ? (hl['longitude'] as num?)?.toDouble()
          : (json['homeLocationLng'] as num?)?.toDouble(),
    );
    return model;
  }
}

