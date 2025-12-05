import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/kolosal_ocr_service.dart';
import '../../data/services/product_service.dart';
import '../../data/services/product_matcher_service.dart';
import '../../data/models/ocr_models.dart';
import '../../data/models/product_model.dart';
import '../../data/models/restock_model.dart';

/// Smart Restock Controller
/// Controller untuk scan invoice dan restock otomatis
class SmartRestockController extends GetxController {
  final KolosalOcrService _ocrService = KolosalOcrService();
  final ProductService _productService = ProductService();
  final ProductMatcherService _matcherService = ProductMatcherService();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable states
  final isScanning = false.obs;
  final isProcessing = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  
  // OCR Results
  final Rx<OcrInvoiceResponse?> ocrResult = Rx<OcrInvoiceResponse?>(null);
  final RxList<OcrInvoiceItem> items = <OcrInvoiceItem>[].obs;
  
  // Products from database
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  
  // Form data
  final supplierNameController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  final Rx<DateTime> invoiceDate = DateTime.now().obs;
  
  // Sell price controllers (one for each item)
  final Map<int, TextEditingController> sellPriceControllers = {};

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  /// Load all products from database
  Future<void> loadProducts() async {
    try {
      allProducts.value = await _productService.getAllProducts();
    } catch (e) {
      errorMessage.value = 'Gagal memuat produk: $e';
      print('❌ Load products error: $e');
    }
  }

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    try {
      errorMessage.value = '';
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress sedikit untuk upload lebih cepat
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await processInvoiceImage(File(image.path));
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengambil foto: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      errorMessage.value = '';
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await processInvoiceImage(File(image.path));
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih gambar: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  /// Process invoice image dengan OCR
  Future<void> processInvoiceImage(File imageFile) async {
    isScanning.value = true;
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      // Step 1: Scan dengan Kolosal OCR
      Get.snackbar(
        '📸 Scanning',
        'Memproses invoice dengan AI...',
        duration: const Duration(seconds: 3),
      );

      final result = await _ocrService.scanInvoice(imageFile);
      ocrResult.value = result;

      // Step 2: Fill form dengan hasil OCR
      if (result.supplierName != null) {
        supplierNameController.text = result.supplierName!;
      }
      if (result.invoiceNumber != null) {
        invoiceNumberController.text = result.invoiceNumber!;
      }
      if (result.invoiceDate != null) {
        invoiceDate.value = result.invoiceDate!;
      }

      // Step 3: Match items dengan database (Smart Matching!)
      Get.snackbar(
        '🧠 Smart Matching',
        'Mencocokkan barang dengan database...',
        duration: const Duration(seconds: 2),
      );

      final matchedItems = await _matcherService.matchMultipleItems(
        result.items,
        allProducts,
      );

      items.value = matchedItems;

      // Step 4: Initialize sell price controllers
      _initializeSellPriceControllers();

      // Step 5: Show results
      isScanning.value = false;
      isProcessing.value = false;

      Get.snackbar(
        '✅ Success',
        'Invoice berhasil di-scan! ${items.length} item terdeteksi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Navigate to reconciliation screen
      Get.toNamed('/smart-restock/reconcile');

    } catch (e) {
      isScanning.value = false;
      isProcessing.value = false;
      errorMessage.value = 'Gagal memproses invoice: $e';
      
      Get.snackbar(
        '❌ Error',
        errorMessage.value,
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 4),
      );
      
      print('❌ Process invoice error: $e');
    }
  }

