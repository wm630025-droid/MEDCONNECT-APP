class Review {
  final int id;
  final int doctorId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? doctorName;
  bool canDelete ;
  final int productId;
  
  final String?  profileImageUrl;

  Review({
    required this.id,
    required this.doctorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.doctorName,
    this.canDelete = false, 
     this.profileImageUrl,
    required this.productId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    print('Review JSON: $json'); // Debugging line to print the JSON data
    String? profileImageUrl1;
    if (json['doctor'] != null ) {
      profileImageUrl1 = json['doctor']['profile_image_url'].toString();
    }
    // if(json['doctor'] != null && profileImageUrl!.startsWith('//')) {
    //   profileImageUrl = 'https:${profileImageUrl}';
    // }
     String? doctorName;
  if (json['doctor'] != null && json['doctor']['all_user'] != null) {
    doctorName = json['doctor']['all_user']['fullname'];
  }
  print('Review URL: $profileImageUrl1'); // Debugging line to print the profile image URL
    return Review(
      id: json['id'],
      doctorId: json['doctor_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      doctorName:doctorName,
      productId: json['product_id'],
      profileImageUrl: profileImageUrl1,


      
    );
  }
}