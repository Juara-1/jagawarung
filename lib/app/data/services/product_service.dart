import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/restock_model.dart';

/// Product Service
/// Service untuk manage products dan restocking
class ProductService {
  final _supabase = Supabase.instance.client;
  static const String _productsTable = 'products';
  static const String _restocksTable = 'restocks';

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ============================================
  // PRODUCT OPERATIONS
  // ============================================

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select()
          .eq('merchant_id', _currentUserId!)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select()
          .eq('merchant_id', _currentUserId!)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from(_productsTable)
          .select()
          .eq('id', id)
          .eq('merchant_id', _currentUserId!)
          .maybeSingle();

      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Create new product
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final data = product.toJson();
      data['merchant_id'] = _currentUserId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_productsTable)
          .insert(data)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final data = product.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_productsTable)
          .update(data)
          .eq('id', product.id!)
          .eq('merchant_id', _currentUserId!)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase
          .from(_productsTable)
          .delete()
          .eq('id', id)
          .eq('merchant_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Update stock quantity
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _supabase
          .from(_productsTable)
          .update({
            'stock': newStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId)
          .eq('merchant_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  /// Increase stock (for restocking)
  Future<void> increaseStock(String productId, int quantity) async {
    try {
      // Get current stock
      final product = await getProductById(productId);
      if (product == null) throw Exception('Product not found');

      // Update with new stock
      final newStock = product.stock + quantity;
      await updateStock(productId, newStock);
    } catch (e) {
      throw Exception('Failed to increase stock: $e');
    }
  }

  /// Decrease stock (for sales)
  Future<void> decreaseStock(String productId, int quantity) async {
    try {
      // Get current stock
      final product = await getProductById(productId);
      if (product == null) throw Exception('Product not found');

      if (product.stock < quantity) {
        throw Exception('Stock tidak cukup');
      }

      // Update with new stock
      final newStock = product.stock - quantity;
      await updateStock(productId, newStock);
    } catch (e) {
      throw Exception('Failed to decrease stock: $e');
    }
  }

  // ============================================
  // RESTOCK OPERATIONS
  // ============================================

  /// Record restock transaction
  Future<RestockModel> recordRestock(RestockModel restock) async {
    try {
      final data = restock.toJson();
      data['merchant_id'] = _currentUserId;

      final response = await _supabase
          .from(_restocksTable)
          .insert(data)
          .select()
          .single();

      return RestockModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to record restock: $e');
    }
  }

  /// Get restock history
  Future<List<RestockModel>> getRestockHistory({int limit = 50}) async {
    try {
      final response = await _supabase
          .from(_restocksTable)
          .select()
          .eq('merchant_id', _currentUserId!)
          .order('restock_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RestockModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get restock history: $e');
    }
  }

  /// Get restock history by product
  Future<List<RestockModel>> getRestocksByProduct(String productId) async {
    try {
      final response = await _supabase
          .from(_restocksTable)
          .select()
          .eq('merchant_id', _currentUserId!)
          .eq('product_id', productId)
          .order('restock_date', ascending: false);

      return (response as List)
          .map((json) => RestockModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get product restock history: $e');
    }
  }

  /// Calculate total spending (total modal keluar)
  Future<double> getTotalSpending({DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _supabase
          .from(_restocksTable)
          .select('total_cost')
          .eq('merchant_id', _currentUserId!);

      if (startDate != null) {
        query = query.gte('restock_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('restock_date', endDate.toIso8601String());
      }

      final response = await query;
      
      double total = 0;
      for (var item in response as List) {
        total += (item['total_cost'] as num).toDouble();
      }
      
      return total;
    } catch (e) {
      throw Exception('Failed to calculate total spending: $e');
    }
  }
}
