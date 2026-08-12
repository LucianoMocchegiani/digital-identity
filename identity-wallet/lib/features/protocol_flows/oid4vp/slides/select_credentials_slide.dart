import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

import '../../../categories/models/wallet_category.dart';
import '../../../categories/widgets/category_icon.dart';
import '../../../credentials/mappers/credential_ui_mapper.dart';
import '../../../credentials/models/wallet_credential.dart';
import '../../../credentials/widgets/credential_logo.dart';

/// Slide de selección de credenciales del flujo **OID4VP** / DIDComm.
///
/// Por cada requisito del verificador ([FormattedSubmissionEntry]) lista sus
/// credenciales candidatas con radio de selección única, filtro por
/// [WalletCategory] y búsqueda por título/emisor, como bottom sheet del design
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
    required this.categories,
    required this.onSelect,
    required this.onContinue,
    required this.onCancel,
  });

  /// Solicitud resuelta con requisitos y credenciales candidatas.
  final CredentialsForRequest request;

  /// Descriptor de entrada → id de la credencial elegida hasta ahora.
  final Map<String, String> selected;

  /// Categorías del wallet (incluye "Todas las credenciales" de sistema).
  final List<WalletCategory> categories;

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
  String? _selectedCategoryId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = _defaultCategoryId(widget.categories);
  }

  @override
  void didUpdateWidget(covariant SelectCredentialsSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      final stillValid = widget.categories.any((c) => c.id == _selectedCategoryId);
      if (!stillValid) {
        _selectedCategoryId = _defaultCategoryId(widget.categories);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String? _defaultCategoryId(List<WalletCategory> categories) {
    for (final category in categories) {
      if (category.isSystem) return category.id;
    }
    return categories.firstOrNull?.id;
  }

  WalletCategory? get _selectedCategory {
    for (final category in widget.categories) {
      if (category.id == _selectedCategoryId) return category;
    }
    return widget.categories.firstOrNull;
  }

  /// Ids permitidos por la categoría activa; `null` = sin filtro (sin categorías).
  Set<String>? get _categoryCredentialIds {
    final category = _selectedCategory;
    if (category == null) return null;
    return {
      for (final credential in category.credentials)
        if (credential.id != null) credential.id!,
    };
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
    return entries.isNotEmpty &&
        entries.every(
            (entry) => widget.selected.containsKey(entry.inputDescriptorId));
  }

  /// Aplica filtro de categoría y búsqueda sobre las candidatas de [entry].
  List<WalletCredential> _visibleCredentials(FormattedSubmissionEntry entry) {
    final query = _searchController.text.trim().toLowerCase();
    final allowedIds = _categoryCredentialIds;
    return [
      for (final record
          in entry.matchingCredentials ?? const <CredentialRecord>[])
        if (allowedIds == null || allowedIds.contains(record.id))
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
          if (widget.categories.isNotEmpty) ...[
            _CategoryFilterTags(
              categories: widget.categories,
              selectedId: _selectedCategory?.id,
              onSelect: (id) => setState(() => _selectedCategoryId = id),
            ),
            const SizedBox(height: 12),
          ],
          _SearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          for (final entry in entries) ...[
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
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Chips horizontales de [WalletCategory].
class _CategoryFilterTags extends StatelessWidget {
  const _CategoryFilterTags({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<WalletCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                _CategoryTag(
                  category: categories[i],
                  isSelected: categories[i].id == selectedId,
                  onTap: () => onSelect(categories[i].id),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final WalletCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  String get _label => category.isSystem ? 'Todas' : category.label;

  @override
  Widget build(BuildContext context) {
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
              CategoryIcon(
                asset: category.iconAsset,
                colorArgb: category.colorArgb,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                _label,
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
          const SizedBox(width: 10),
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
class _CredentialOptionList extends StatelessWidget {
  const _CredentialOptionList({
    required this.credentials,
    required this.selectedId,
    required this.onSelect,
  });

  final List<WalletCredential> credentials;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (credentials.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Fila de candidata: logo + título + emisor + radio.
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
              const SizedBox(width: 12),
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
                    const SizedBox(height: 2),
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
              const SizedBox(width: 8),
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
