import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shiroma_flutter_app/base_screens.dart';
import 'package:shiroma_flutter_app/screens/login.dart';
import 'package:shiroma_flutter_app/screens/novo_cadastro_produto.dart';
import 'package:shiroma_flutter_app/stores/atualizar_page.dart';


import 'common/Cores.dart';

void main() {
  setupLocators();
  runApp(MyApp());
}
void setupLocators(){
  GetIt.I.registerSingleton(AtualizarPage());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shiroma_flutter_app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.white,
        cursorColor: BaseColors('color1'),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        Locale('pt','BR'),
      ],
      home:  BaseScreen(),//CONTEINERS
    );
  }
}
