import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserProvider extends ChangeNotifier {
  User? _user;
  String _nombre = 'Amigo';
  bool _isPro = false;
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _perfilSubscription;

  User? get user => _user;
  String get nombre => _nombre;
  bool get isPro => _isPro;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String get email => _user?.email ?? '';
  String get correoSeguro => email.toLowerCase().trim();
  bool get esAdmin => correoSeguro == 'fonoaudiologia41@gmail.com';

  UserProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      if (user != null) {
        _cargarPerfil(user.uid);
      } else {
        _perfilSubscription?.cancel();
        _nombre = 'Amigo';
        _isPro = false;
      }
      notifyListeners();
    });
  }

  void _cargarPerfil(String uid) {
    _perfilSubscription?.cancel();
    _perfilSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _nombre = doc.data()?['nombre'] ?? 'Amigo';
        _isPro = doc.data()?['isPro'] ?? false;
        notifyListeners();
      }
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _perfilSubscription?.cancel();
    super.dispose();
  }
}
