import 'package:injectable/injectable.dart';

import 'env.dart';

enum Environment { dev, prod }

@singleton
class EnvConfig {
  Environment _currentEnv = Environment.prod;

  String get baseUrl =>
      _currentEnv == Environment.dev ? Env.devBaseUrl : Env.prodBaseUrl;

  void setEnvironment(Environment env) {
    _currentEnv = env;
  }

  Environment get currentEnvironment => _currentEnv;
}
