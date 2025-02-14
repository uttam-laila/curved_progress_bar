library curved_progress_bar;

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kMinCurvedCircularProgressIndicatorSize = 36.0;
const int _kIndeterminateLinearDuration = 1800;
const int _kIndeterminateCircularDuration = 1333 * 2222;

enum _ActivityIndicatorType { material, adaptive }

/// A base class for material design progress indicators.
///
/// This widget cannot be instantiated directly. For a linear progress
/// indicator, see [CurvedLinearProgressIndicator]. For a circular progress indicator,
/// see [CurvedCircularProgressIndicator].
///
/// See also:
///
///  * <https://material.io/components/progress-indicators>
abstract class ProgressIndicator extends StatefulWidget {
  /// Creates a progress indicator.
  ///
  /// {@template flutter.material.ProgressIndicator.ProgressIndicator}
  /// The [value] argument can either be null for an indeterminate
  /// progress indicator, or a non-null value between 0.0 and 1.0 for a
  /// determinate progress indicator.
  ///
  /// ## Accessibility
  ///
  /// The [semanticsLabel] can be used to identify the purpose of this progress
  /// bar for screen reading software. The [semanticsValue] property may be used
  /// for determinate progress indicators to indicate how much progress has been made.
  /// {@endtemplate}
  const ProgressIndicator({
    Key? key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = 4.0,
    this.animationDuration,
  }) : super(key: key);

  /// If non-null, the value of this progress indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// If null, this progress indicator is indeterminate, which means the
  /// indicator displays a predetermined animation that does not indicate how
  /// much actual progress is being made.
  final double? value;

  //Added by Uttam_laila for value animation
  final Duration? animationDuration;

  /// The progress indicator's background color.
  ///
  /// It is up to the subclass to implement this in whatever way makes sense
  /// for the given use case. See the subclass documentation for details.
  final Color? backgroundColor;

  /// {@template flutter.progress_indicator.ProgressIndicator.color}
  /// The progress indicator's color.
  ///
  /// This is only used if [ProgressIndicator.valueColor] is null.
  /// If [ProgressIndicator.color] is also null, then the ambient
  /// [ProgressIndicatorThemeData.color] will be used. If that
  /// is null then the current theme's [ColorScheme.primary] will
  /// be used by default.
  /// {@endtemplate}
  final Color? color;

  /// The progress indicator's color as an animated value.
  ///
  /// If null, the progress indicator is rendered with [color]. If that is null,
  /// then it will use the ambient [ProgressIndicatorThemeData.color]. If that
  /// is also null then it defaults to the current theme's [ColorScheme.primary].
  final Animation<Color?>? valueColor;

  /// {@template flutter.progress_indicator.ProgressIndicator.semanticsLabel}
  /// The [SemanticsProperties.label] for this progress indicator.
  ///
  /// This value indicates the purpose of the progress bar, and will be
  /// read out by screen readers to indicate the purpose of this progress
  /// indicator.
  /// {@endtemplate}
  final String? semanticsLabel;

  /// {@template flutter.progress_indicator.ProgressIndicator.semanticsValue}
  /// The [SemanticsProperties.value] for this progress indicator.
  ///
  /// This will be used in conjunction with the [semanticsLabel] by
  /// screen reading software to identify the widget, and is primarily
  /// intended for use with determinate progress indicators to announce
  /// how far along they are.
  ///
  /// For determinate progress indicators, this will be defaulted to
  /// [ProgressIndicator.value] expressed as a percentage, i.e. `0.1` will
  /// become '10%'.
  /// {@endtemplate}
  final String? semanticsValue;

  ///Stroke width
  final double? strokeWidth;

  Color _getValueColor(BuildContext context) {
    return valueColor?.value ??
        color ??
        ProgressIndicatorTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(PercentProperty('value', value,
        showName: false, ifNull: '<indeterminate>'));
  }

  Widget _buildSemanticsWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    String? expandedSemanticsValue = semanticsValue;
    if (value != null) {
      expandedSemanticsValue ??= '${(value! * 100).round()}%';
    }
    return Semantics(
      label: semanticsLabel,
      value: expandedSemanticsValue,
      child: child,
    );
  }
}

