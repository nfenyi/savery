import 'package:date_time_format/date_time_format.dart';
import 'package:savery/app_constants/app_constants.dart';

class AppFunctions {
  static String formatDate(String date, {String format = 'd/m/Y'}) {
    return date == AppConstants.na || date == 'null' || date.isEmpty
        ? AppConstants.na
        : date == '--'
            ? '--'
            : DateTimeFormat.format(DateTime.parse(date), format: format);
  }
}
