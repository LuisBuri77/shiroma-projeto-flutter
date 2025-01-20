import 'package:cloud_firestore/cloud_firestore.dart';

int SetPage(String usuario){
  if(usuario == "clientes") {
    return 1;
  }
}
Map<String, dynamic> data = Map();

String idUser;



Future<void> setData(Map userData, String IDusuario) async {
  data = userData;
  idUser = IDusuario;

  if (data['hierarquia'] == 'clientes') {
    DocumentSnapshot docUser = await Firestore.instance.collection("clientes").document(idUser).get();
    data = docUser.data;
  }
}


  Map<String, dynamic> getData() {
    return data;
  }

  String getIDuser() {
    return idUser;
  }