class _CurvedLinearProgressIndicatorPainter extends CustomPainter {
  const _CurvedLinearProgressIndicatorPainter({
    required this.backgroundColor,
    required this.valueColor,
    this.value,
    required this.strokeWidth,
    required this.animationValue,
    required this.textDirection,
  });

  final Color backgroundColor;
  final Color valueColor;
  final double? value;
  final double strokeWidth;
  final double animationValue;
  final TextDirection textDirection;

  // The indeterminate progress animation displays two lines whose leading (head)
  // and trailing (tail) endpoints are defined by the following four curves.
  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width, 0),
      Offset.zero,
      paint,
    );

    paint.color = valueColor;

    void drawBar(double x, double width) {
      if (width <= 0.0) {
        return;
      }

      final double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }
      paint.strokeCap = StrokeCap.round;
      paint.strokeWidth = strokeWidth;
      if (value != null) {
        canvas.drawLine(
          const Offset(2, 0),
          Offset(width, 0),
          paint,
        );
      }

      canvas.drawLine(
        Offset(left + width, 0),
        Offset(left, 0),
        paint,
      );
    }

    if (value != null) {
      drawBar(0.0, value!.clamp(0.0, 1.0) * size.width);
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 =
          size.width * line1Head.transform(animationValue) - x1;

      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 =
          size.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(_CurvedLinearProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.animationValue != animationValue ||
        oldPainter.textDirection != textDirection;
  }
}

/// A material design linear progress indicator, also known as a progress bar.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=O-rhXZLtpv0}
///
/// A widget that shows progress along a line. There are two kinds of linear
/// progress indicators:
///
///  * _Determinate_. Determinate progress indicators have a specific value at
///    each point in time, and the value should increase monotonically from 0.0
///    to 1.0, at which time the indicator is complete. To create a determinate
///    progress indicator, use a non-null [value] between 0.0 and 1.0.
///  * _Indeterminate_. Indeterminate progress indicators do not have a specific
///    value at each point in time and instead indicate that progress is being
///    made without indicating how much progress remains. To create an
///    indeterminate progress indicator, use a null [value].
///
/// The indicator line is displayed with [valueColor], an animated value. To
/// specify a constant color value use: `AlwaysStoppedAnimation<Color>(color)`.
///
/// The minimum height of the indicator can be specified using [minHeight].
/// The indicator can be made taller by wrapping the widget with a [SizedBox].
///
/// {@tool dartpad}
/// This example shows a [CurvedLinearProgressIndicator] with a changing value.
///
/// ** See code in examples/api/lib/material/progress_indicator/linear_progress_indicator.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CurvedCircularProgressIndicator], which shows progress along a circular arc.
///  * [RefreshIndicator], which automatically displays a [CurvedCircularProgressIndicator]
///    when the underlying vertical scrollable is overscrolled.
///  * <https://material.io/design/components/progress-indicators.html#linear-progress-indicators>
class CurvedLinearProgressIndicator extends ProgressIndicator {
  /// Creates a linear progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const CurvedLinearProgressIndicator({
    Key? key,
    double? value,
    Color? backgroundColor,
    Color? color,
    Animation<Color?>? valueColor,
    this.minHeight,
    double? strokeWidth,
    String? semanticsLabel,
    String? semanticsValue,
    Duration? animationDuration,
  })  : assert(minHeight == null || minHeight > 0),
        super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          color: color,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
          strokeWidth: strokeWidth,
          animationDuration: animationDuration,
        );

  /// {@template flutter.material.CurvedLinearProgressIndicator.trackColor}
  /// Color of the track being filled by the linear indicator.
  ///
  /// If [CurvedLinearProgressIndicator.backgroundColor] is null then the
  /// ambient [ProgressIndicatorThemeData.linearTrackColor] will be used.
  /// If that is null, then the ambient theme's [ColorScheme.background]
  /// will be used to draw the track.
  /// {@endtemplate}
  @override
  Color? get backgroundColor => super.backgroundColor;

  /// {@template flutter.material.CurvedLinearProgressIndicator.minHeight}
  /// The minimum height of the line used to draw the linear indicator.
  ///
  /// If [CurvedLinearProgressIndicator.minHeight] is null then it will use the
  /// ambient [ProgressIndicatorThemeData.linearMinHeight]. If that is null
  /// it will use 4dp.
  /// {@endtemplate}
  final double? minHeight;

  @override
  State<CurvedLinearProgressIndicator> createState() =>
      _CurvedLinearProgressIndicatorState();
}

