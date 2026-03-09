import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(categoryBreakdownProvider);
    final totalExp  = ref.watch(totalExpenseProvider);
    final totalInc  = ref.watch(totalIncomeProvider);
    final txs       = ref.watch(transactionsProvider);
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SavingsCard(income: totalInc, expense: totalExp),
          const SizedBox(height: 24),
          if (breakdown.isNotEmpty) ...[
            SectionHeader(title: 'Spending by Category'),
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.card : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: breakdown.take(6).map((item) {
                        final cat = AppCategories.find(item['category'] as String);
                        final pct = totalExp > 0
                            ? (item['amount'] as double) / totalExp * 100
                            : 0.0;
                        return PieChartSectionData(
                          color: Color(cat['color'] as int),
                          value: item['amount'] as double,
                          title: '${pct.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: breakdown.take(6).map((item) {
                    final cat = AppCategories.find(item['category'] as String);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: Color(cat['color'] as int),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${cat['emoji']} ${item['category']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ]),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          SectionHeader(title: 'Top Expenses'),
          ...txs
              .where((t) => t.type == TransactionType.expense)
              .take(5)
              .map((tx) => TransactionTile(
                    tx: tx,
                    onDelete: () =>
                        ref.read(transactionsProvider.notifier).delete(tx.id),
                  )),
          if (txs.where((t) => t.type == TransactionType.expense).isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EmptyState(message: 'No expenses recorded yet'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final double income, expense;
  const _SavingsCard({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final savings = income - expense;
    final rate    = income > 0 ? (savings / income * 100).clamp(0.0, 100.0) : 0.0;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Savings Rate',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 13,
                  letterSpacing: .5)),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => Text(
              '${val.toStringAsFixed(1)}%',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: val >= 20 ? AppTheme.income : AppTheme.expense),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rate / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(.07)
                    : Colors.black.withOpacity(.07),
                color: rate >= 20 ? AppTheme.income : AppTheme.expense,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            rate >= 20 ? '🔥 Great job! Keep saving.' : '⚠️ Try to save more than 20%',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}