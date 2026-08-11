import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';

/// [AppBar] de pantallas internas apiladas sobre el navbar.
abstract final class IdentityPageAppBar {
  static AppBar build({required String title, List<Widget>? actions}) {
    return AppBar(
      // Colores vía tema; el builder usa extension al paint time.
      backgroundColor: null,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const BackButton(),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Builder(
          builder: (context) => Divider(
            height: 1,
            thickness: 1,
            color: context.kuatia.border,
          ),
        ),
      ),
    );
  }
}
