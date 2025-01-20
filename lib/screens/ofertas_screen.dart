import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shiroma_flutter_app/common/Cores.dart';
import 'package:shiroma_flutter_app/common/drawer/custom_drawer_cliente.dart';
import 'package:url_launcher/url_launcher.dart';


class OfertasScreen extends StatefulWidget {
  @override
  _OfertasScreenState createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  Icon cusIcon = Icon(Icons.search, size: 30);
  Widget cusSearchBar = Text('Ofertas');


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
                    this.cusSearchBar = Text('Ofertas');
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
                  stream: Firestore.instance.collection("ofertas").orderBy('data', descending: true).snapshots(),
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
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Card(
                                color: BaseColors('color3'),
                                child: ExpansionTile(
                                  title: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: <Widget>[
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

                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data.documents[index].data['nome'],
                                              style: TextStyle(
                                                color: BaseColors('color2'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Categoria: ${snapshot.data.documents[index].data['tipo']}',
                                              style: TextStyle(
                                                color: BaseColors('color2'),
                                              //  fontStyle: FontStyle.italic,
                                                fontSize: 12,
                                              ),
                                              //overflow: TextOverflow.clip,
                                            ),
                                            SizedBox(height: 2,),
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: Firestore.instance.collection('clientes').document(snapshot.data.documents[index].data['responsavel']).snapshots(),
                                              builder: (context, snapshot2) {
                                                if (!snapshot2.hasData) {
                                                  return Center(
                                                    child: Text(
                                                      'Carregando',
                                                      style: TextStyle(
                                                        color:
                                                        BaseColors('colortxt'),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    'Local: ' + snapshot2.data['cidade'] +"/" + snapshot2.data['estado'],
                                                    style: TextStyle(
                                                      color: BaseColors('color2'),
                                                 //     fontStyle: FontStyle.italic,
                                                      fontSize: 12,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 16, right: 16, bottom: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              // Descrição


                                              Row(
                                                children: [
                                                  Text(
                                                    'Descrição:',
                                                    style: TextStyle(
                                                      color: BaseColors('color2'),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    snapshot.data.documents[index].data['descricao'],
                                                    style: TextStyle(
                                                      color: BaseColors('color4'),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),

                                              Row(
                                                children: [
                                                  Text(
                                                    'Valor:',
                                                    style: TextStyle(
                                                      color: BaseColors('color2'),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'R\$ ${snapshot.data.documents[index].data['valor']}',
                                                    style: TextStyle(
                                                      color: BaseColors('color4'),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 10),

                                              // Localização
                                              StreamBuilder<DocumentSnapshot>(
                                                stream: Firestore.instance.collection('clientes').document(snapshot.data.documents[index].data['responsavel']).snapshots(),
                                                builder: (context, snapshot3) {
                                                  if (!snapshot3.hasData) {
                                                    return Center(
                                                      child: Text(
                                                        'Carregando',
                                                        style: TextStyle(
                                                          color:
                                                          BaseColors('colortxt'),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Vendedor:',
                                                              style: TextStyle(
                                                                color: BaseColors('color2'),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              snapshot3.data['nome'],
                                                              style: TextStyle(
                                                                color: BaseColors('color4'),
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(height: 10),

                                                        // Contato
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Entre em contato:',
                                                              style: TextStyle(
                                                                color: BaseColors('color2'),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),

                                                            SizedBox(width: 5),
                                                            Text(
                                                              snapshot3.data['telefone'],
                                                              style: TextStyle(
                                                                color: BaseColors(
                                                                    'color4'),
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Column(children: <Widget>[

                                                          SizedBox(height: 5),
                                                          Divider(color: BaseColors('color2'),),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                            children: [
                                                               IconButton(
                                                                  icon: Icon(
                                                                    FontAwesomeIcons.whatsapp,
                                                                    size: 18,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    var url = "https://api.whatsapp.com/send?phone=+550${snapshot3.data['telefone']}&text=Olá,%20estou%20interessado%20no%20seu%20anúncio!";
                                                                    if (await canLaunch(url)) {
                                                                      await launch(url);
                                                                    } else {
                                                                      throw 'Could not launch $url';
                                                                    }
                                                                  }),
                                                            ],
                                                          ),
                                                        ]),
                                                      ],
                                                    );
                                                  }
                                                },
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            );
                          });
                    }
                  })),
        ));
  }
}