class _CurvedLinearProgressIndicatorState
    extends State<CurvedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ??
          const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CurvedLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {
    final ProgressIndicatorThemeData indicatorTheme =
        ProgressIndicatorTheme.of(context);
    final Color trackColor = widget.backgroundColor ??
        indicatorTheme.linearTrackColor ??
        Theme.of(context).colorScheme.background;
    final double minHeight = widget.minHeight ??
        widget.strokeWidth ??
        indicatorTheme.linearMinHeight ??
        4.0;

    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: minHeight,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(120),
        ),
        child: CustomPaint(
          painter: _CurvedLinearProgressIndicatorPainter(
            backgroundColor: trackColor,
            valueColor: widget._getValueColor(context),
            strokeWidth: widget.strokeWidth ?? 4.0,
            value: widget.value, // may be null
            animationValue:
                animationValue, // ignored if widget.value is not null
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null) {
      return _buildIndicator(context, _controller.value, textDirection);
    }

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget? child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}

class _CurvedCircularProgressIndicatorPainter extends CustomPainter {
  _CurvedCircularProgressIndicatorPainter({
    this.backgroundColor,
    required this.valueColor,
    required this.value,
    required this.headValue,
    required this.tailValue,
    required this.offsetValue,
    required this.rotationValue,
    required this.strokeWidth,
  })  : arcStart = value != null
            ? _startAngle
            : _startAngle +
                tailValue * 3 / 2 * math.pi +
                rotationValue * math.pi * 2.0 +
                offsetValue * 0.5 * math.pi,
        arcSweep = value != null
            ? value.clamp(0.0, 1.0) * _sweep
            : math.max(
                headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi,
                _epsilon);

  final Color? backgroundColor;
  final Color valueColor;
  final double? value;
  final double strokeWidth;
  final double headValue;
  final double tailValue;
  final double offsetValue;
  final double rotationValue;

  final double arcStart;
  final double arcSweep;

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (backgroundColor != null) {
      final Paint backgroundPaint = Paint()
        ..color = backgroundColor!
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Offset.zero & size, 0, _sweep, false, backgroundPaint);
    }

    if (value == null) // Indeterminate
    {
      paint.strokeCap = StrokeCap.round;
    }
    /*  for (var i = 0.0; i < arcSweep; i += 0.01) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) { */
    canvas.drawArc(Offset.zero & size, arcStart, arcSweep, false, paint);
    /*   });
    } */
  }

  @override
  bool shouldRepaint(_CurvedCircularProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.headValue != headValue ||
        oldPainter.tailValue != tailValue ||
        oldPainter.offsetValue != offsetValue ||
        oldPainter.rotationValue != rotationValue ||
        oldPainter.strokeWidth != strokeWidth;
  }
}

