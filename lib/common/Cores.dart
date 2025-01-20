import 'package:flutter/material.dart';

Color BaseColors(String color){
  if(color == 'color1'){
    return Color.fromRGBO(7, 164, 96, 1.0); // verde
    //return Color.fromRGBO(220, 50, 10, 1.0); // vermelho
    //return Color.fromRGBO(6, 60, 122, 1.0); // azul
  } else if(color == 'color2') {
    return Color.fromRGBO(23, 77, 53, 1.0); // verde
    //return Color.fromRGBO(100, 55, 55, 1.0); // vermelho
    //return Color.fromRGBO(21, 35, 50, 1.0); // azul
  } else if(color == 'color3') {
    return Colors.white;
  } else if(color == 'color4') {
    return Colors.black;
  } else if(color == 'colortxt') {
    return Colors.white;
  } else if(color == 'colorbgimgpri') {
    return Colors.grey[200];
  } else if(color == 'colorbgimgsec') {
    return Colors.grey[300];
  } else if(color == 'corcancel'){
    return Colors.grey;
  }
}



