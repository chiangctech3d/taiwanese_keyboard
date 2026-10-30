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
- **A− / A+** (canto superior direito) diminuem ou aumentam o teclado.
  O tamanho fica salvo.
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

- Windows: Visual Studio 2022 com **Desenvolvimento para desktop com C++**
  e o **Modo de Desenvolvedor** ligado (exigido por plugins do Flutter).
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
- [ ] A+ / A− mudam o tamanho da janela; ao reabrir o app o tamanho volta.
- [ ] Mac sem permissão: aparece "Copiado — cole com ⌘V" e o botão
      *Permitir* abre os Ajustes.
- [ ] Mac com permissão: digita no TextEdit sem tirar o foco dele.
- [ ] Mac: passar o mouse mostra o código Unicode; fechar a janela encerra o app.
- [ ] Windows: minimizar e restaurar pela barra de tarefas; título "Teclado Taiwanês".

## Privacidade

O Teclado Taiwanês não coleta nem envia dados. Ele não acessa a internet;
só digita no programa em uso os caracteres em que você clica. O tamanho
escolhido (A−/A+) fica salvo apenas no seu computador.

## Licença

GPL-3.0. Veja [LICENSE](LICENSE).

## Code signing policy

Free code signing provided by [SignPath.io](https://about.signpath.io),
certificate by [SignPath Foundation](https://signpath.org).

- Autor, revisor e aprovador: [chiangctech3d](https://github.com/chiangctech3d)
- Só o executável `teclado_taiwanes.exe`, compilado a partir deste
  repositório pelo GitHub Actions, é assinado.

## Publicação (para o mantenedor)

### Assinatura do .exe no GitHub (SignPath)

1. Peça o plano gratuito para open source em <https://signpath.org/apply>
   (o projeto precisa estar público, com a licença GPL-3.0 e uma release
   já publicada — a v0.1.0 serve).
2. Ative MFA na conta do SignPath e no GitHub.
3. No SignPath: crie o projeto, conecte o *Trusted Build System* do
   GitHub e cole o conteúdo de
   [`.signpath/artifact-configuration.xml`](.signpath/artifact-configuration.xml)
   como configuração de artefato.
4. No GitHub, em **Settings → Secrets and variables → Actions**:
   - segredo `SIGNPATH_API_TOKEN` (token de API do SignPath);
   - variáveis `SIGNPATH_ORGANIZATION_ID`, `SIGNPATH_PROJECT_SLUG` e
     `SIGNPATH_SIGNING_POLICY_SLUG`.
5. A próxima tag `v*` gera o `.zip` do Windows com o `.exe` assinado. Se a
   política exigir aprovação, aprove o pedido no SignPath em até 1 hora.

Sem essas variáveis, o workflow continua gerando o `.zip` sem assinatura.

### Microsoft Store

1. Crie a conta de desenvolvedor individual (grátis) em
   <https://storedeveloper.microsoft.com> e conclua a verificação de
   identidade.
2. No Partner Center, reserve o nome **Teclado Taiwanês**.
3. Em **Gerenciamento de produto → Identidade do produto**, copie:
   *Package/Identity/Name*, *Package/Identity/Publisher* (começa com
   `CN=`) e *Package/Properties/PublisherDisplayName*.
4. No GitHub, crie as variáveis `MSIX_IDENTITY_NAME`, `MSIX_PUBLISHER` e
   `MSIX_PUBLISHER_DISPLAY_NAME` com esses valores.
5. Rode o workflow **Release** (tag `v*` ou manualmente) e baixe o
   artifact **msix-store**.
6. No Partner Center, crie uma submissão, envie o `teclado-taiwanes.msix`
   em **Pacotes**, preencha a listagem (descrição, capturas de tela) e
   envie para certificação. Como o app usa `runFullTrust` (simula
   digitação), explique na nota para os certificadores que ele digita os
   caracteres clicados no programa em uso, a pedido do usuário.
