import 'package:cloud_firestore/cloud_firestore.dart';


import '../data/models/user_model.dart';

class AdminServices {


  UserModel? currentUser;
  static Future<bool> isAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  }
  Future<String?> getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }




}




