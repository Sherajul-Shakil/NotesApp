import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_firebase_ddd/domain/auth/user.dart';
import 'package:notes_firebase_ddd/domain/auth/value_objects.dart';

extension FirebaseUserDomainX on User {
  AsUser toDomain() {
    return AsUser(id: UniqueId.fromUniqueString(uid));
  }
}
