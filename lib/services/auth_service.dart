/**
 * =================================================================
 * Servicio de Autenticación para Flutter (en Dart)
 * =================================================================
 * Este archivo contiene la lógica para que tu aplicación Flutter
 * maneje el inicio de sesión con Google y la creación de perfiles de usuario
 * en Firestore.
 *
 * Dependencias necesarias (ya las tienes en tu pubspec.yaml):
 * firebase_core, firebase_auth, cloud_firestore, google_sign_in
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /**
   * -----------------------------------------------------------------
   * Inicia el flujo de autenticación con Google
   * -----------------------------------------------------------------
   * @returns {Future<UserCredential?>} Las credenciales del usuario si el
   * inicio de sesión es exitoso, o null si falla.
   */
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          print("Usuario nuevo detectado. Creando perfil en Firestore...");
          await _createUserProfile(user);
        } else {
          print("Bienvenido de nuevo, ${user.displayName}.");
        }
      }

      return userCredential;
    } catch (e) {
      print("Error durante el inicio de sesión con Google: $e");
      return null;
    }
  }

  /**
   * -----------------------------------------------------------------
   * Crea el documento del usuario en la colección 'users' de Firestore
   * -----------------------------------------------------------------
   */
  Future<void> _createUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    final docSnap = await userRef.get();
    if (docSnap.exists) {
      print("El documento del perfil ya existe. No se creará uno nuevo.");
      return;
    }

    final newUserProfile = {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'dateOfBirth': null,
      'needsAgeVerification': false,
      'blockedUsers': [],
    };

    try {
      await userRef.set(newUserProfile);
      print("Perfil para ${user.displayName} creado exitosamente.");
    } catch (e) {
      print("Error al crear el perfil de usuario en Firestore: $e");
    }
  }

  /**
   * -----------------------------------------------------------------
   * Cierra la sesión del usuario actual (VERSIÓN FINAL Y ROBUSTA)
   * -----------------------------------------------------------------
   */
  Future<void> signOut() async {
    // El orden es importante: primero cerramos la sesión de Google.
    try {
      await _googleSignIn.signOut();
      print("Sesión de Google cerrada exitosamente.");
    } catch (e) {
      print("Error al cerrar sesión de Google Sign-In: $e");
    }
    
    // Luego, cerramos la sesión de Firebase.
    try {
      await _auth.signOut();
      print("Sesión de Firebase cerrada exitosamente.");
    } catch (e) {
      print("Error al cerrar sesión de Firebase: $e");
    }
  }
}
