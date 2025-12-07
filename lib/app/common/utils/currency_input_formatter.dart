import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class CurrencyInputFormatter extends TextInputFormatter {
  final _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

   
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

  
    final formatted = _formatter.format(number);

    
    int cursorPosition = formatted.length;
   
    if (newValue.text.length > oldValue.text.length) {
 
      cursorPosition = formatted.length;
    } else {
      
      final oldDigitCount = oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length;
      final newDigitCount = digitsOnly.length;
      final digitDiff = oldDigitCount - newDigitCount;
      
      
      if (digitDiff > 0) {
        
        cursorPosition = newValue.selection.baseOffset;
      } else {
        cursorPosition = formatted.length;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

