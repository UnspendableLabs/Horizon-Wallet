import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:horizon/domain/services/encryption_service.dart';
import "encryption_service_impl.dart";
import 'dart:convert';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:encrypt/encrypt.dart';
import 'package:horizon/common/normalize_b64.dart';

const String _argon2Prefix = 'A2::';
final _secureRandom = Random.secure();

String _generateRandomIV() {
  final randomBytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  return base64Encode(randomBytes);
}

class EncryptionServiceWebWorkerImpl implements EncryptionService {
  late html.Worker? _worker;
  bool _useWorker = true;
  late EncryptionService fallback;
  final Map<int, Completer<String>> _pendingRequests = {};
  int _messageId = 0;

  EncryptionServiceWebWorkerImpl() {
    fallback = EncryptionServiceImpl();
    if (html.Worker.supported) {
      try {
        var worker = html.Worker('encryption_worker.js');
        worker.onMessage.listen(_recv);
        _worker = worker;
      } catch (e) {
        _useWorker = false;
        print('Failed to initialize worker: $e');
      }
    }
  }

  @override
  Future<String> encrypt(String data, String password) async {
    if (_useWorker) {
      try {
        final iv = IV(base64Decode(_generateRandomIV()));
        final salt = Salt.newSalt();
        final encoded = await _send(
            'hash',
            jsonEncode({
              "password": password,
              "salt": base64Encode(salt.bytes),
            }));

        final parts = encoded.split("\$");

        final version = parts[2];
        final params = parts[3];
        final hash = parts.last;

        var hashB64 = normalizeB64(hash);

        final key = Key(Uint8List.fromList(base64Decode(hashB64)));

        final encrypter = Encrypter(AES(key));
        final cipher = encrypter.encrypt(data, iv: iv).base64;
        final result =
            '$_argon2Prefix$version::$params::${base64Encode(salt.bytes)}::${iv.base64}$cipher';

        return result;
      } catch (e) {
        return fallback.encrypt(data, password);
      }
    } else {
      return fallback.encrypt(data, password);
    }
  }

  @override
  Future<String> decrypt(String data_, String password) async {
    //1) verify password

    final data = data_.substring(_argon2Prefix.length);

    if (_useWorker) {
      try {
        final parts = data.split('::');
        if (parts.length != 4) {
          throw const FormatException('Invalid encrypted data format');
        }

        final saltBase64 = parts[2];
        final ivAndCipher = parts[3];
        final salt = Salt(base64Decode(saltBase64));
        final iv = IV(base64Decode(ivAndCipher.substring(0, 24)));
        final cipher = ivAndCipher.substring(24);
        final encoded = await _send(
            'hash',
            jsonEncode({
              "password": password,
              "salt": base64Encode(salt.bytes),
            }));

        var hashB64 = normalizeB64(encoded.split('\$').last);
        final key =
            Key(Uint8List.fromList(base64Decode(normalizeB64(hashB64))));
        final encrypter = Encrypter(AES(key));
        return encrypter.decrypt64(cipher, iv: iv);
      } catch (e) {
        return fallback.decrypt(data_, password);
      }
    } else {
      return fallback.decrypt(data_, password);
    }
  }

  void _recv(html.MessageEvent event) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(event.data);
    final id = data['id'] as int;
    final result = data['result'] as dynamic;
    final error = data['error'] as String?;

    final completer = _pendingRequests.remove(id);
    if (completer != null) {
      if (error != null) {
        completer.completeError(error);
      } else if (result != null) {
        completer.complete(result);
      } else {
        completer.completeError('Invalid worker response');
      }
    }
  }

  Future<String> _send(String action, String data) {
    final id = _messageId++;
    final completer = Completer<String>();
    _pendingRequests[id] = completer;

    _worker!.postMessage(jsonEncode({
      'id': id,
      'action': action,
      'data': data,
    }));

    return completer.future;
  }
  // TODO: cleanup?
}
