class TaxResult {
  final double baseAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;
  final double totalAmount;

  TaxResult({
    required this.baseAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
    required this.totalAmount,
  });
}

class TaxCalculator {
  /// Calculates GST for tax-exclusive pricing (Price + Tax)
  static TaxResult calculateExclusive({
    required double amount,
    required double taxRate,
    bool isInterstate = false,
  }) {
    double totalTax = amount * (taxRate / 100);
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (isInterstate) {
      igst = totalTax;
    } else {
      cgst = totalTax / 2;
      sgst = totalTax / 2;
    }

    return TaxResult(
      baseAmount: amount,
      cgst: _round(cgst),
      sgst: _round(sgst),
      igst: _round(igst),
      totalTax: _round(totalTax),
      totalAmount: _round(amount + totalTax),
    );
  }

  /// Calculates GST for tax-inclusive pricing (Price is already including Tax)
  static TaxResult calculateInclusive({
    required double totalAmount,
    required double taxRate,
    bool isInterstate = false,
  }) {
    // Formula: Base Price = Total Amount / (1 + Tax Rate / 100)
    double baseAmount = totalAmount / (1 + (taxRate / 100));
    double totalTax = totalAmount - baseAmount;
    
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (isInterstate) {
      igst = totalTax;
    } else {
      cgst = totalTax / 2;
      sgst = totalTax / 2;
    }

    return TaxResult(
      baseAmount: _round(baseAmount),
      cgst: _round(cgst),
      sgst: _round(sgst),
      igst: _round(igst),
      totalTax: _round(totalTax),
      totalAmount: totalAmount,
    );
  }

  static double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
