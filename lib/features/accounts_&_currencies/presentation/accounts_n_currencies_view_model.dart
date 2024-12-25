// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:html/dom.dart' as dom;

// import '../../../utils/view_model_result.dart';
// import '../services/api_services.dart';

// class AccountsnCurrenciesViewModel extends ChangeNotifier {
//   Future<Result> getCurrencies() async {
//     dynamic response;
//     try {
//       response = await ApiServices().fetchExchangeRates();
//       dom.Document html = dom.Document.html(response.payload);

//       final rates = html
//           .querySelectorAll('#p')
//           .map((element) => element.innerHtml.trim())
//           .toList();
//       return Result.ok(rates.take(3));
//     } on Exception catch (_) {
//       return Result.error(response.payload);
//     }
//   }
// }

// final accountsnCurrenciesViewModel =
//     ChangeNotifierProvider<AccountsnCurrenciesViewModel>((ref) {
//   return AccountsnCurrenciesViewModel();
// });

// class CurrencyState {
//   final bool running = false;

// }
