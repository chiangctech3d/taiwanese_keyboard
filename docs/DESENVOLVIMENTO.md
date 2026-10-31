# Guia técnico

Para quem quer modificar o código, gerar versões ou publicar o app.

## Rodar no seu computador

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
como *artifacts* da execução (sem publicar um Release).

## Checklist de teste manual

- [ ] Windows: com o Bloco de Notas em foco, clicar em teclas digita nele e
      o cursor continua lá.
- [ ] Windows: Word e navegador recebem a̍ e o̍͘ corretamente.
- [ ] Segurar Shift físico: letras em maiúsculas; clique digita maiúscula
      sem selecionar texto no app.
- [ ] Caps Lock físico liga as maiúsculas.
- [ ] Acento + letra digita a combinação; letra sozinha sai simples.
- [ ] Com acento escolhido, o ⁿ fica desativado.
- [ ] A+ / A− mudam o tamanho da janela; ao reabrir o app o tamanho volta.
- [ ] Rodapé mostra a versão; "Verificar atualizações" responde; com versão
      nova, "Baixar versão X" abre a página de releases no navegador.
- [ ] Mac sem permissão: aparece "Copiado — cole com ⌘V" e o botão
      *Permitir* abre os Ajustes.
- [ ] Mac com permissão: digita no TextEdit sem tirar o foco dele.
- [ ] Mac: passar o mouse mostra a dica; fechar a janela encerra o app.
- [ ] Windows: minimizar e restaurar pela barra de tarefas.

## Assinatura do .exe (SignPath)

1. Peça o plano gratuito para open source em <https://signpath.org/apply>.
2. Ative MFA na conta do SignPath e no GitHub.
3. No SignPath: crie o projeto, conecte o *Trusted Build System* do
   GitHub e cole o conteúdo de
   [`.signpath/artifact-configuration.xml`](../.signpath/artifact-configuration.xml)
   como configuração de artefato.
4. No GitHub, em **Settings → Secrets and variables → Actions**:
   - segredo `SIGNPATH_API_TOKEN` (token de API do SignPath);
   - variáveis `SIGNPATH_ORGANIZATION_ID`, `SIGNPATH_PROJECT_SLUG` e
     `SIGNPATH_SIGNING_POLICY_SLUG`.
5. A próxima tag `v*` gera o `.zip` do Windows com o `.exe` assinado. Se a
   política exigir aprovação, aprove o pedido no SignPath em até 1 hora.

Sem essas variáveis, o workflow continua gerando o `.zip` sem assinatura.

## Microsoft Store

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
   em **Pacotes**, preencha a listagem e envie para certificação. Como o
   app usa `runFullTrust` (simula digitação), explique na nota para os
   certificadores que ele digita os caracteres clicados no programa em
   uso, a pedido do usuário.
