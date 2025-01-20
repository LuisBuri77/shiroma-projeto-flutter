import 'package:mobx/mobx.dart';

part 'atualizar_page.g.dart';

class AtualizarPage = _AtualizarPage with _$AtualizarPage;

abstract class _AtualizarPage with Store{
  @observable
  int page = 0;

  @action
  void setPage(int value) => page = value;
}