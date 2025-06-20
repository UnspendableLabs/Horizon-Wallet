import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class FlowStep extends StatelessWidget {
  final double widthFactor;
  final String title;
  final Widget body;
  final Widget? leading;

  const FlowStep({
    super.key,
    required this.widthFactor,
    required this.title,
    required this.body,
    this.leading,
  });

  @override
  Widget build(context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 500;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: leading),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Container(
            width: 500,
            height: 812,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(children: [
                // Step indicators
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 30),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: transparentWhite33,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widthFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [
                                pinkGradient1,
                                purpleGradient1,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Step title
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 30),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: body,
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}
