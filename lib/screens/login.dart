
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/config_pages.dart';
import 'package:shiroma_flutter_app/common/header_drawer.dart';
import 'package:shiroma_flutter_app/model/user_model.dart';
import 'package:shiroma_flutter_app/screens/novo_cadastro.dart';
import 'package:shiroma_flutter_app/stores/atualizar_page.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var color1 = BaseColors('color1');
  var color2 = BaseColors('color2');
  String email, senha;
  bool firstTime = false;
  bool senhaIcon = false;
  int emailIcon = 0;


  final AtualizarPage atualizarPage = GetIt.I<AtualizarPage>();

  var emailController = TextEditingController();
  var senhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Center(child: Text("Seja bem-vindo")),
          backgroundColor: color1,
        ),
        //backgroundColor: Color.fromRGBO(7, 164, 96, 1.0),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color1, color2],
            ),
          ),
          child: ScopedModel<UserModel>(
            model: UserModel(),
            child: ScopedModelDescendant<UserModel>(
              builder: (context, child, model) {
                if (model.isLoading)
                  return Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      height: 50.0,
                      width: 50.0,
                    ),
                  );
                if (firstTime == false) {
                  model.signOut();
                  firstTime = true;
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*0.85,
                        child: Center(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  margin:
                                  const EdgeInsets.symmetric(horizontal: 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 3, bottom: 4),
                                          child: Text("E-mail",
                                              style: TextStyle(
                                                color: color2,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                        TextFormField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.person),
                                              onPressed: (){
                                                if(emailIcon == 0){
                                                  print('Deu bom, admin!');
                                                  setState(() {
                                                    email = 'admin@ejeet.com.br';
                                                    emailController.text = email;
                                                    senha = 'Ejeet123';
                                                    senhaController.text = senha;
                                                    emailIcon = 1;
                                                  });
                                                }else if(emailIcon == 1){
                                                  print('Deu bom, cliente!');
                                                  setState(() {
                                                    email = 'cliente@ejeet.com.br';
                                                    emailController.text = email;
                                                    senha = 'Ejeet123';
                                                    senhaController.text = senha;
                                                    emailIcon = 2;
                                                  });
                                                }else if(emailIcon == 2){
                                                  print('Deu bom, parceiro!');
                                                  setState(() {
                                                    email = 'parceiro@ejeet.com.br';
                                                    emailController.text = email;
                                                    senha = 'Ejeet123';
                                                    senhaController.text = senha;
                                                    emailIcon = 3;
                                                  });
                                                }else if(emailIcon == 3){
                                                  print('Deu bom, funcionario!');
                                                  setState(() {
                                                    email = 'funcionario@ejeet.com.br';
                                                    emailController.text = email;
                                                    senha = 'Ejeet123';
                                                    senhaController.text = senha;
                                                    emailIcon = 4;
                                                  });
                                                }else if(emailIcon == 4){
                                                  print('Deu bom, condominio!');
                                                  setState(() {
                                                    email = 'condominio@ejeet.com.br';
                                                    emailController.text = email;
                                                    senha = 'Ejeet123';
                                                    senhaController.text = senha;
                                                    emailIcon = 5;
                                                  });
                                                }else if(emailIcon == 5){
                                                  setState(() {
                                                    email = null;
                                                    emailController.clear();
                                                    senha = null;
                                                    senhaController.clear();
                                                    emailIcon = 0;
                                                  });
                                                }
                                              },
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                          autocorrect: false,
                                          onChanged: (textEmail) {
                                            email = textEmail;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty) {
                                              return 'Informe o seu email!';
                                            }
                                            if (value.contains('@') &&
                                                value.contains('.com')) {
                                              return null;
                                            } else {
                                              return 'O email informado não é valido!';
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 3, bottom: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Senha",
                                                  style: TextStyle(
                                                    color: color2,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              GestureDetector(
                                                onTap: () {
                                                  if ((!email.contains('@') &&
                                                      !email.contains('.com')) || email.isEmpty) {
                                                    Digiteoemail(context);
                                                  }else{
                                                    EsqueceuSenha(context, model, email);
                                                  }
                                                },
                                                child: Text(
                                                  "Esqueceu sua senha?",
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration.underline,
                                                    color: color1,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextFormField(
                                          controller: senhaController,
                                          decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              icon: (senhaIcon == false) ? Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye),
                                              onPressed: (){
                                                setState(() {
                                                  senhaIcon = !senhaIcon;
                                                });
                                              },
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          obscureText: !senhaIcon,
                                          onChanged: (textSenha) {
                                            senha = textSenha;
                                          },
                                          validator: (String value) {
                                            if (value.isEmpty) {
                                              return 'Informe sua senha!';
                                            } else if (value.length <= 7) {
                                              return 'Sua senha deve ter pelo menos 8 caracteres';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          height: 40,
                                          child: RaisedButton(
                                            color: color1,
                                            textColor: Colors.white,
                                            child: Text("Entrar"),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                model.signIn(
                                                    email: email,
                                                    pass: senha,
                                                    onSuccess: _onSuccess,
                                                    onFail: _onFail);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          height: 5,
                                          color: color2,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Não tem uma conta?",
                                                style: TextStyle(
                                                  color: color2,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              NovoCadastroScreen()));

                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    "Cadastre-se!",
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration.underline,
                                                      color: color1,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Copyright @ 2021. Desenvolvido por Luís Shiroma.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: BaseColors('color3'),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  void _onSuccess(String model, Map userData, String idUsuario) {
    InserirUsuario(model);
    setData(userData, idUsuario);
    int num = SetPage(model);
    FocusScope.of(context).requestFocus(new FocusNode());
    atualizarPage.setPage(1);
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao Entrar!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}

Digiteoemail(BuildContext context) {
  // configura o button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  // configura o  AlertDialog
  AlertDialog alerta = AlertDialog(
    title: Text("Digite seu e-mail!"),
    content: Text("Para recuperação de senha, é preciso que você digite o e-mail no campo de 'E-mail' e, em seguida, clique novamente em 'Esqueceu sua senha'."),
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
    content: Text("Caso não tenha recebido nenhum e-mail, aguarde alguns instantes. Após esperar, caso não tenha recebido, o e-mail inserido não possui conta."),
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