import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  factory CryptoService() => _instance;
  CryptoService._internal();

  final _algorithm = AesGcm.with256bits();

  /// Generates a random 32-byte key for the trip
  Future<SecretKey> generateTripKey() async {
    return await _algorithm.newSecretKey();
  }

  /// Encrypts data using the provided secret key
  Future<SecretBox> encrypt(Uint8List data, SecretKey secretKey) async {
    return await _algorithm.encrypt(
      data,
      secretKey: secretKey,
    );
  }

  /// Decrypts data using the provided secret key
  Future<Uint8List> decrypt(SecretBox secretBox, SecretKey secretKey) async {
    return Uint8List.fromList(await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    ));
  }

  /// Encodes a SecretKey to a base64 string for QR code sharing
  Future<String> exportKey(SecretKey secretKey) async {
    final bytes = await secretKey.extractBytes();
    return base64Encode(bytes);
  }

  /// Decodes a SecretKey from a base64 string
  SecretKey importKey(String base64Key) {
    return SecretKey(base64Decode(base64Key));
  }
}
