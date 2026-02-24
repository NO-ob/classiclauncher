import 'dart:convert';
import 'dart:typed_data';

import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/screens/selectable_container.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:classiclauncher/widgets/selectable/selectable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  AppHandler appHandler = Get.find<AppHandler>();
  SelectableController controller = SelectableController(route: "/SettingsScreen");

  @override
  void initState() {
    // Make this a controller options
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.zoneIndex = 0;
      controller.setSelected(0);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: themeHandler.theme.value.settingsTheme.backgroundColour,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Selectable(
            controller: controller,
            child: Column(
              children: [
                SizedBox(height: Get.mediaQuery.padding.top + 16),
                SelectableList.builder(
                  zoneIndex: 0,
                  zoneKey: "Settings",
                  axis: Axis.vertical,
                  childCount: 6,
                  childBuilder: (index, key) {
                    switch (index) {
                      case 0:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            themeHandler.exportTheme();
                          },
                          title: "Export Theme",
                          body: "Export the current theme as Json",
                        );
                      case 1:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            themeHandler.importTheme();
                          },
                          title: "Import Theme",
                          body: "Import a theme Json file",
                        );
                      //openWallpaperPicker()
                      case 2:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            themeHandler.resetTheme();
                          },
                          title: "Reset Theme",
                          body: "Reset to the default theme",
                        );
                      case 3:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            appHandler.openWallpaperPicker();
                          },
                          title: "Set wallpaper",
                          body: "Choose a wallpaper",
                        );
                      case 4:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            appHandler.importAppOrder();
                          },
                          title: "Import App Order",
                          body: "Import the order of your apps",
                        );
                      case 5:
                        return SettingsCard(
                          selectableKey: "${key}_$index",
                          onTap: () async {
                            appHandler.exportAppOrder();
                          },
                          title: "Export App Order",
                          body: "Export the order of your apps",
                        );

                      default:
                        return SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatefulWidget {
  final String title;
  final String body;
  final void Function() onTap;
  final String selectableKey;
  const SettingsCard({super.key, required this.onTap, required this.title, required this.body, required this.selectableKey});

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return SelectableContainer(
      onTap: widget.onTap,
      selectableKey: widget.selectableKey,
      selectedCallback: (bool newSelected) {
        if (!mounted) {
          return;
        }
        if (newSelected == selected) {
          return;
        }

        setState(() {
          selected = newSelected;
        });
      },
      selectorTheme: themeHandler.theme.value.settingsTheme.selectorTheme,
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1.5, color: themeHandler.theme.value.settingsTheme.menuItemBorderColour)),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 16, right: 16, top: 10, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: selected
                          ? themeHandler.theme.value.settingsTheme.menuItemTitleSelectedTextStyle
                          : themeHandler.theme.value.settingsTheme.menuItemTitleTextStyle,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.body,
                      style: selected
                          ? themeHandler.theme.value.settingsTheme.menuItemBodySelectedTextStyle
                          : themeHandler.theme.value.settingsTheme.menuItemBodyTextStyle,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
