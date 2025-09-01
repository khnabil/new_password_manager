import 'dart:math';

class PasswordGenerator {
  static final _random = Random.secure();

  // Function to generate a strong random password
  static String generateStrongPassword({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=<>?';

    // Ensure at least one uppercase letter, one number, and one special character
    final password = StringBuffer();

    password.write(_getRandomChar('ABCDEFGHIJKLMNOPQRSTUVWXYZ')); // Uppercase
    password.write(_getRandomChar('abcdefghijklmnopqrstuvwxyz')); // Lowercase
    password.write(_getRandomChar('0123456789')); // Digit
    password.write(_getRandomChar('!@#\$%^&*()_-+=<>?')); // Special char

    // Fill the rest of the password
    for (int i = password.length; i < length; i++) {
      password.write(_getRandomChar(chars));
    }

    return _shuffleString(password.toString()); // Shuffle to ensure randomness
  }

  // Helper function to get a random character from a given string
  static String _getRandomChar(String chars) {
    return chars[_random.nextInt(chars.length)].toString();
  }

  // Shuffle the string to ensure the password is fully random
  static String _shuffleString(String input) {
    final chars = input.split('');
    chars.shuffle(_random);
    return chars.join();
  }
}
