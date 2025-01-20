import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class UserModel extends Model {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();


  bool isLoading = false;

  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  void signUp({@required Map<String, dynamic> userData, @required String pass,
    @required VoidCallback onSuccess, @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
        email: userData["email"], password: pass)
        .then((user) async {
      firebaseUser = user.user;
      await _saveUserData(userData);

      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void saveOfertaUp({@required Map<String, dynamic> userData,
    @required VoidCallback onSuccess, @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    Firestore.instance.collection('ofertas').add(userData).then((user) async {
      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn(
      {@required String email, @required String pass, @required Function onSuccess, @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then((user) async {
      firebaseUser = user.user;



      await _loadCurrentUser();
      while (userData['hierarquia'] == null) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
      onSuccess(userData['hierarquia'], userData, firebaseUser.uid);
      isLoading = false;
      notifyListeners();
    }).catchError((e) {

      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void signOut() async {
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }


  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;

    if (userData['hierarquia'] == "clientes") {
      await Firestore.instance.collection("clientes").document(firebaseUser.uid).setData(userData);
      await Firestore.instance.collection("usuarios").document(firebaseUser.uid).setData({
        "hierarquia": "clientes",
      });
    }
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser != null) {
      if (userData["nome"] == null) {
        Firestore.instance.collection("usuarios").getDocuments().then((snapshot) async {
          for (DocumentSnapshot ds in snapshot.documents) {
            if (ds.documentID == firebaseUser.uid) {
              DocumentSnapshot docUser = await Firestore.instance.collection("usuarios").document(firebaseUser.uid).get();
              userData = docUser.data;
            }
          }
        });
      }
    }
    if (firebaseUser == null) {
      firebaseUser = await _auth.currentUser();
      if (firebaseUser != null) {
        if (userData["nome"] == null) {
          Firestore.instance.collection("usuarios").getDocuments().then((snapshot) async {
            for (DocumentSnapshot ds in snapshot.documents) {
              if (ds.documentID == firebaseUser.uid) {
                DocumentSnapshot docUser = await Firestore.instance.collection("usuarios").document(firebaseUser.uid).get();
                userData = docUser.data;
              }
            }
          });
        }
      }
    }
    notifyListeners();

  }
}
