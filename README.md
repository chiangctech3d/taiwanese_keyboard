# Teclado Taiwanês

Teclado virtual flutuante para os caracteres especiais do taiwanês
(Pe̍h-ōe-jī): vogais com tons, o͘, m e n com diacríticos, ⁿ.

Clique num caractere e ele é **digitado no programa que você estava usando**
(Word, navegador, bloco de notas…). A janela fica sempre por cima e não
rouba o foco, então dá para alternar entre o teclado do computador e os
cliques.

- **Como um teclado normal:** clique no acento (tons 2, 3, 5, 7, 8, 9) e
  depois na letra (a e i o o͘ u m n). Sem acento, a letra sai simples.
  Clicar no acento de novo desmarca. O ⁿ não recebe acento.
- **Maiúsculas:** segure o Shift do computador (ou ligue o Caps Lock).
- Passe o mouse numa tecla para ver o código Unicode.

## Baixar

Na página **Releases** do repositório:

- **Windows:** `teclado-taiwanes-windows.zip` → descompacte e abra
  `teclado_taiwanes.exe`. Se o SmartScreen avisar, clique em *Mais
  informações → Executar assim mesmo*.
- **Mac:** `teclado-taiwanes-macos.dmg` → arraste para *Aplicativos*.
  Como o app não é assinado pela Apple, o Mac bloqueia a primeira
  abertura. Tente abrir uma vez, depois vá em **Ajustes do Sistema →
  Privacidade e Segurança** e clique em **Abrir Mesmo Assim**. (Ou, no
  Terminal: `xattr -dr com.apple.quarantine "/Applications/Teclado Taiwanes.app"`.)
  Depois permita em **Ajustes do Sistema → Privacidade e Segurança →
  Acessibilidade**. Sem essa permissão o caractere é copiado e você cola
  com ⌘V.
  - Ao atualizar para uma versão nova, se parar de digitar, remova o app
    da lista de Acessibilidade (botão **−**) e adicione de novo.
  - Logo depois de abrir o app, clique primeiro no documento onde vai
    escrever.

**Limitação:** programas abertos como administrador (no Windows) não
aceitam a digitação de outros programas. Neles o teclado não funciona.

## Desenvolver

Requisitos: Flutter (canal stable) e VS Code com a extensão Flutter.

- Windows: Visual Studio 2022 com **Desenvolvimento para desktop com C++**.
- Mac: Xcode.

```bash
flutter pub get
flutter test
flutter run -d windows   # ou -d macos
```

A tabela de caracteres fica em `lib/data/poj_chars.dart`.

## Gerar os executáveis (GitHub Actions)

- `CI` roda `flutter analyze` e `flutter test` a cada push.
- `Release` compila Windows e Mac. Para publicar uma versão:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Os arquivos aparecem em **Releases** em ~10 minutos. Também dá para rodar
o workflow à mão em **Actions → Release → Run workflow**; os arquivos ficam
como *artifacts* da execução.

## Checklist de teste manual

- [ ] Windows: com o Bloco de Notas em foco, clicar em teclas digita nele e
      o cursor continua lá.
- [ ] Windows: Word e navegador recebem a̍ e o̍͘ corretamente.
- [ ] Segurar Shift físico: grade em maiúsculas; clique digita maiúscula sem
      selecionar texto no app.
- [ ] Caps Lock físico liga as maiúsculas.
- [ ] Acento + letra digita a combinação; letra sozinha sai simples.
- [ ] Mac sem permissão: aparece "Copiado — cole com ⌘V" e o botão
      *Permitir* abre os Ajustes.
- [ ] Mac com permissão: digita no TextEdit sem tirar o foco dele.
- [ ] Mac: passar o mouse mostra o código Unicode; fechar a janela encerra o app.
- [ ] Windows: minimizar e restaurar pela barra de tarefas; título "Teclado Taiwanês".
