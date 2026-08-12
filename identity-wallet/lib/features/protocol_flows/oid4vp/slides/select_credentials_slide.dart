import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../credentials/mappers/credential_ui_mapper.dart';
import '../../../credentials/models/wallet_credential.dart';
import '../../../credentials/widgets/credential_logo.dart';

/// Filtro del selector de credenciales (tags del mockup).
enum _SelectFilter { todas, favoritas }

/// Slide de selección de credenciales del flujo **OID4VP**.
///
/// Por cada requisito del verificador ([FormattedSubmissionEntry]) lista sus
/// credenciales candidatas con radio de selección única, filtro
/// Todas/Favoritas y búsqueda por título/emisor, como bottom sheet del design
/// system ([IdentityFlowSheet]).
///
/// [onSelect] notifica cada elección a `Oid4VpNotifier.selectCredential`;
/// "Presentar" ([onContinue]) queda deshabilitado hasta que todos los
/// requisitos satisfacibles tengan una credencial en [selected].
class SelectCredentialsSlide extends StatefulWidget {
  const SelectCredentialsSlide({
    super.key,
    required this.request,
    required this.selected,
    required this.favoriteIds,
    required this.onSelect,
    required this.onContinue,
    required this.onCancel,
  });

  /// Solicitud resuelta con requisitos y credenciales candidatas.
  final CredentialsForRequest request;

  /// Descriptor de entrada → id de la credencial elegida hasta ahora.
  final Map<String, String> selected;

  /// Ids de credenciales marcadas como favoritas (tab "Favoritas").
  final Set<String> favoriteIds;

  /// Notifica la elección de una credencial para un descriptor.
  final void Function(String inputDescriptorId, String credentialId) onSelect;

  /// Confirma la selección y avanza a la vista de compartir.
  final VoidCallback onContinue;

  /// Cancela y vuelve o cierra según el contenedor.
  final VoidCallback onCancel;

  @override
  State<SelectCredentialsSlide> createState() =>
      _SelectCredentialsSlideState();
}

class _SelectCredentialsSlideState extends State<SelectCredentialsSlide> {
  _SelectFilter _filter = _SelectFilter.todas;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Requisitos con candidatas: solo estos exigen selección.
  List<FormattedSubmissionEntry> get _selectableEntries => [
        for (final entry in widget.request.submission.entries)
          if (entry.isSatisfied &&
              (entry.matchingCredentials?.isNotEmpty ?? false))
            entry,
      ];

  /// Verdadero cuando cada requisito tiene una credencial elegida.
  bool get _allSelected {
    final entries = _selectableEntries;
    // Sin requisitos no hay nada que presentar: el botón queda deshabilitado.
    return entries.isNotEmpty &&
        entries.every(
            (entry) => widget.selected.containsKey(entry.inputDescriptorId));
  }

