import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SunriseSunsetWidget extends StatelessWidget {
  final TimeOfDay sunrise;
  final TimeOfDay sunset;

  const SunriseSunsetWidget({
    Key? key,
    required this.sunrise,
    required this.sunset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1)),
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: SunArcPainter(sunrise: sunrise, sunset: sunset),
                  child: Container(),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeColumn('Sunrise', sunrise),
              _buildTimeColumn('Sunset', sunset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, TimeOfDay time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          _formatTime(time),
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class SunArcPainter extends CustomPainter {
  final TimeOfDay sunrise;
  final TimeOfDay sunset;

  SunArcPainter({required this.sunrise, required this.sunset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      paint,
    );

    // Draw sun
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final now = TimeOfDay.now();
    final sunPosition = _calculateSunPosition(now);
    final sunCenter = _pointOnArc(center, radius, sunPosition);

    // Draw sun glow
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 20, glowPaint);

    // Draw sun
    canvas.drawCircle(sunCenter, 10, sunPaint);

    // Draw current time
    final textPainter = TextPainter(
      text: TextSpan(
        text: _formatTime(now),
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height - 30));
  }

  Offset _pointOnArc(Offset center, double radius, double angle) {
    return center + Offset(cos(angle) * radius, -sin(angle) * radius);
  }

  double _calculateSunPosition(TimeOfDay now) {
    final sunriseMinutes = sunrise.hour * 60 + sunrise.minute;
    final sunsetMinutes = sunset.hour * 60 + sunset.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    if (nowMinutes < sunriseMinutes) return pi;
    if (nowMinutes > sunsetMinutes) return 0;

    final totalDayMinutes = sunsetMinutes - sunriseMinutes;
    final minutesSinceSunrise = nowMinutes - sunriseMinutes;
    final progress = minutesSinceSunrise / totalDayMinutes;

    return pi * (1 - progress);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage example
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sunrise Sunset Widget')),
      body: Center(
        child: SunriseSunsetWidget(
          sunrise: TimeOfDay(hour: 5, minute: 4),
          sunset: TimeOfDay(hour: 18, minute: 45),
        ),
      ),
    );
  }
}

main() {
  runApp(MaterialApp(home: MyHomePage()));
}
