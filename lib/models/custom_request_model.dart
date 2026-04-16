class CustomRequest {
  final int id;
  final int doctorId;
  final String type;
  final List<String> item;
  final String expiresAt;
  final String? rentStartDate;
  final String? rentEndDate;
  final String status;
  final String? additionalDetails;
  final String? budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomRequest({
    required this.id,
    required this.doctorId,
    required this.type,
    required this.item,
    required this.expiresAt,
    this.rentStartDate,
    this.rentEndDate,
    required this.status,
    this.additionalDetails,
    this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ لتحويل JSON اللي جاي من API إلى كائن
  factory CustomRequest.fromJson(Map<String, dynamic> json) {
    return CustomRequest(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      type: json['type'] ?? '',
      item: List<String>.from(json['item'] ?? []),
      expiresAt: json['expires_at'] ?? '',
      rentStartDate: json['rent_start_date'],
      rentEndDate: json['rent_end_date'],
      status: json['status'] ?? "open",
      additionalDetails: json['additionalDetails'],
      budget: json['budget'],
      createdAt: json['created_at'] != null
      ? DateTime.parse(json['created_at'])
      : DateTime.now() ,
      updatedAt: json['updated_at'] != null
      ? DateTime.parse(json['updated_at'])
      :DateTime.now()    ,
    );
  }

  // ✅ لتحويل الكائن إلى JSON (لو محتاجة تبعتيه لـ API تاني)
  Map<String, dynamic> toJson() {
    String _formatDate(dynamic date) {
    if (date == null) return '';
    
    // لو كان DateTime
    if (date is DateTime) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
    }
    
    // لو كان String
    if (date is String) {
      return date;
    }
    
    return '';
  }

    return {
      'type': type,
      'item': item,
      'expires_at': expiresAt,
     // 'created_at' : DateTime.now(),
      if (rentStartDate != null) 'rent_start_date': _formatDate(rentStartDate),
      if (rentEndDate != null) 'rent_end_date': _formatDate(rentEndDate) ,
      'additionalDetails' : additionalDetails,
      'budget' : budget,
 
    };
  }
}