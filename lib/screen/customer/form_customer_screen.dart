import 'package:flutter/material.dart';
import 'package:medhuro_mobile/api/customer_api.dart';
import 'package:medhuro_mobile/model/customer_model.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:medhuro_mobile/widget/form_widget.dart';

class FormCustomerScreen extends StatefulWidget {
  final String? customerId;

  const FormCustomerScreen({
    Key? key,
    this.customerId,
  }) : super(key: key);

  @override
  _FormCustomerScreenState createState() => _FormCustomerScreenState();
}

class _FormCustomerScreenState extends State<FormCustomerScreen> {
  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  bool isLoading = false;
  bool isLoadingDetail = false;
  bool isEditMode = false;
  CustomerDataModel? editingCustomer;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();

    isEditMode = widget.customerId != null;
    if (isEditMode) {
      _loadCustomerDetail();
    }
  }

  void _loadCustomerDetail() async {
    setState(() {
      isLoadingDetail = true;
    });

    final customer = await CustomerApi().getCustomerDetail(widget.customerId!);
    if (customer != null) {
      setState(() {
        editingCustomer = customer;
        codeController.text = customer.code;
        nameController.text = customer.name;
        phoneController.text = customer.phoneNumber;
        addressController.text = customer.address;
        cityController.text = customer.cityName ?? '';
        latitudeController.text = customer.latitude?.toString() ?? '';
        longitudeController.text = customer.longitude?.toString() ?? '';
        isLoadingDetail = false;
      });
    } else {
      setState(() {
        isLoadingDetail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail customer')),
      );
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    // Validate mandatory fields
    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode customer wajib diisi')),
      );
      return;
    }

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama customer wajib diisi')),
      );
      return;
    }

    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon wajib diisi')),
      );
      return;
    }

    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      double? latitude;
      double? longitude;

      if (latitudeController.text.isNotEmpty) {
        latitude = double.tryParse(latitudeController.text);
      }

      if (longitudeController.text.isNotEmpty) {
        longitude = double.tryParse(longitudeController.text);
      }

      CustomerDataModel? result;

      if (isEditMode) {
        // Update customer
        result = await CustomerApi().updateCustomer(
          customerId: widget.customerId!,
          code: codeController.text,
          name: nameController.text,
          phoneNumber: phoneController.text,
          address: addressController.text,
          cityName: cityController.text.isEmpty ? null : cityController.text,
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        // Create new customer
        result = await CustomerApi().createCustomer(
          code: codeController.text,
          name: nameController.text,
          phoneNumber: phoneController.text,
          address: addressController.text,
          cityName: cityController.text.isEmpty ? null : cityController.text,
          latitude: latitude,
          longitude: longitude,
        );
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Customer berhasil diupdate'
                  : 'Customer berhasil ditambahkan',
            ),
            backgroundColor: PalletConfig.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Gagal update customer. Periksa kembali data Anda.'
                  : 'Gagal tambah customer. Periksa kembali data Anda.',
            ),
            backgroundColor: PalletConfig.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: PalletConfig.errorColor,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          isEditMode ? 'Edit Customer' : 'Tambah Customer',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: PalletConfig.primaryColor,
      ),
      body: isLoadingDetail && isEditMode
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(PalletConfig.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code Section
                    Text(
                      'Kode Customer *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: PalletConfig.fontMediumSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormWidget().textInput(
                      controller: codeController,
                      label: 'Kode Customer',
                      hintText: 'contoh: CUST-001',
                    ),
                    const SizedBox(height: 24),

                    // Name Section
                    Text(
                      'Nama Customer *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: PalletConfig.fontMediumSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormWidget().textInput(
                      controller: nameController,
                      label: 'Nama Customer',
                      hintText: 'Toko ABC',
                    ),
                    const SizedBox(height: 24),

                    // Phone Number Section
                    Text(
                      'Nomor Telepon *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: PalletConfig.fontMediumSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormWidget().textInput(
                      controller: phoneController,
                      label: 'Nomor Telepon',
                      hintText: '08123456789',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Address Section
                    Text(
                      'Alamat *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: PalletConfig.fontMediumSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormWidget().textInput(
                      controller: addressController,
                      label: 'Alamat',
                      hintText: 'Jl. Raya No. 123',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // City Section (Optional)
                    // Text(
                    //   'Kota (Opsional)',
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: PalletConfig.fontMediumSize,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // FormWidget().textInput(
                    //   controller: cityController,
                    //   label: 'Kota',
                    //   hintText: 'Jakarta',
                    // ),
                    // const SizedBox(height: 24),

                    // // Latitude Section (Optional)
                    // Text(
                    //   'Latitude (Opsional)',
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: PalletConfig.fontMediumSize,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // FormWidget().textInput(
                    //   controller: latitudeController,
                    //   label: 'Latitude',
                    //   hintText: '-6.2088',
                    //   keyboardType:
                    //       TextInputType.numberWithOptions(decimal: true),
                    // ),
                    // const SizedBox(height: 24),

                    // // Longitude Section (Optional)
                    // Text(
                    //   'Longitude (Opsional)',
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: PalletConfig.fontMediumSize,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // FormWidget().textInput(
                    //   controller: longitudeController,
                    //   label: 'Longitude',
                    //   hintText: '106.8456',
                    //   keyboardType:
                    //       TextInputType.numberWithOptions(decimal: true),
                    // ),
                    const SizedBox(height: 32),

                    // Submit Button
                    FormWidget().button(
                      icon: isEditMode ? Icons.edit : Icons.add,
                      label: isEditMode ? 'Update Customer' : 'Tambah Customer',
                      callBack: isLoading ? () {} : _handleSubmit,
                      showLoader: isLoading,
                      backgroundColor: PalletConfig.primaryColor,
                    ),
                    const SizedBox(height: 20),

                    // Cancel Button
                    FormWidget().button(
                      icon: Icons.close,
                      label: 'Batal',
                      callBack:
                          isLoading ? () {} : () => Navigator.pop(context),
                      backgroundColor: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
