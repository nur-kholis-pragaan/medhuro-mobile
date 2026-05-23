# Fitur Pembayaran Piutang - Implementasi Flutter Mobile

## 📋 Overview
Fitur pembayaran piutang (receivables payment) untuk aplikasi mobile Flutter Medhuro, memungkinkan salesman mengumpulkan pembayaran piutang penjualan mereka langsung dari aplikasi mobile.

---

## 📁 Files Created

### 1. **Models** (Dalam `lib/model/`)

#### `sales_payment_term_model.dart` (NEW)
Model untuk representasi sales payment term dengan relasi ke:
- Sales
- Customer  
- Salesman
- Payment

**Key Features:**
- ✅ Pagination support
- ✅ Status tracking (unpaid, partial, completed)
- ✅ Amount calculations (total, paid, remaining)
- ✅ Payment type (tempo, credit, cash)
- ✅ Helper methods untuk formatting (getStatusLabel, getTypeLabel, getStatusColor)

**Main Classes:**
```dart
class SalesPaymentTermModel {
  List<SalesPaymentTermDataModel> data;
  PaginationModel? pagination;
}

class SalesPaymentTermDataModel {
  String id;
  String salesId;
  String customerId;
  String salesmanId;
  String invoice;
  String customerName;
  String salesmanName;
  String type; // tempo, credit, cash
  String? dueDate;
  double amount;
  double paidAmount;
  double remaining;
  String status; // unpaid, partial, completed
  // ... helper methods
}
```

#### `payment_method_model.dart` (NEW)
Model untuk master data payment methods.

**Key Features:**
- ✅ Pagination support
- ✅ Active status filtering
- ✅ Search by name/code

**Main Classes:**
```dart
class PaymentMethodModel {
  List<PaymentMethodDataModel> data;
  PaginationModel? pagination;
}

class PaymentMethodDataModel {
  String id;
  String code;
  String name;
  int isActive;
  // ... timestamps
}
```

---

### 2. **API Services** (Dalam `lib/api/`)

#### `sales_payment_api.dart` (NEW)
API client untuk mengelola sales payment transactions.

**Methods:**
1. **`getReceivables()`** - GET `/api/sales-payments`
   - Dengan pagination & filtering (customer_id, status, date range)
   - Returns: `SalesPaymentTermModel`

2. **`getReceivablesByCustomer(customerId)`** - GET `/api/sales-payments/by-customer`
   - Get receivables untuk customer tertentu
   - Returns: `List<SalesPaymentTermDataModel>`

3. **`getPaymentMethods()`** - GET `/api/payment-methods`
   - Get master data payment methods dengan pagination
   - Returns: `PaymentMethodModel`

4. **`createPayment()`** - POST `/api/sales-payments`
   - Create payment dengan items allocation
   - Validation: no overpayment, total match
   - Returns: `Map<String, dynamic>` dengan success flag

---

### 3. **Screens** (Dalam `lib/screen/sales_payment/`)

#### `receivables_list_screen.dart` (NEW)
**Halaman: Daftar Piutang** - List semua piutang yang belum lunas

**Features:**
- ✅ **Infinite Scroll Pagination** - Load more saat scroll ke bawah
- ✅ **Filtering:**
  - By Status (Belum Bayar, Sebagian, Lunas)
  - By Date Range (Tanggal Jatuh Tempo)
- ✅ **Search/Filter Debouncing** - Prevent excessive API calls
- ✅ **Refresh** - Pull-to-refresh untuk reload data
- ✅ **Status Badge** - Color-coded status indicators
- ✅ **Currency Formatting** - Formatted dalam IDR
- ✅ **Quick Action Button** - Tombol "+ Pembayaran" untuk buat pembayaran baru

**UI Components:**
```
[AppBar: Daftar Piutang + Button Add]
├── [Filters Section]
│   ├── Status Dropdown
│   ├── Date Range Picker
│   └── [Filter] [Reset] buttons
├── [List Items]
│   ├── Invoice + Status Badge
│   ├── Customer & Type
│   ├── Due Date
│   └── Amount Summary (Total, Paid, Remaining)
└── [Loading Indicator saat infinite scroll]
```

