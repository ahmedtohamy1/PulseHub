import 'package:fpdart/fpdart.dart';
import 'package:pulsehub/features/project_dashboard/data/models/project_dashboards.dart';

abstract class DashRepository {
 Future<Either<String,  ProjectDashboards>> getDashs(String token, int projectId);
}
