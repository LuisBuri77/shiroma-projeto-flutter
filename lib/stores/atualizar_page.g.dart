// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atualizar_page.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AtualizarPage on _AtualizarPage, Store {
  final _$pageAtom = Atom(name: '_AtualizarPage.page');

  @override
  int get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  final _$_AtualizarPageActionController =
  ActionController(name: '_AtualizarPage');

  @override
  void setPage(int value) {
    final _$actionInfo = _$_AtualizarPageActionController.startAction(
        name: '_AtualizarPage.setPage');
    try {
      return super.setPage(value);
    } finally {
      _$_AtualizarPageActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
page: ${page}
    ''';
  }
}
