import 'dart:math' as math;

import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/config_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/models/theme/app_grid_theme.dart';
import 'package:classiclauncher/screens/selectable_container.dart';
import 'package:classiclauncher/selection/key_input_handler.dart';
import 'package:classiclauncher/utils/constants.dart';
import 'package:classiclauncher/widgets/app_page.dart';
import 'package:classiclauncher/widgets/custom_page_view.dart';
import 'package:classiclauncher/widgets/page_indicator.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:classiclauncher/widgets/selectable/app_grid.dart';
import 'package:classiclauncher/widgets/selectable/selectable_list.dart';
import 'package:classiclauncher/widgets/shadowed_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' hide Selectable;
import 'package:get/get.dart';

void main() {
  Get.put(KeyInputHandler(), permanent: true);
  Get.put(ConfigHandler(), permanent: true);
  Get.put(AppHandler(), permanent: true);
  Get.put(ThemeHandler(), permanent: true);
  Get.put(AppGridHandler(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      color: Colors.transparent,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AppHandler appHandler = Get.find<AppHandler>();
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  final SelectableController controller = SelectableController(route: "/");
  final AppGridHandler appGridHandler = Get.find<AppGridHandler>();

  List<List<T>> splitList<T>(List<T> list, int countPerSplit) {
    if (countPerSplit <= 0) {
      return [];
    }

    List<List<T>> result = [];
    for (var i = 0; i < list.length; i += countPerSplit) {
      int end = (i + countPerSplit < list.length) ? i + countPerSplit : list.length;
      result.add(list.sublist(i, end));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Obx(() {
        return SizedBox(
          width: Get.width,
          height: Get.height,
          child: Column(
            children: [
              SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Selectable(
                      controller: controller,
                      child: AppGrid(constraints: constraints),
                    );
                  },
                ),
              ),
              SizedBox(
                height: themeHandler.theme.value.navBarTheme.navBarHeight,
                child: Selectable(
                  controller: controller,
                  child: SelectableList.builder(
                    zoneIndex: 1,
                    childCount: 3,
                    zoneKey: "NavRow",
                    axis: Axis.horizontal,
                    childBuilder: (index, key) {
                      switch (index) {
                        case 0:
                          return Padding(
                            padding: EdgeInsetsGeometry.only(
                              left: themeHandler.theme.value.navBarTheme.navBarSpacing,
                              right: themeHandler.theme.value.navBarTheme.navBarSpacing,
                            ),
                            child: SelectableContainer(
                              selectableKey: "${key}_$index",
                              selectorTheme: themeHandler.theme.value.appGridTheme.selectorTheme,
                              onTap: () {
                                appHandler.launchMail();
                              },
                              child: SizedBox(
                                height: themeHandler.theme.value.navBarTheme.navBarHeight,
                                width: themeHandler.theme.value.navBarTheme.navBarHeight,
                                child: ShadowedImage(
                                  width: themeHandler.theme.value.navBarTheme.navBarIconSize,
                                  height: themeHandler.theme.value.navBarTheme.navBarIconSize,
                                  colour: themeHandler.theme.value.navBarTheme.iconColour,
                                  assetPath: appHandler.loliSnatcher.value == null ? iconMessages : iconKanna2,
                                ),
                              ),
                            ),
                          );
                        case 1:
                          return Expanded(
                            child: SelectableContainer(
                              selectableKey: "${key}_$index",
                              selectorTheme: themeHandler.theme.value.appGridTheme.selectorTheme,
                              child: SizedBox(
                                height: themeHandler.theme.value.navBarTheme.navBarHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() {
                                      int pageCount =
                                          (appHandler.installedApps.length /
                                                  (themeHandler.theme.value.appGridTheme.rows * themeHandler.theme.value.appGridTheme.columns))
                                              .ceil();
                                      return PageIndicators(selected: appGridHandler.pageNotifier, pageCount: pageCount);
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          );

                        case 2:
                          return Padding(
                            padding: EdgeInsetsGeometry.only(
                              left: themeHandler.theme.value.navBarTheme.navBarSpacing,
                              right: themeHandler.theme.value.navBarTheme.navBarSpacing,
                            ),
                            child: SelectableContainer(
                              selectableKey: "${key}_$index",
                              selectorTheme: themeHandler.theme.value.appGridTheme.selectorTheme,
                              onTap: () {
                                appHandler.launchCamera();
                              },
                              child: SizedBox(
                                height: themeHandler.theme.value.navBarTheme.navBarHeight,
                                width: themeHandler.theme.value.navBarTheme.navBarHeight,
                                child: ShadowedImage(
                                  width: themeHandler.theme.value.navBarTheme.navBarIconSize,
                                  height: themeHandler.theme.value.navBarTheme.navBarIconSize,
                                  colour: themeHandler.theme.value.navBarTheme.iconColour,
                                  assetPath: iconCamera,
                                ),
                              ),
                            ),
                          );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
