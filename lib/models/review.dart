class Review {
  final int id;
  final int doctorId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? doctorName;
  bool canDelete ;
  final int productId;

  Review({
    required this.id,
    required this.doctorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.doctorName,
    this.canDelete = false, 
    required this.productId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
     String? doctorName;
  if (json['doctor'] != null && json['doctor']['all_user'] != null) {
    doctorName = json['doctor']['all_user']['fullname'];
  }
    return Review(
      id: json['id'],
      doctorId: json['doctor_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      doctorName:doctorName,
      productId: json['product_id']

      
    );
  }
}