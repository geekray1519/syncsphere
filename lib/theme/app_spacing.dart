/// SyncSphere design system — spacing, sizing, and animation constants.
/// Consistent spacing creates visual rhythm and hierarchy.
class AppSpacing {
  AppSpacing._();

  // ── Vertical / General Spacing ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // ── Page Layout ──
  static const double pagePadding = 16.0;
  static const double sectionGap = 24.0;
  static const double itemGap = 12.0;

  // ── Card ──
  static const double cardPadding = 16.0;
  static const double cardInnerPadding = 12.0;

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 28.0;

  // ── Responsive Breakpoints ──
  static const double mobileBreakpoint = 700.0;
  static const double desktopBreakpoint = 900.0;
  static const double maxContentWidth = 600.0;

  // ── Icon Sizes ──
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconHero = 64.0;

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Progress Bar ──
  static const double progressBarHeight = 8.0;
  static const double progressBarHeightLg = 12.0;
}
