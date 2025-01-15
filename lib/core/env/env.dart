import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(
      varName: 'DEV_BASE_URL',
      defaultValue: "https://pulsehub.synology.me:9099")
  static const String devBaseUrl = _Env.devBaseUrl;

  @EnviedField(
      varName: 'PROD_BASE_URL',
      defaultValue: "https://pulsehub.synology.me:9099")
  static const String prodBaseUrl = _Env.prodBaseUrl;
}