/// A material design circular progress indicator, which spins to indicate that
/// the application is busy.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=O-rhXZLtpv0}
///
/// A widget that shows progress along a circle. There are two kinds of circular
/// progress indicators:
///
///  * _Determinate_. Determinate progress indicators have a specific value at
///    each point in time, and the value should increase monotonically from 0.0
///    to 1.0, at which time the indicator is complete. To create a determinate
///    progress indicator, use a non-null [value] between 0.0 and 1.0.
///  * _Indeterminate_. Indeterminate progress indicators do not have a specific
///    value at each point in time and instead indicate that progress is being
///    made without indicating how much progress remains. To create an
///    indeterminate progress indicator, use a null [value].
///
/// The indicator arc is displayed with [valueColor], an animated value. To
/// specify a constant color use: `AlwaysStoppedAnimation<Color>(color)`.
///
/// {@tool dartpad}
/// This example shows a [CurvedCircularProgressIndicator] with a changing value.
///
/// ** See code in examples/api/lib/material/progress_indicator/circular_progress_indicator.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CurvedLinearProgressIndicator], which displays progress along a line.
///  * [RefreshIndicator], which automatically displays a [CurvedCircularProgressIndicator]
///    when the underlying vertical scrollable is overscrolled.
///  * <https://material.io/design/components/progress-indicators.html#circular-progress-indicators>
class CurvedCircularProgressIndicator extends ProgressIndicator {
  /// Creates a circular progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const CurvedCircularProgressIndicator({
    Key? key,
    Duration? animationDuration,
    double? value,
    Color? backgroundColor,
    Color? color,
    Animation<Color?>? valueColor,
    double? strokeWidth,
    String? semanticsLabel,
    String? semanticsValue,
  })  : _indicatorType = _ActivityIndicatorType.material,
        super(
          key: key,
          animationDuration: animationDuration,
          value: value,
          backgroundColor: backgroundColor,
          color: color,
          valueColor: valueColor,
          strokeWidth: strokeWidth,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  /// Creates an adaptive progress indicator that is a
  /// [CupertinoActivityIndicator] in iOS and [CurvedCircularProgressIndicator] in
  /// material theme/non-iOS.
  ///
  /// The [value], [backgroundColor], [valueColor], [strokeWidth],
  /// [semanticsLabel], and [semanticsValue] will be ignored in iOS.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const CurvedCircularProgressIndicator.adaptive({
    Key? key,
    double? value,
    Color? backgroundColor,
    Animation<Color?>? valueColor,
    double? strokeWidth,
    String? semanticsLabel,
    String? semanticsValue,
  })  : _indicatorType = _ActivityIndicatorType.adaptive,
        super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
          strokeWidth: strokeWidth,
        );

  final _ActivityIndicatorType _indicatorType;

  /// {@template flutter.material.CurvedCircularProgressIndicator.trackColor}
  /// Color of the circular track being filled by the circular indicator.
  ///
  /// If [CurvedCircularProgressIndicator.backgroundColor] is null then the
  /// ambient [ProgressIndicatorThemeData.circularTrackColor] will be used.
  /// If that is null, then the track will not be painted.
  /// {@endtemplate}
  @override
  Color? get backgroundColor => super.backgroundColor;

  /// The width of the line used to draw the circle.
  @override
  double? get strokeWidth;

  @override
  State<CurvedCircularProgressIndicator> createState() =>
      _CurvedCircularProgressIndicatorState();
}

class _CurvedCircularProgressIndicatorState
    extends State<CurvedCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  static const int _pathCount = _kIndeterminateCircularDuration ~/ 1333;
  static const int _rotationCount = _kIndeterminateCircularDuration ~/ 2222;

  static final Animatable<double> _strokeHeadTween = CurveTween(
    curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(_pathCount),
  ));
  static final Animatable<double> _strokeTailTween = CurveTween(
    curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
  ).chain(CurveTween(
    curve: const SawTooth(_pathCount),
  ));
  static final Animatable<double> _offsetTween =
      CurveTween(curve: const SawTooth(_pathCount));
  static final Animatable<double> _rotationTween =
      CurveTween(curve: const SawTooth(_rotationCount));

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
          milliseconds: (widget.animationDuration != null
                  ? widget.animationDuration!.inMilliseconds * 2222
                  : null) ??
              _kIndeterminateCircularDuration),
      vsync: this,
    );
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CurvedCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCupertinoIndicator(BuildContext context) {
    final Color? tickColor = widget.backgroundColor;
    return CupertinoActivityIndicator(key: widget.key, color: tickColor);
  }

  Widget _buildMaterialIndicator(BuildContext context, double headValue,
      double tailValue, double offsetValue, double rotationValue) {
    final Color? trackColor = widget.backgroundColor ??
        ProgressIndicatorTheme.of(context).circularTrackColor;

    return widget._buildSemanticsWrapper(
      context: context,
      child: widget.value != null
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: widget.value),
              duration: widget.animationDuration ?? Duration.zero,
              builder: (context, value, _) => Container(
                constraints: const BoxConstraints(
                  minWidth: _kMinCurvedCircularProgressIndicatorSize,
                  minHeight: _kMinCurvedCircularProgressIndicatorSize,
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(120)),
                child: CustomPaint(
                  painter: _CurvedCircularProgressIndicatorPainter(
                    backgroundColor: trackColor,
                    valueColor: widget._getValueColor(context),
                    value: value, // may be null
                    headValue:
                        headValue, // remaining arguments are ignored if widget.value is not null
                    tailValue: tailValue,
                    offsetValue: offsetValue,
                    rotationValue: rotationValue,
                    strokeWidth: widget.strokeWidth ?? 4.0,
                  ),
                ),
              ),
            )
          : Container(
              constraints: const BoxConstraints(
                minWidth: _kMinCurvedCircularProgressIndicatorSize,
                minHeight: _kMinCurvedCircularProgressIndicatorSize,
              ),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(120)),
              child: CustomPaint(
                painter: _CurvedCircularProgressIndicatorPainter(
                  backgroundColor: trackColor,
                  valueColor: widget._getValueColor(context),
                  value: widget.value, // may be null
                  headValue:
                      headValue, // remaining arguments are ignored if widget.value is not null
                  tailValue: tailValue,
                  offsetValue: offsetValue,
                  rotationValue: rotationValue,
                  strokeWidth: widget.strokeWidth ?? 4.0,
                ),
              ),
            ),
    );
  }

  Widget _buildAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return _buildMaterialIndicator(
          context,
          _strokeHeadTween.evaluate(_controller),
          _strokeTailTween.evaluate(_controller),
          _offsetTween.evaluate(_controller),
          _rotationTween.evaluate(_controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget._indicatorType) {
      case _ActivityIndicatorType.material:
        if (widget.value != null) {
          return _buildMaterialIndicator(context, 0.0, 0.0, 0, 0.0);
        }
        return _buildAnimation();
      case _ActivityIndicatorType.adaptive:
        final ThemeData theme = Theme.of(context);
        switch (theme.platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            return _buildCupertinoIndicator(context);
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            if (widget.value != null) {
              return _buildMaterialIndicator(context, 0.0, 0.0, 0, 0.0);
            }
            return _buildAnimation();
        }
    }
  }
}

