import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jagawarung/app/routes/app_routes.dart';
import '../../common/utils/format_utils.dart';
import '../../common/utils/transaction_type_utils.dart';
import 'dashboard_controller.dart';
import '../../data/models/transaction_model.dart';
import 'widgets/shimmer_loading.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoadingDashboard.value && controller.dashboardSummary.value.transactionCount == 0) {
          return const SafeArea(child: DashboardShimmer());
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildTimeRange(context),
                  const SizedBox(height: 12),
                  _buildSummaryCards(context),
                  const SizedBox(height: 28),
                  _buildRecentTransactions(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: _buildVoiceFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Pagi' : (now.hour < 15 ? 'Siang' : (now.hour < 18 ? 'Sore' : 'Malam'));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat $timeOfDay 👋',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dashboard Keuangan',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 24),
                  onPressed: controller.loadDashboard,
                  tooltip: 'Muat Ulang Data',
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRange(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ranges = const [
      {'label': 'Harian', 'value': 'day'},
      {'label': 'Mingguan', 'value': 'week'},
      {'label': 'Bulanan', 'value': 'month'}
    ];

    return Obx(() {
      final selected = controller.summaryRange.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan periode',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ranges.map((r) {
                  final value = r['value']!;
                  final isSelected = selected == value;
                  return ChoiceChip(
                    label: Text(r['label']!),
                    selected: isSelected,
                    onSelected: (_) => controller.changeSummaryRange(value),
                    selectedColor: const Color(0xFFFF8F00).withOpacity(0.18), // accent
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFF8F00) : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFFF8F00).withOpacity(0.4)
                            : colorScheme.outline.withOpacity(0.4),
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards(BuildContext context) {
    final theme = Theme.of(context);
    final summary = controller.dashboardSummary.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Hari Ini',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hari Ini',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Pemasukan',
                  amount: summary.todayIncome,
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF10B981),
                  controller: controller,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Pengeluaran',
                  amount: summary.todayExpense,
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFFEF4444),
                  controller: controller,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SummaryCard(
            title: 'Total Utang Pelanggan',
            amount: summary.totalDebt,
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFFF59E0B),
            controller: controller,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.recentTransactions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildEmptyState(context),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terakhir',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.transactions);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Lihat Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.recentTransactions.asMap().entries.map(
              (entry) => TransactionTile(
                transaction: entry.value,
                controller: controller,
                isLast: entry.key == controller.recentTransactions.length - 1,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat transaksi dengan\nmenekan tombol mikrofon di bawah',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceFAB(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isListening = controller.isListening.value;
      final isProcessing = controller.isVoiceProcessing.value;
      final statusText = isProcessing
          ? 'Memproses...'
          : (isListening ? 'Mendengarkan...' : 'Ketuk untuk bicara');

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isListening 
                      ? Colors.red.withOpacity(0.3)
                      : colorScheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? Colors.red : colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (isListening ? Colors.red : colorScheme.primary).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    statusText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            VoiceButton(
              isListening: isListening,
              isLoading: isProcessing,
              onTapStart: () async => await controller.startVoiceInput(),
              onTapEnd: controller.stopListening,
              colorScheme: colorScheme,
            ),
          ],
        ),
      );
    });
  }
}


class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final DashboardController controller;
  final bool isWide;

  const SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.controller,
    this.isWide = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountText =
        controller.formatCurrency(amount).replaceFirst('Rp ', 'Rp\u00A0');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isWide)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '$title: $amountText',
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                amountText,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final DashboardController controller;
  final bool isLast;

  const TransactionTile({
    required this.transaction,
    required this.controller,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = TransactionTypeUtils.getColor(transaction.type);
    final icon = TransactionTypeUtils.getIcon(transaction.type);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.customerName ?? TransactionTypeUtils.getLabel(transaction.type),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(transaction.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: 'Nominal: ${controller.formatCurrency(transaction.amount)}',
              child: Text(
                controller.formatCurrency(transaction.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return FormatUtils.formatDateTime(dateTime);
  }
}

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final bool isLoading;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;
  final ColorScheme colorScheme;

  const VoiceButton({
    required this.isListening,
    required this.isLoading,
    required this.onTapStart,
    required this.onTapEnd,
    required this.colorScheme,
    super.key,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.isListening && !widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isListening) {
          widget.onTapEnd();
        } else {
          widget.onTapStart();
        }
      },
      onLongPressStart: (_) => widget.onTapStart(),
      onLongPressEnd: (_) => widget.onTapEnd(),
      child: Semantics(
        button: true,
        label: widget.isListening
            ? 'Sedang mendengarkan. Lepas untuk berhenti'
            : 'Ketuk atau tahan untuk mulai bicara',
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isListening)
                  Container(
                    height: 120 * _scaleAnim.value,
                    width: 120 * _scaleAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(_ringOpacity.value * 0.3),
                    ),
                  ),
                if (widget.isListening)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.15),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isListening
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              widget.colorScheme.primary,
                              widget.colorScheme.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isListening
                                ? Colors.red
                                : widget.colorScheme.primary)
                            .withOpacity(0.4),
                        blurRadius: widget.isListening ? 28 : 16,
                        spreadRadius: widget.isListening ? 4 : 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: widget.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Icon(
                          widget.isListening ? Icons.mic : Icons.mic_none_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}