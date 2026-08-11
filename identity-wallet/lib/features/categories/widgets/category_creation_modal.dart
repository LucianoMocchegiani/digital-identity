import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';

import '../../../shared/identity_shared.dart';
import '../../credentials/mappers/credential_ui_mapper.dart';
import '../../credentials/providers/credentials_provider.dart';
import '../../credentials/widgets/credential_logo.dart';
import '../constants/category_catalog.dart';
import '../models/wallet_category.dart';
import '../providers/categories_provider.dart';
import 'category_created_modal.dart';

const Color _labelColor = Color(0xFF181D27);

final TextStyle _labelStyle = TextStyle(
  fontSize: 14,
  height: 18 / 14,
  fontWeight: FontWeight.w500,
  color: _labelColor,
);

final TextStyle _placeholderStyle = TextStyle(
  fontSize: 14,
  height: 18 / 14,
  fontWeight: FontWeight.w400,
  color: AppColors.textNeutralSecondary,
);

const List<BoxShadow> _shadowXs = [
  BoxShadow(
    color: Color.fromRGBO(10, 13, 18, 0.05),
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
];

/// Modal de creación/edición de categoría (componente `Modal-creación-credenciales`).
///
/// Arma la estructura visual (nombre, ícono, color, credenciales) y el desplegable
/// de credenciales disponibles. En modo creación muestra el botón "Crear"; en modo
/// edición ([isEditing]) precarga los datos y muestra "Eliminar" + "Guardar".
/// Persiste vía [categoriesNotifierProvider] (crear/editar/eliminar).
class CategoryCreationModal extends ConsumerStatefulWidget {
  const CategoryCreationModal({
    super.key,
    this.title = 'Creación de categoría',
    this.categoryId,
    this.initialName,
    this.initialIcon,
    this.initialColor,
    this.initialCredentialIds = const <String>{},
    this.isEditing = false,
  });

  /// Título del encabezado.
  final String title;

  /// Id de la categoría a editar ([CategoryData.id]); `null` en creación.
  final String? categoryId;

  /// Nombre precargado (modo edición).
  final String? initialName;

  /// Índice del ícono precargado.
  final int? initialIcon;

  /// Índice del color precargado.
  final int? initialColor;

  /// Ids de credenciales precargadas (modo edición).
  final Set<String> initialCredentialIds;

  /// Si es modo edición (cambia el pie a "Eliminar" + "Guardar").
  final bool isEditing;

  /// Muestra el modal de creación sobre un fondo oscuro.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x99000000), // rgba(0,0,0,0.6)
      builder: (_) => const CategoryCreationModal(),
    );
  }

  /// Muestra el modal de edición precargado con los datos reales de [category].
  ///
  /// Los ids de credenciales asignadas los resuelve el propio modal desde el
  /// notifier (ver [_CategoryCreationModalState.initState]).
  static Future<void> showEdit(
    BuildContext context, {
    required WalletCategory category,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => CategoryCreationModal(
        title: 'Edición de categoría',
        categoryId: category.id,
        initialName: category.label,
        initialIcon: category.iconIndex,
        initialColor: _colorIndexFromArgb(category.colorArgb),
        isEditing: true,
      ),
    );
  }

  /// Resuelve el índice de [kCategoryColors] que corresponde a [argb].
  static int? _colorIndexFromArgb(int? argb) {
    if (argb == null) return null;
    for (var i = 0; i < kCategoryColors.length; i++) {
      if (kCategoryColors[i].toARGB32() == argb) return i;
    }
    return null;
  }

  @override
  ConsumerState<CategoryCreationModal> createState() =>
      _CategoryCreationModalState();
}

