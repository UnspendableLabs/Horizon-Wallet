import 'package:uniparty/models/key_pair.dart';

abstract class PublicPrivateKeyService {
  KeyPair createPublicPrivateKeyPairForPath(dynamic args);
}