  /// Aplica filtro de favoritas y búsqueda sobre las candidatas de [entry].
  List<WalletCredential> _visibleCredentials(FormattedSubmissionEntry entry) {
    final query = _searchController.text.trim().toLowerCase();
    return [
      for (final record
          in entry.matchingCredentials ?? const <CredentialRecord>[])
        if (_filter == _SelectFilter.todas ||
            widget.favoriteIds.contains(record.id))
          CredentialUiMapper.toWalletCredential(record),
    ]
        .where((credential) =>
            query.isEmpty ||
            credential.title.toLowerCase().contains(query) ||
            credential.issuer.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _selectableEntries;
    return FlowSheetScaffold(
      sheet: IdentityFlowSheet(
        title: '¿Qué credenciales querés presentar?',
        secondaryLabel: 'Cancelar',
        onSecondary: widget.onCancel,
        primaryLabel: 'Presentar',
        onPrimary: _allSelected ? widget.onContinue : null,
        children: [
          _FilterTags(
            selected: _filter,
            onSelect: (filter) => setState(() => _filter = filter),
          ),
          SizedBox(height: 12),
          _SearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 16),
          for (final entry in entries) ...[
            // Con un solo requisito el encabezado sobra (mockup).
            if (entries.length > 1 && entry.name != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  entry.name!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 18 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textNeutralPrimary,
                  ),
                ),
              ),
            _CredentialOptionList(
              credentials: _visibleCredentials(entry),
              selectedId: widget.selected[entry.inputDescriptorId],
              onSelect: (credentialId) =>
                  widget.onSelect(entry.inputDescriptorId, credentialId),
            ),
            SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Barra flotante segmentada Todas/Favoritas del sheet OID4VP
/// (componente `Tag-group` de Figma).
///
/// Un único contenedor con borde y radio 16 envuelve los dos tags; el
/// seleccionado va en accent sobre superficie accent.
class _FilterTags extends StatelessWidget {
  const _FilterTags({required this.selected, required this.onSelect});

  final _SelectFilter selected;
  final ValueChanged<_SelectFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderNeutral),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tag(
              iconAsset: 'public/images/icons/credenciales.png',
              label: 'Todas',
              isSelected: selected == _SelectFilter.todas,
              onTap: () => onSelect(_SelectFilter.todas),
            ),
            SizedBox(width: 2),
            _tag(
              iconAsset: 'public/images/icons/favoritos.png',
              label: 'Favoritas',
              isSelected: selected == _SelectFilter.favoritas,
              onTap: () => onSelect(_SelectFilter.favoritas),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag({
    required String iconAsset,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color =
        isSelected ? AppColors.accentBlue : AppColors.textNeutralPrimary;
    final radius = BorderRadius.circular(16);
    return Material(
      color: isSelected ? AppColors.accentBlueSurface : AppColors.panel,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconAsset,
                width: 16,
                height: 16,
                color: color,
                colorBlendMode: BlendMode.srcIn,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de búsqueda fijo del selector (mockup: "Buscar...").
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: Row(
        children: [
          Image.asset(
            'public/images/icons/lupa.png',
            width: 18,
            height: 18,
            color: AppColors.textNeutralSecondary,
            colorBlendMode: BlendMode.srcIn,
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.accentBlue,
              style: TextStyle(
                fontSize: 16,
                height: 22 / 16,
                color: AppColors.textNeutralPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Buscar...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textNeutralSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de candidatas de un requisito con selección única por radio.
///
/// Presentacional y testeable sin construir [CredentialsForRequest].
class _CredentialOptionList extends StatelessWidget {
  const _CredentialOptionList({
    required this.credentials,
    required this.selectedId,
    required this.onSelect,
  });

  /// Candidatas visibles tras filtro y búsqueda.
  final List<WalletCredential> credentials;

  /// Id de la credencial elegida para este requisito; `null` si ninguna.
  final String? selectedId;

  /// Notifica el id de la credencial tocada.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (credentials.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No se encontraron credenciales.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textNeutralSecondary,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final credential in credentials) ...[
          _CredentialOptionRow(
            key: ValueKey('credential-option-${credential.id}'),
            credential: credential,
            isSelected: credential.id == selectedId,
            onTap: () {
              final id = credential.id;
              if (id != null) onSelect(id);
            },
          ),
          SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Fila de candidata: logo + título + emisor + radio (mockup).
class _CredentialOptionRow extends StatelessWidget {
  const _CredentialOptionRow({
    super.key,
    required this.credential,
    required this.isSelected,
    required this.onTap,
  });

  final WalletCredential credential;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AppColors.panel,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color:
                  isSelected ? AppColors.accentBlue : AppColors.borderNeutral,
            ),
          ),
          child: Row(
            children: [
              CredentialLogo(logoUrl: credential.logoUrl, size: 36),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      credential.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textNeutralPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      credential.issuer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              _RadioIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Radio circular del design system: aro neutro; elegido → relleno azul con punto.
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.accentBlue : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.accentBlue : AppColors.borderNeutral,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Icon(Icons.circle, size: 8, color: AppColors.inkOnAccent),
            )
          : null,
    );
  }
}
