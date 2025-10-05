class UserProfile {
  final String uid;
  final String fullName;
  final DateTime dateOfBirth;
  final String? bio;
  final String? photoUrl;
  final String email;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isComplete;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.dateOfBirth,
    this.bio,
    this.photoUrl,
    required this.email,
    required this.createdAt,
    required this.lastUpdated,
    required this.isComplete,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bio': bio,
      'photoUrl': photoUrl,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isComplete: map['isComplete'] ?? false,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? fullName,
    DateTime? dateOfBirth,
    String? bio,
    String? photoUrl,
    String? email,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isComplete,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
