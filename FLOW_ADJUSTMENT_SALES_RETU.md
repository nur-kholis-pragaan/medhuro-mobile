Kamu adalah Flutter developer.

Saya sedang membangun fitur **Create Sales + Return (Mobile Sales App)**.

Gunakan:

* HTTP client: http
* State management: Provider
* Fokus: UI/UX mobile yang cepat (lapangan)

==================================================
KONSEP UTAMA
============

* Sales dan Return dalam 1 flow (wizard)
* Return bersifat optional
* Harga default dari product, tapi editable
* Input harus cepat (minim klik)

==================================================
FLOW HALAMAN (WIZARD)
=====================

1. Step 1 → Header
2. Step 2 → Sales Items
3. Step 3 → Return Items (optional)
4. Step 4 → Konfirmasi & Submit

==================================================
PAYLOAD API (WAJIB DIIKUTI)
===========================

POST /api/sales

{
"customer_id": 2,
"sales_date": "2026-07-20",
"payment_term_id": 2,
"discount_amount": 0,
"cash_amount": 0,
"items": [
{
"product_id": 1,
"unit": "pack",
"qty": 20,
"discount_amount": 0,
"price": 50000
}
],
"return_items": [
{
"product_id": 2,
"unit": "pack",
"qty": 5,
"discount_amount": 0,
"price": 10000
}
]
}


GET /api/product
{
    "success": true,
    "code": 200,
    "message": "success",
    "data": [
        {
            "id": 1,
            "name": "Dove Shampoo 200ml",
            "code": "010101",
            "selling_price_carton": 240000,
            "selling_price_pack": 80000,
            "selling_price_pcs": 26667,
            "created_at": "2026-04-30T01:27:24.000000Z",
            "updated_at": "2026-04-30T01:27:24.000000Z"
        },
        {
            "id": 2,
            "name": "Lipton Tea Premium 100g",
            "code": "010201",
            "selling_price_carton": 320000,
            "selling_price_pack": 32000,
            "selling_price_pcs": 3200,
            "created_at": "2026-04-30T01:27:24.000000Z",
            "updated_at": "2026-04-30T01:27:24.000000Z"
        }
    ],
    "pagination": {
        "per_page": 10,
        "total_data": 2,
        "total_page": 1,
        "current_page": 1
    },
    "query": []
}



==================================================
STEP 2: SALES ITEMS (UI WAJIB)
==============================

Tampilan list item:

┌──────────────────────────────┐
│ Dove Shampoo 200ml           │
│ Kode: 010101                 │
│                              │
│ [ Carton ] [ Pack ] [ Pcs ]  │
│                              │
│ Qty:   [ - ]  5  [ + ]       │
│                              │
│ Harga: [ 50.000 ] ✏️         │
│ Diskon: [ 0 ]                │
│                              │
│ Subtotal: 250.000            │
│                              │
│                    [ Hapus ] │
└──────────────────────────────┘

Behavior:

* Unit selector (chip, bukan dropdown)
* Qty pakai tombol + / -
* Harga editable
* Ganti unit → reset harga ke default unit
* Subtotal realtime

---

Sticky Summary:

┌──────────────────────────────┐
│ Total: 560.000               │
│ Item: 3                      │
│                    [ Lanjut ]│
└──────────────────────────────┘

---

Button:

[ + Tambah Produk ]

→ buka Product Picker

==================================================
PRODUCT PICKER SCREEN (WAJIB)
=============================

UI:

┌──────────────────────────────┐
│ 🔍 Cari produk...            │
├──────────────────────────────┤
│ Dove Shampoo 200ml           │
│ Harga: 50.000                │
│ [ - ] 0 [ + ]                │
├──────────────────────────────┤
│ Sunsilk 170ml                │
│ Harga: 25.000                │
│ [ - ] 0 [ + ]                │
├──────────────────────────────┤
│ ...                          │
└──────────────────────────────┘

Behavior:

* Tap + → langsung add ke Provider
* Tidak pakai modal
* Jika item sudah ada → qty bertambah
* Search realtime

Bottom:

┌──────────────────────────────┐
│ 3 item dipilih               │
│           [ Selesai ]        │
└──────────────────────────────┘

==================================================
STEP 3: RETURN ITEMS
====================

Mirip Sales Items, tapi:

* Label: "Retur (Opsional)"
* Warna berbeda (warning tone)
* Data masuk ke returnItems

UI sama seperti sales item

==================================================
STEP 4: KONFIRMASI
==================

Tampilkan:

Customer
Tanggal

--- Sales Items ---
(list)

--- Return Items ---
(list)

--- Summary ---

Total Sales: xxx
Total Return: xxx

Cash Input:
[ 80.000 ]

Sisa Hutang:
xxx

---

Button:

[ Simpan Penjualan ]

==================================================
RULE UX PENTING
===============

* Tidak boleh banyak modal
* Semua inline editing
* Minim klik
* Fokus ke kecepatan input

==================================================
STATE MANAGEMENT (PROVIDER)
===========================

SalesProvider:

State:

* List<SalesItem> items
* List<ReturnItem> returnItems
* double cashAmount

Function:

* addItem()

* updateItem()

* removeItem()

* addReturnItem()

* updateReturnItem()

* removeReturnItem()

* setCash()

Getter:

* totalSales
* totalReturn
* netPayment
* remainingAmount

==================================================
BEHAVIOR PENTING
================

* Unit menentukan default harga
* Harga bisa di-edit
* Ganti unit → reset harga ke default
* Return tidak mengurangi sales, hanya mempengaruhi pembayaran

==================================================
OUTPUT YANG DIHARAPKAN
======================

* Struktur folder feature-based
* Provider
* Model
* Screen UI
* Widget reusable:

  * ProductItemCard
  * QtyControl
  * UnitSelector
  * PriceInput
  * SummaryBar

==================================================
KESIMPULAN
==========

* UX harus cepat seperti POS
* Product picker adalah kunci
* Sales & return dalam 1 flow
* Provider sebagai sumber state utama

==================================================
