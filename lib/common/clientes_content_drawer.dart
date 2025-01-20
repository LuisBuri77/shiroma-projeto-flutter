
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shiroma_flutter_app/common/list_icon.dart';
import 'package:shiroma_flutter_app/model/user_model.dart';
import 'package:shiroma_flutter_app/stores/atualizar_page.dart';

class ClientesContentDrawer extends StatefulWidget {

  @override
  _ClientesContentDrawerState createState() => _ClientesContentDrawerState();
}

class _ClientesContentDrawerState extends State<ClientesContentDrawer> {
  final AtualizarPage atualizarPage = GetIt.I<AtualizarPage>();

  bool highlighted = true;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>(
          builder: (context, child, model){
            return Column(
              children: <Widget> [
                ListIcon(
                  text: "Ofertas",
                  iconData: Icons.business,
                  onTap: (){
                    Navigator.of(context).pop();
                    atualizarPage.setPage(1);
                  },
                  highlighted: atualizarPage.page == 1,
                ),

                ListIcon(
                  text: "Meus Produtos",
                  iconData: Icons.business,
                  onTap: (){
                    Navigator.of(context).pop();
                    atualizarPage.setPage(2);
                  },
                  highlighted: atualizarPage.page == 2,
                ),
                Divider(),
                ListIcon(
                    text: "Sair",
                    iconData: Icons.arrow_back,
                    onTap: (){
                      Navigator.of(context).pop();
                      model.signOut();
                      atualizarPage.setPage(0);
                    },
                    highlighted: false
                ),
              ],
            );
          }
      ),
    );
  }
}
