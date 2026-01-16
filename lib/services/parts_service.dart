import '../models/filters.dart';
import '../models/part.dart';
import 'api_client.dart';

class PartsService {
  PartsService(this._api);

  final ApiClient _api;

  Future<List<PartListItem>> getParts({
    String? query,
    List<String>? categories,
    String? category,
    List<String>? partBrands,
    String? partBrand,
    int? vehicleId,
    String? brand,
    List<String>? brands,
    String? model,
    List<String>? models,
    int? year,
    List<int>? years,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final params = <String, dynamic>{
      'q': query,
      'category': category,
      'categoryList': categories,
      'partBrand': partBrand,
      'partBrandList': partBrands,
      'vehicleId': vehicleId,
      'brand': brand,
      'brandList': brands,
      'model': model,
      'modelList': models,
      'year': year,
      'yearList': years,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'sort': sort,
    };

    final data = await _api.getList('/api/parts', query: params);
    return data
        .whereType<Map<String, dynamic>>()
        .map(PartListItem.fromJson)
        .toList();
  }

  Future<PartDetail> getPart(int id) async {
    final data = await _api.getMap('/api/parts/$id');
    return PartDetail.fromJson(data);
  }

  Future<PartsFilterMeta> getFilters() async {
    final data = await _api.getMap('/api/parts/filters');
    return PartsFilterMeta.fromJson(data);
  }

  Future<void> askQuestion(int partId, String question, {required String token}) async {
    await _api.postMap(
      '/api/parts/$partId/questions',
      {'question': question},
      token: token,
    );
  }

  Future<void> addReview(
    int partId, {
    required int rating,
    String? comment,
    required String token,
  }) async {
    await _api.postMap(
      '/api/parts/$partId/reviews',
      {
        'rating': rating,
        'comment': comment,
      },
      token: token,
    );
  }
}
