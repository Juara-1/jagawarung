import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DebtController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jaga Warung - Catat Hutang'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDebts(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Apakah Anda yakin ingin keluar?',
                textConfirm: 'Ya',
                textCancel: 'Tidak',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  Get.offAllNamed('/login');
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7),
                  const Color(0xFF6C5CE7).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '🎤 Voice Command',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tekan tombol dan ucapkan:\n"Catat hutang Budi 2000"\n"Berapa hutang Budi?"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

               
                Obx(
                  () => Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (controller.isListening.value) {
                            controller.stopListening();
                          } else {
                            controller.startListening();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.isListening.value
                                ? Colors.red
                                : Colors.white,
                            boxShadow: controller.isListening.value
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            controller.isListening.value
                                ? Icons.mic
                                : Icons.mic_none,
                            size: 40,
                            color: controller.isListening.value
                                ? Colors.white
                                : const Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.isListening.value
                            ? 'Mendengarkan...'
                            : 'Tap untuk mulai bicara',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

              
                const SizedBox(height: 16),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.recognizedText.value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Teks yang didengar:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.recognizedText.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (controller.lastResponseText.value.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Respon sistem:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.lastResponseText.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

       
                Obx(() => controller.isProcessing.value
                    ? const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink()),

     
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),

       
          Expanded(
            child: Obx(() {
              if (controller.debts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada hutang tercatat',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gunakan voice command untuk mencatat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final Map<String, List<dynamic>> groupedDebts = {};
              for (var debt in controller.debts) {
                if (!groupedDebts.containsKey(debt.customerName)) {
                  groupedDebts[debt.customerName] = [];
                }
                groupedDebts[debt.customerName]!.add(debt);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedDebts.length,
                itemBuilder: (context, index) {
                  final customerName = groupedDebts.keys.elementAt(index);
                  final customerDebts = groupedDebts[customerName]!;
                  final totalDebt = customerDebts.fold<double>(
                    0.0,
                    (sum, debt) => sum + debt.amount,
                  );

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF6C5CE7),
                        child: Text(
                          customerName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Total: ${controller.formatCurrency(totalDebt)}',
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: customerDebts.map<Widget>((debt) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.receipt_long,
                            size: 20,
                            color: Colors.grey,
                          ),
                          title: Text(
                            controller.formatCurrency(debt.amount),
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            controller.formatDate(debt.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Hapus Hutang',
                                middleText: 'Hapus hutang ini?',
                                textConfirm: 'Ya',
                                textCancel: 'Tidak',
                                confirmTextColor: Colors.white,
                                onConfirm: () async {
                                  await controller.debtService
                                      .deleteDebt(debt.id!);
                                  await controller.loadDebts();
                                  Get.back();
                                  Get.snackbar(
                                    '✅ Berhasil',
                                    'Hutang berhasil dihapus',
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.debts.isEmpty) return const SizedBox.shrink();

        final totalAllDebts = controller.debts.fold<double>(
          0.0,
          (sum, debt) => sum + debt.amount,
        );

        return FloatingActionButton.extended(
          onPressed: () {
            Get.defaultDialog(
              title: '📊 Total Semua Hutang',
              middleText: controller.formatCurrency(totalAllDebts),
              textConfirm: 'OK',
              onConfirm: () => Get.back(),
            );
          },
          backgroundColor: const Color(0xFF6C5CE7),
          icon: const Icon(Icons.analytics),
          label: Text(controller.formatCurrency(totalAllDebts)),
        );
      }),
    );
  }
}
