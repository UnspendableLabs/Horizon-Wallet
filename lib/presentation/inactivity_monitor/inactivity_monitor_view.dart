import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inactivity_monitor_bloc.dart';

class InactivityMonitorView extends StatefulWidget {
  final Widget child;

  final VoidCallback onTimeout;

  final bool autoStart;

  const InactivityMonitorView({
    super.key,
    required this.child,
    required this.onTimeout,
    this.autoStart = true,
  });

  @override
  State<InactivityMonitorView> createState() => _InactivityMonitorViewState();
}

class _InactivityMonitorViewState extends State<InactivityMonitorView>
    with WidgetsBindingObserver {
  InactivityMonitorBloc? _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bloc = context.read<InactivityMonitorBloc>();

    if (widget.autoStart) {
      _bloc?.add(InactivityMonitorStarted());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ) {
      _bloc?.add(AppLostFocus());
    } else if (state == AppLifecycleState.resumed) {
      _bloc?.add(AppResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InactivityMonitorBloc, InactivityMonitorState>(
      listener: (context, state) {
        if (state is TimeoutOut) {
          widget.onTimeout();
        }
      },
      child: Listener(
        onPointerDown: (_) {
          _bloc?.add(UserActivityDetected());
        },
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}
