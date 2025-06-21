import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<User?> signUpUser(String name, String email, String password, String propertyType, String houseId) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Realtime Database
        await _db.ref('users/${user.uid}').set({
          'name': name,
          'email': email,
          'propertyType': propertyType,
          'houseId': houseId,
          'createdAt': ServerValue.timestamp,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email-already-in-use)
      print('Failed to sign up: ${e.message}');
      return null;
    }
  }

  Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign in: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
