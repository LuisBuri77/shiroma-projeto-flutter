import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:shiroma_flutter_app/screens/login.dart';
import 'package:shiroma_flutter_app/screens/minhas_ofertas_screen.dart';
import 'package:shiroma_flutter_app/screens/ofertas_screen.dart';
import 'package:shiroma_flutter_app/stores/atualizar_page.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final PageController pageController = PageController();
  final AtualizarPage atualizarPage = GetIt.I<AtualizarPage>();

  @override
  void initState(){
    super.initState();
    reaction((_) => atualizarPage.page,
            (page) => pageController.jumpToPage(page)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //backgroundColor: BaseColors('corpri'),
      //title: Text("Clube de Benefícios"),
      //),
      //drawer: CustomDrawer(),
      body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            LoginScreen(), //0
            OfertasScreen(), //1
            MinhasOfertasScreen(), //2


          ]
      ),
    );
  }
}

