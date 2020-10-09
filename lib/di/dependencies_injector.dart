import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app_sample/core/service/firebase_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future initDependencies() async {
  getIt.registerSingleton<FirebaseService>(FirebaseServiceImpl());
}
