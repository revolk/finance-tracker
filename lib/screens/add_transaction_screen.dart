import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  TransactionType _type     = TransactionType.expense;
  String?         _category;
  DateTime        _date     = DateTime.now();
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _categories =>
      _type == TransactionType.expense
          ? AppCategories.expense
          : AppCategories.income;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    ref.read(transactionsProvider.notifier).add(
          title: _titleCtrl.text.trim(),
          amount: double.parse(_amountCtrl.text.trim()),
          type: _type,
          category: _category!,
          date: _date,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Transaction'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.card : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  _TypeTab(
                    label: 'Expense',
                    icon: '💸',
                    selected: _type == TransactionType.expense,
                    color: AppTheme.expense,
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _category = null;
                    }),
                  ),
                  _TypeTab(
                    label: 'Income',
                    icon: '💰',
                    selected: _type == TransactionType.income,
                    color: AppTheme.income,
                    onTap: () => setState(() {
                      _type = TransactionType.income;
                      _category = null;
                    }),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  prefixText: 'EGP  ',
                  prefixStyle: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w600),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  if (double.parse(v) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Title (e.g. Lunch, Salary)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 24),
              Text('Category',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _category == cat['name'];
                  final color = Color(cat['color'] as int);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(.2)
                            : (isDark ? AppTheme.card : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(cat['emoji'] as String,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(cat['name'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? color : null)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.card : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 12),
                    Text(DateFormat('d MMMM yyyy').format(_date),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(hintText: 'Note (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TransactionType.expense
                        ? AppTheme.expense
                        : AppTheme.income,
                  ),
                  child: Text(
                    'Save ${_type == TransactionType.expense ? 'Expense' : 'Income'}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? color : Colors.grey)),
          ]),
        ),
      ),
    );
  }
}