# API Documentation - Receivables & Customer Management

Dokumentasi lengkap untuk API endpoint baru yang menangani Customer dan Receivables Management.

## Overview

Berikut adalah perubahan dan penambahan yang dilakukan:

1. **Login Validation** - Login API sekarang hanya untuk salesman
2. **Customer Management** - Endpoint baru untuk menambah customer
3. **Receivables Summary** - Melihat total piutang per customer
4. **Receivables Detail** - Melihat detail piutang per customer

## 1. Authentication - Login (Modified)

### Endpoint: POST /api/auth/login

**Description**: Login untuk user yang memiliki role salesman. User tanpa salesman profile tidak bisa login.

**Request Body**:
```json
{
  "email": "salesman@example.com",
  "password": "password123"
}
```

**Response (Success - 200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "Login berhasil",
  "data": {
    "id": "uuid",
    "name": "John Doe",
    "email": "salesman@example.com",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  },
  "token": "1|abc123..."
}
```

**Response (Error - 401)**:
```json
{
  "success": false,
  "code": 401,
  "message": "User tidak memiliki akses sebagai salesman",
  "data": null
}
```

---

## 2. Customer Management

### 2.1 Get All Customers

**Endpoint**: GET /api/customers

**Description**: Mendapatkan list customer (public endpoint)

**Query Parameters**:
- `limit` (int, optional): Jumlah data per halaman, default 10
- `sort_by` (string, optional): Field untuk sorting, default 'created_at'
- `sort` (string, optional): 'asc' atau 'desc', default 'desc'
- `search` (string, optional): Search berdasarkan nama, kode, atau nomor telepon

**Example Request**:
```
GET /api/customers?limit=10&sort_by=name&sort=asc&search=toko
```

**Response (200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "uuid",
      "code": "CUST-001",
      "name": "Toko ABC",
      "phone_number": "081234567890",
      "address": "Jl. Merdeka No. 123",
      "city_name": "Jakarta",
      "latitude": -6.200000,
      "longitude": 106.816666,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-01T00:00:00.000000Z"
    }
  ],
  "pagination": {
    "per_page": 10,
    "total_data": 50,
    "total_page": 5,
    "current_page": 1
  },
  "query": {
    "limit": "10",
    "sort_by": "name",
    "sort": "asc",
    "search": "toko"
  }
}
```

---

### 2.2 Get Customer Detail

**Endpoint**: GET /api/customers/{customer_id}

**Description**: Mendapatkan detail customer spesifik (public endpoint)

**Path Parameters**:
- `customer_id` (uuid): ID customer

**Example Request**:
```
GET /api/customers/550e8400-e29b-41d4-a716-446655440000
```

