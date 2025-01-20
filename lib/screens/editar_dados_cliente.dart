import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/config_pages.dart';
import 'package:shiroma_flutter_app/model/user_model.dart';
import 'package:http/http.dart' as http;




class EditarDadosScreen extends StatefulWidget {
  @override
  _EditarDadosScreenState createState() => _EditarDadosScreenState();
}

class _EditarDadosScreenState extends State<EditarDadosScreen> {



  File _image;
  String fileName, url;
  var selectedEstado;
  List<String> estados = <String>['AC','AL','AP','AM','BA','CE','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO','DF'];

  String _nome, _telefone, _bloco, _numero, cep, rua, bairro, cidade, numero, estado, _email;
  Map<String, dynamic> dados = Map();
  String IDusuario;
  bool firstTime = false, inicio = false, erroCep;

  final _formKey = GlobalKey<FormState>();

  //Controlar os campos
  final _nomeController = TextEditingController();
  final _CPFController = TextEditingController();
  final _telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final _emailController = TextEditingController();


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
    }else{
      setState(() {
        _image = null;
      });
    }
  }
  void IniciarCampos(){
    _nomeController.text = dados['nome'];
    _telefoneController.text  = dados['telefone'];
   _CPFController.text = dados['CPF'];
    cepController.text = dados['cep'];
    _emailController.text = dados['email'];
    selectedEstado = dados['estado'];
    numeroController.text = dados['numero'];
    numero = dados['numero'];

    cep =  cepController.text;
    _nome = _nomeController.text;
    _telefone = _telefoneController.text;
    _email = _emailController.text;

    ConsultaCep();


  }
  ConsultaCep() async {
    String newcep;
    newcep = cep.replaceAll('.', '');
    String url = "https://viacep.com.br/ws/${newcep}/json/";
    http.Response response;
    response = await http.get(url);
    Map<String, dynamic> retorno = json.decode(response.body);
    rua = retorno["logradouro"];
    cidade = retorno["localidade"];
    bairro = retorno["bairro"];
    selectedEstado = retorno["uf"];
    ruaController.text = rua;
    cidadeController.text = cidade;
    bairroController.text = bairro;
    erroCep = retorno["erro"];
    if (erroCep == true) {
      ruaController.clear();
      cidadeController.clear();
      bairroController.clear();
    }
    void limparcampos() {
      _nomeController.clear();
      _telefoneController.clear();
      _emailController.clear();

      _image = null;
      fileName = null;
      url = null;
      _nome = null;
      _telefone = null;
      _bloco = null;
      _numero = null;
      _email = null;
      firstTime = false;
      inicio = false;
    }
  }
    Future<void> SalvarCliente(context) async {
      if (_image == null) {
        Firestore.instance.collection('clientes')
            .document(getIDuser())
            .updateData({
          'nome': _nome,
          'telefone': _telefone,
          'cep': cep,
          'rua': rua,
          'bairro': bairro,
          'numero': numero,
          'cidade': cidade,
          'estado': selectedEstado,

        });
      } else if (dados['image'] != null) {
        // Apagar imagem anterior
        FirebaseStorage.instance.ref().child(dados["image"]).delete();

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
        Firestore.instance.collection('clientes')
            .document(getIDuser())
            .updateData({
          'image': fileName,
          'urlimg': url,
          'nome': _nome,
          'telefone': _telefone,
          'cep': cep,
          'rua': rua,
          'bairro': bairro,
          'numero': numero,
          'cidade': cidade,
          'estado': selectedEstado,
        });
      } else {
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
        Firestore.instance.collection('clientes')
            .document(getIDuser())
            .updateData({
          'image': fileName,
          'urlimg': url,
          'nome': _nome,
          'telefone': _telefone,
          'cep': cep,
          'rua': rua,
          'bairro': bairro,
          'numero': numero,
          'cidade': cidade,
          'estado': selectedEstado,
        });
      }

      // Atualizar o Mapa
      Map<String, dynamic> dadosAtt = {
        'hierarquia': "clientes",
      };
      setData(dadosAtt, getIDuser());

      Navigator.of(context).pop();
    }

  @override
  Widget build(BuildContext context) {
    dados = getData();
    IDusuario = getIDuser();

    if(inicio == false){
      IniciarCampos();
      inicio = true;
    }

    return Scaffold(
      //backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text("Editar dados"),
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
          child: ScopedModel<UserModel>(
            model: UserModel(),
            child: ScopedModelDescendant<UserModel>(
                builder: (context, child, model) {
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

                                  // Campo para a Imagem
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
                                          child: (dados['urlimg'] == null && _image == null)?
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
                                          ): (dados != null && _image == null)?
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(44.0),
                                            child: Container(
                                              width: 90,
                                              height: 90,
                                              child: Image.network(
                                                dados['urlimg'],
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

                                  // Campo para Nome
                                  TextFormField(
                                    controller: _nomeController,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Nome completo *",
                                    ),
                                    onChanged: (textNome){
                                      _nome = _nomeController.text;
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    validator: (String value) {
                                      if(value.isEmpty){
                                        return 'Informe seu nome completo!';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Campo para o CPF
                                  TextFormField(
                                    controller: _CPFController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "CPF *",
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      CpfInputFormatter(),
                                    ],

                                  ),

                                  // Campo para o Celular
                                  TextFormField(
                                    controller: _telefoneController,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Celular *",
                                    ),
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      TelefoneInputFormatter(),
                                    ],
                                    onChanged: (textTelefone){
                                      _telefone = textTelefone;
                                      if(firstTime == true){
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe o telefone!';
                                      }
                                      String subvalue = value.substring(0, 6);
                                      if((subvalue.endsWith('9') && value.length == 15) || (!subvalue.endsWith('9') && value.length == 14)){
                                        return null;
                                      }else{
                                        return 'O telefone digitado não é válido!';
                                      }
                                    },
                                  ),
                                  // Campo para o Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "E-mail *",
                                    ),
                                    onChanged: (textEmail){
                                      _email = _emailController.text;
                                      if(firstTime == true){
                                        _formKey.currentState.validate();
                                      }
                                    },
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe o seu email!';
                                      }
                                      if(value.contains('@') && value.contains('.com')){
                                        return null;
                                      } else{
                                        return 'O email informado não é valido!';
                                      }
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                  ),

                                  const SizedBox(height: 20),
                                  Text(
                                      "Localização",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: BaseColors('color2'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )
                                  ),

                                  // Campo para o CEP
                                  TextFormField(
                                    controller: cepController,
                                    onChanged: (txtcep){
                                      cep = cepController.text;
                                      if(cep.length == 10){
                                        ConsultaCep();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "CEP *",
                                    ),
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      CepInputFormatter(),
                                    ],
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe o CEP!';
                                      } else if(erroCep == true || value.length < 10){
                                        return 'O CEP informado não é válido!';
                                      } else{
                                        return null;
                                      }
                                      return null;
                                    },
                                  ),

                                  // Campo para o Rua
                                  TextFormField(
                                    controller: ruaController,
                                    onChanged: (txtrua){
                                      rua = ruaController.text;
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Rua *",
                                    ),
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe a rua!';
                                      } else{
                                        return null;
                                      }
                                    },
                                  ),

                                  // Campo para o Numero
                                  TextFormField(
                                    controller: numeroController,
                                    onChanged: (txtnumero){
                                      numero = numeroController.text;
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Número *",
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe o número!';
                                      } else{
                                        return null;
                                      }
                                    },
                                  ),

                                  // Campo para o Bairro
                                  TextFormField(
                                    controller: bairroController,
                                    onChanged: (txtbairro){
                                      bairro = bairroController.text;
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Bairro *",
                                    ),
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe o bairro!';
                                      } else{
                                        return null;
                                      }
                                    },
                                  ),

                                  // Campo para a Cidade
                                  TextFormField(
                                    controller: cidadeController,
                                    onChanged: (txtcidade){
                                      cidade = cidadeController.text;
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    decoration: InputDecoration(
                                      //border: const OutlineInputBorder(),
                                      isDense: true,
                                      labelText: "Cidade *",
                                    ),
                                    validator: (String value){
                                      if(value.isEmpty){
                                        return 'Informe a cidade!';
                                      } else{
                                        return null;
                                      }
                                    },
                                  ),

                                  // Campo para Estado
                                  DropdownButtonFormField(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    items: estados.map((value)=>DropdownMenuItem(
                                      child: Container(
                                        child: Text(
                                          value,
                                          //style:
                                        ),
                                      ),
                                      value: value,
                                    )).toList(),
                                    onChanged: (selectednewEstado){
                                      setState(() {
                                        selectedEstado = selectednewEstado;
                                      });
                                      if(firstTime == true) _formKey.currentState.validate();
                                    },
                                    value: selectedEstado,
                                    isExpanded: true,
                                    hint: Text(
                                      'Estado *',
                                      // ignore: missing_return
                                    ),
                                    validator: (value) => value == null ? 'Selecione o estado!' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Botão para se Confirmar/Cancelar
                                  Container(
                                    height: 40,
                                    child: Row(
                                      children: <Widget> [
                                        Expanded(
                                          child: RaisedButton(
                                            color: Colors.red,
                                            textColor: Colors.white,
                                            child: Text("Cancelar"),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: RaisedButton(
                                            color: Color.fromRGBO(6, 60, 122, 1.0),
                                            textColor: Colors.white,
                                            child: Text("Confirmar"),
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
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Texto para se ja tiver uma conta, apenas logar
                                  //Divider(height: 5, color: BaseColors('color2'),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: <Widget> [
                                        Text(
                                          "Quer alterar sua senha?",
                                          style: TextStyle(
                                            color: BaseColors('color2'),
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            EsqueceuSenha(context, model, dados['email']);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Text(
                                              "Altera já!",
                                              style: TextStyle(
                                                decoration: TextDecoration.underline,
                                                color: BaseColors('color1'),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        )
                    ),
                  );
                }
            ),
          ),
        )
    );
  }
}
EsqueceuSenha(BuildContext context, UserModel model, String email) {
  // configura o button
  Widget simButton = FlatButton(
    child: Text("Sim"),
    onPressed: () {
      model.recoverPass(email);
      Verifiqueoemail(context);

    },
  );
  Widget cancelButton = FlatButton(
    child: Text("Não"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Nova senha"),
    content: Text("Atenção: Será enviado um e-mail com instruções para redefinir sua senha. Aceita que seja enviado o e-mail?"),
    actions: [
      cancelButton,
      simButton,

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
Verifiqueoemail(BuildContext context) {
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Verifique sua caixa de e-mail"),
    content: Text("Caso não tenha recebido nenhum e-mail, aguarde alguns instantes."),
    actions: [
      okButton,
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