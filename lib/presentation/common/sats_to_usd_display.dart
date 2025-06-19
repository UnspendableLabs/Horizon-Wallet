import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/mempool_price_service.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class SatsToUsdDisplay extends StatefulWidget {
  final BigInt sats;
  final Function(double)? child;
  
  const SatsToUsdDisplay({
    super.key,
    required this.sats,
    this.child,
  });

  @override
  State<SatsToUsdDisplay> createState() => _SatsToUsdDisplayState();
}

class _SatsToUsdDisplayState extends State<SatsToUsdDisplay> {
  final _priceService = GetIt.I<MempoolPriceService>();
  StreamSubscription<int>? _subscription;
  int? _currentPrice;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    _priceService.startListening(httpConfig: session.httpConfig);
    _subscription = _priceService.priceStream.listen((price) {
      setState(() => _currentPrice = price);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _priceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPrice == null) {
      return const SizedBox.shrink();
    }

    final usdValue = (widget.sats * BigInt.from(_currentPrice!)) / BigInt.from(100000000);
    return widget.child?.call(usdValue) ?? Text(
      '\$${usdValue.toStringAsFixed(2)}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  } 
}