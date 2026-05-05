import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/config/pallet_config.dart';

enum ButtonSize { small, medium }

class FormWidget {
  Widget textFormField({
    required TextEditingController controller,
    required String label,
    required TextInputType type,
    int? maxLength,
    bool? disable,
    IconData? icon,
    bool? obscureText,
    Function? onTap,
    bool? idrValue, 
    bool? textCapital,
    String? hintText,
    int? maxLines,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        color: disable == true ? Colors.grey[300] : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          onTap!();
        },
        child: TextFormField(
          maxLines: maxLines != null ? maxLines : 1,
          style: TextStyle(color: Colors.black87),
          enabled: onTap == null ? true : false,
          readOnly: disable == null ? false : true,
          keyboardType: type,
          controller: controller,
          obscureText: obscureText == null ? false : true,
          textCapitalization: textCapital == null
              ? TextCapitalization.words
              : TextCapitalization.none,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.black87),
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
              borderSide:
                  BorderSide(color: PalletConfig.primaryColor, width: 2.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
              borderSide: BorderSide(color: PalletConfig.shadePrimaryColor),
            ),
            labelText: label,
            hintText: hintText ?? null,
            labelStyle: TextStyle(
              fontSize: PalletConfig.fontMediumSize,
              color: Colors.black87,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: Colors.black87,
                    size: PalletConfig.fontMediumSize,
                  )
                : null,
            suffixIcon: onTap == null
                ? null
                : Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black87,
                    size: PalletConfig.fontMediumSize,
                  ),
          ),
          maxLength: maxLength,
          inputFormatters: idrValue == null
              ? null
              : [
                  // WhitelistingTextInputFormatter.digitsOnly,
                  CurrencyPtBrInputFormatter(),
                ],
          validator: (String? value) {
            if (value!.isEmpty) {
              return label + ' Harus Diisi';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget button({
    required String label,
    required Function callBack,
    required bool showLoader,
    Color? buttonColor,
    Color? textColorColor,
    IconData? icon,
    ButtonSize? buttonSize,
    double? width,
  }) {
    return SizedBox(
      width: buttonSize == null ? double.infinity : width,
      height: buttonSize == null ? 50.0 : 30.0,
      child: ElevatedButton(
        onPressed: () {
          callBack();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? PalletConfig.primaryColor,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
          ),
        ),
        // elevation: 1.0,
        // color: buttonColor == null ? PalletConfig.primaryColor : buttonColor,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(PalletConfig.borderRadius),
        // ),
        child: showLoader
            ? SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: icon == null
                          ? SizedBox()
                          : Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                icon,
                                size: buttonSize == ButtonSize.medium ||
                                        buttonSize == null
                                    ? PalletConfig.fontMediumSize
                                    : PalletConfig.fontSmallSize,
                                color: textColorColor == null
                                    ? Colors.white
                                    : textColorColor,
                              ),
                            ),
                    ),
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: buttonSize == ButtonSize.medium ||
                                buttonSize == null
                            ? PalletConfig.fontMediumSize
                            : PalletConfig.fontSmallSize,
                        color: textColorColor == null
                            ? Colors.white
                            : textColorColor,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CurrencyPtBrInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    double value = double.parse(newValue.text);
    String newText =
        NumberFormat.simpleCurrency(locale: "IDR", decimalDigits: 0)
            .format(value);
    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
