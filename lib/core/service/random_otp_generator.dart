import 'dart:math';

String generateRandomOTP() {
  Random random = Random();
  return (1000 + random.nextInt(9000)).toString();
}