**Response (200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "code": "CUST-001",
    "name": "Toko ABC",
    "phone_number": "081234567890",
    "address": "Jl. Merdeka No. 123",
    "city_name": "Jakarta",
    "latitude": -6.200000,
    "longitude": 106.816666,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 2.3 Add New Customer

**Endpoint**: POST /api/customers

**Description**: Menambahkan customer baru. Memerlukan authentication.

**Authentication**: Required (Bearer Token)

**Request Headers**:
```
Authorization: Bearer {TOKEN}
Content-Type: application/json
```

**Request Body**:
```json
{
  "code": "CUST-002",
  "name": "Toko XYZ",
  "phone_number": "081234567890",
  "address": "Jl. Sudirman No. 456",
  "city_name": "Bandung",
  "latitude": -6.914744,
  "longitude": 107.609810,
  "is_active": true
}
```

**Field Requirements**:
- `name` (string, required): Nama customer, max 255 characters
- `phone_number` (string, required): Nomor telepon, max 20 characters
- `address` (string, required): Alamat customer, max 500 characters
- `code` (string, optional): Kode customer, max 50 characters, harus unik jika diisi
- `city_name` (string, optional): Nama kota, max 100 characters
- `latitude` (numeric, optional): Latitude untuk map
- `longitude` (numeric, optional): Longitude untuk map
- `is_active` (boolean, optional): Status customer, default true

**Response (Success - 201)**:
```json
{
  "success": true,
  "code": 201,
  "message": "Customer berhasil ditambahkan",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "code": "CUST-002",
    "name": "Toko XYZ",
    "phone_number": "081234567890",
    "address": "Jl. Sudirman No. 456",
    "city_name": "Bandung",
    "latitude": -6.914744,
    "longitude": 107.609810,
    "is_active": true,
    "created_at": "2024-05-05T10:30:00.000000Z",
    "updated_at": "2024-05-05T10:30:00.000000Z"
  }
}
```

**Response (Error - 422)**:
```json
{
  "success": false,
  "code": 422,
  "message": "Nama customer wajib diisi",
  "data": null
}
```

---

### 2.4 Update Customer

**Endpoint**: PUT /api/customers/{customer_id}

**Description**: Memperbarui data customer yang sudah ada. Memerlukan authentication.

**Authentication**: Required (Bearer Token)

**Request Headers**:
```
Authorization: Bearer {TOKEN}
Content-Type: application/json
```

**Path Parameters**:
- `customer_id` (uuid): ID customer yang akan diupdate

**Request Body**:
```json
{
  "code": "CUST-002-UPDATED",
  "name": "Toko XYZ Updated",
  "phone_number": "081234567890",
  "address": "Jl. Sudirman No. 456",
  "city_name": "Bandung",
  "latitude": -6.914744,
  "longitude": 107.609810,
  "is_active": true
}
```

**Field Requirements** (sama seperti POST):
- `name` (string, required): Nama customer, max 255 characters
- `phone_number` (string, required): Nomor telepon, max 20 characters
- `address` (string, required): Alamat customer, max 500 characters
- `code` (string, required): Kode customer, max 50 characters, harus unik
- `city_name` (string, optional): Nama kota, max 100 characters
- `latitude` (numeric, optional): Latitude untuk map
- `longitude` (numeric, optional): Longitude untuk map
- `is_active` (boolean, optional): Status customer

**Response (Success - 200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "Customer berhasil diperbarui",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "code": "CUST-002-UPDATED",
    "name": "Toko XYZ Updated",
    "phone_number": "081234567890",
    "address": "Jl. Sudirman No. 456",
    "city_name": "Bandung",
    "latitude": -6.914744,
    "longitude": 107.609810,
    "is_active": true,
    "created_at": "2024-05-05T10:30:00.000000Z",
    "updated_at": "2024-05-06T14:45:00.000000Z"
  }
}
```

**Response (Error - 404)**:
```json
{
  "success": false,
  "code": 404,
  "message": "Customer tidak ditemukan",
  "data": null
}
```

**Response (Error - 422)**:
```json
{
  "success": false,
  "code": 422,
  "message": "Kode sudah terdaftar",
  "data": null
}
```

---

## 3. Receivables Management

### 3.1 Get Receivables Summary

**Endpoint**: GET /api/receivables/summary

**Description**: Mendapatkan ringkasan piutang untuk semua customer berdasarkan sales dengan status 'posted' atau 'partial'.

**Authentication**: Required (Bearer Token)

**Request Headers**:
```
Authorization: Bearer {TOKEN}
Accept: application/json
```

**Query Parameters**:
- `limit` (int, optional): Jumlah data per halaman, default 15
- `sort_by` (string, optional): Field untuk sorting, default 'total_debt'
- `sort` (string, optional): 'asc' atau 'desc', default 'desc'
- `search` (string, optional): Search berdasarkan nama, kode, atau nomor telepon customer

**Example Request**:
```
GET /api/receivables/summary?limit=15&sort_by=total_debt&sort=desc&search=toko
```

**Response (200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "code": "CUST-001",
      "name": "Toko ABC",
      "phone_number": "081234567890",
      "address": "Jl. Merdeka No. 123",
      "city_name": "Jakarta",
      "total_debt": 3000000,
      "created_at": "2024-01-01T00:00:00.000000Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "code": "CUST-002",
      "name": "Toko XYZ",
      "phone_number": "089876543210",
      "address": "Jl. Sudirman No. 456",
      "city_name": "Bandung",
      "total_debt": 1500000,
      "created_at": "2024-01-02T00:00:00.000000Z"
    }
  ],
  "pagination": {
    "per_page": 15,
    "total_data": 2,
    "total_page": 1,
    "current_page": 1
  },
  "query": {
    "limit": "15",
    "sort_by": "total_debt",
    "sort": "desc",
    "search": "toko"
  }
}
```

**Notes**:
- `total_debt` = SUM(total_amount - paid_amount) dari sales dengan status 'posted' atau 'partial'
- Hanya customer yang memiliki hutang (total_debt > 0) yang ditampilkan
- Status sales: 'posted' (belum bayar), 'partial' (bayar sebagian)

---

### 3.2 Get Receivables Detail by Customer

**Endpoint**: GET /api/receivables/{customer_id}

**Description**: Mendapatkan detail piutang untuk customer spesifik dengan semua invoice/payment terms.

**Authentication**: Required (Bearer Token)

**Request Headers**:
```
Authorization: Bearer {TOKEN}
Accept: application/json
```

**Path Parameters**:
- `customer_id` (uuid): ID customer

