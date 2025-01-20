import 'dart:convert';

import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cpfcnpj/cpfcnpj.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/config_pages.dart';
import 'package:shiroma_flutter_app/model/user_model.dart';

class NovoProdutoScreen extends StatefulWidget {
  @override
  _NovoProdutoScreenState createState() => _NovoProdutoScreenState();
}

class _NovoProdutoScreenState extends State<NovoProdutoScreen> {
  //variáveis
  File _image;
  String fileName, url;
  var selectedCategorias;
  String nome_fantasia, descricao, valor;
  DateTime data = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool firstTime = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //controlar os campos
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  //Funções
  //Obterndo imagem da galeria
  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        maxWidth: 1800,
        maxHeight: 1800,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Editar imagem',
            toolbarColor: BaseColors('color1'),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Editar imagem',
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {
        _image = croppedFile;
      });
    } else {
      setState(() {
        _image = null;
      });
    }
  }

  //limpar todos os campos
  void limparcampos() {
    _nomeController.clear();
    _descricaoController.clear();
    _image = null;
    fileName = null;
    nome_fantasia = null;
    descricao = null;
  }

  _onSuccess(BuildContext context) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Oferta criada com sucesso!"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao criar oferta!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  //função para salvar parceiro
  Future<void> salvaroferta(context, model) async {
    if(_image !=null){
      fileName = basename(_image.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask storageUploadTask = firebaseStorageRef.putFile(_image);
      var downURL = await(await storageUploadTask.onComplete).ref.getDownloadURL();
      url = downURL.toString();
    }

    Map<String, dynamic> userData = {
      'image': fileName,
      'urlimg': url,
      'nome': nome_fantasia,
      'tipo': selectedCategorias,
      'descricao': descricao,
      'valor': valor.replaceAll(".", ""),
      'responsavel': getIDuser(),
      'data': data,
    };

    model.saveOfertaUp(
        userData: userData,
        onSuccess: _onSuccess(context),
        onFail: _onFail
    );
    print(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text("Novo produto"),
          centerTitle: true,
          backgroundColor: BaseColors('color1'),
          elevation: 0,
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [BaseColors('color1'), BaseColors('color2')],
              ),
            ),
            //padding: EdgeInsets.only(top: 50),
            alignment: Alignment(0, -0.25),
            //padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: ScopedModel<UserModel>(
                model: UserModel(),
                child: ScopedModelDescendant<UserModel>(
                    builder: (context, child, model) {
                  if (model.isLoading)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  return SingleChildScrollView(
                    child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // Campos para Informações Básicas
                                  Text("Informações",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: BaseColors('color2'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),

                                  SizedBox(
                                    height: 10,
                                  ),
                                  //Adicionar Imagem
                                  Container(
                                    //color: BaseColors('colorbgimgpri'),
                                    height: 90,
                                    child: ListView.builder(
                                      itemCount: 1,
                                      //scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap: () {
                                              getImage();
                                            },
                                            child: CircleAvatar(
                                              radius: 44,
                                              backgroundColor:
                                              BaseColors('colorbgimgsec'),
                                              child: (_image != null)
                                                  ? ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(44.0),
                                                  child: Container(
                                                    width: 90,
                                                    height: 90,
                                                    child: Image.file(
                                                      _image,
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ))
                                                  : Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: BaseColors('colortxt'),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Campo para o Nome Fantasia
                                  TextFormField(
                                    controller: _nomeController,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Nome *",
                                    ),
                                    onChanged: (textfantasia) {
                                      nome_fantasia = _nomeController.text;
                                      if (firstTime == true) {
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Informe o nome fantasia!';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Campo para tipo
                                  StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance
                                        .collection("categorias")
                                        .orderBy("tipo")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return Text('Carregando');
                                      else {
                                        List<DropdownMenuItem> categoriasItens = [];
                                        for (int i = 0;
                                        i < snapshot.data.documents.length;
                                        i++) {
                                          DocumentSnapshot snap =
                                          snapshot.data.documents[i];
                                          categoriasItens.add(DropdownMenuItem(
                                            child: Text(
                                              snap.data['tipo'],
                                              //style: TextStyle(color: BaseColors("color2")),
                                            ),
                                            value: "${snap.data['tipo']}",
                                          ));
                                        }
                                        return DropdownButtonFormField(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          items: categoriasItens,
                                          onChanged: (categoriasValue) {
                                            if (firstTime == true) {
                                              _formKey.currentState.validate();
                                            }
                                            setState(() {
                                              selectedCategorias = categoriasValue;
                                            });
                                          },
                                          value: selectedCategorias,
                                          isExpanded: true,
                                          hint: Text(
                                            'Tipo de Categoria *',
                                            // ignore: missing_return
                                          ),
                                          validator: (value) => value == null
                                              ? 'Selecione o tipo de categoria!'
                                              : null,
                                        );
                                      }
                                    },
                                  ),
                                  // Descrição da empresa
                                  TextFormField(
                                    controller: _descricaoController,
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Descrição *",
                                    ),
                                    onChanged: (textdescricao) {
                                      descricao = textdescricao;
                                      if (firstTime == true) {
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Informe a descrição do estabelecimento!';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _valorController,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      hintText: "Valor em R\$ * ",
                                    ),
                                    onChanged: (num){
                                      valor = num;
                                    },
                                    validator: (String value){
                                        if (value.isEmpty) {
                                          return 'Insira o valor';
                                        }else{
                                          return null;
                                        }
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      RealInputFormatter(
                                          centavos: true),
                                    ],
                                  ),

                                  const SizedBox(height: 11),

                                  // Botão para se Cadastrar
                                  Container(
                                    height: 40,
                                    child: RaisedButton(
                                      color: BaseColors('color1'),
                                      textColor: Colors.white,
                                      child: Text("Cadastrar"),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onPressed: () {
                                        firstTime = true;
                                        _formKey.currentState.validate();
                                        if (_formKey.currentState.validate() == true) {
                                          salvaroferta(context, model);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                  );
                })
            )
        )
    );
  }
}