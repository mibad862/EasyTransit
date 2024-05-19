class SearchUsers {
  final String id;
  final String adminName;
  final String image;

 SearchUsers({
    required this.id,
    required this.adminName,
    required this.image,
  });

  factory SearchUsers.fromJson(Map<String, dynamic> json) {
    return SearchUsers(
      id: json['id'],
      adminName: json['admin_name'],
      image: json['image'],
    );
  }
}
