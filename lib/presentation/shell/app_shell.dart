import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/version_cubit.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  late TabController _bottomTabController;

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(length: 2, vsync: this);
    _updateIndexFromRoute(widget.currentRoute);

    _bottomTabController.addListener(() {
      // Update URL when tab changes
      if (_bottomTabController.index == 1) {
        context.go('/settings');
      } else {
        context.go('/dashboard');
      }
    });
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      _updateIndexFromRoute(widget.currentRoute);
    }
  }

  void _updateIndexFromRoute(String route) {
    if (route.startsWith('/settings')) {
      if (_bottomTabController.index != 1) {
        _bottomTabController.animateTo(1);
      }
    } else {
      if (_bottomTabController.index != 0) {
        _bottomTabController.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width > 500 ? 500 : double.infinity,
          ),
          child: VersionWarningSnackbar(
            child: Scaffold(
              backgroundColor: isDarkTheme ? offBlack : offWhite,
              body: widget.child,
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom Navigation Bar - Styled exactly like dashboard_page.dart
                  Container(
                    width: double.infinity,
                    height: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.black : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _bottomTabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      labelColor: isDarkTheme ? Colors.white : Colors.black,
                      unselectedLabelColor:
                          isDarkTheme ? transparentWhite33 : transparentBlack33,
                      tabs: [
                        Container(
                          width: 75,
                          height: 74,
                          decoration: BoxDecoration(
                            color:
                                _bottomTabController.index == 0 && !isDarkTheme
                                    ? offWhite
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _bottomTabController.index == 0
                                  ? (isDarkTheme
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1))
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart_outline,
                                  size: 24,
                                  color: _bottomTabController.index == 0
                                      ? (isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      : (isDarkTheme
                                          ? transparentWhite33
                                          : transparentBlack33),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Portfolio',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _bottomTabController.index == 0
                                        ? (isDarkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        : (isDarkTheme
                                            ? transparentWhite33
                                            : transparentBlack33),
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 75,
                          height: 74,
                          decoration: BoxDecoration(
                            color:
                                _bottomTabController.index == 1 && !isDarkTheme
                                    ? offWhite
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _bottomTabController.index == 1
                                  ? (isDarkTheme
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1))
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: _bottomTabController.index == 1
                                      ? (isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      : (isDarkTheme
                                          ? transparentWhite33
                                          : transparentBlack33),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _bottomTabController.index == 1
                                        ? (isDarkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        : (isDarkTheme
                                            ? transparentWhite33
                                            : transparentBlack33),
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VersionWarningSnackbar extends StatefulWidget {
  final Widget child;

  const VersionWarningSnackbar({required this.child, super.key});

  @override
  VersionWarningState createState() => VersionWarningState();
}

class VersionWarningState extends State<VersionWarningSnackbar> {
  bool _hasShownSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final versionInfo = context
        .read<VersionCubit>()
        .state; // we should only ever get to this page if session is success

    if (!_hasShownSnackbar && versionInfo.warning != null) {
      switch (versionInfo.warning!) {
        case NewVersionAvailable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
        case VersionServiceUnreachable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'Version service unreachable.  Horizon Wallet may be out of date. Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
      }
    }

    if (!_hasShownSnackbar && versionInfo.current < versionInfo.latest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
          )),
        );
        _hasShownSnackbar = true;
      });
    }
  }

  @override
  Widget build(context) => widget.child;
}
