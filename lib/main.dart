import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/env/env_config.dart';
import 'package:pulsehub/core/utils/my_bloc_observer.dart';
import 'package:pulsehub/core/utils/shared_pref_helper.dart';
import 'package:pulsehub/core/utils/user_manager.dart';
import 'package:pulsehub/my_app.dart';

void main() async {
  // init flutter stuff
  WidgetsFlutterBinding.ensureInitialized();
  // init dependencies and services
  configureDependencies();
  // init shared preferences storage
  await SharedPrefHelper.init();
  // init user manager
  await UserManager().init();
  // init bloc observer (for logging)
  Bloc.observer = MyBlocObserver();

  // Set environment (change to Environment.dev for development)
  sl<EnvConfig>().setEnvironment(Environment.dev);

  // run app
  runApp(const MyApp());
}
