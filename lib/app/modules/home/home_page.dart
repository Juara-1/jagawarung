import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomePage extends GetView<DebtController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(
                () => controller.debts.isEmpty
                    ? const _EmptyState()
                    : _DebtList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildVoiceCommandButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Utang',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                ),
                const SizedBox(height: 4),
                Text(
                  'Catat dan kelola utang pelanggan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.document_scanner_outlined, size: 28),
                onPressed: () => Get.toNamed('/smart-restock'),
                tooltip: 'Smart Restock (Scan Nota)',
                padding: const EdgeInsets.all(12),
              ),
              _buildLogoutMenu(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opsi Lainnya',
      padding: const EdgeInsets.all(12),
      icon: const Icon(Icons.more_vert, size: 28),
      onSelected: (value) {
        if (value == 'logout') {
          Get.defaultDialog(
            title: 'Logout',
            middleText: 'Apakah Anda yakin ingin keluar?',
            textConfirm: 'Ya, Keluar',
            textCancel: 'Batal',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              Get.offAllNamed('/login');
            },
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCommandButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isListening = controller.isListening.value;
      final isProcessing = controller.isProcessing.value;

      String label = 'Ketuk untuk Bicara';
      IconData icon = Icons.mic_none;
      Color buttonColor = colorScheme.primary;
      if (isProcessing) {
        label = 'Memproses...';
        icon = Icons.sync;
        buttonColor = colorScheme.secondary;
      } else if (isListening) {
        label = 'Mendengarkan...';
        icon = Icons.mic;
        buttonColor = Colors.red;
      }

      // Using Semantics for accessibility
      return Semantics(
        label: 'Tombol Perintah Suara. Status saat ini: $label',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: isProcessing ? null : () {
            if (isListening) {
              controller.stopListening();
            } else {
              controller.startListening();
            }
          },
          backgroundColor: buttonColor,
          icon: isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Icon(icon, color: colorScheme.onPrimary),
          label: Text(label, style: TextStyle(color: colorScheme.onPrimary)),
          // Ensure large enough tap target by default
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final controller = Get.find<DebtController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: colorScheme.onBackground.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Utang',
              style: textTheme.headlineLarge?.copyWith(
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan perintah suara untuk mencatat utang baru.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // The main FAB serves as the primary CTA, no need for another button here.
          ],
        ),
      ),
    );
  }
}

class _DebtList extends GetView<DebtController> {
  @override
  Widget build(BuildContext context) {
    // Group debts by customer name
    final Map<String, List<dynamic>> groupedDebts = {};
    for (var debt in controller.debts) {
      if (!groupedDebts.containsKey(debt.customerName)) {
        groupedDebts[debt.customerName ?? ''] = [];
      }
      groupedDebts[debt.customerName]!.add(debt);
    }
    final customerNames = groupedDebts.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // Padding for FAB
      itemCount: customerNames.length,
      itemBuilder: (context, index) {
        final customerName = customerNames[index];
        final customerDebts = groupedDebts[customerName]!;
        final totalDebt = customerDebts.fold<double>(
          0.0,
          (sum, debt) => sum + debt.amount,
        );

        return _CustomerDebtCard(
          customerName: customerName,
          totalDebt: totalDebt,
          debts: List<dynamic>.from(customerDebts),
        );
      },
    );
  }
}

class _CustomerDebtCard extends GetView<DebtController> {
  final String customerName;
  final double totalDebt;
  final List<dynamic> debts;

  const _CustomerDebtCard({
    required this.customerName,
    required this.totalDebt,
    required this.debts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // Card styling from AppTheme
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          foregroundColor: colorScheme.primary,
          child: Text(
            customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customerName, style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
        subtitle: Text(
          'Total: ${controller.formatCurrency(totalDebt)}',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        children: debts.map((debt) => _buildDebtTile(context, debt)).toList(),
      ),
    );
  }

  Widget _buildDebtTile(BuildContext context, dynamic debt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      dense: true,
      leading: const SizedBox(width: 24, child: Icon(Icons.shopping_bag_outlined, size: 20)),
      title: Text(controller.formatCurrency(debt.amount)),
      subtitle: Text(controller.formatDate(debt.createdAt)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: Colors.green),
            tooltip: 'Tandai Lunas',
            padding: const EdgeInsets.all(12.0),
            onPressed: () {
              Get.defaultDialog(
                title: 'Pelunasan Utang',
                middleText: 'Tandai utang ${controller.formatCurrency(debt.amount)} untuk ${debt.customerName} sebagai LUNAS?\n\nUtang akan berubah menjadi pemasukan.',
                textConfirm: 'Ya, Lunas',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.green,
                onConfirm: () async {
                  Get.back(); // Close dialog
                  await controller.repayDebt(debt.id!);
                },
              );
            },
          ),
          // Button Delete
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Hapus utang ini',
            padding: const EdgeInsets.all(12.0),
            onPressed: () {
              Get.defaultDialog(
                title: 'Hapus Utang',
                middleText: 'Anda yakin ingin menghapus utang ${controller.formatCurrency(debt.amount)} untuk ${debt.customerName}?',
                textConfirm: 'Ya, Hapus',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  Get.back(); // Close dialog
                  await controller.debtService.deleteDebt(debt.id!);
                  await controller.loadDebts();
                  Get.snackbar(
                    'Berhasil',
                    'Utang berhasil dihapus.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}