import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/transaction_model.dart';
import 'transactions_controller.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Column(
          children: [
            _FilterChips(controller),
            Expanded(
              child: _TransactionsList(controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final TransactionsController controller;
  const _FilterChips(this.controller);

  @override
  Widget build(BuildContext context) {
    final filters = const [
      {'label': 'Semua', 'value': ''},
      {'label': 'Pemasukan', 'value': 'earning'},
      {'label': 'Pengeluaran', 'value': 'spending'},
      {'label': 'Utang', 'value': 'debts'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((f) {
          final value = f['value']!;
          return Obx(() {
            final selected = controller.selectedType.value == value;
            return ChoiceChip(
              label: Text(f['label']!),
              selected: selected,
              onSelected: (_) => controller.setFilter(value),
              selectedColor: Colors.deepPurple.withOpacity(0.15),
              labelStyle: TextStyle(
                color: selected ? Colors.deepPurple : Colors.black87,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final TransactionsController controller;
  const _TransactionsList(this.controller);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            controller.hasMore.value &&
            !controller.isLoading.value) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            controller.fetchTransactions();
          }
        }
        return false;
      },
      child: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return const Center(
            child: Text('Belum ada transaksi'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.transactions.length +
              (controller.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index >= controller.transactions.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final tx = controller.transactions[index];
            final typeColor = controller.typeColor(tx.type);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            tx.description?.isNotEmpty == true
                                ? tx.description!
                                : '(Tanpa catatan)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            controller.typeLabel(tx.type),
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.formatCurrency(tx.amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.formatDate(tx.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (tx.type == TransactionType.debts &&
                            tx.customerName != null &&
                            tx.customerName!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                tx.customerName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (tx.invoiceData != null && tx.invoiceData!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tx.invoiceData!.entries.take(3).map((e) {
                            return Chip(
                              label: Text('${e.key}: ${e.value}'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  Colors.blueGrey.withOpacity(0.08),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

