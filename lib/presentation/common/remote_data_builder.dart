import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;

import 'package:horizon/domain/entities/remote_data.dart';

/// Page payload returned by your data source.
class PagedResult<T, K> {
  final List<T> items;
  final K? nextKey; // null => no more pages

  const PagedResult({
    required this.items,
    required this.nextKey,
  });

  bool get hasMore => nextKey != null;
}

/// Builder signature for paged data.
/// - `refresh()` reloads from scratch
/// - `fetchNext()` loads the next page (no-op if none)
/// - `hasMore` indicates more pages are available
/// - `isFetchingNext` indicates an in-flight "load more" request
typedef RemotePagedDataBuilderFn<T> = Widget Function(
  BuildContext context,
  RemoteData<List<T>> state,
  Future<void> Function() refresh,
  Future<void> Function() fetchNext,
  bool hasMore,
  bool isFetchingNext,
);

class RemoteDataPagedTaskEitherBuilder<E extends Object, T, K>
    extends StatefulWidget {
  /// Loader for a page given the current `nextKey` (null => first page).
  final TaskEither<E, PagedResult<T, K>> Function(K? nextKey) loadPage;

  /// UI builder for aggregated items + paging controls.
  final RemotePagedDataBuilderFn<T> builder;

  /// Optional: stable key extractor for deduplication across overlapping pages.
  final Object Function(T item)? itemKey;

  /// Optional: initial key (usually null).
  final K? initialKey;

  const RemoteDataPagedTaskEitherBuilder({
    super.key,
    required this.loadPage,
    required this.builder,
    this.itemKey,
    this.initialKey,
  });

  @override
  State<RemoteDataPagedTaskEitherBuilder<E, T, K>> createState() =>
      _RemoteDataPagedTaskEitherBuilderState<E, T, K>();
}

class _RemoteDataPagedTaskEitherBuilderState<E extends Object, T, K>
    extends State<RemoteDataPagedTaskEitherBuilder<E, T, K>> {
  /// Aggregated items from refresh + subsequent pages.
  final List<T> _items = <T>[];

  /// Next page key from the most recent fetch (null => no more pages).
  K? _nextKey;

  /// Are we currently fetching a *next* page (not the initial/refresh load)?
  bool _fetchingNext = false;

  /// Bumps to force a rebuild of the inner task when we refresh.
  Object _refreshToken = Object();

  @override
  void initState() {
    super.initState();
    _nextKey = widget.initialKey;
  }

  @override
  void didUpdateWidget(
    covariant RemoteDataPagedTaskEitherBuilder<E, T, K> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadPage != widget.loadPage) {
      _resetAndKick();
    }
  }

  /// Task used by the *composed* RemoteDataTaskEitherBuilder during refresh.
  TaskEither<E, List<T>> _refreshTask() {
    return widget.loadPage(null).map((page) {
      // On refresh we *replace* aggregation with the first page.
      _items
        ..clear()
        ..addAll(page.items);
      _nextKey = page.nextKey;
      _fetchingNext = false;
      return _items.toList();
    });
  }

  void _resetAndKick() {
    setState(() {
      _items.clear();
      _nextKey = widget.initialKey;
      _fetchingNext = false;
      _refreshToken = Object();
    });
  }

  Future<void> _refresh() async {
    // Trigger the inner RemoteDataTaskEitherBuilder to run a new task.
    _resetAndKick();
    // No await here — inner builder owns the async lifecycle.
  }

  Future<void> _fetchNext() async {
    if (_fetchingNext || _nextKey == null) return;

    setState(() => _fetchingNext = true);

    final priorLen = _items.length;
    final result = await widget.loadPage(_nextKey).run();

    result.match(
      // On next-page error, keep existing list and stop pagination (simple default).
      (err) {
        print("error fetchng next $err");
        setState(() {
          _fetchingNext = false;
          _nextKey = null;
        });
      },
      (page) {
        print("succes fetching next: $page");
        final incoming = page.items;
        if (incoming.isNotEmpty) {
          if (widget.itemKey != null) {
            final keyOf = widget.itemKey!;
            final seen = _items.map(keyOf).toSet();
            for (final t in incoming) {
              final k = keyOf(t);
              if (!seen.contains(k)) {
                _items.add(t);
                seen.add(k);
              }
            }
          } else {
            _items.addAll(incoming);
          }
        }
        setState(() {
          _nextKey = page.nextKey;
          _fetchingNext = false;
        });
      },
    );

    // Guard: zero new items but claims more → stop looping.
    if (_items.length == priorLen && _nextKey != null) {
      setState(() => _nextKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compose: inner builder manages the *refresh* remote state.
    // We translate its state to the aggregated list state we expose.
    return RemoteDataTaskEitherBuilder<E, List<T>>(
      key: ValueKey(_refreshToken),
      task: _refreshTask(),
      builder: (context, refreshState, innerRefresh) {
        final RemoteData<List<T>> outward = switch (refreshState) {
          Initial<List<T>>() => const Initial(),
          Loading<List<T>>() => const Loading(),
          Failure<List<T>>(:final error) => () {
              // On refresh failure, clear paging so a manual refresh can retry.
              _items.clear();
              _nextKey = null;
              _fetchingNext = false;
              return Failure<List<T>>(error);
            }(),
          Refreshing<List<T>>(:final value) => Refreshing<List<T>>(value),
          Success<List<T>>(:final value) => Success<List<T>>(value),
        };

        // If we’re fetching next, keep outward Success/Refreshing as-is;
        // callers can show a tail spinner via `isFetchingNext`.
        final hasMore = _nextKey != null;

        print("hasMore $hasMore");
        print("nextkey $_nextKey");

        return widget.builder(
          context,
          outward,
          _refresh,
          _fetchNext,
          hasMore,
          _fetchingNext,
        );
      },
    );
  }
}

/// A pagination-aware builder driven by a TaskEither-based page loader.
/// It aggregates items across pages and exposes a familiar RemoteData<List<T>>.

typedef RemoteDataBuilderFn<T> = Widget Function(
  BuildContext context,
  RemoteData<T> state,
  Future<void> Function() refresh,
);

class RemoteDataTaskEitherBuilder<E extends Object, T> extends StatefulWidget {
  final TaskEither<E, T> task;
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
  Object _reloadToken = Object();
  T? _latestValue;

  @override
  void initState() {
    super.initState();
    _future = widget.task.run(); // ← TaskEither → Future
  }

  @override
  void didUpdateWidget(covariant RemoteDataTaskEitherBuilder<E, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) _run();
  }

  Future<void> _run() async {
    setState(() {
      _reloadToken = Object(); // force a new key for the builder
      _future = widget.task.run();
    });
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
