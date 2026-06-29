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
    IconData icon = Icons.text_fields,
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

  /// Text input field dengan lebih banyak opsi (untuk form create/edit)
  Widget textInput({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
    double minWidth = 40,
    double minHeight = 45,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: minWidth,
        height: minHeight,
        child: IconButton(
          icon: Icon(icon, size: size),
          onPressed: onPressed,
          color: color,
          tooltip: tooltip,
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: const EdgeInsets.all(2),
        ),
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
    final Map<String, String> unitLabels = {
      'carton': 'CTN',
      'pack': 'PCK',
      'pcs': 'PCS',
    };

    return Wrap(
      spacing: 6,
      children: units.map((unit) {
        bool isSelected = value == unit;
        return GestureDetector(
          onTap: () => onChanged(unit),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              unitLabels[unit] ?? unit.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Quantity Control - dengan tombol +/- dan text field untuk input langsung
  Widget qtyControl({
    required int value,
    required ValueChanged<int> onChanged,
    int minValue = 1,
    Color? color,
    TextEditingController? controller,
  }) {
    // Gunakan controller jika disediakan, atau buat internal controller
    final TextEditingController qtyController =
        controller ?? TextEditingController(text: value.toString());

    // Sync controller text jika value berubah dari luar (misal dari tombol +/-)
    if (controller == null && qtyController.text != value.toString()) {
      qtyController.text = value.toString();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        iconButton(
          icon: Icons.remove,
          onPressed: () {
            if (value > minValue) {
              final newValue = value - 1;
              qtyController.text = newValue.toString();
              onChanged(newValue);
            }
          },
          color: color ?? Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: color ?? Colors.blue, width: 2),
              ),
            ),
            onChanged: (text) {
              // Allow empty temporarily (untuk bisa hapus semua angka)
              if (text.isEmpty) {
                return;
              }

              int? numericValue = int.tryParse(text);
              if (numericValue != null && numericValue >= minValue) {
                onChanged(numericValue);
              }
            },
            onSubmitted: (text) {
              // Validate setelah user selesai input (tekan enter/done)
              int numericValue = int.tryParse(text) ?? minValue;
              if (numericValue < minValue) {
                numericValue = minValue;
                qtyController.text = minValue.toString();
                qtyController.selection = TextSelection.fromPosition(
                  TextPosition(offset: qtyController.text.length),
                );
              }
              onChanged(numericValue);
            },
            onEditingComplete: () {
              // Validate saat focus hilang atau user tap done
              final text = qtyController.text;
              if (text.isEmpty) {
                qtyController.text = minValue.toString();
                onChanged(minValue);
              } else {
                int numericValue = int.tryParse(text) ?? minValue;
                if (numericValue < minValue) {
                  numericValue = minValue;
                  qtyController.text = minValue.toString();
                }
                onChanged(numericValue);
              }
            },
          ),
        ),
        const SizedBox(width: 4),
        iconButton(
          icon: Icons.add,
          onPressed: () {
            final newValue = value + 1;
            qtyController.text = newValue.toString();
            onChanged(newValue);
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
