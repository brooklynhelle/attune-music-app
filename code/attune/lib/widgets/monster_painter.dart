import 'package:flutter/material.dart';


// This is the canvas painter thing where I made our mascot! You can find him under "Nearby"
// on the homepage, but only when nobody is around (or if you didnt allow location sharing)... 
void main() {
  runApp(MaterialApp(
    home: MainApp()
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: CustomPaint(
              painter: MonsterPainter(),
            )
          ),
        )
      ),
    );
  }
}

class MonsterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    final paintHeadphones = Paint()
      ..color = const Color(0xff1e1b4b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // outline
    final Outline = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // body & outline
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.65),
        width: size.width * 0.6,
        height: size.height * 0.65,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.65),
        width: size.width * 0.6,
        height: size.height * 0.65,
      ),
      Outline,
    );

    // mouth 
    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.8),
      width: size.width * 0.25,
      height: size.height * 0.1,
    );

    canvas.drawArc(mouthRect, 3.14, 3.14, false, paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      );

    // eyes
    final eyeWhite = Paint()..color = const Color(0xffe9d5ff);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.6), size.width * 0.08, eyeWhite);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.6), size.width * 0.08, eyeWhite);

    final eyePupil = Paint()..color = const Color(0xff2e1065);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.62), size.width * 0.06, eyePupil);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.62), size.width * 0.06, eyePupil);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.6), size.width * 0.08, Outline);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.6), size.width * 0.08, Outline);

    // nostrils
    final nostrilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.69), size.width * 0.01, nostrilPaint);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.69), size.width * 0.01, nostrilPaint);

   // horns & outline
    paint 
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    final leftHorn = Path()
      ..moveTo(size.width * 0.24, size.height * 0.47)
      ..lineTo(size.width * 0.25, size.height * 0.24)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..close();
    final rightHorn = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5) // leftmost point
      ..lineTo(size.width * 0.73, size.height * 0.23) 
      ..lineTo(size.width * 0.76, size.height * 0.52) // rightmost point
      ..close();
    canvas.drawPath(leftHorn, paint);
    canvas.drawPath(rightHorn, paint);

    // headphones
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.55,
        height: size.height * 0.35,
      ),
      3.14,
      3.14,
      false,
      paintHeadphones,
    );

    // more headphones
    final leftCupRect = Rect.fromCenter(
      center: Offset(size.width * 0.2, size.height * 0.6),
      width: size.width * 0.18,
      height: size.height * 0.3,
    );
    final rightCupRect = Rect.fromCenter(
      center: Offset(size.width * 0.8, size.height * 0.6),
      width: size.width * 0.18,
      height: size.height * 0.3,
    );

    final leftCupPaint = Paint()..color = const Color(0xff312e81);
    canvas.drawOval(leftCupRect, leftCupPaint);
    canvas.drawOval(rightCupRect, leftCupPaint);
    canvas.drawOval(leftCupRect, Outline);
    canvas.drawOval(rightCupRect, Outline);

    // fangs
    final fangPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final leftFang = Path()
    ..moveTo(size.width * 0.43, size.height * 0.765)
    ..lineTo(size.width * 0.47, size.height * 0.755)
    ..lineTo(size.width * 0.45, size.height * 0.81)
    ..close();

    final rightFang = Path()
      ..moveTo(size.width * 0.53, size.height * 0.755)
      ..lineTo(size.width * 0.57, size.height * 0.765)
      ..lineTo(size.width * 0.55, size.height * 0.81)
      ..close();

    canvas.drawPath(leftFang, fangPaint);
    canvas.drawPath(rightFang, fangPaint);
    canvas.drawPath(leftFang, Outline);
    canvas.drawPath(rightFang, Outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
