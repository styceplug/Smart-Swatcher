import 'event_model.dart';

class DisplayMediaModel {
  final String id;
  final String ownerId;
  final String ownerType;
  final String url;
  final String? title;
  final String visibility;
  final DateTime? createdAt;

  const DisplayMediaModel({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.url,
    this.title,
    this.visibility = 'General',
    this.createdAt,
  });

  factory DisplayMediaModel.fromJson(Map<String, dynamic> json) {
    return DisplayMediaModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      ownerType: json['ownerType']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      title: json['title']?.toString(),
      visibility: json['visibility']?.toString() ?? 'General',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class TipModel {
  final String id;
  final String ownerId;
  final String ownerType;
  final String title;
  final String description;
  final String visibility;
  final int saves;
  final bool isSaved;
  final DateTime? createdAt;

  const TipModel({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.title,
    required this.description,
    this.visibility = 'General',
    this.saves = 0,
    this.isSaved = false,
    this.createdAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    final viewer = json['viewer'];
    return TipModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      ownerType: json['ownerType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      visibility: json['visibility']?.toString() ?? 'General',
      saves: int.tryParse(json['saves']?.toString() ?? '0') ?? 0,
      isSaved: viewer is Map ? viewer['saved'] == true : false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  TipModel copyWith({
    int? saves,
    bool? isSaved,
  }) {
    return TipModel(
      id: id,
      ownerId: ownerId,
      ownerType: ownerType,
      title: title,
      description: description,
      visibility: visibility,
      saves: saves ?? this.saves,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
    );
  }
}

class ProductModel {
  final String id;
  final String companyId;
  final String productName;
  final String? productImageUrl;
  final String? description;
  final String visibility;
  final List<String> otherImages;
  final double? price;
  final double? oldPrice;
  final int sortOrder;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.companyId,
    required this.productName,
    this.productImageUrl,
    this.description,
    this.visibility = 'General',
    this.otherImages = const [],
    this.price,
    this.oldPrice,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productImageUrl: json['productImageUrl']?.toString(),
      description: json['description']?.toString(),
      visibility: json['visibility']?.toString() ?? 'General',
      otherImages: json['otherImages'] is List
          ? List<String>.from(json['otherImages'])
          : const [],
      price: double.tryParse(json['price']?.toString() ?? ''),
      oldPrice: double.tryParse(json['oldPrice']?.toString() ?? ''),
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class ProfileContentBundle {
  final List<DisplayMediaModel> media;
  final List<TipModel> tips;
  final List<ProductModel> products;
  final List<EventModel> events;

  const ProfileContentBundle({
    this.media = const [],
    this.tips = const [],
    this.products = const [],
    this.events = const [],
  });
}