class _RefreshProgressIndicatorPainter
    extends _CurvedCircularProgressIndicatorPainter {
  _RefreshProgressIndicatorPainter({
    required Color valueColor,
    required double? value,
    required double headValue,
    required double tailValue,
    required double offsetValue,
    required double rotationValue,
    required double strokeWidth,
    required this.arrowheadScale,
  }) : super(
          valueColor: valueColor,
          value: value,
          headValue: headValue,
          tailValue: tailValue,
          offsetValue: offsetValue,
          rotationValue: rotationValue,
          strokeWidth: strokeWidth,
        );

  final double arrowheadScale;

  void paintArrowhead(Canvas canvas, Size size) {
    // ux, uy: a unit vector whose direction parallels the base of the arrowhead.
    // (So ux, -uy points in the direction the arrowhead points.)
    final double arcEnd = arcStart + arcSweep;
    final double ux = math.cos(arcEnd);
    final double uy = math.sin(arcEnd);

    assert(size.width == size.height);
    final double radius = size.width / 2.0;
    final double arrowheadPointX =
        radius + ux * radius + -uy * strokeWidth * 2.0 * arrowheadScale;
    final double arrowheadPointY =
        radius + uy * radius + ux * strokeWidth * 2.0 * arrowheadScale;
    final double arrowheadRadius = strokeWidth * 2.0 * arrowheadScale;
    final double innerRadius = radius - arrowheadRadius;
    final double outerRadius = radius + arrowheadRadius;

    final Path path = Path()
      ..moveTo(radius + ux * innerRadius, radius + uy * innerRadius)
      ..lineTo(radius + ux * outerRadius, radius + uy * outerRadius)
      ..lineTo(arrowheadPointX, arrowheadPointY)
      ..close();
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    if (arrowheadScale > 0.0) {
      paintArrowhead(canvas, size);
    }
  }
}

/// An indicator for the progress of refreshing the contents of a widget.
///
/// Typically used for swipe-to-refresh interactions. See [RefreshIndicator] for
/// a complete implementation of swipe-to-refresh driven by a [Scrollable]
/// widget.
///
/// The indicator arc is displayed with [valueColor], an animated value. To
/// specify a constant color use: `AlwaysStoppedAnimation<Color>(color)`.
///
/// See also:
///
///  * [RefreshIndicator], which automatically displays a [CurvedCircularProgressIndicator]
///    when the underlying vertical scrollable is overscrolled.
class RefreshProgressIndicator extends CurvedCircularProgressIndicator {
  /// Creates a refresh progress indicator.
  ///
  /// Rather than creating a refresh progress indicator directly, consider using
  /// a [RefreshIndicator] together with a [Scrollable] widget.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const RefreshProgressIndicator({
    Key? key,
    double? value,
    Color? backgroundColor,
    Color? color,
    Animation<Color?>? valueColor,
    double?
        strokeWidth, // Different default than CurvedCircularProgressIndicator.
    String? semanticsLabel,
    String? semanticsValue,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          color: color,
          valueColor: valueColor,
          strokeWidth: strokeWidth ?? 4.0,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  /// {@template flutter.material.RefreshProgressIndicator.backgroundColor}
  /// Background color of that fills the circle under the refresh indicator.
  ///
  /// If [RefreshIndicator.backgroundColor] is null then the
  /// ambient [ProgressIndicatorThemeData.refreshBackgroundColor] will be used.
  /// If that is null, then the ambient theme's [ThemeData.canvasColor]
  /// will be used.
  /// {@endtemplate}
  @override
  Color? get backgroundColor => super.backgroundColor;

