import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UninstallButton extends StatefulWidget {
  final AppInfo appInfo;
  const UninstallButton({super.key, required this.appInfo});

  @override
  State<UninstallButton> createState() => _UninstallButtonState();
}

class _UninstallButtonState extends State<UninstallButton> {
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  AppHandler appHandler = Get.find<AppHandler>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appHandler.uninstallApp(widget.appInfo);
      },
      child: Container(
        width: themeHandler.theme.value.uninstallButtonTheme.uninstallButtonSize,
        height: themeHandler.theme.value.uninstallButtonTheme.uninstallButtonSize,
        decoration: BoxDecoration(
          color: themeHandler.theme.value.uninstallButtonTheme.uninstallButtonColour,
          shape: BoxShape.circle,
          border: Border.all(color: themeHandler.theme.value.uninstallButtonTheme.uninstallButtonBorderColour, width: 2),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Image(
            image: AssetImage(iconBin),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            color: themeHandler.theme.value.uninstallButtonTheme.uninstallButtonIconColour,
          ),
        ),
      ),
    );
  }
}
