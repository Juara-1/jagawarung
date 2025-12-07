import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'smart_restock_controller.dart';
import '../../common/utils/format_utils.dart';
import '../../common/utils/currency_input_formatter.dart';

/// Confirmation page for expense OCR result
class ReconciliationPage extends StatelessWidget {
  const ReconciliationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SmartRestockController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pengeluaran'),
        backgroundColor: Colors.deepPurple,
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
                  onPressed: controller.saveExpense,
                  tooltip: 'Simpan',
                )),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(controller, context),
              const SizedBox(height: 16),
              _noteField(controller),
              const SizedBox(height: 16),
              _itemsCard(controller),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isSaving.value ? null : controller.saveExpense,
            backgroundColor: Colors.deepPurple,
            icon: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan'),
          )),
    );
  }

  Widget _headerCard(SmartRestockController controller, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Struk',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.store, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.storeName.value.isEmpty
                        ? 'Toko'
                        : controller.storeName.value,
                    style: Get.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nominal (boleh diedit jika tidak sesuai OCR)',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.receipt_long, color: Colors.deepPurple),
                labelText: 'Total pengeluaran',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixText: 'Rp ',
                hintText: '0',
              ),
              onChanged: (value) {
                final parsed = FormatUtils.parseCurrency(value);
                controller.totalAmount.value = parsed;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteField(SmartRestockController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Belanja harian toko',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsCard(SmartRestockController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Item Terdeteksi (${controller.items.length})',
                  style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.items.isEmpty)
              Text(
                'Item tidak terdeteksi, hanya total yang digunakan.',
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(item),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

