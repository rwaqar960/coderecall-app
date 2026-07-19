import 'package:flutter/material.dart';

/// Shared visual language for the app — mirrors the website's branding
/// (same seed color, same Inter typeface, same pill/monogram motifs).
///
/// Inter is bundled as a local asset (see pubspec.yaml `fonts:`), not fetched
/// via the google_fonts package — that package downloads font files over the
/// network on first use, which would break this app's offline-first guarantee.
abstract final class AppTheme {
  static const seed = Color(0xFF00696B);
  static const fontFamily = 'Inter';

  static ThemeData of(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final textTheme = base.textTheme.apply(fontFamily: fontFamily);
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleLarge!.copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: const CardThemeData(elevation: 0),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelLarge,
        backgroundColor: scheme.surfaceContainerHighest,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }
}

/// Two-letter course badge, same motif as the website's homepage cards.
class Monogram extends StatelessWidget {
  const Monogram({super.key, required this.courseId, this.size = 44, this.tinted = true});

  final String courseId;
  final double size;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = tinted ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final foreground = tinted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        courseId.length >= 2 ? courseId.substring(0, 2).toUpperCase() : courseId.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

/// Small uppercase pill label — mirrors the "Bundled" / "Downloadable"
/// delivery pills on the website's course cards.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.emphasis = false});

  final String label;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasis ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: emphasis ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Small ring showing progress as a percentage — used wherever a chapter or
/// quiz completion fraction needs to read at a glance instead of as a bar.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.size = 40});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 4,
            color: scheme.surfaceContainerHighest,
          ),
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            color: scheme.primary,
            backgroundColor: Colors.transparent,
          ),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.23,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
