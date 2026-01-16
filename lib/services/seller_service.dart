import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/part.dart';
import '../models/seller.dart';
import 'api_client.dart';

class SellerService {
  SellerService(this._api);

  final ApiClient _api;

  Future<SellerDashboard> getDashboard(String token) async {
    final data = await _api.getMap('/api/seller/dashboard', token: token);
    return SellerDashboard.fromJson(data);
  }

  Future<List<PartListItem>> getMyParts(String token) async {
    final data = await _api.getList('/api/seller/parts', token: token);
    return data
        .whereType<Map<String, dynamic>>()
        .map(PartListItem.fromJson)
        .toList();
  }

  Future<List<SellerQuestion>> getQuestions(String token) async {
    final parts = await getMyParts(token);
    if (parts.isEmpty) return [];

    final details = await Future.wait(
      parts.map((part) async {
        final data = await _api.getMap('/api/parts/${part.id}');
        return PartDetail.fromJson(data);
      }),
    );

    final questions = <SellerQuestion>[];
    for (final detail in details) {
      final imageUrl =
          detail.imageUrl ?? (detail.images.isNotEmpty ? detail.images.first.url : null);
      for (final q in detail.questions) {
        questions.add(
          SellerQuestion(
            id: q.id,
            question: q.question,
            createdAt: q.createdAt,
            partId: detail.id,
            partName: detail.name,
            answer: q.answer,
            userName: q.userName,
            answeredAt: q.answeredAt,
            imageUrl: imageUrl,
          ),
        );
      }
    }

    questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return questions;
  }

  Future<List<SellerOrder>> getOrders(String token) async {
    final data = await _api.getList('/api/seller/orders', token: token);
    return data
        .whereType<Map<String, dynamic>>()
        .map(SellerOrder.fromJson)
        .toList();
  }

  Future<void> answerQuestion({
    required int questionId,
    required String answer,
    required String token,
  }) async {
    await _api.postMap(
      '/api/seller/questions/$questionId/answer',
      {'answer': answer},
      token: token,
    );
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
    required String token,
  }) async {
    await _api.postForm(
      '/api/seller/orders/$orderId/status',
      {'status': status},
      token: token,
    );
  }

  Future<void> createPart({
    required String token,
    required String name,
    required String brand,
    required String category,
    required double price,
    required int stock,
    String? description,
    List<int>? vehicleIds,
    File? image,
    List<File>? gallery,
  }) async {
    final fields = _buildPartFields(
      name: name,
      brand: brand,
      category: category,
      price: price,
      stock: stock,
      description: description,
      vehicleIds: vehicleIds,
    );
    final files = await _buildFiles(image: image, gallery: gallery);
    await _api.postMultipart(
      '/api/seller/parts',
      fields,
      files: files,
      token: token,
    );
  }

  Future<void> updatePart({
    required String token,
    required int partId,
    required String name,
    required String brand,
    required String category,
    required double price,
    required int stock,
    String? description,
    List<int>? vehicleIds,
    File? image,
    List<File>? gallery,
  }) async {
    final fields = _buildPartFields(
      name: name,
      brand: brand,
      category: category,
      price: price,
      stock: stock,
      description: description,
      vehicleIds: vehicleIds,
    );
    final files = await _buildFiles(image: image, gallery: gallery);
    await _api.putMultipart(
      '/api/seller/parts/$partId',
      fields,
      files: files,
      token: token,
    );
  }

  Map<String, dynamic> _buildPartFields({
    required String name,
    required String brand,
    required String category,
    required double price,
    required int stock,
    String? description,
    List<int>? vehicleIds,
  }) {
    final fields = <String, dynamic>{
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'stock': stock,
      if (description != null) 'description': description,
    };

    if (vehicleIds != null && vehicleIds.isNotEmpty) {
      for (var i = 0; i < vehicleIds.length; i++) {
        fields['vehicleIds[$i]'] = vehicleIds[i];
      }
    }

    return fields;
  }

  Future<List<http.MultipartFile>> _buildFiles({
    File? image,
    List<File>? gallery,
  }) async {
    final files = <http.MultipartFile>[];

    if (image != null) {
      files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    if (gallery != null) {
      for (final item in gallery) {
        files.add(await http.MultipartFile.fromPath('gallery', item.path));
      }
    }

    return files;
  }
}
