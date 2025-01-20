import 'dart:io';
import 'package:brasil_fields/formatter/real_input_formatter.dart';
import 'package:path/path.dart';
import 'package:brasil_fields/formatter/cpf_input_formatter.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';

class DetalhesProdutosScreen extends StatefulWidget {
  final DocumentSnapshot detalhes;
  DetalhesProdutosScreen({this.detalhes});

  @override
  _DetalhesProdutosScreenState createState() => _DetalhesProdutosScreenState();
}

class _DetalhesProdutosScreenState extends State<DetalhesProdutosScreen> {


  File _image;
  String fileName, url;
  var selectedCategorias;
  String nome, descricao, valor;
  DateTime data = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  bool firstTime = false, inicio = false;
  bool atualizando = false;


  final _formKey = GlobalKey<FormState>();

  //Controlar os campos
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  void IniciarCampos(){
    _nomeController.text = widget.detalhes.data['nome'];
    _descricaoController.text = widget.detalhes.data['descricao'];
    _valorController.text  = widget.detalhes.data['valor'];
    selectedCategorias = widget.detalhes.data['tipo'];

    nome = _nomeController.text;
    descricao = _descricaoController.text;
    valor = _valorController.text;
  }
  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
    _cropImage();
  }
  //Editar Imagem
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
    }else{
      setState(() {
        _image = null;
      });
    }
  }
  void limparcampos(){
    _nomeController.clear();
    _image = null;
    fileName = null; url = null;
    firstTime = false; inicio = false;
  }
  Future<void> SalvarCliente(context) async {
    setState(() {
      atualizando = true;
    });
    if (_image == null) {
      widget.detalhes.reference.updateData({
        'nome': nome,
        'tipo': selectedCategorias,
        'descricao': descricao,
        'valor': valor.replaceAll(".", ""),
        'data': data,
      }).whenComplete((){
        setState(() {
          atualizando = false;
        });
      });

    } else if(widget.detalhes.data['image'] != null) {
      // Apagar imagem anterior
      FirebaseStorage.instance.ref().child(widget.detalhes.data["image"]).delete();

      //Salvar nova imagem
      fileName = basename(_image.path);
      StorageReference firebaseStorageRef1 = FirebaseStorage.instance
          .ref().child(fileName);
      StorageUploadTask storageUploadTask1 = firebaseStorageRef1.putFile(_image);
      var downURL = await(await storageUploadTask1.onComplete).ref.getDownloadURL();
      url = downURL.toString();

      //editar dados
      widget.detalhes.reference.updateData({
        'image': fileName,
        'urlimg': url,
        'nome': nome,
        'tipo': selectedCategorias,
        'descricao': descricao,
        'valor': valor.replaceAll(".", ""),
        'data': data,
      }).whenComplete((){
        setState(() {
          atualizando = false;
        });
      });;
    } else{
      //Salvar nova imagem
      fileName = basename(_image.path);
      StorageReference firebaseStorageRef1 = FirebaseStorage.instance
          .ref().child(fileName);
      StorageUploadTask storageUploadTask1 = firebaseStorageRef1.putFile(
          _image);
      var downURL = await(await storageUploadTask1.onComplete).ref
          .getDownloadURL();
      url = downURL.toString();

      //editar dados
      widget.detalhes.reference.updateData({
        'image': fileName,
        'urlimg': url,
        'nome': nome,
        'tipo': selectedCategorias,
        'descricao': descricao,
        'valor': valor.replaceAll(".", ""),
        'data': data,
      }).whenComplete((){
        setState(() {
          atualizando = false;
        });
      });
    }
    limparcampos();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    if(inicio == false){
      IniciarCampos();
      inicio = true;
    }

    return (atualizando == true)? Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BaseColors('color1'), BaseColors('color2')],
            ),
          ),
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
              height: 50.0,
              width: 50.0,
            ),
          )
      ),
    ):Scaffold(
      //backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text("Detalhes do cliente"),
        backgroundColor: BaseColors('color1'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        //padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
          height :MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BaseColors('color1'), BaseColors('color2')],
            ),
          ),
          //padding: EdgeInsets.only(top: 50),
          alignment: Alignment(0, -0.25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5,),
                Card(
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
                            Text(
                                "Informações básicas",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: BaseColors('color2'),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            //Adicionar Imagem
                            Container(
                              height: 90,
                              //width: 60,
                              //color: BaseColors('color2'),
                              child: GestureDetector(
                                onTap: (){
                                  getImage();
                                },
                                child: CircleAvatar(
                                    radius: 44,
                                    backgroundColor: BaseColors('colorbgimgsec'),
                                    child: (widget.detalhes.data['urlimg'] == null && _image == null)?
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(44.0),
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: BaseColors('colortxt'),
                                          ),
                                        )
                                    ): (widget.detalhes.data['urlimg'] != null && _image == null)?
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(44.0),
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        child: Image.network(
                                          widget.detalhes.data['urlimg'],
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ): ClipRRect(
                                        borderRadius: BorderRadius.circular(44.0),
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          child: Image.file(
                                            _image,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )
                                    )
                                ),
                              ),
                            ),
                            SizedBox(height: 5,),

                            // Campo para o Nome Fantasia
                            TextFormField(
                              controller: _nomeController,
                              decoration: InputDecoration(
                                //border: const OutlineInputBorder(),
                                isDense: true,
                                labelText: "Nome *",
                              ),
                              onChanged: (textfantasia) {
                                nome = _nomeController.text;
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
                            const SizedBox(height: 16),

                            // Botão para Editar e Excluir
                            Row(
                              children: [
                                // Botão para Excluir
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: RaisedButton(
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      child: Text("Excluir"),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onPressed: (){
                                        AlertaExclusao(context, widget.detalhes);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),

                                // Botão para Editar
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: RaisedButton(
                                      color: Color.fromRGBO(6, 60, 122, 1.0),
                                      textColor: Colors.white,
                                      child: Text("Editar"),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onPressed: (){
                                        firstTime = true;
                                        _formKey.currentState.validate();
                                        if(_formKey.currentState.validate() == true){
                                          SalvarCliente(context);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
              ],
            ),
          )
      ),
    );
  }
}

AlertaExclusao(BuildContext context, doc){
  // configura o button
  Widget okButton = FlatButton(
    child: Text("Sim"),
    onPressed: (){
      doc.reference.delete();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
  );
  Widget cancelButton = FlatButton(
    child: Text("Não"),
    onPressed: (){
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Você tem certeza que deseja excluir?"),
    actions: [
      okButton,
      cancelButton
    ],
  );
  // exibe o dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alerta;
    },
  );
}