**Key Props:**
```dart
- ScrollController - untuk infinite scroll
- Future<SalesPaymentTermModel?> - untuk API data
- selectedStatus, dueDateFrom, dueDateTo - filter state
```

---

#### `payment_form_screen.dart` (NEW)
**Halaman: Pembayaran Piutang** - Form untuk membuat payment

**Features:**
- ✅ **Step-by-Step Form:**
  1. Informasi Pembayaran (Customer, Payment Date, Method)
  2. Daftar Piutang dengan Allocation
  3. Summary & Notes

- ✅ **Customer Picker Modal** - Search & select customer
- ✅ **Dynamic Receivables Loading** - Auto-load saat customer dipilih
- ✅ **Checkbox Selection** - Select/deselect items
- ✅ **Amount Allocation** - Input nominal per piutang
- ✅ **Validation:**
  - No overpayment check
  - Minimal 1 item dipilih
  - Total amount > 0
  - Total items = total amount

- ✅ **Select All** - Checkbox untuk select semua receivables
- ✅ **Real-time Total Calculation** - Update total saat input berubah
- ✅ **Loading States** - Loading indicator saat submit

**UI Components:**
```
[AppBar: Pembayaran Piutang]
├── [Section 1: Informasi Pembayaran]
│   ├── Customer Picker (Modal)
│   ├── Payment Date (DatePicker)
│   └── Payment Method (Dropdown)
│
├── [Section 2: Daftar Piutang]
│   ├── [Select All Checkbox]
│   └── [For each term]
│       ├── Checkbox + Invoice
│       ├── Amount Info (Total, Paid, Sisa)
│       └── Allocation Input (saat dipilih)
│
├── [Section 3: Ringkasan]
│   ├── Total Pembayaran (Big Text)
│   └── Notes Input (optional)
│
└── [Simpan Pembayaran Button]
```

**Key Props:**
```dart
- selectedCustomer: CustomerDataModel?
- selectedPaymentMethod: PaymentMethodDataModel?
- receivables: List<SalesPaymentTermDataModel>
- allocationAmounts: Map<String, double>
- selectedTerms: Map<String, bool>
- totalAllocation: double
```

---

### 4. **Navigation Integration**

#### Updated `home_screen.dart`
**Imports Added:**
```dart
import 'package:medhuro_mobile/screen/sales_payment/receivables_list_screen.dart';
import 'package:medhuro_mobile/screen/sales_payment/payment_form_screen.dart';
```

**Menu Items Added:**
1. **Daftar Piutang** (Menu Card)
   - Icon: `Icons.account_balance_wallet`
   - Navigate to: `ReceivablesListScreen()`

2. **Bayar Piutang** (Menu Card)
   - Icon: `Icons.payment`
   - Navigate to: `PaymentFormScreen()`

**Navigation Flow:**
```
Home Screen
├── Menu: Daftar Piutang → ReceivablesListScreen
│   └── Button: + Pembayaran → PaymentFormScreen
│
└── Menu: Bayar Piutang → PaymentFormScreen
    └── Modal: Customer Picker
```

---

### 5. **Configuration Updates**

#### `endpoint_config.dart` (UPDATED)
**New Endpoints Added:**
```dart
'payment_methods': '/api/payment-methods',
'sales_payments': '/api/sales-payments',
```

---

## 🔄 Complete User Flow

### Flow 1: View Receivables
```
Home → "Daftar Piutang" Menu
  ↓
Receivables List Screen
  ├── Filter by Status / Date Range
  ├── View all piutang dengan infinite scroll
  └── Button: "+ Pembayaran" → Payment Form
```

### Flow 2: Create Payment (dari Menu Home)
```
Home → "Bayar Piutang" Menu
  ↓
Payment Form Screen
  ├── Pilih Customer (Modal Picker)
  ├── GET /api/sales-payments/by-customer → Load receivables
  ├── Select items & input amount per item
  ├── Select payment method
  ├── Input payment date & note (optional)
  └── Submit → POST /api/sales-payments
       ├── Validation Check
       └── Success/Error Response
```

