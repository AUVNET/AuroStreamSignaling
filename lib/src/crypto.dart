import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'dart:math';

class CryptoUtils {
  /// Encryption

  /// Generates a random Uint8List of [length].
  static Uint8List randomBytes(int length) {
    final Random rnd = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rnd.nextInt(256)));
  }

  /// Converts Uint8List to a hexadecimal string.
  static String toHex(Uint8List data) {
    return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Encrypts [dataMap] using AES-256 in CTR mode and returns a string containing the encrypted data.
  static Map<String, dynamic> encryptEventsData(Map<String, dynamic> dataMap) {
    // Convert the map to a JSON string
    String input = json.encode(dataMap);

    if (input.isEmpty) {
      return {
        'success': false,
        'message': "Failed to encrypt data",
        'errorMessage': "Input data is empty"
      };
    }

    try {
      final Uint8List iv = randomBytes(16); // IV is 16 bytes
      final Uint8List key = randomBytes(32); // Key for AES-256 is 32 bytes

      // Initialize cipher for encryption in CTR mode
      final StreamCipher cipher = StreamCipher('AES/CTR');
      cipher.init(true, ParametersWithIV<KeyParameter>(KeyParameter(key), iv));

      // Encrypt
      final Uint8List inputData = Uint8List.fromList(utf8.encode(input));
      final Uint8List encryptedData = cipher.process(inputData);

      // Convert IV, encrypted data, and key to Hex string
      String ivHex = toHex(iv);
      String encryptedHex = toHex(encryptedData);
      String keyHex = toHex(key);

      // Return success response
      return {'success': true, 'data': "$ivHex.$encryptedHex.$keyHex"};
    } catch (error) {
      // Return error response
      return {
        'success': false,
        'message': "Failed to encrypt data",
        'errorMessage': error.toString()
      };
    }
  }

  /// Decryption

  /// Converts a hexadecimal string to Uint8List.
  static Uint8List fromHex(String hexString) {
    return Uint8List.fromList(List.generate(hexString.length ~/ 2,
        (i) => int.parse(hexString.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  /// Decrypts the [encryptedDataString] which is in the format `${ivHex}.${encryptedHex}.${keyHex}` and returns the decrypted `Map<String, dynamic>`.
  static Map<String, dynamic> decryptEventsData(String encryptedDataString) {
    try {
      final parts = encryptedDataString.split('.');
      if (parts.length != 3) {
        throw const FormatException('Invalid encrypted data format');
      }

      final Uint8List iv = fromHex(parts[0]);
      final Uint8List encryptedData = fromHex(parts[1]);
      final Uint8List key = fromHex(parts[2]);

      // Initialize cipher for decryption in CTR mode
      final StreamCipher cipher = StreamCipher('AES/CTR');
      cipher.init(
          false,
          ParametersWithIV<KeyParameter>(
              KeyParameter(key), iv)); // false for decryption

      // Decrypt
      final Uint8List decryptedData = cipher.process(encryptedData);

      // Convert decrypted data back to String and then to Map
      final String decryptedString = utf8.decode(decryptedData);
      final Map<String, dynamic> decodedMap = json.decode(decryptedString);

      return {'success': true, 'data': decodedMap};
    } catch (error) {
      // Return error response in case of exception
      return {
        'success': false,
        'message': "Failed to decrypt data",
        'errorMessage': error.toString()
      };
    }
  }
}