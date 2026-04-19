class CustomRequestModel {
  final String type;
  final List<String> products;
  final String description;
  final String budget;
  final DateTime createdOn;
  final DateTime expiresOn;

  CustomRequestModel({
    required this.type,
    required this.products,
    required this.description,
    required this.budget,
    required this.createdOn,
    required this.expiresOn,
  });
}