  /// Initialize sell price controllers untuk setiap item
  void _initializeSellPriceControllers() {
    sellPriceControllers.clear();
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      // Jika item matched dengan produk existing, use existing sell price
      if (item.matchedProductId != null) {
        final product = allProducts.firstWhereOrNull(
          (p) => p.id == item.matchedProductId,
        );
        if (product != null) {
          sellPriceControllers[i] = TextEditingController(
            text: product.sellPrice.toStringAsFixed(0),
          );
          continue;
        }
      }
      
      // Default: Markup 30% dari buy price
      final suggestedSellPrice = item.price * 1.3;
      sellPriceControllers[i] = TextEditingController(
        text: suggestedSellPrice.toStringAsFixed(0),
      );
    }
  }

  /// Update item manually (user edit)
  void updateItem(int index, {
    String? name,
    int? quantity,
    double? price,
    String? matchedProductId,
    String? matchedProductName,
  }) {
    if (index < 0 || index >= items.length) return;

    final item = items[index];
    items[index] = item.copyWith(
      name: name ?? item.name,
      quantity: quantity ?? item.quantity,
      price: price ?? item.price,
      total: (price ?? item.price) * (quantity ?? item.quantity),
      matchedProductId: matchedProductId ?? item.matchedProductId,
      matchedProductName: matchedProductName ?? item.matchedProductName,
      isManuallyEdited: true,
    );
  }

  /// Select product untuk item (dari dropdown)
  void selectProductForItem(int index, ProductModel product) {
    updateItem(
      index,
      matchedProductId: product.id,
      matchedProductName: product.name,
    );
    
    // Update sell price dengan harga jual produk yang dipilih
    sellPriceControllers[index]?.text = product.sellPrice.toStringAsFixed(0);
  }

  /// Remove item dari list
  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    
    items.removeAt(index);
    sellPriceControllers[index]?.dispose();
    sellPriceControllers.remove(index);
    
    // Re-index controllers
    _reindexSellPriceControllers();
  }

  void _reindexSellPriceControllers() {
    final temp = Map<int, TextEditingController>.from(sellPriceControllers);
    sellPriceControllers.clear();
    
    int newIndex = 0;
    for (int oldIndex in temp.keys.toList()..sort()) {
      if (newIndex < items.length) {
        sellPriceControllers[newIndex] = temp[oldIndex]!;
        newIndex++;
      } else {
        temp[oldIndex]?.dispose();
      }
    }
  }

  /// Save restock data (MAIN ACTION!)
  Future<void> saveRestock() async {
    if (items.isEmpty) {
      Get.snackbar('Error', 'Tidak ada item untuk disimpan');
      return;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      int successCount = 0;
      int newProductCount = 0;
      double totalSpending = 0;

      Get.snackbar(
        '💾 Menyimpan',
        'Memproses ${items.length} item...',
        duration: const Duration(seconds: 3),
      );

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final sellPriceText = sellPriceControllers[i]?.text ?? '0';
        final sellPrice = double.tryParse(sellPriceText) ?? item.price * 1.3;

        String productId;
        String productName;

        // Case 1: Item matched dengan existing product
        if (item.matchedProductId != null) {
          productId = item.matchedProductId!;
          productName = item.matchedProductName ?? item.name;

          // Update product: stock, buy price, sell price
          final existingProduct = allProducts.firstWhereOrNull(
            (p) => p.id == productId,
          );

          if (existingProduct != null) {
            final updatedProduct = existingProduct.copyWith(
              stock: existingProduct.stock + item.quantity,
              buyPrice: item.price, // Update buy price
              sellPrice: sellPrice,  // Update sell price
              updatedAt: DateTime.now(),
            );

            await _productService.updateProduct(updatedProduct);
          }
        } 
        // Case 2: Create new product
        else {
          productName = item.name;
          
          final newProduct = ProductModel(
            name: productName,
            buyPrice: item.price,
            sellPrice: sellPrice,
            stock: item.quantity,
            unit: 'pcs', // Default unit
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final created = await _productService.createProduct(newProduct);
          productId = created.id!;
          newProductCount++;
        }

        // Record restock transaction
        final restock = RestockModel(
          productId: productId,
          productName: productName,
          quantity: item.quantity,
          buyPrice: item.price,
          totalCost: item.total,
          supplierName: supplierNameController.text,
          invoiceNumber: invoiceNumberController.text,
          restockDate: invoiceDate.value,
          createdAt: DateTime.now(),
        );

        await _productService.recordRestock(restock);
        
        totalSpending += item.total;
        successCount++;
      }

      // Reload products
      await loadProducts();

      isSaving.value = false;

      // Success message
      Get.back(); // Close reconciliation screen
      
      Get.snackbar(
        '✅ Berhasil Disimpan!',
        '$successCount item berhasil diproses\n'
        '🆕 Produk baru: $newProductCount\n'
        '💰 Total pengeluaran: ${formatCurrency(totalSpending)}',
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );

      // Clear form
      _clearForm();

    } catch (e) {
      isSaving.value = false;
      errorMessage.value = 'Gagal menyimpan restock: $e';
      
      Get.snackbar(
        '❌ Error',
        errorMessage.value,
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 4),
      );
      
      print('❌ Save restock error: $e');
    }
  }

  /// Clear form setelah save
  void _clearForm() {
    items.clear();
    ocrResult.value = null;
    supplierNameController.clear();
    invoiceNumberController.clear();
    invoiceDate.value = DateTime.now();
    
    for (var controller in sellPriceControllers.values) {
      controller.dispose();
    }
    sellPriceControllers.clear();
  }

  /// Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Calculate suggested sell price (30% markup)
  double calculateSuggestedSellPrice(double buyPrice, {double markup = 0.3}) {
    return buyPrice * (1 + markup);
  }

  /// Get confidence color
  Color getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Get confidence text
  String getConfidenceText(double confidence) {
    if (confidence >= 80) return 'High Match';
    if (confidence >= 60) return 'Medium Match';
    return 'Low Match';
  }

  @override
  void onClose() {
    supplierNameController.dispose();
    invoiceNumberController.dispose();
    for (var controller in sellPriceControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
