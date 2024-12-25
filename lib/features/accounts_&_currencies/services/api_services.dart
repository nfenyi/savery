import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/main.dart';

import 'api_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.xchangeApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json",
    ));
  }

  // For testing purposes, allow overriding the dio instance
  void setDio(Dio dioInstance) {
    dio = dioInstance;
  }
}

class RequestResponse {
  late Enum status;
  dynamic payload;

  RequestResponse({required this.status, this.payload});

  @override
  String toString() {
    return "Status: $status \nContent: $payload";
  }
}

class ApiServices {
  final appStatebox = Hive.box(AppBoxes.appState);
  final Dio dio = DioClient().dio;

  // Future<RequestResponse> fetchExchangeRates() async {
  //   final connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult.any(
  //     (result) =>
  //         result == ConnectivityResult.mobile ||
  //         result == ConnectivityResult.wifi ||
  //         result == ConnectivityResult.vpn,
  //   )) {
  //     try {
  //       String token = appStatebox.get(
  //         'ratesAccessKey',
  //       );
  //       Map<String, dynamic> params = {
  //         "base": "GHS",
  //       };
  //       if (token.isEmpty) {
  //         return RequestResponse(
  //           status: RequestStatus.other,
  //         );
  //       } else {
  //         Response response = await dio.get(
  //           '${ApiConstants.xchangeApiBaseUrl}${ApiConstants.latest}',
  //           queryParameters: params,
  //           options: Options(
  //             headers: {
  //               "api-key": token,
  //             },
  //           ),
  //         );

  //         return RequestResponse(
  //           status: RequestStatus.success,
  //           payload: response.data,
  //         );
  //       }
  //     } on DioException catch (exception) {
  //       if (exception.type == DioExceptionType.connectionTimeout ||
  //           exception.type == DioExceptionType.receiveTimeout ||
  //           exception.type == DioExceptionType.sendTimeout ||
  //           exception.type == DioExceptionType.connectionError) {
  //         return RequestResponse(
  //           status: RequestStatus.connectionTimedOut,
  //           payload:
  //               'Connection timed out. Reason: Weak Connection or No Data. Check connection and try again.',
  //         );
  //       }

  //       if (exception.type == DioExceptionType.unknown) {
  //         return RequestResponse(
  //           status: RequestStatus.other,
  //           payload: exception.error.toString(),
  //         );
  //       }

  //       if (exception.response!.statusCode! > 500) {
  //         // service unavailable
  //         return RequestResponse(
  //           status: RequestStatus.other,
  //           payload:
  //               'Service temporarily unavailable. Please try again in a few minutes.',
  //         );
  //       }
  //       return RequestResponse(
  //         status: RequestStatus.other,
  //         payload: exception.response!.data['message'],
  //       );
  //     }
  //   } else {
  //     return RequestResponse(
  //       status: RequestStatus.socketException,
  //       payload: 'No internet connection detected. Turn on your data/wifi.',
  //     );
  //   }
  // }

  Future<RequestResponse> fetchExchangeRates() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.vpn,
    )) {
      try {
        Response response = await dio.get(
          '${ApiConstants.tradingEconomicsBaseUrl}${ApiConstants.ghCurrencyConversions}',
        );

        return RequestResponse(
          status: RequestStatus.success,
          payload: response.data,
        );
      } on DioException catch (exception) {
        if (exception.type == DioExceptionType.connectionTimeout ||
            exception.type == DioExceptionType.receiveTimeout ||
            exception.type == DioExceptionType.sendTimeout ||
            exception.type == DioExceptionType.connectionError) {
          return RequestResponse(
            status: RequestStatus.connectionTimedOut,
            payload:
                navigatorKey.currentContext!.localizations.connection_timeout,
            // 'Connection timed out. Reason: Weak Connection or No Data. Check connection and try again.',
          );
        }

        if (exception.type == DioExceptionType.unknown) {
          return RequestResponse(
            status: RequestStatus.other,
            payload: exception.error.toString(),
          );
        }

        if (exception.response!.statusCode! > 500) {
          // service unavailable
          return RequestResponse(
            status: RequestStatus.other,
            payload: navigatorKey
                .currentContext!.localizations.service_temp_unavailable,
            // 'Service temporarily unavailable. Please try again in a few minutes.',
          );
        }
        return RequestResponse(
          status: RequestStatus.other,
          payload: exception.response!.data['message'],
        );
      }
    } else {
      return RequestResponse(
        status: RequestStatus.socketException,
        payload:
            navigatorKey.currentContext!.localizations.no_internet_connection,
        // 'No internet connection detected. Turn on your data/wifi.',
      );
    }
  }
}
