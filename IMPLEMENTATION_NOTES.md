# Sales + Return Wizard Implementation

## 📁 File Structure

```
lib/
├── provider/
│   └── sales_provider.dart          ✅ Updated dengan return_items, cashAmount
├── api/
│   └── sales_api.dart               ✅ Updated dengan return_items & cash_amount
├── widget/
│   └── form_widget.dart             ✅ Added: unitSelector, qtyControl, priceInput
├── screen/sales/
│   ├── sales_wizard_screen.dart           ✅ Main container (Step 1-4)
│   ├── sales_step1_header.dart            ✅ Customer, Tanggal, Payment Terms, Diskon
│   ├── sales_step2_items.dart             ✅ Tambah/edit sales items
│   ├── sales_step3_return.dart            ✅ Tambah/edit return items (optional)
│   ├── sales_step4_confirmation.dart      ✅ Review & submit dengan cash input
│   └── product_picker_screen.dart         ✅ Full-screen product picker (sales & return mode)
└── util/
    └── formatter_util.dart          (already exists, used for formatting)
```

## 🎯 Flow Wizard (4 Steps)

### Step 1: Header Information
- Customer selection (dropdown)
- Sales date picker
- Payment terms selection
- Transaction discount input (optional)

### Step 2: Sales Items
- Add products via Product Picker
- Edit qty, unit, harga, diskon untuk setiap item
- Delete items
- Summary sticky bar: Total + Item count

### Step 3: Return Items (Optional)
- Add return products via Product Picker (return mode)
- Edit qty, unit, harga, diskon untuk setiap return item
- Delete items
- Styling: Soft amber (#FFF3E0) background
- Can skip if no return needed

### Step 4: Confirmation & Payment
- Review semua sales items & return items (if any)
- Summary: Total penjualan, Total retur, Diskon transaksi
- Cash amount input
- Calculate remaining amount (Total Sales - Cash)
- Submit button untuk create sales

## 🔄 State Management (SalesProvider)

### State Variables
- `List<SalesItem> items` - Sales items
- `List<ReturnItem> returnItems` - Return items
- `int cashAmount` - Pembayaran tunai

### Key Methods
- `addItem()` - Tambah sales item
- `updateItem()` - Update qty & diskon sales item
- `updateItemPrice()` - Update harga sales item
- `updateItemUnit()` - Ubah unit & reset harga
- `removeItem()` - Hapus sales item
- `addReturnItem()` - Tambah return item
- `updateReturnItem()` - Update qty & diskon return item
- `updateReturnItemPrice()` - Update harga return item
- `updateReturnItemUnit()` - Ubah unit & reset harga
- `removeReturnItem()` - Hapus return item
- `setCashAmount()` - Set cash amount

### Computed Getters
- `totalSales` - Total dari sales items
- `totalReturn` - Total dari return items
- `remainingAmount` - Total Sales - Cash Amount
- `totalDiscount` - Total diskon dari sales items
- `totalReturnDiscount` - Total diskon dari return items

## 🎨 UI/UX Features

### Form Widgets (form_widget.dart)
```dart
// Unit selector (chip-based)
FormWidget().unitSelector(
  value: 'carton',
  onChanged: (unit) { },
  units: ['carton', 'pack', 'pcs'],
)

// Quantity control (+ / qty / -)
FormWidget().qtyControl(
  value: 5,
  onChanged: (newQty) { },
)

// Price input (formatted)
FormWidget().priceInput(
  controller: controller,
  label: 'Harga',
  onChanged: (value) { },
)

// Existing widgets (still available)
- currencyInput()
- numericInput()
- dropdown()
- button()
- iconButton()
```

### Return Items Styling
- Background: `#FFF3E0` (soft amber)
- Accent: `#FF9800` (amber)
- Used for visual differentiation dari sales items

### Price Formatting
- Used `FormatterUtil` dari util/formatter_util.dart
- Format: `72.000` (dengan thousand separator)
- Currency: `Rp. 72.000`

## 📋 API Payload

### POST /api/sales
```json
{
  "customer_id": 2,
  "payment_term_id": 2,
  "sales_date": "2026-07-20",
  "discount_amount": 0,
  "cash_amount": 80000,
  "items": [
    {
      "product_id": 1,
      "unit": "pack",
      "qty": 20,
      "price": 50000,
      "discount_amount": 0
    }
  ],
  "return_items": [
    {
      "product_id": 2,
      "unit": "pack",
      "qty": 5,
      "price": 10000,
      "discount_amount": 0
    }
  ]
}
```

## 🚀 How to Use

```dart
// Navigate ke wizard dari menu
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SalesWizardScreen()),
);
```

## ✅ Checklist

- ✅ Wizard flow dengan 4 steps
- ✅ Product picker full-screen (tidak modal)
- ✅ Sales items editable (qty, unit, harga, diskon)
- ✅ Return items optional (dapat di-skip)
- ✅ Return items styling (soft amber)
- ✅ Price formatting konsisten
- ✅ Cash amount input
- ✅ Remaining amount calculation
- ✅ All Form widgets reusable
- ✅ No compilation errors
- ✅ API payload sudah sesuai spec
- ✅ State management dengan Provider

---

**Notes:**
- Semua komponen menggunakan FormWidget untuk konsistensi style
- Return items adalah optional - user bisa skip Step 3
- Cash amount masuk ke payload sebagai `cash_amount`
- Remaining Amount = Total Sales - Cash Amount (tidak termasuk return)
- Product Picker bisa digunakan untuk sales dan return mode