class _CategoryCreationModalState extends ConsumerState<CategoryCreationModal> {
  /// Controla el campo de nombre (precargado en edición).
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);

  /// Ids de credenciales seleccionadas ([CredentialRecord.id]).
  late final Set<String> _selectedCredentialIds = {
    ...widget.initialCredentialIds,
  };

  /// Índice del ícono representativo elegido (null = ninguno aún).
  late int? _selectedIcon = widget.initialIcon;

  /// Índice del color elegido (null = ninguno aún).
  late int? _selectedColor = widget.initialColor;

  /// Indica si una operación de persistencia está en curso.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // En edición, precarga las credenciales ya asignadas a la categoría.
    final id = widget.categoryId;
    if (id != null) {
      _selectedCredentialIds.addAll(
        ref.read(categoriesNotifierProvider).credentialIdsForCategory(id),
      );
    }
  }

  /// Ancla del select para posicionar el dropdown flotante.
  final LayerLink _credentialsLink = LayerLink();

  /// Overlay del dropdown de credenciales (null = cerrado). Flota sobre el
  /// contenido para no estirar el alto del modal.
  OverlayEntry? _credentialsOverlay;

  bool get _credentialsOpen => _credentialsOverlay != null;

  @override
  void dispose() {
    _removeCredentialsOverlay();
    _nameController.dispose();
    super.dispose();
  }

  /// Abre o cierra el dropdown flotante de credenciales.
  void _toggleCredentialsOverlay() {
    if (_credentialsOpen) {
      _removeCredentialsOverlay();
    } else {
      _credentialsOverlay = _buildCredentialsOverlay();
      Overlay.of(context).insert(_credentialsOverlay!);
    }
    setState(() {});
  }

  void _removeCredentialsOverlay() {
    _credentialsOverlay?.remove();
    _credentialsOverlay = null;
  }

  /// Credenciales reales del SDK disponibles para asignar.
  List<CredentialRecord> get _availableCredentials =>
      ref.read(credentialsProvider).valueOrNull ?? const [];

  /// Marca/desmarca una credencial (por id) y refresca tags + dropdown.
  void _toggleCredential(String id) {
    setState(() {
      if (!_selectedCredentialIds.remove(id)) {
        _selectedCredentialIds.add(id);
      }
    });
    _credentialsOverlay?.markNeedsBuild();
  }

  /// Nombre recortado; vacío si el usuario no ingresó nada.
  String get _trimmedName => _nameController.text.trim();

  /// Índice de ícono y color a persistir (con fallback al primero del catálogo).
  int get _iconIndexToSave => _selectedIcon ?? 0;
  int get _colorArgbToSave => kCategoryColors[_selectedColor ?? 0].toARGB32();

  /// Crea la categoría con los datos del formulario y persiste.
  Future<void> _onCreate() async {
    if (_trimmedName.isEmpty) {
      showAppSnackBar(context, 'Ingresá un nombre para la categoría.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(categoriesNotifierProvider).createCategory(
            label: _trimmedName,
            iconIndex: _iconIndexToSave,
            colorArgb: _colorArgbToSave,
            credentialIds: _selectedCredentialIds.toList(),
          );
      if (!mounted) return;
      _removeCredentialsOverlay();
      Navigator.of(context).pop();
      CategoryCreatedModal.show(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, 'No se pudo crear la categoría.');
    }
  }

  /// Guarda los cambios de la categoría en edición.
  Future<void> _onSave() async {
    final id = widget.categoryId;
    if (id == null) return;
    if (_trimmedName.isEmpty) {
      showAppSnackBar(context, 'Ingresá un nombre para la categoría.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(categoriesNotifierProvider).updateCategory(
            id: id,
            label: _trimmedName,
            iconIndex: _iconIndexToSave,
            colorArgb: _colorArgbToSave,
            credentialIds: _selectedCredentialIds,
          );
      if (!mounted) return;
      _removeCredentialsOverlay();
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, 'No se pudieron guardar los cambios.');
    }
  }

  /// Pide confirmación y elimina la categoría en edición.
  Future<void> _onDelete() async {
    final id = widget.categoryId;
    if (id == null) return;
    final confirmed = await IdentityConfirmModal.show(
      context,
      title: 'Eliminar categoría',
      description:
          'Se eliminará la categoría y sus credenciales dejarán de estar '
          'agrupadas. Las credenciales no se borran.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(categoriesNotifierProvider).deleteCategory(id);
      if (!mounted) return;
      _removeCredentialsOverlay();
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnackBar(context, 'No se pudo eliminar la categoría.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: AppColors.backgroundNeutralSecondary,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Color(0xFFF1F1F1)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SizedBox(
              width: 297,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHead(context),
                  Flexible(child: SingleChildScrollView(child: _buildContent())),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Encabezado: título + botón cerrar.
  Widget _buildHead(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              // TODO: aplicar la familia 'Manrope' al definir la tipografía global.
              style: TextStyle(
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textNeutralPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              'public/images/icons/Close-Circle.png',
              width: 24,
              height: 24,
              color: AppColors.textNeutralSecondary,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  /// Cuerpo del modal con los campos del formulario.
  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.borderNeutral)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNameInput(),
          SizedBox(height: 12),
          _buildIconSelector(),
          SizedBox(height: 12),
          _buildColorSelector(),
          SizedBox(height: 12),
          _buildCredentialsSelect(),
          SizedBox(height: 12),
          // Pie: "Crear" (creación) o "Eliminar" + "Guardar" (edición).
          if (widget.isEditing) _buildEditButtons() else _buildCreateButton(),
        ],
      ),
    );
  }

  /// Input "Nombre de la categoría".
  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nombre de la categoria:', style: _labelStyle),
        SizedBox(height: 4),
        Container(
          // Alto mínimo en lugar de fijo: el campo crece con la fuente del sistema.
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: _fieldDecoration,
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'Ej: Servicios',
              hintStyle: _placeholderStyle,
            ),
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              color: AppColors.textNeutralPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Selector horizontal de íconos representativos + barra de scroll.
  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icono representativo:', style: _labelStyle),
        SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: Stack(
            children: [
              ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kCategoryIconAssets.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (_, i) => _iconButton(i, kCategoryIconAssets[i]),
              ),
              // Degradé que insinúa más íconos hacia la derecha.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    width: 49.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Barra de navegación (indicador de scroll).
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0x0D1C274D), // rgba(28,39,77,0.05)
            borderRadius: BorderRadius.circular(18),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 54,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0x1A1C274D), // rgba(28,39,77,0.1)
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Punto de color; el elegido va a opacidad plena con un tilde blanco.
  Widget _colorDot(int index, Color color) {
    final selected = _selectedColor == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 1 : 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderNeutral),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 12, color: AppColors.panel)
            : null,
      ),
    );
  }

  /// Botón de un ícono representativo; se resalta al estar seleccionado.
  Widget _iconButton(int index, String asset) {
    final selected = _selectedIcon == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBlueSurface : AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accentBlue : AppColors.borderNeutral,
          ),
        ),
        child: Opacity(
          // Seleccionado a opacidad plena; el resto atenuado.
          opacity: selected ? 1 : 0.3,
          child: Image.asset(
            asset,
            width: 24,
            height: 24,
            color: selected ? AppColors.accentBlue : const Color(0xFF1C274C),
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  /// Paleta de colores (estado base, atenuado).
  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color:', style: _labelStyle),
        SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderNeutral),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < kCategoryColors.length; i++)
                _colorDot(i, kCategoryColors[i]),
            ],
          ),
        ),
      ],
    );
  }

  /// Select "Credenciales" + desplegable de credenciales disponibles.
  Widget _buildCredentialsSelect() {
    // Records seleccionados, en el orden en que aparecen en el SDK.
    final selected = _availableCredentials
        .where((r) => _selectedCredentialIds.contains(r.id))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Credenciales:', style: _labelStyle),
            Image.asset(
              'public/images/icons/Question Circle.png',
              width: 16,
              height: 16,
            ),
          ],
        ),
        SizedBox(height: 6),
        CompositedTransformTarget(
          link: _credentialsLink,
          child: GestureDetector(
            onTap: _toggleCredentialsOverlay,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: _fieldDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: selected.isEmpty
                        // Placeholder cuando no hay credenciales elegidas.
                        ? Text('Elegir las credenciales',
                            style: _placeholderStyle)
                        // Tags: primera credencial (removible) + "+N" restantes.
                        : Row(
                            children: [
                              Flexible(child: _credentialTag(selected.first)),
                              if (selected.length > 1) ...[
                                SizedBox(width: 4),
                                _countBadge(selected.length - 1),
                              ],
                            ],
                          ),
                  ),
                  SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _credentialsOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Image.asset(
                      'public/images/icons/Alt Arrow Down.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el overlay del dropdown anclado bajo el select. Flota sobre el
  /// resto del modal sin alterar su alto; toca fuera para cerrarlo.
  OverlayEntry _buildCredentialsOverlay() {
    return OverlayEntry(
      builder: (context) {
        final width = _credentialsLink.leaderSize?.width ?? 265;
        return Stack(
          children: [
            // Capa para cerrar el dropdown al tocar fuera.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleCredentialsOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _credentialsLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 6),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: Material(
                    color: Colors.transparent,
                    child: _buildCredentialsDropdown(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Tag de una credencial seleccionada, con cruz para quitarla.
  Widget _credentialTag(CredentialRecord record) {
    final credential = CredentialUiMapper.toWalletCredential(record);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      decoration: _badgeDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CredentialLogo(
            logoUrl: credential.logoUrl,
            size: 20,
            radius: 6,
            borderColor: AppColors.borderNeutral,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              credential.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _badgeTextStyle,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => _toggleCredential(record.id),
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              'public/images/icons/Cross.png',
              width: 12,
              height: 12,
              color: AppColors.textNeutralSecondary,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge "+N" para las credenciales seleccionadas restantes.
  Widget _countBadge(int n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: _badgeDecoration,
      child: Text('+$n', style: _badgeTextStyle),
    );
  }

  /// Desplegable con las credenciales disponibles (multi-selección).
  Widget _buildCredentialsDropdown() {
    final credentials = _availableCredentials;
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral),
        boxShadow: _shadowXs,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text('Credenciales disponibles', style: _placeholderStyle),
          ),
          if (credentials.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Text(
                'No tenés credenciales todavía.',
                style: _placeholderStyle,
              ),
            )
          else
            for (final record in credentials) _credentialRow(record),
        ],
      ),
    );
  }

  /// Fila de una credencial disponible con su check de selección.
  Widget _credentialRow(CredentialRecord record) {
    final selected = _selectedCredentialIds.contains(record.id);
    final credential = CredentialUiMapper.toWalletCredential(record);
    return InkWell(
      onTap: () => _toggleCredential(record.id),
      child: Container(
        color: selected ? AppColors.accentBlueSurface : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CredentialLogo(
              logoUrl: credential.logoUrl,
              size: 28,
              radius: 8,
              borderColor: AppColors.borderNeutral,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                credential.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textNeutralPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 18, color: Color(0xFF2E90FA)),
          ],
        ),
      ),
    );
  }

  /// Botón "Crear": persiste la categoría y muestra la confirmación de éxito.
  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _saving ? null : _onCreate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Alto mínimo en lugar de fijo: crece con la fuente del sistema.
        constraints: const BoxConstraints(minHeight: 34),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _shadowXs,
        ),
        child: Text(
          'Crear',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFDFDFD),
          ),
        ),
      ),
    );
  }

  /// Pie de edición: "Eliminar" (destructivo) + "Guardar".
  Widget _buildEditButtons() {
    return Row(
      children: [
        // Eliminar (rojo suave).
        Expanded(
          child: IdentityDangerButton(
            label: 'Eliminar',
            onTap: _saving ? null : _onDelete,
          ),
        ),
        SizedBox(width: 12),
        // Guardar (primario).
        Expanded(
          child: GestureDetector(
            onTap: _saving ? null : _onSave,
            behavior: HitTestBehavior.opaque,
            child: Container(
              // Alto mínimo en lugar de fijo: crece con la fuente del sistema.
              constraints: const BoxConstraints(minHeight: 34),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _shadowXs,
              ),
              child: Text(
                'Guardar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDFDFD),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Decoración compartida de los campos (input/select).
  static final BoxDecoration _fieldDecoration = BoxDecoration(
    color: AppColors.backgroundNeutralSecondary,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderNeutral),
    boxShadow: _shadowXs,
  );

  /// Decoración compartida de los badges/tags (credenciales).
  static final BoxDecoration _badgeDecoration = BoxDecoration(
    color: AppColors.backgroundNeutralSecondary,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.borderNeutral),
  );

  /// Texto de los badges/tags (Text xs/Medium).
  // TODO: aplicar 'Nunito Sans' al definir la tipografía global.
  static TextStyle get _badgeTextStyle => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textNeutralPrimary,
  );
}
