/// Envia texto para o aplicativo que está com o foco.
abstract class Typer {
  /// Retorna `false` se não foi possível digitar (ex.: sem permissão).
  Future<bool> type(String text);
}
