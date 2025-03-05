import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Column(
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
              const SizedBox(width: 8),
              Text(
                widget.assetName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
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
                                color:
                                    isDarkTheme ? Colors.white : Colors.black,
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
                          color: isDarkTheme ? Colors.white : Colors.black,
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
    );
  }
}
