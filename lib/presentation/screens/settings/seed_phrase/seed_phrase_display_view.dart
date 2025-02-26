import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class SeedPhraseDisplayView extends StatefulWidget {
  final String seedPhrase;

  const SeedPhraseDisplayView({
    super.key,
    required this.seedPhrase,
  });

  @override
  State<SeedPhraseDisplayView> createState() => _SeedPhraseDisplayViewState();
}

class _SeedPhraseDisplayViewState extends State<SeedPhraseDisplayView> {
  bool _showSeedPhrase = false;
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.seedPhrase));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final words = widget.seedPhrase.split(' ');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 40,
        toolbarHeight: 74,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            "Seed phrase",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 9.0, top: 18.0),
          child: BackButton(
            color: isDarkTheme ? Colors.white : Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Seed Phrase',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write down these 12 words in order and keep them safe.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isDarkTheme
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _showSeedPhrase ? words[index] : '••••',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: transparentPurple8,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSeedPhrase = !_showSeedPhrase;
                          });
                        },
                        icon: Icon(
                          _showSeedPhrase
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        label: Text(_showSeedPhrase ? 'Hide' : 'Show'),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: transparentPurple8,
                        ),
                        onPressed: _copyToClipboard,
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                        ),
                        label: Text(_copied ? 'Copied!' : 'Copy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
