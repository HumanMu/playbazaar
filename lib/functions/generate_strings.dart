import 'dart:math' as math;

String generateStrings(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = math.Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}