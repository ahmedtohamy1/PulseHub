import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/service_locator.dart';
import 'package:pulsehub/core/utils/my_bloc_observer.dart';
import 'package:pulsehub/my_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
