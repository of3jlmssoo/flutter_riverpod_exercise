## メモ 1

https://github.com/rrousselGit/riverpod/tree/master/examples/todos

flutter spread operator https://dart.dev/language/collections

画面全体が listview(ロゴも含めて)

- Title()
- TextField()
- Toolbar()
- todo のエントリー for()で Dismissible()を表示している

```dart
todoのエントリーを保持しているのはここ
final todoListProvider = StateNotifierProvider<TodoList, List<Todo>>((ref) {
  return TodoList(const [
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]);
});



filteredTodosでリストが返される in Home()
final todos = ref.watch(filteredTodos);



todoListFilterの設定に応じて返すリストを変えている
final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
});




Toolbar内(アイテム数、All、Active、Completedのメニュー)
ここでtodoListFilterの値をセットしている。state=
onPressed: () => ref.read(todoListFilter.notifier).state = TodoListFilter.all,
onPressed: () => ref.read(todoListFilter.notifier).state = TodoListFilter.active,
onPressed: () => ref.read(todoListFilter.notifier).state = TodoListFilter.completed,




enum TodoListFilter {
  all,
  active,
  completed,
}
final todoListFilter = StateProvider((_) => TodoListFilter.all);
デフォルトをセットしている
stateは無いがstateにセットされている

```

### - todo のエントリー for()で Dismissible()を表示している

````dart
children: [

  - Title()
  - TextField()
  - Toolbar()

  if (todos.isNotEmpty) const Divider(height: 0),
    for (var i = 0; i < todos.length; i++) ...[
      if (i > 0) const Divider(height: 0),
      Dismissible(
        key: ValueKey(todos[i].id),
        onDismissed: (_) {
          ref.read(todoListProvider.notifier).remove(todos[i]);
        },
        child: ProviderScope(
          overrides: [
            _currentTodo.overrideWithValue(todos[i]),
          ],
          child: const TodoItem(),
        ),
      ),
  ],
],```
````

- for + spread operator(...)
  for + spread operator(...)で Dismissible Widget が作成されて children の 1 child として返される
- dismissible
  If the Dismissible is a list item, it must have a key that distinguishes it from the other items and its onDismissed callback must remove the item from the list.

#### TodoItem()

```dart
todo.dartにclass Todoあり
final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

/// The widget that that displays the components of an individual Todo Item
class TodoItem extends HookConsumerWidget {
  const TodoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    上でProvider _currentTodoを定義の上watchしている
    final todo = ref.watch(_currentTodo);

    flutter hooksでのuseFocusNode()。Creates a FocusNode
    final itemFocusNode = useFocusNode();

    useIsFocusedでコールバック関数を登録すると共にwidgetがフォーカスされているか
    itemIsFocusedへ収めている
    final itemIsFocused = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();

    useFocusNode()2つ目
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,


        フォーカスを得るとtrueでフォーカスが外れるとfalse
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            ref
                .read(todoListProvider.notifier)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },

        アイコンとテキストのListTile
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },

          マテリアルデザインのCheckboxあり
          valueはbool
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) =>
                ref.read(todoListProvider.notifier).toggle(todo.id),
          ),
          title: itemIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
```

```dart
FocusNodeが引数として呼ばれる
bool useIsFocused(FocusNode node) {

  flutter hooksのuseState。Creates a variable and subscribes to it.
  hasFocusはFocusNodeのプロパティ
  フォーカスされているか初期状態をvariable isFocusedに収めている
  final isFocused = useState(node.hasFocus);

  useEffectはflutter hooksの関数
  [node]のノードが変わった際に呼ばれる関数を登録
  その後初期自体(bool)をreturnしている
  useEffect(
    () {
      void listener() {
        isFocused.value = node.hasFocus;
      }

      node.addListener(listener);
      return () => node.removeListener(listener);
    },
    [node],
  );

  return isFocused.value;
}
```

## メモ 2

```dart
final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

/// The widget that that displays the components of an individual Todo Item
class TodoItem extends HookConsumerWidget {
  const TodoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);         // 上の_currentTodoをwatchしている
    final itemFocusNode = useFocusNode();
      // return MaterialのFocusにセット
      // フォーカスがあると、textEditingController.text = todo.description;
      // フォーカスが外れると、editでループで再構築
    final itemIsFocused = useIsFocused(itemFocusNode);
      // これで、TextFieldかTextを切り替える

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();
---------------------------------------------------------------------
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
            // requestFocus() x 2
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) =>
                ref.read(todoListProvider.notifier).toggle(todo.id),
          ),
          title: itemIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
```