  @override
  State<CurvedCircularProgressIndicator> createState() =>
      _RefreshProgressIndicatorState();
}

class _RefreshProgressIndicatorState
    extends _CurvedCircularProgressIndicatorState {
  static const double _indicatorSize = 41.0;

  /// Interval for arrow head to fully grow.
  static const double _strokeHeadInterval = 0.33;

  late final Animatable<double> _convertTween = CurveTween(
    curve: const Interval(0.1, _strokeHeadInterval),
  );

  late final Animatable<double> _additionalRotationTween =
      TweenSequence<double>(
    <TweenSequenceItem<double>>[
      // Makes arrow to expand a little bit earlier, to match the Android look.
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -0.1, end: -0.2),
        weight: _strokeHeadInterval,
      ),
      // Additional rotation after the arrow expanded
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -0.2, end: 1.35),
        weight: 1 - _strokeHeadInterval,
      ),
    ],
  );

  // Last value received from the widget before null.
  double? _lastValue;

  // Always show the indeterminate version of the circular progress indicator.
  //
  // When value is non-null the sweep of the progress indicator arrow's arc
  // varies from 0 to about 300 degrees.
  //
  // When value is null the arrow animation starting from wherever we left it.
  @override
  Widget build(BuildContext context) {
    final double? value = widget.value;
    if (value != null) {
      _lastValue = value;
      _controller.value = _convertTween.transform(value) *
          (1333 / 2 / _kIndeterminateCircularDuration);
    }
    return _buildAnimation();
  }

  @override
  Widget _buildAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return _buildMaterialIndicator(
          context,
          // Lengthen the arc a little
          1.05 *
              _CurvedCircularProgressIndicatorState._strokeHeadTween
                  .evaluate(_controller),
          _CurvedCircularProgressIndicatorState._strokeTailTween
              .evaluate(_controller),
          _CurvedCircularProgressIndicatorState._offsetTween
              .evaluate(_controller),
          _CurvedCircularProgressIndicatorState._rotationTween
              .evaluate(_controller),
        );
      },
    );
  }

  @override
  Widget _buildMaterialIndicator(BuildContext context, double headValue,
      double tailValue, double offsetValue, double rotationValue) {
    final double? value = widget.value;
    final double arrowheadScale = value == null
        ? 0.0
        : const Interval(0.1, _strokeHeadInterval).transform(value);
    final double rotation;

    if (value == null && _lastValue == null) {
      rotation = 0.0;
    } else {
      rotation =
          math.pi * _additionalRotationTween.transform(value ?? _lastValue!);
    }

    Color valueColor = widget._getValueColor(context);
    final double opacity = valueColor.opacity;
    valueColor = valueColor.withOpacity(1.0);

    final Color backgroundColor = widget.backgroundColor ??
        ProgressIndicatorTheme.of(context).refreshBackgroundColor ??
        Theme.of(context).canvasColor;

    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        width: _indicatorSize,
        height: _indicatorSize,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(120)),
        margin: const EdgeInsets.all(4.0), // accommodate the shadow
        child: Material(
          type: MaterialType.circle,
          color: backgroundColor,
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  painter: _RefreshProgressIndicatorPainter(
                    valueColor: valueColor,
                    value: null, // Draw the indeterminate progress indicator.
                    headValue: headValue,
                    tailValue: tailValue,
                    offsetValue: offsetValue,
                    rotationValue: rotationValue,
                    strokeWidth: widget.strokeWidth ?? 4.0,
                    arrowheadScale: arrowheadScale,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
