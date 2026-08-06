import '../../../invitation/models/invitation_result.dart';

/// Determina el tipo de flujo DIDComm a partir del payload de una invitación OOB.
abstract final class OobResolver {
  /// Detecta el [DidCommFlowType] a partir del campo `goal_code` de [invitation].
  ///
  /// Heurística:
  /// - `issue-vc`, `streamlined-vc`, `vc.*` → [DidCommFlowType.issue]
  /// - `present-proof`, `verify.*`, `proof.*` → [DidCommFlowType.verify]
  /// - Sin `goal_code` o valor desconocido → [DidCommFlowType.connect]
  static DidCommFlowType detectFlowType(Map<String, dynamic> invitation) {
    final goalCode = _extractGoalCode(invitation);
    if (goalCode == null) return DidCommFlowType.connect;

    if (goalCode.contains('issue') ||
        goalCode.contains('vc') ||
        goalCode.startsWith('streamlined')) {
      return DidCommFlowType.issue;
    }

    if (goalCode.contains('proof') ||
        goalCode.contains('present') ||
        goalCode.contains('verify')) {
      return DidCommFlowType.verify;
    }

    return DidCommFlowType.connect;
  }

  static String? _extractGoalCode(Map<String, dynamic> invitation) {
    final direct = invitation['goal_code'] as String?;
    if (direct != null) return direct.toLowerCase();

    // DIDComm v2: goal_code puede estar dentro de body
    final body = invitation['body'] as Map<String, dynamic>?;
    return (body?['goal_code'] as String?)?.toLowerCase();
  }
}
