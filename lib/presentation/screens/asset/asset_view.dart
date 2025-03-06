import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_bloc.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/asset_icon.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

class AssetView extends StatefulWidget {
  final String assetName;

  const AssetView({
    super.key,
    required this.assetName,
  });

  @override
  State<AssetView> createState() => _AssetViewState();
}

class _AssetViewState extends State<AssetView> {
  @override
  void initState() {
    super.initState();
    context.read<AssetViewBloc>().add(PageLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AssetViewBloc, RemoteDataState<MultiAddressBalance>>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (error) => SelectableText(error),
          success: (balance) => Column(
            children: [
              // Asset page header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDarkTheme ? Colors.white : Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        context.go('/dashboard');
                      },
                    ),
                    const SizedBox(width: 4),
                    AssetIcon(asset: balance.asset, size: 40),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        SelectableText(
                          balance.asset,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        balance.assetLongname != null
                            ? SelectableText(
                                textAlign: TextAlign.left,
                                balance.assetLongname!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: isDarkTheme
                                            ? transparentWhite33
                                            : transparentBlack33,
                                        fontSize: 12))
                            : const SizedBox.shrink(),
                        SelectableText(
                          balance.totalNormalized,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: isDarkTheme
                                      ? transparentWhite33
                                      : transparentBlack33,
                                  fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Asset page content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Asset details card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDarkTheme
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Asset icon and name row
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey, // Placeholder color
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.assetName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // More details can be added here in the future
                            Text(
                              'Asset Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDarkTheme ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'More information about ${widget.assetName} will be displayed here.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkTheme
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
