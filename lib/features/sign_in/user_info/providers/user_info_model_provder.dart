import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/constants.dart';
import '../../constants/firebase_collection_name.dart';
import '../models/user_info_model.dart';

final userInfoModelProvider = StreamProvider.family
    .autoDispose<UserInfoModel, String>((ref, String userId) {
  final controller = StreamController<UserInfoModel>();
  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.users)
      .where(
        FirebaseFieldName.userId,
        isEqualTo: userId,
      )
      .limit(1)
      .snapshots()
      .listen(
    (snapshot) {
      final doc = snapshot.docs.first;
      final json = doc.data();
      final userInfoModel = UserInfoModel.fromJson(
        json,
        userId: userId,
      );
      controller.add(userInfoModel);
    },
  );
  ref.onDispose(() {
    controller.close();
    sub.cancel();
  });
  return controller.stream;
});
