import 'dart:math' as math;

class BezierEvaluator {
  static double evaluate(double x1, double y1, double x2, double y2, double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;

    double u = _solveUForX(x1, x2, t);
    return _sampleCurve(u, y1, y2);
  }

  static double evaluateVelocity(double x1, double y1, double x2, double y2, double t) {
    if (t <= 0.0 || t >= 1.0) return 0.0;
    double u = _solveUForX(x1, x2, t);
    double dx = _sampleDerivative(u, x1, x2);
    double dy = _sampleDerivative(u, y1, y2);
    return dx.abs() > 1e-6 ? (dy / dx) : 0.0;
  }

  static double _sampleCurve(double u, double p1, double p2) {
    final oneMinusU = 1.0 - u;
    return 3.0 * oneMinusU * oneMinusU * u * p1 +
           3.0 * oneMinusU * u * u * p2 +
           u * u * u;
  }

  static double _sampleDerivative(double u, double p1, double p2) {
    return 3.0 * (1.0 - 3.0 * u + 3.0 * u * u) * p1 +
           3.0 * (2.0 * u - 3.0 * u * u) * p2 +
           3.0 * u * u;
  }

  static double _solveUForX(double x1, double x2, double targetX) {
    double u = targetX;
    // Newton-Raphson iteration
    for (int i = 0; i < 8; i++) {
      double currentX = _sampleCurve(u, x1, x2) - targetX;
      if (currentX.abs() < 1e-6) return u;
      double dX = _sampleDerivative(u, x1, x2);
      if (dX.abs() < 1e-6) break;
      u -= currentX / dX;
      if (u < 0.0 || u > 1.0) break;
    }

    // Binary search fallback
    double lo = 0.0, hi = 1.0;
    u = targetX;
    while (lo < hi) {
      double currentX = _sampleCurve(u, x1, x2);
      if ((currentX - targetX).abs() < 1e-5) return u;
      if (targetX > currentX) {
        lo = u;
      } else {
        hi = u;
      }
      u = (hi + lo) * 0.5;
    }
    return u;
  }
}
