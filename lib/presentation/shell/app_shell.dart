import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
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

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateIndexFromRoute(widget.currentRoute);
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      _updateIndexFromRoute(widget.currentRoute);
    }
  }

  void _updateIndexFromRoute(String route) {
    if (route.startsWith('/dashboard')) {
      setState(() => _currentIndex = 0);
    } else if (route.startsWith('/settings')) {
      setState(() => _currentIndex = 1);
    }
    // For other routes, we maintain the current index
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
              backgroundColor: isDarkTheme ? Colors.black : Colors.white,
              body: widget.child,
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom Navigation Bar
                  Container(
                    width: double.infinity,
                    height: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDarkTheme
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Portfolio',
                          index: 0,
                          route: '/dashboard',
                        ),
                        _buildNavItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          index: 1,
                          route: '/settings',
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
        context.go(route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.purple
                : (isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Colors.purple
                  : (isDarkTheme ? Colors.white : Colors.black)
                      .withOpacity(0.5),
            ),
          ),
        ],
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

    final versionInfo = context.read<VersionCubit>().state;

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
