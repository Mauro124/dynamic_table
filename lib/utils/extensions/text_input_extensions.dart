import 'package:flutter/services.dart';

extension TextInputFormatterExtension on TextInputFormatter {
  static FilteringTextInputFormatter get digitsOnlyWithDecimal =>
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));
}

class PhoneTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    final StringBuffer newTextBuffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (newValue.text.length > 11) {
        return oldValue;
      }
      if (RegExp(r'^[\d\-\+]{0,11}$').hasMatch(newText[i])) {
        newTextBuffer.write(newText[i]);
      }
    }
    return TextEditingValue(
      text: newTextBuffer.toString(),
      selection: TextSelection.collapsed(offset: newTextBuffer.length),
    );
  }
}

class CustomDateFormatter extends TextInputFormatter {
  final RegExp _regex = RegExp(r'^\d{0,2}(\/\d{0,2})?(\/\d{0,4})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Si el nuevo valor cumple con la expresión regular, lo permitimos
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    // De lo contrario, devolvemos el texto anterior
    return oldValue;
  }
}

class CustomTimeFormatter extends TextInputFormatter {
  final RegExp _regex = RegExp(r'^\d{0,2}(\:\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Si el nuevo valor cumple con la expresión regular, lo permitimos
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    // De lo contrario, devolvemos el texto anterior
    return oldValue;
  }
}