### Flow 3: Create Payment (dari Receivables List)
```
Receivables List Screen
  └── Button: "+ Pembayaran"
       ↓
Payment Form Screen
       └── (Same as Flow 2)
```

---

## 🎨 UI/UX Highlights

### Color Scheme
- ✅ Primary Color: Dari `PalletConfig.primaryColor`
- ✅ Status Colors:
  - **Belum Bayar** (Unpaid): Red (#EF4444)
  - **Sebagian** (Partial): Yellow (#FACC15)
  - **Lunas** (Completed): Green (#10B981)

### Typography
- ✅ Font sizes sesuai `PalletConfig`
- ✅ Bold untuk headers, Regular untuk content
- ✅ Color-coded amounts (IDR formatting)

### Components Used
- ✅ `TextField` - Input fields
- ✅ `DropdownButtonFormField` - Select dropdowns
- ✅ `CheckboxListTile` - Item selection
- ✅ `Card` - Item containers
- ✅ `ElevatedButton` - Primary actions
- ✅ `CircularProgressIndicator` - Loading states
- ✅ `SnackBar` - Error/success messages
- ✅ `BottomSheet Modal` - Customer picker

---

## 📊 Data Binding & State Management

### Receivables List Screen
```dart
future: Future<SalesPaymentTermModel?>
  ↓
setState() → update data + pagination
  ↓
ListView.separated + RefreshIndicator
  ↓
[Display items with filters applied]
```

### Payment Form Screen
```dart
selectedCustomer → Load receivables
  ↓
receivables list populated
  ↓
selectedTerms + allocationAmounts → Track selections
  ↓
_calculateTotalAllocation() → Update total on change
  ↓
Form Validation + Submit
  ↓
API Response → Show success/error
```

---

## ✅ Testing Checklist

- [ ] **List Screen:**
  - [ ] Load receivables dengan pagination
  - [ ] Filter by status
  - [ ] Filter by date range
  - [ ] Infinite scroll loading more items
  - [ ] Refresh data
  - [ ] Navigate to payment form

- [ ] **Payment Form:**
  - [ ] Customer picker modal works
  - [ ] Receivables load saat customer dipilih
  - [ ] Checkbox selection works
  - [ ] Amount input validation (no overpayment)
  - [ ] Select all / deselect all works
  - [ ] Total calculation updates correctly
  - [ ] Payment method selection works
  - [ ] Date picker for payment date
  - [ ] Form validation (all required fields)
  - [ ] Submit success/error handling

- [ ] **Integration:**
  - [ ] Menu navigation dari home works
  - [ ] Back button behavior
  - [ ] Data refresh after successful payment
  - [ ] Error handling & messages

---

## 🐛 Known Limitations & Future Improvements

### Current Limitations:
1. Payment date validation - currently allows backdate (as per requirement)
2. No image/attachment support for proof of payment
3. No offline support (requires active internet)
4. Single customer per transaction

### Future Enhancements:
1. **Receipt Generation** - PDF receipt export
2. **Payment Verification** - Verify payment with photo
3. **Batch Payments** - Multiple customers in one transaction
4. **Payment Schedules** - Recurring/scheduled payments
5. **Payment Analytics** - Charts & reports
6. **Offline Mode** - Sync when online

---

## 📦 Dependencies Used

- `flutter/material.dart` - UI framework
- `http` - API calls (via shared client in api layer)
- `shared_preferences` - Token storage
- `intl` - Date & currency formatting
- Custom models from project

---

## 🚀 Ready for Testing

All files are created and integrated. The feature is ready for:
1. ✅ Manual testing via Flutter emulator/device
2. ✅ API integration testing (ensure backend endpoints work)
3. ✅ UI/UX validation
4. ✅ Performance optimization (if needed)

---

## 📝 Notes

- Semua currency di-format menggunakan `NumberFormat.currency()` dengan locale `id_ID`
- Status transitions berdampak otomatis di API (SalesPaymentService.php handling)
- Validation dilakukan both di client (Flutter) dan server (PHP)
- Error messages di-display via SnackBar untuk better UX
- Loading states handled dengan CircularProgressIndicator & disabled buttons
