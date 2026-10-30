import 'package:flutter/material.dart';

import '../update/update_checker.dart';

/// Altura do rodapé em 100%.
const double updateBarHeight = 22;

enum _State { idle, checking, upToDate, available, failed }

/// Rodapé: botão de atualização à esquerda, versão no canto direito.
class UpdateBar extends StatefulWidget {
  const UpdateBar({
    super.key,
    required this.version,
    required this.check,
    required this.openUrl,
    this.checkOnStart = false,
  });

  final String version;
  final Future<UpdateResult> Function() check;
  final Future<void> Function(String url) openUrl;

  /// Consulta o GitHub assim que o teclado abre.
  final bool checkOnStart;

  @override
  State<UpdateBar> createState() => _UpdateBarState();
}

class _UpdateBarState extends State<UpdateBar> {
  _State _state = _State.idle;
  UpdateAvailable? _update;

  @override
  void initState() {
    super.initState();
    if (widget.checkOnStart) _check();
  }

  Future<void> _check() async {
    setState(() => _state = _State.checking);
    final result = await widget.check();
    if (!mounted) return;
    setState(() {
      switch (result) {
        case UpdateAvailable():
          _update = result;
          _state = _State.available;
        case UpToDate():
          _state = _State.upToDate;
        case UpdateCheckFailed():
          _state = _State.failed;
      }
    });
  }

  void _onTap() {
    if (_state == _State.checking) return;
    if (_update case final update?) {
      widget.openUrl(update.url);
    } else {
      _check();
    }
  }

  String get _label => switch (_state) {
    _State.idle => 'Verificar atualizações',
    _State.checking => 'Verificando…',
    _State.upToDate => 'Você está na última versão',
    _State.available => 'Baixar versão ${_update!.version}',
    _State.failed => 'Não foi possível verificar',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final available = _state == _State.available;
    final fg = available ? scheme.primary : scheme.onSurfaceVariant;
    return SizedBox(
      height: updateBarHeight,
      child: Row(
        children: [
          InkWell(
            key: const Key('update'),
            onTap: _onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    available ? Icons.download_rounded : Icons.refresh_rounded,
                    size: 13,
                    color: fg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: available
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              'v${widget.version}',
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
