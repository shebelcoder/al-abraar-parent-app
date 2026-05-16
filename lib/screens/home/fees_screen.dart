import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _selectedChild = 0;
  static const _children = ['Abdullah', 'Aisha'];

  static const _feeData = [
    // Abdullah
    _ChildFees(
      totalDue: 450,
      totalPaid: 300,
      currency: 'AED',
      invoices: [
        _Invoice('Term 3 Tuition', 300, 300, 'Paid', 'May 1, 2026'),
        _Invoice('Term 3 Materials', 50, 50, 'Paid', 'May 1, 2026'),
        _Invoice('Term 3 Activity Fee', 100, 0, 'Unpaid', 'Jun 1, 2026'),
      ],
    ),
    // Aisha
    _ChildFees(
      totalDue: 380,
      totalPaid: 380,
      currency: 'AED',
      invoices: [
        _Invoice('Term 3 Tuition', 280, 280, 'Paid', 'May 1, 2026'),
        _Invoice('Term 3 Materials', 50, 50, 'Paid', 'May 1, 2026'),
        _Invoice('Term 3 Registration', 50, 50, 'Paid', 'Apr 15, 2026'),
      ],
    ),
  ];

  _ChildFees get _current => _feeData[_selectedChild];

  @override
  Widget build(BuildContext context) {
    final outstanding = _current.totalDue - _current.totalPaid;
    return Scaffold(
      backgroundColor: AppTheme.warmBackground,
      appBar: AppBar(
        title: const Text('Fees'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Child selector
          Container(
            color: AppTheme.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: List.generate(_children.length, (i) {
                final selected = i == _selectedChild;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChild = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < _children.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryGreen : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _children[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: outstanding > 0
                          ? [AppTheme.warningOrange, const Color(0xFFEA580C)]
                          : [AppTheme.successGreen, const Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (outstanding > 0
                                ? AppTheme.warningOrange
                                : AppTheme.successGreen)
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outstanding > 0 ? 'Amount Due' : 'All Paid',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        outstanding > 0
                            ? '${_current.currency} ${outstanding.toStringAsFixed(0)}'
                            : '${_current.currency} 0.00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SumStat(
                              label: 'Total Billed',
                              value: '${_current.currency} ${_current.totalDue}',
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withValues(alpha: 0.3)),
                          Expanded(
                            child: _SumStat(
                              label: 'Paid',
                              value: '${_current.currency} ${_current.totalPaid}',
                            ),
                          ),
                        ],
                      ),
                      if (outstanding > 0) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showPaySheet(context, outstanding),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.warningOrange,
                              minimumSize: const Size(0, 46),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            child: Text(
                                'Pay ${_current.currency} ${outstanding.toStringAsFixed(0)}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Invoices',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ..._current.invoices.map((inv) => _InvoiceCard(invoice: inv)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaySheet(BuildContext context, int amount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.payment_rounded,
                size: 48, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text(
              'Pay AED $amount',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'You will be redirected to the payment gateway.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Payment gateway coming soon.'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumStat extends StatelessWidget {
  final String label;
  final String value;
  const _SumStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final _Invoice invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == 'Paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isPaid ? AppTheme.successGreen : AppTheme.warningOrange)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isPaid ? AppTheme.successGreen : AppTheme.warningOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(
                  isPaid ? 'Paid on ${invoice.dueDate}' : 'Due ${invoice.dueDate}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AED ${invoice.amount}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPaid ? AppTheme.successGreen : AppTheme.warningOrange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppTheme.successGreen : AppTheme.warningOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildFees {
  final int totalDue;
  final int totalPaid;
  final String currency;
  final List<_Invoice> invoices;
  const _ChildFees({
    required this.totalDue,
    required this.totalPaid,
    required this.currency,
    required this.invoices,
  });
}

class _Invoice {
  final String label;
  final int amount;
  final int paid;
  final String status;
  final String dueDate;
  const _Invoice(this.label, this.amount, this.paid, this.status, this.dueDate);
}
