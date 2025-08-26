# Lembra AÍ

Breve guia prático para entender a estrutura do projeto e reaproveitar componentes.

---

## Estrutura principal

```
lib/
core/ # constants, tema, utils reutilizáveis
models/ # modelos (Hive)
providers/ # state (ListsProvider, ReportProvider, ThemeProvider)
screens/ # telas (UI)
services/ # serviços (PDF, barcode, AI)
widgets/ # componentes reutilizáveis (cards, inputs, dialogs, buttons)
```


---

## `lib/core/`
- `constants/strings.dart` — todas as strings: use `Strings.xxx`.
- `constants/dimensions.dart` — espaçamentos, tamanhos, ícones.
- `theme/colors.dart` — `AppColors` centraliza paleta.
- `theme/app_theme.dart` — `AppTheme.light` / `AppTheme.dark` (defina `floatingActionButtonTheme`, `textTheme`).
- `theme/text_styles.dart` — funções `AppTextStyles.xxx(context)` que retornam `TextStyle` dependentes do `Theme`.
- `utils/formatters.dart` — formatadores (moeda, data).

Reaproveitar:
- Importe e use: `AppTextStyles.bodyLarge(context)` e `Dimensions.*`, `AppColors.*`, `Strings.*`.

---

## `lib/models/`
- Hive models e arquivos gerados. Ao alterar modelos:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## `lib/providers/`
- Lógica de negócio / fonte única da verdade.
- Padrões:
  - Ler em `build`: `context.watch<ProviderType>()`.
  - Ações sem ouvir: `context.read<ProviderType>()`.
  - Capture provider antes de `await` se precisar dele depois do `await`.

---

## `lib/screens/`
- Telas compostas por widgets do `widgets/` e lógica em `providers/`.
- Convenção: UI apenas; movimento de dados em providers.
- Evite usar `context` após `await` sem checar `mounted` ou capturar valores antes.

Exemplo (criar nova lista):
```dart
final provider = context.read<ListsProvider>();
final name = await _showNewListDialog(context);
if (name != null && name.isNotEmpty) await provider.addList(name);
```

---

## `lib/widgets/`
- Componentes reutilizáveis:
  - `cards/` — `ShoppingItemCard`, `ShoppingInfoCard`
  - `inputs/` — `SearchField`, `CurrencyField`
  - `dialogs/` — `ConfirmDialog.show(...)`
  - `buttons/` — `PrimaryButton`
- Regras:
  - Receba callbacks (melhor testabilidade).
  - Use `Dimensions`, `AppColors`, e `AppTextStyles(context)`.

---

## Botões / UX
- Use **FAB** para ação principal (criar lista). Controle cor via `floatingActionButtonTheme` em `AppTheme`.
- Use `PrimaryButton` para botões de formulário/layout (suporta `isLoading`, `fullWidth`).
- Label de botões sempre via `Strings.*`.

---

## Tema e textos dinâmicos
- Use `AppTextStyles.xxx(context)` para que as fontes mudem automaticamente com o tema.
- Não crie `TextStyle` com cores fixas que não mudem no modo escuro.

---

## Serviços
- `ReportProvider` orquestra geração de PDF (serviço `pdf` + salvar com `path_provider` + `open_file`).
- Mantenha serviços stateless e fáceis de testar.

---

## Boas práticas (resumo)
- DRY: Strings, dimensões, cores centralizados.
- KISS: lógica no provider, UI nas telas.
- Segurança com context: capture antes de `await` e cheque `if (!context.mounted) return;` antes de usar `context`.
- Use `const` sempre que possível.
- Centralize estilos no `core/theme` — muda o visual em um lugar só.

---

## Exemplos práticos rápidos
- Usar texto do core:
```dart
Text(Strings.btnCreate)
```

- Usar estilo reativo ao tema:
```dart
Text('Título', style: AppTextStyles.titleMedium(context));
```

- Capturar provider antes de await:
```dart
final provider = context.read<ListsProvider>();
final result = await someAsync();
await provider.doSomething(); // OK — provider capturado antes do await
```

- FAB usando theme:
```dart
FloatingActionButton.extended(
  onPressed: () { ... },
  icon: const Icon(Icons.add),
  label: Text(Strings.btnCreate),
)
```
(tema controla `foregroundColor` via `AppTheme`)

---

## Hive / build runner
Se alterar modelos Hive:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Comandos úteis
```bash
dart format .
flutter analyze
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Checklist antes de remover código
- Rodar `rg`/search global por nomes antigos (`theme.dart`, `primaryColor`, `shopping_provider`, `item_card`, `info_card`) — não deve haver referências.
- `dart format .` → `flutter analyze` → `flutter run` (fluxos críticos).

---