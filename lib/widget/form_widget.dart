import 'package:flutter/material.dart';

class CurrencyFormatter {
  /// Format number with thousands separator (ribuan)
  static String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Parse currency string to int (remove dots from thousands)
  static int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '')) ?? 0;
  }
}

class FormWidget {
  Widget textFormField({
    required TextEditingController controller,
    required String label,
    required TextInputType type,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscureText,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  /// Numeric input field dengan format ribuan (currency)
  Widget currencyInput({
    required TextEditingController controller,
    required String label,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<int>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onChanged: (value) {
        // Remove dots and get the numeric value
        int numericValue = CurrencyFormatter.parseCurrency(value);
        // Format back with dots
        String formatted = CurrencyFormatter.formatCurrency(numericValue);

        // Update controller if different
        if (formatted != value && formatted.isNotEmpty) {
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }

        if (onChanged != null) {
          onChanged(numericValue);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
      ),
    );
  }

  /// Numeric input field (for qty, count, etc)
  Widget numericInput({
    required TextEditingController controller,
    required String label,
    ValueChanged<int>? onChanged,
    int minValue = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: (value) {
        int numericValue = int.tryParse(value) ?? minValue;
        if (numericValue < minValue) {
          numericValue = minValue;
          controller.text = minValue.toString();
        }
        if (onChanged != null) {
          onChanged(numericValue);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
      ),
    );
  }

  /// Dropdown component
  Widget dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? label,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
      ),
    );
  }

  /// Icon button dengan bordered style
  Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    String? tooltip,
    double size = 24,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        color: color,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget button({
    required IconData icon,
    required String label,
    required VoidCallback callBack,
    bool showLoader = false,
    double? width,
    double height = 50,
    Color? backgroundColor,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: showLoader ? null : callBack,
        icon: Icon(icon, color: textColor),
        label: showLoader
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: TextStyle(color: textColor),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }

  /// Unit Selector - chip-based untuk memilih unit (carton, pack, pcs)
  Widget unitSelector({
    required String value,
    required ValueChanged<String> onChanged,
    List<String> units = const ['carton', 'pack', 'pcs'],
  }) {
    return Wrap(
      spacing: 8,
      children: units.map((unit) {
        bool isSelected = value == unit;
        return FilterChip(
          label: Text(unit.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onChanged(unit);
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.blue.shade100,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        );
      }).toList(),
    );
  }

  /// Quantity Control - dengan tombol +/- dan display qty
  Widget qtyControl({
    required int value,
    required ValueChanged<int> onChanged,
    int minValue = 1,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        iconButton(
          icon: Icons.remove,
          onPressed: () {
            if (value > minValue) {
              onChanged(value - 1);
            }
          },
          color: color ?? Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        iconButton(
          icon: Icons.add,
          onPressed: () {
            onChanged(value + 1);
          },
          color: color ?? Colors.grey.shade600,
          size: 20,
        ),
      ],
    );
  }

  /// Price Input Field - dengan format currency
  Widget priceInput({
    required TextEditingController controller,
    required String label,
    ValueChanged<int>? onChanged,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      readOnly: readOnly,
      onChanged: (value) {
        int numericValue = CurrencyFormatter.parseCurrency(value);
        String formatted = CurrencyFormatter.formatCurrency(numericValue);

        if (formatted != value && formatted.isNotEmpty) {
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }

        if (onChanged != null) {
          onChanged(numericValue);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rp. ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
      ),
    );
  }
}
