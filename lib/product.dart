class Product {
  String name = "";
  int? Qty = 0;
  double? ProductPrice = 0.0;
  double? Price = 0.0;

  Product({required this.name, this.Price, this.ProductPrice, this.Qty});

  String getIndex(int index, int no_index) {
    switch (index) {
      case 0:
        return (no_index + 1).toString();
      case 1:
        return name;
      case 2:
        return Qty.toString();
      case 3:
        return _formatCurrency(ProductPrice!).toString();
      case 4:
        return _formatCurrency(Price!).toString();
    }
    return '';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
