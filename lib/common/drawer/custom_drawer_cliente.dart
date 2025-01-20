
import 'package:flutter/material.dart';

import '../clientes_content_drawer.dart';
import '../header_drawer.dart';



class CustomDrawerCliente extends StatefulWidget {
  @override
  _CustomDrawerClienteState createState() => _CustomDrawerClienteState();
}

class _CustomDrawerClienteState extends State<CustomDrawerCliente> {
  @override


  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(35)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                HeaderDrawer(),
                ClientesContentDrawer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
