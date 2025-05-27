import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;

import 'package:horizon/domain/entities/remote_data.dart';
typedef RemoteDataBuilderFn<T> = Widget Function(
  BuildContext context,
  RemoteData<T> state,
  Future<void> Function() refresh,
);

class RemoteDataTaskEitherBuilder<E extends Object, T> extends StatefulWidget {
  final TaskEither<E, T> Function() task;
  final RemoteDataBuilderFn<T> builder;

  const RemoteDataTaskEitherBuilder({
    super.key,
    required this.task,
    required this.builder,
  });

  @override
  State<RemoteDataTaskEitherBuilder<E, T>> createState() =>
      _RemoteDataTaskEitherBuilderState<E, T>();
}

class _RemoteDataTaskEitherBuilderState<E extends Object, T>
    extends State<RemoteDataTaskEitherBuilder<E, T>> {
  late Future<Either<E, T>> _future;
  T? _latestValue;

  @override
  void initState() {
    super.initState();
    _future = widget.task().run(); // ← TaskEither → Future
  }

  @override
  void didUpdateWidget(covariant RemoteDataTaskEitherBuilder<E, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) _run();
  }

  Future<void> _run() async {
    setState(() => _future = widget.task().run());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<E, T>>(
      future: _future,
      builder: (context, snap) {
        final RemoteData<T> state = switch (snap.connectionState) {
          ConnectionState.none => const Initial(),
          ConnectionState.waiting ||
          ConnectionState.active =>
            _latestValue != null
                ? Refreshing(_latestValue as T)
                : const Loading(),
          ConnectionState.done => () {
              if (snap.hasError) {
                return Failure<T>(snap.error!);
              }

              final either = snap.data;
              if (either == null) return Failure<T>('invariant: null result');

              return either.match(
                (err) => Failure<T>(err),
                (val) {
                  _latestValue = val;
                  return Success<T>(val);
                },
              );
            }(),
        };

        return widget.builder(context, state, _run);
      },
    );
  }
}
