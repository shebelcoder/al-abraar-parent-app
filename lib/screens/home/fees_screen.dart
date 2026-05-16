import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/stripe_service.dart';
import '../../theme/app_theme.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _selectedChild = 0;
  static const _children = ['Abdullah', 'Aisha'];

  // Mutable so we can flip status after successful payment
  late List<List<_Invoice>> _feeData;

  @override
  void initState() {
    super.initState();
    _feeData = [
      // Abdullah
      [
        _Invoice(id: 'inv_001', label: 'Term 3 Tuition', amount: 300, status: 'Paid', dueDate: 'May 1, 2026'),
        _Invoice(id: 'inv_002', label: 'Term 3 Materials', amount: 50, status: 'Paid', dueDate: 'May 1, 2026'),
        _Invoice(id: 'inv_003', label: 'Term 3 Activity Fee', amount: 100, status: 'Unpaid', dueDate: 'Jun 1, 2026'),
      ],
      // Aisha
      [
        _Invoice(id: 'inv_004', label: 'Term 3 Tuition', amount: 280, status: 'Paid', dueDate: 'May 1, 2026'),
        _Invoice(id: 'inv_005', label: 'Term 3 Materials', amount: 50, status: 'Paid', dueDate: 'May 1, 2026'),
        _Invoice(id: 'inv_006', label: 'Term 3 Registration', amount: 50, status: 'Paid', dueDate: 'Apr 15, 2026'),
      ],
    ];
  }

  List<_Invoice> get _invoices => _feeData[_selectedChild];
  int get _totalDue => _invoices.fold(0, (s, i) => s + i.amount);
  int get _totalPaid => _invoices
      .where((i) => i.status == 'Paid')
      .fold(0, (s, i) => s + i.amount);
  int get _outstanding => _totalDue - _totalPaid;

  Future<void> _payInvoice(_Invoice invoice) async {
    setState(() => invoice.loading = true);
    try {
      await StripeService.payFee(
        invoiceId: invoice.id,
        amountAed: invoice.amount,
        description: invoice.label,
      );
      // Mark paid on success
      setState(() => invoice.status = 'Paid');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${invoice.label} paid successfully.'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return; // user dismissed sheet
      if (mounted) _showError(e.error.localizedMessage ?? 'Payment failed.');
    } catch (e) {
      if (mounted) _showError('Could not reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => invoice.loading = false);
    }
  }

  Future<void> _payAll() async {
    final unpaid = _invoices.where((i) => i.status == 'Unpaid').toList();
    if (unpaid.isEmpty) return;

    // Pay the largest/only outstanding invoice; for multiple, pay the first
    await _payInvoice(unpaid.first);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _SummaryCard(
                  outstanding: _outstanding,
                  totalDue: _totalDue,
                  totalPaid: _totalPaid,
                  onPay: _outstanding > 0 ? _payAll : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Invoices',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),
                ..._invoices.map(
                  (inv) => _InvoiceCard(invoice: inv, onPay: () => _payInvoice(inv)),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int outstanding;
  final int totalDue;
  final int totalPaid;
  final VoidCallback? onPay;

  const _SummaryCard({
    required this.outstanding,
    required this.totalDue,
    required this.totalPaid,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = outstanding == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? [AppTheme.successGreen, const Color(0xFF059669)]
              : [AppTheme.warningOrange, const Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (isPaid ? AppTheme.successGreen : AppTheme.warningOrange)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isPaid ? 'All Paid' : 'Amount Due',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            isPaid ? 'AED 0' : 'AED $outstanding',
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SumStat(label: 'Total Billed', value: 'AED $totalDue')),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(child: _SumStat(label: 'Paid', value: 'AED $totalPaid')),
            ],
          ),
          if (!isPaid && onPay != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: Text('Pay AED $outstanding with Stripe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.warningOrange,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ],
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
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final _Invoice invoice;
  final VoidCallback onPay;
  const _InvoiceCard({required this.invoice, required this.onPay});

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
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(
                  isPaid ? 'Paid on ${invoice.dueDate}' : 'Due ${invoice.dueDate}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('AED ${invoice.amount}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              if (isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Paid',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen)),
                )
              else if (invoice.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primaryGreen),
                )
              else
                GestureDetector(
                  onTap: onPay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Pay',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────

class _Invoice {
  final String id;
  final String label;
  final int amount;
  String status;
  final String dueDate;
  bool loading = false;

  _Invoice({
    required this.id,
    required this.label,
    required this.amount,
    required this.status,
    required this.dueDate,
  });
}
