import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final income  = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final txs     = ref.watch(transactionsProvider);
    final monthly = ref.watch(monthlyDataProvider);
    final isDark  = ref.watch(themeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('FT',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Finance Tracker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () => ref.read(themeProvider.notifier).state = !isDark,
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _BalanceCard(balance: balance),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'INCOME',
                      amount: income,
                      color: AppTheme.income,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'EXPENSES',
                      amount: expense,
                      color: AppTheme.expense,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SectionHeader(title: 'Last 6 Months'),
                _MonthlyChart(monthly: monthly),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'Recent',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ),
                if (txs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptyState(
                        message: 'No transactions yet.\nTap + to add one.'),
                  )
                else
                  ...txs.take(8).map((tx) => TransactionTile(
                        tx: tx,
                        onDelete: () => ref
                            .read(transactionsProvider.notifier)
                            .delete(tx.id),
                      )),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: balance),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => Text(
              formatAmount(val),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthly;
  const _MonthlyChart({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxY = monthly
            .map((m) => [m['income'] as double, m['expense'] as double])
            .expand((e) => e)
            .fold(0.0, (a, b) => a > b ? a : b) * 1.3;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.05)
                : Colors.black.withOpacity(.06)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY < 1 ? 1000 : maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx >= monthly.length) return const SizedBox();
                  final month = monthly[idx]['month'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(DateFormat('MMM').format(month),
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white38 : Colors.black38)),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            horizontalInterval: 1000,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark
                  ? Colors.white.withOpacity(.04)
                  : Colors.black.withOpacity(.04),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(monthly.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthly[i]['income'] as double,
                  color: AppTheme.income,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: monthly[i]['expense'] as double,
                  color: AppTheme.expense,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}