import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cpfcnpj/cpfcnpj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiroma_flutter_app/base_screens.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/model/user_model.dart';
import 'package:http/http.dart' as http;





class NovoCadastroScreen extends StatefulWidget {

  @override
  _NovoCadastroScreenState createState() => _NovoCadastroScreenState();
}
class _NovoCadastroScreenState extends State<NovoCadastroScreen> {
  var selectedtipoCond;
  List<String> tipoCond = <String>['Casa', 'Apartamento'];
  var selectedEstado;
  List<String> estados = <String>['AC','AL','AP','AM','BA','CE','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO','DF'];
  var selectedCondominios;
  File _image;
  String fileName, url;
  String Token;
  String _nome, _CPF, _telefone, _codigo, _bloco, _numero, _email, _senha, cep, rua, numero, bairro, cidade, _conformesenha;
  String IDCondominio, CodigoCondominio;
  bool firstTime = false, checkBoxValue = false;
  var erroCep;


  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
  final _senhaController = TextEditingController();
  final _confirmesenhaController = TextEditingController();

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
    }else{
      setState(() {
        _image = null;
      });
    }
  }
  ConsultaCep() async{
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
    if(erroCep == true){
      ruaController.clear();
      cidadeController.clear();
      bairroController.clear();
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if(firstTime == true) _formKey.currentState.validate();
    });

  }
  //limparcampos
  void limparcampos(){
    _nomeController.clear();
    _CPFController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _senhaController.clear();
    _confirmesenhaController.clear();
    selectedCondominios = null;
    _image = null;
    fileName = null; url = null;
    _nome = null; _CPF = null; _telefone = null; _codigo = null; _bloco = null; _numero = null; _email = null; _senha = null; _conformesenha = null;
    IDCondominio = null; CodigoCondominio = null;
    firstTime = false;
  }
  _onSuccess(BuildContext context){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
    );
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();
    });
  }
  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Falha ao criar usuário!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        )
    );
  }
  Future<void> salvarcliente(context, model) async {
    //capturando algum campo do bd que já tenha o CNPJ ou nome fantasia iguais
    final QuerySnapshot result1 = await Future.value(Firestore.instance.collection("clientes").where("CPF", isEqualTo: "$_CPF").limit(1).getDocuments());
    final QuerySnapshot result2 = await Future.value(Firestore.instance.collection("clientes").where("email", isEqualTo: "$_email").limit(1).getDocuments());
    final List<DocumentSnapshot> documents1 = result1.documents;
    final List<DocumentSnapshot> documents2 = result2.documents;
    //verificar se já existe o CNPJ ou nome_fantasia
    if (documents1.length == 1 || documents2.length == 1 ) {
      AlertaClienteExistente(context);
    } else{
      if(CPF.isValid(_CPF)){
        //Salavando imagem
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
          'nome': _nome,
          'CPF': _CPF,
          'telefone': _telefone,
          'email': _email,
          'cep': cep,
          'rua': rua,
          'bairro': bairro,
          'numero': numero,
          'cidade': cidade,
          'estado': selectedEstado,
          'hierarquia': "clientes",
        };

        model.signUp(
            userData: userData,
            pass: _senha,
            onSuccess: _onSuccess(context),
            onFail: _onFail
        );

      }else {
        AlertaCPFIncorreto(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text("Novo cliente"),
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
                  if (model.isLoading)
                    return Center(child: CircularProgressIndicator(),);
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
                                  //color: BaseColors('colorbgimgpri'),
                                  height: 90,
                                  child: ListView.builder(
                                    itemCount: 1,
                                    //scrollDirection: Axis.horizontal,
                                    itemBuilder: (context,index){
                                      return Container(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: (){
                                            getImage();
                                          },
                                          child: CircleAvatar(
                                            radius: 44,
                                            backgroundColor: BaseColors('colorbgimgsec'),
                                            child: (_image!=null)? ClipRRect(
                                                borderRadius: BorderRadius.circular(44.0),
                                                child: Container(
                                                  width: 90,
                                                  height: 90,
                                                  child: Image.file(
                                                    _image,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                )
                                            ): Icon(
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

                                Text(
                                    "Informações Pessoais",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: BaseColors('color2'),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )
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
                                    if(firstTime == true){
                                      _formKey.currentState.validate();
                                    }
                                  },
                                  validator: (String value) {
                                    if(value.isEmpty){
                                      return 'Insira seu nome completo!';
                                    }
                                    return null;
                                  },
                                ),

                                // Campo para o CPF
                                TextFormField(
                                  controller: _CPFController,
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
                                  onChanged: (textCPF){
                                    _CPF = _CPFController.text;
                                    if(firstTime == true){
                                      _formKey.currentState.validate();
                                    }
                                  },
                                  validator: (String value) {
                                    if(value.isEmpty){
                                      return 'Informe o CPF!';
                                    }
                                    if(!(CPF.isValid(value))){
                                      return 'O CPF informado não é valido!';
                                    }
                                    return null;
                                  },
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

                                // Campos para Conta Bancária

                                const SizedBox(height: 20),
                                Text(
                                    "Senha",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: BaseColors('color2'),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                // Campo para a Senha
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: InputDecoration(
                                    //border: const OutlineInputBorder(),
                                    isDense: true,
                                    labelText: "Senha *",
                                  ),
                                  onChanged: (textSenha){
                                    _senha = _senhaController.text;
                                    if(firstTime == true){
                                      _formKey.currentState.validate();
                                    }
                                  },
                                  validator: (String value){
                                    if(value.isEmpty){
                                      return 'Informe sua senha!';
                                    }else if(value.length <= 7){
                                      return 'Sua senha deve ter pelo menos 8 caracteres';
                                    }
                                    return null;
                                  },
                                  obscureText: true,
                                ),

                                // Campo para confirmar a Senha
                                TextFormField(
                                  controller: _confirmesenhaController,
                                  decoration: InputDecoration(
                                    //border: const OutlineInputBorder(),
                                    isDense: true,
                                    labelText: "Confirme sua senha *",
                                  ),
                                  onChanged: (textConfirmesenha){
                                    _conformesenha = _confirmesenhaController.text;
                                    if(firstTime == true){
                                      _formKey.currentState.validate();
                                    }
                                  },
                                  validator: (String value){
                                    if(value.isEmpty){
                                      return 'Informe novamente sua senha!';
                                    }
                                    if(_confirmesenhaController.text == _senhaController.text){
                                      return null;
                                    } else{
                                      return 'As senhas não correspondem!';
                                    }
                                  },
                                  obscureText: true,
                                ),

                                SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(value: checkBoxValue,
                                        activeColor: Colors.green,
                                        materialTapTargetSize: MaterialTapTargetSize.padded,
                                        onChanged:(bool newValue){
                                          setState(() {
                                            checkBoxValue = newValue;
                                          });
                                        }
                                    ),
                                    // SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Li e aceito os ",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.clip
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                /*Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            TermosDeUsoScreen()));*/
                                              },
                                              child: Text(
                                                "Termos e ",
                                                style: TextStyle(
                                                  color: BaseColors("color1"),
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            /*Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        TermosDeUsoScreen()));*/
                                          },
                                          child: Text(
                                            "Condições de Uso",
                                            style: TextStyle(
                                              color: BaseColors("color1"),
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                                const SizedBox(height: 16),

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
                                    onPressed: (){
                                      print(Token);
                                      firstTime = true;
                                      _formKey.currentState.validate();
                                      if(_formKey.currentState.validate() == true){
                                        salvarcliente(context, model);
                                      }
                                    },
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
                                        "Ja possui uma conta?",
                                        style: TextStyle(
                                          color: BaseColors('color2'),
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          limparcampos();
                                          Navigator.of(context).pop(
                                              MaterialPageRoute(builder: (_) =>  BaseScreen())
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "Entre já!",
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
                          ),

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
AlertaClienteExistente(BuildContext context){
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: (){
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Você já está cadastrado!"),
    content: Text("CPF ou e-mail já existente!"),
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
RequisitarCondominio(BuildContext context){
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: (){
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Não encontrou seu condomínio?"),
    content: Text("Entre em contato para realizar a solicitação do cadastro do seu condomínio "
        "no aplicativo. Os administradores irão analisar se o seu condomínio deve ou nao ser aceito. "
        "Para entrar em contato: \n\nEmail: contato@freesbe.com.br\nTelefone: (16)99250-3290"),
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
DuvidaCodigoCondominio(BuildContext context){
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: (){
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Codigo do condomínio?"),
    content: Text("Entre em contato com o sindico do seu condomínio para que o mesmo "
        "lhe forneça o código do seu condomínio, pois sem esse código não será possivel "
        "completar o seu cadastro!"),
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
AlertaCPFIncorreto(BuildContext context){
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: (){
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("O CPF digitado está incorreto!"),
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
