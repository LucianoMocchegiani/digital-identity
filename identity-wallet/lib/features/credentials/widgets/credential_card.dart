import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../shared/identity_shared.dart';
import '../models/wallet_credential.dart';
import '../providers/credential_ux_provider.dart';
import 'credential_background.dart';
import 'credential_logo.dart';

/// Tarjeta de credencial reutilizable (componente `Credencial-v2`).
///
/// Muestra logo + insignia de verificado, título y emisor. El ojo
/// ([IdentityEyeToggle]) despliega los claims en una superficie aparte que asoma
/// desde atrás de la tarjeta, con filas etiqueta/valor como el detalle y el
/// share. La tarjeta no cambia: conserva su alto y su radio de 16 en las cuatro
/// esquinas, expandida o no. El corazón marca o desmarca la favorita.
class CredentialCard extends ConsumerStatefulWidget {
  const CredentialCard({
    super.key,
    required this.credential,
    this.labeledClaims = const [],
    this.initiallyExpanded = false,
    this.showExpandToggle = true,
    this.showFavoriteToggle = false,
    this.onTap,
  });

  /// Datos de la credencial a representar.
  final WalletCredential credential;

  /// Claims etiqueta/valor del panel expandido (mismo formato que el detalle).
  ///
  /// Si está vacío, el panel cae a [WalletCredential.details] como valores sin
  /// etiqueta (mocks / preview de oferta).
  final List<LabeledClaim> labeledClaims;

  /// Si arranca con los detalles visibles.
  final bool initiallyExpanded;

  /// Si se muestra el ícono de ojo para mostrar/ocultar detalles. En vistas
  /// donde los datos ya se listan aparte (ej. modal de confirmación), se oculta.
  final bool showExpandToggle;

  /// Si se muestra el corazón de favorita. En sheets de flujo (agregar/compartir)
  /// se oculta: el favorito solo tiene sentido en el listado de la wallet.
  final bool showFavoriteToggle;

  /// Callback al tocar la tarjeta (ej. abrir el drawer de detalle).
  final VoidCallback? onTap;

  @override
  ConsumerState<CredentialCard> createState() => _CredentialCardState();
}

/// Cuánto se mete la superficie del panel por debajo de la tarjeta.
const double _panelOverlap = 16;

/// Inset horizontal del panel (= radio de la card) para alinear con el arranque
/// del redondeo y centrarlo respecto a la tarjeta.
const double _panelInset = 16;

class _CredentialCardState extends ConsumerState<CredentialCard> {
  late bool _showDetails = widget.initiallyExpanded;

  bool get _hasExpandableContent =>
      widget.labeledClaims.isNotEmpty || widget.credential.details.isNotEmpty;

  // Tema neutro por defecto vía [WalletCredential.resolvedBackground/Foreground].
  @override
  Widget build(BuildContext context) {
    final credential = widget.credential;
    final hasDetails = _hasExpandableContent;
    final brightness = Theme.of(context).brightness;
    final bg = credential.resolvedBackground(brightness);
    final fg = credential.resolvedForeground(brightness);
    final showPanel =
        _showDetails && hasDetails && widget.showExpandToggle;

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCredentialCelesteShadow(brightness),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned.fill(
              child: CredentialBackground(
                backgroundColor: bg,
                backgroundImageUrl: credential.backgroundImageUrl,
                borderRadius: BorderRadius.circular(16),
                showSheen: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHead(credential, hasDetails, fg),
                  const SizedBox(height: 14),
                  _buildData(credential, fg),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final surface = widget.onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: card,
            ),
          );

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      // `up` invierte la posición (tarjeta arriba, panel abajo) sin invertir el
      // orden de pintado: el panel se dibuja primero y la tarjeta lo tapa, así
      // el arranque del panel queda escondido detrás de ella.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        verticalDirection: VerticalDirection.up,
        children: [
          if (showPanel) _buildDetailsPanel(),
          surface,
        ],
      ),
    );
  }

  /// Contenedor propio de claims que asoma desde atrás de la tarjeta.
  Widget _buildDetailsPanel() {
    final colors = context.kuatia;
    final rows = widget.labeledClaims.isNotEmpty
        ? widget.labeledClaims
        : [
            // Preview / mocks sin [labeledClaims]: cada `details` es la etiqueta
            // (oferta OID4VCI) o el valor suelto; sin valor se omite la línea.
            for (var i = 0; i < widget.credential.details.length; i++)
              LabeledClaim(
                label: widget.credential.details[i],
                key: 'detail_$i',
                value: '',
              ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _panelInset),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // La superficie arranca por encima del contenido para meterse debajo
          // de la tarjeta: su borde y sus esquinas superiores nunca se ven.
          Positioned(
            top: -_panelOverlap,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final claim in rows)
                  SheetFieldRow(
                    label: claim.label,
                    value: _formatValue(claim.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Representación en una línea (null, bool, map, list), igual que el drawer.
  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    if (value is List) return value.map(_formatValue).join(', ');
    return value.toString();
  }

  Widget _buildHead(WalletCredential credential, bool hasDetails, Color fg) {
    // Sin alto fijo: la fila se ajusta al título cuando la fuente del sistema
    // es mayor (textScaleFactor alto), en vez de desbordar.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _logo(credential),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: 0.8,
            child: Text(
              credential.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
        // Corazón de favorita: solo en listado/home, no en sheets de flujo.
        if (widget.showFavoriteToggle) ...[
          const SizedBox(width: 12),
          _buildFavoriteButton(credential, fg),
        ],
        if (hasDetails && widget.showExpandToggle) ...[
          const SizedBox(width: 16),
          IdentityEyeToggle(
            expanded: _showDetails,
            onTap: () => setState(() => _showDetails = !_showDetails),
            color: fg,
            opacity: 0.4,
          ),
        ],
      ],
    );
  }

  /// Botón de favorita: `favorite_border` (vacío) o `favorite` (relleno).
  ///
  /// Lee y persiste el estado vía la capa UX ([credentialUxNotifierProvider]).
  /// Si la credencial no tiene `id` (no debería ocurrir en runtime), no se muestra.
  Widget _buildFavoriteButton(WalletCredential credential, Color fg) {
    final id = credential.id;
    if (id == null) return const SizedBox.shrink();

    final isFavorite = ref.watch(isCredentialFavoriteProvider(id));
    return GestureDetector(
      onTap: () => ref.read(credentialUxNotifierProvider).toggleFavorite(id),
      behavior: HitTestBehavior.opaque,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: 24,
        // Mismo gris claro que el ojo y el corazón vacío (fg al 40%): la única
        // diferencia entre favorito y no favorito es relleno vs borde.
        color: fg.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _logo(WalletCredential credential) {
    return CredentialLogoWithBadge(
      logoUrl: credential.logoUrl,
      verified: credential.verified,
      size: 32,
    );
  }

  Widget _buildData(WalletCredential credential, Color fg) {
    return Opacity(
      opacity: 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            credential.issuer,
            style: TextStyle(
              fontSize: 14,
              height: 19 / 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
