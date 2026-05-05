Kamu adalah Flutter developer.

Saya sedang membangun aplikasi Android untuk salesman menggunakan Flutter 3.3.

CATATAN:

* Login dan Product List SUDAH SELESAI → TIDAK PERLU DIBUAT LAGI
* Gunakan HTTP client: http
* Gunakan Provider untuk cart
* SharedPreferences hanya untuk token (sudah ada)

Gunakan pendekatan:

* menu
* user story
* data flow

==================================================
STRUKTUR MENU
=============

Bottom Navigation:

* Home
* Products (SUDAH ADA)
* Create Sales
* My Sales
* Receivables

==================================================
KONSEP UTAMA (WAJIB)
====================

* Cart disimpan di Provider (bukan local storage)
* Input qty menggunakan:

  * unit (carton / pack / pcs)
  * qty
* Satu produk bisa memiliki multiple unit input
* Setelah submit sukses → cart di-clear

==================================================
USER STORY
==========

1. Create Sales

Sebagai salesman:

* Saya menambahkan produk ke cart dari halaman product list
* Saya memilih unit (carton / pack / pcs)
* Saya menginput qty
* Saya bisa menambahkan beberapa unit untuk produk yang sama
* Saya melihat mini cart di bawah layar
* Saya membuka halaman cart
* Saya memilih customer
* Saya memilih payment terms
* Saya lanjut ke halaman konfirmasi
* Saya submit transaksi

==================================================

2. My Sales

Sebagai salesman:

* Saya melihat daftar penjualan saya
* Saya melihat detail transaksi
* Saya melihat item dan payment terms

==================================================

3. Receivables

Sebagai salesman:

* Saya melihat daftar piutang saya

==================================================
DATA FLOW
=========

CART (PROVIDER)

* add item → masuk ke provider
* update qty → update provider
* remove item → update provider
* hitung total → dari provider

==================================================

CREATE SALES

Ambil data dari provider:

Body request:

{
"customer_id": int,
"payment_term_id": int,
"sales_date": "YYYY-MM-DD",
"discount_amount": 0,
"items": [
{
"product_id": int,
"unit": "carton|pack|pcs",
"qty": int,
"price": number,
"discount_amount": 0
}
]
}

Flow:

* user klik submit
* POST /api/sales
* jika sukses:

  * clear provider
  * redirect ke success / my sales

==================================================

LOAD MY SALES

* GET /api/my-sales
* parse response:

{
success,
data: [ ... ],
pagination
}

==================================================

# MODEL RESPONSE (WAJIB HANDLE)

Sales:

* id
* invoice_number
* customer.name
* salesman.name
* sales_date
* total_amount
* status

SalesItem:

* product.name
* qty_carton
* price
* subtotal

PaymentTerm:

* name
* type
* amount
* remaining_amount
* status

==================================================
UX ADD TO CART (WAJIB DIIKUTI)
==============================

1. Product List (SUDAH ADA, TINGGAL EXTEND)

Tambahkan:

Per produk:

[ Nama Produk ]

[ Unit Dropdown ]
(carton / pack / pcs)

[ - ] [ qty ] [ + ]

[ Tambah ke Cart ]

Behavior:

* user pilih unit
* klik + / - untuk qty
* klik tambah → masuk provider

==================================================

2. Mini Cart (Sticky Bottom)

Tampilkan:

Cart (x item) | Total: xxx | [ Lihat Cart ]

Behavior:

* selalu tampil
* klik → buka Cart Page

==================================================

3. Cart Page

Tampilkan:

Customer: [ pilih ]

List Item:

* Produk A
  Unit: carton / pack / pcs
  Qty editable
  [ Hapus ]

* Produk B
  ...

Total: xxx

[ Lanjutkan ]

==================================================

4. Confirmation Page

Tampilkan:

* Customer
* Tanggal
* Payment Terms
* List item
* Total

Button:
[ Submit Sales ]

==================================================
PROVIDER (WAJIB)
================

SalesProvider:

State:

* List<SalesItem> items

Function:

* addItem(product, unit, qty, price)
* updateItem(index, unit, qty)
* removeItem(index)
* clear()

Getter:

* totalAmount
* totalItems

==================================================
MODEL (WAJIB)
=============

SalesItem:

* product_id
* name
* unit
* qty
* price
* discount_amount

NOTE:

* Tidak perlu qty_carton/pack/pcs di frontend
* Backend yang handle konversi

==================================================
UI YANG DIBUTUHKAN
==================

1. Create Sales Flow:

* Product List (extend)
* Cart Page
* Confirmation Page

2. My Sales Screen:

* list sales
* klik → detail

3. Sales Detail Screen:

* header (customer, tanggal, status)
* list item
* payment terms

4. Receivables Screen:

* list piutang

==================================================
VALIDATION
==========

* tidak boleh submit jika cart kosong
* qty harus > 0
* unit wajib dipilih
* handle error API
* tampilkan loading

==================================================
OUTPUT
======

* struktur folder feature-based
* provider untuk cart
* service API (http)
* parsing JSON response
* UI sederhana dan clean

==================================================
KESIMPULAN
==========

* Fokus hanya ke Create Sales, My Sales, Receivables
* Cart menggunakan Provider
* Input menggunakan unit + qty
* Backend handle konversi ke carton/pack/pcs
* UX harus cepat dan minim klik

==================================================