**Query Parameters**:
- `limit` (int, optional): Jumlah data per halaman, default 20
- `sort_by` (string, optional): Field untuk sorting, default 'spt.due_date'
- `sort` (string, optional): 'asc' atau 'desc', default 'asc'
- `status` (string, optional): Filter berdasarkan status - 'pending', 'partial', 'completed'

**Example Request**:
```
GET /api/receivables/550e8400-e29b-41d4-a716-446655440000?limit=20&sort_by=spt.due_date&sort=asc
```

**Response (200)**:
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "payment-term-uuid-1",
      "customer": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "code": "CUST-001",
        "name": "Toko ABC",
        "phone_number": "081234567890",
        "address": "Jl. Merdeka No. 123"
      },
      "sales_id": "sales-uuid-1",
      "sales_date": "2024-04-01",
      "payment_term": "Cicilan 3x",
      "payment_type": "credit",
      "total_amount": 1500000,
      "paid_amount": 500000,
      "outstanding_amount": 1000000,
      "due_date": "2024-05-01",
      "status": "partial",
      "created_at": "2024-04-01T00:00:00.000000Z",
      "updated_at": "2024-04-15T00:00:00.000000Z"
    },
    {
      "id": "payment-term-uuid-2",
      "customer": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "code": "CUST-001",
        "name": "Toko ABC",
        "phone_number": "081234567890",
        "address": "Jl. Merdeka No. 123"
      },
      "sales_id": "sales-uuid-2",
      "sales_date": "2024-04-05",
      "payment_term": "Cicilan 2x",
      "payment_type": "credit",
      "total_amount": 3500000,
      "paid_amount": 0,
      "outstanding_amount": 3500000,
      "due_date": "2024-05-05",
      "status": "pending",
      "created_at": "2024-04-05T00:00:00.000000Z",
      "updated_at": "2024-04-05T00:00:00.000000Z"
    }
  ],
  "pagination": {
    "per_page": 20,
    "total_data": 2,
    "total_page": 1,
    "current_page": 1
  },
  "query": {
    "limit": "20",
    "sort_by": "spt.due_date",
    "sort": "asc"
  },
  "customer": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "code": "CUST-001",
    "name": "Toko ABC",
    "phone_number": "081234567890",
    "address": "Jl. Merdeka No. 123"
  }
}
```

**Response (Error - 404)**:
```json
{
  "success": false,
  "code": 404,
  "message": "Customer tidak ditemukan",
  "data": null
}
```

---

## Error Responses

Semua endpoint mengikuti format response yang konsisten menggunakan ResponderHelper:

### Validation Error (422)
```json
{
  "success": false,
  "code": 422,
  "message": "Validation error message",
  "data": null
}
```

### Unauthorized (401)
```json
{
  "success": false,
  "code": 401,
  "message": "User tidak terautentikasi",
  "data": null
}
```

### Server Error (500)
```json
{
  "success": false,
  "code": 500,
  "message": "Terjadi kesalahan",
  "data": null
}
```

---

## Implementation Details

### Modified Files
1. **AuthController.php** - Menambahkan validasi salesman pada login
2. **CustomerRequest.php** - Updated untuk require phone_number dan address
3. **CustomerController.php** - Menambahkan method store() untuk POST

### New Files
1. **ReceivableController.php** - Controller baru untuk receivables management
2. **ReceivableSummaryResource.php** - Resource untuk receivables summary
3. **ReceivableDetailResource.php** - Resource untuk receivables detail

### Updated Files
1. **routes/api.php** - Menambahkan route baru untuk customers dan receivables

---

## Testing with Postman

Gunakan file `POSTMAN_COLLECTION.json` yang disediakan untuk import collection ke Postman.

**Langkah-langkah**:
1. Buka Postman
2. Click "Import" → "Upload Files"
3. Select file `POSTMAN_COLLECTION.json`
4. Collection akan di-import dengan semua request

**Setup Variables**:
- `BASE_URL`: Sesuaikan dengan base URL API (default: http://localhost:8000)
- `TOKEN`: Isi dengan token setelah login
- `CUSTOMER_ID`: Isi dengan ID customer untuk testing detail endpoint
- `PRODUCT_ID`: Isi dengan ID product untuk testing sales endpoint
- `PAYMENT_TERM_ID`: Isi dengan ID payment term untuk testing sales endpoint

---

## Notes

- Semua endpoint yang butuh authentication harus include header: `Authorization: Bearer {TOKEN}`
- Response format konsisten menggunakan ResponderHelper
- Pagination info tersedia di setiap list endpoint
- Error messages dalam Bahasa Indonesia untuk user experience yang lebih baik
