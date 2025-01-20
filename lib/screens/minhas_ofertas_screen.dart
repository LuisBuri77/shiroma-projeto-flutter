import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/config_pages.dart';
import 'package:shiroma_flutter_app/common/drawer/custom_drawer_cliente.dart';
import 'package:shiroma_flutter_app/screens/detalhes_produtos_screen.dart';
import 'package:shiroma_flutter_app/screens/novo_cadastro_produto.dart';
import 'package:url_launcher/url_launcher.dart';


class MinhasOfertasScreen extends StatefulWidget {
  @override
  _MinhasOfertasScreenState createState() => _MinhasOfertasScreenState();
}

class _MinhasOfertasScreenState extends State<MinhasOfertasScreen> {
  Icon cusIcon = Icon(Icons.search, size: 30);
  Widget cusSearchBar = Text('Minhas Ofertas');


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: BaseColors('color1'),
          title: cusSearchBar,
          actions: <Widget>[
            IconButton(
              icon: cusIcon,
              onPressed: () {
                setState(() {
                  if (this.cusIcon.icon == Icons.search) {
                    this.cusIcon = Icon(Icons.cancel, size: 30);
                    this.cusSearchBar = TextField(
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: BaseColors('color3'),
                        fontSize: 20,
                      ),
                    );
                  } else {
                    this.cusIcon = Icon(Icons.search, size: 30);
                    this.cusSearchBar = Text('Minhas Ofertas');
                  }
                });
              },
            ),
          ],
        ),
        drawer: CustomDrawerCliente(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BaseColors('color1'), BaseColors('color2')],
            ),
          ),
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("ofertas").where('responsavel', isEqualTo: getIDuser()).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          height: 50.0,
                          width: 50.0,
                        ),
                      );
                    } else if (snapshot.data.documents.length == 0) {
                      return Center(
                        child: Text(
                          'Lista Vazia',
                          style: TextStyle(
                            color: BaseColors('colortxt'),
                            fontSize: 16,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) =>  DetalhesProdutosScreen(
                                      detalhes: snapshot.data.documents[index],
                                    ))
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                height: 87,
                                child: Card(
                                    color: BaseColors('color3'),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 10,),
                                          // Imagem
                                          (snapshot.data.documents[index].data['image'] != null)
                                              ? Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                        snapshot.data.documents[index].data['urlimg'])),
                                              ))
                                              : Icon(
                                            Icons.image,
                                            size: 50,
                                            color: BaseColors('color2'),
                                          ),
                                          SizedBox(width: 10),

                                          Container(
                                            height: 66,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data.documents[index].data['nome'],
                                                  style: TextStyle(
                                                    color: BaseColors('color2'),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Categoria: ${snapshot.data.documents[index].data['tipo']}',
                                                  style: TextStyle(
                                                    color: BaseColors('color2'),
                                                   // fontStyle: FontStyle.italic,
                                                    fontSize: 12,
                                                  ),
                                                  //overflow: TextOverflow.clip,
                                                ),
                                                Text(
                                                  'Descrição: ${snapshot.data.documents[index].data['descricao']}',
                                                  style: TextStyle(
                                                    color: BaseColors('color2'),
                                                  //  fontStyle: FontStyle.italic,
                                                    fontSize: 12,
                                                  ),
                                                  //overflow: TextOverflow.clip,
                                                ),
                                                Text(
                                                  'Valor: R\$${snapshot.data.documents[index].data['valor']}',
                                                  style: TextStyle(
                                                    color: BaseColors('color2'),
                                                    //fontStyle: FontStyle.italic,
                                                    fontSize: 12,
                                                  ),
                                                  //overflow: TextOverflow.clip,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ),
                              ),
                            );
                          });
                    }
                  })),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      NovoProdutoScreen()));
        },
        tooltip: 'Novo cadastro',
        child: Icon(Icons.add, color: BaseColors('color2'),),
        backgroundColor: Colors.white,
      ),
    );
  }
}
