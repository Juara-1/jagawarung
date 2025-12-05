import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'smart_restock_controller.dart';
import '../../data/models/product_model.dart';

/// Reconciliation Page
/// "Layar Pencocokan" - Edit & confirm OCR results
class ReconciliationPage extends StatelessWidget {
  const ReconciliationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SmartRestockController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Restocking'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: controller.saveRestock,
                  tooltip: 'Simpan',
                )),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const Center(
            child: Text('Tidak ada item untuk diproses'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Name
                    TextField(
                      controller: controller.supplierNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Supplier',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Invoice Number
                    TextField(
                      controller: controller.invoiceNumberController,
                      decoration: const InputDecoration(
                        labelText: 'No. Invoice',
                        prefixIcon: Icon(Icons.receipt_long),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.invoiceDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.invoiceDate.value = picked;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tanggal: ${_formatDate(controller.invoiceDate.value)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Items List Header
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF6C5CE7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${controller.items.length} Item Terdeteksi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Geser untuk hapus →',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(context, controller, index);
                },
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        );
      }),

      // Save FAB
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isSaving.value 
                ? null 
                : controller.saveRestock,
            backgroundColor: const Color(0xFF6C5CE7),
            icon: controller.isSaving.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan Semua'),
          )),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    SmartRestockController controller,
    int index,
  ) {
    final item = controller.items[index];

    return Dismissible(
      key: Key('item_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.removeItem(index),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan confidence badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (item.matchConfidence > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: controller.getConfidenceColor(item.matchConfidence)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        controller.getConfidenceText(item.matchConfidence),
                        style: TextStyle(
                          color: controller.getConfidenceColor(item.matchConfidence),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // OCR Name (Read-only)
              Text(
                'Dari Nota:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),

              // Product Matcher (Dropdown)
              Text(
                'Cocokkan ke Produk:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _buildProductDropdown(controller, index, item),
              const SizedBox(height: 12),

              // Qty & Price Row
              Row(
                children: [
                  // Qty
                  Expanded(
                    child: _buildNumberField(
                      label: 'Qty',
                      value: item.quantity.toString(),
                      onChanged: (value) {
                        final qty = int.tryParse(value);
                        if (qty != null) {
                          controller.updateItem(index, quantity: qty);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Buy Price
                  Expanded(
                    child: _buildNumberField(
                      label: 'Harga Beli',
                      value: item.price.toStringAsFixed(0),
                      onChanged: (value) {
                        final price = double.tryParse(value);
                        if (price != null) {
                          controller.updateItem(index, price: price);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sell Price
              _buildNumberField(
                label: 'Set Harga Jual',
                controller: controller.sellPriceControllers[index],
                hint: 'Harga jual ke customer',
              ),
              const SizedBox(height: 12),

              // Total
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Modal:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      controller.formatCurrency(item.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDropdown(
    SmartRestockController controller,
    int index,
    item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductModel>(
          isExpanded: true,
          value: item.matchedProductId != null
              ? controller.allProducts.firstWhereOrNull(
                  (p) => p.id == item.matchedProductId,
                )
              : null,
          hint: const Text('Pilih produk atau buat baru'),
          items: [
            // Option untuk create new
            const DropdownMenuItem<ProductModel>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Color(0xFF6C5CE7)),
                  SizedBox(width: 8),
                  Text(
                    '+ Buat produk baru',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const DropdownMenuItem<ProductModel>(
              enabled: false,
              child: Divider(),
            ),
            // Existing products
            ...controller.allProducts.map((product) {
              return DropdownMenuItem<ProductModel>(
                value: product,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Stock: ${product.stock} | ${controller.formatCurrency(product.sellPrice)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (product) {
            if (product != null) {
              controller.selectProductForItem(index, product);
            } else {
              // Clear match (will create new product)
              controller.updateItem(
                index,
                matchedProductId: null,
                matchedProductName: null,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    String? value,
    TextEditingController? controller,
    String? hint,
    Function(String)? onChanged,
  }) {
    final textController = controller ?? TextEditingController(text: value);

    return TextField(
      controller: textController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
