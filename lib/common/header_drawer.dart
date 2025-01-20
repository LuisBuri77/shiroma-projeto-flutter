
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/config_pages.dart';
import 'package:shiroma_flutter_app/screens/editar_dados_cliente.dart';


String user;
void InserirUsuario(String usuarionovo){
  user = usuarionovo;
}

class HeaderDrawer extends StatefulWidget {

  @override
  _HeaderDrawerState createState() => _HeaderDrawerState();
}

class _HeaderDrawerState extends State<HeaderDrawer> {

  Map<String, dynamic> dados = Map();

  @override
  Widget build(BuildContext context) {
    dados = getData();

    return Container(
        height: 100,
        padding: const EdgeInsets.only(left: 15),
        color : BaseColors('color1'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                ((dados['urlimg'] == null || dados['urlimg'] == '') && (dados['nome_sindico'] != null))?
                ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      child: Icon(
                        Icons.home,
                        size: 35,
                        color: BaseColors('colortxt'),
                      ),
                    )
                ):((dados['urlimg'] == null || dados['urlimg'] == '') && (dados['nome_sindico'] == null))?
                ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: BaseColors('colortxt'),
                      ),
                    )
                ): ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Container(
                    width: 55,
                    height: 55,
                    child: Image.network(
                      dados['urlimg'],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                const SizedBox( width: 20,),
                Container(
                  width: 0.45*MediaQuery.of(context).size.width,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${dados['nome'].isEmpty? "" : dados["nome"]}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                  ),
                )
              ],
            ),
            GestureDetector(
              onTap: (){
                if(user == 'clientes'){
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) =>  EditarDadosScreen())
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget> [
                  Text(
                    "Editar Dados",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                      // fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox( width: 20),
                ],
              ),
            )
          ],
        )
    );
  }
}
