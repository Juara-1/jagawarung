import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/expense_ocr_service.dart';
import '../../data/providers/real_transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class SmartRestockController extends GetxController {
  final ExpenseOcrService _ocrService = ExpenseOcrService();
  final RealTransactionProvider _txProvider = RealTransactionProvider();
  final ImagePicker _imagePicker = ImagePicker();

  final isScanning = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final totalAmount = 0.0.obs;
  final storeName = ''.obs;
  final RxList<String> items = <String>[].obs;
  final noteController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void onClose() {
    noteController.dispose();
    amountController.dispose();
    super.onClose();
  }


  Future<void> pickFromCamera() async {
    try {
      errorMessage.value = '';
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) await _processReceipt(File(image.path));
    } catch (e) {
      errorMessage.value = 'Gagal mengambil foto: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }


  Future<void> pickFromGallery() async {
    try {
      errorMessage.value = '';
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) await _processReceipt(File(image.path));
    } catch (e) {
      errorMessage.value = 'Gagal memilih gambar: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> _processReceipt(File imageFile) async {
    isScanning.value = true;
    errorMessage.value = '';

    try {
      Get.snackbar('📸 Scanning', 'Memproses struk dengan AI...', duration: const Duration(seconds: 2));

      final result = await _ocrService.scanReceipt(imageFile);

      totalAmount.value = result.totalAmount;
      storeName.value = result.storeName;
      items.value = result.items;
      noteController.text = result.summary;
      amountController.text = result.totalAmount.toStringAsFixed(0);

      isScanning.value = false;

     
      Get.toNamed('/smart-restock/reconcile');
    } catch (e) {
      isScanning.value = false;
      errorMessage.value = 'Gagal memproses struk: $e';
      Get.snackbar('❌ Error', errorMessage.value, backgroundColor: Colors.red.shade100);
      print('❌ OCR error: $e');
    }
  }

  
  Future<void> saveExpense() async {
    if (totalAmount.value <= 0) {
      Get.snackbar('Error', 'Total belanja tidak valid');
      return;
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final tx = TransactionModel(
        type: TransactionType.spending,
        amount: totalAmount.value,
        description: noteController.text.isNotEmpty
            ? noteController.text
            : 'Belanja ${storeName.value.isNotEmpty ? storeName.value : 'Toko'}',
        createdAt: DateTime.now(),
        customerName: storeName.value.isNotEmpty ? storeName.value : null,
      );

      await _txProvider.createTransaction(tx);

      Get.back(); 
      Get.snackbar(
        '✅ Tercatat',
        'Pengeluaran ${formatCurrency(totalAmount.value)} berhasil dicatat',
        backgroundColor: Colors.green.shade100,
      );

      _clear();
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan pengeluaran: $e';
      Get.snackbar(' Error', errorMessage.value, backgroundColor: Colors.red.shade100);
    } finally {
      isSaving.value = false;
    }
  }

  void _clear() {
    totalAmount.value = 0;
    storeName.value = '';
    items.clear();
    noteController.clear();
    amountController.clear();
  }


  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

