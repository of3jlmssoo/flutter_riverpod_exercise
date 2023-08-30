import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// done: try to remove stack_strace
// done: immutable warning : HookConsumerWidget/useTextEditingController

final todoListFilter = StateProvider((_) => TodoListFilter.all);

enum TodoListFilter {
  all,
  active,
  completed,
}

final filteredTodos = Provider<List<EntryItem>>(
  (ref) {
    final filter = ref.watch(todoListFilter);
    final todos = ref.watch(listProvider);

    // return todos;
    // return todos.where((todo) => todo.status == false).toList();
    switch (filter) {
      case TodoListFilter.completed:
        return todos.where((todo) => todo.status == true).toList();
      case TodoListFilter.active:
        return todos.where((todo) => todo.status == false).toList();
      case TodoListFilter.all:
        return todos;
    }
  },
);

final itemCount = Provider<int>((ref) {
  return ref.watch(EntryItemNotifier as AlwaysAliveProviderListenable).length;
});

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MainScreen();
    return _MainScreenState();
  }
}

class _MainScreenState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      home: AccountScreen(),
    );
  }
}

// final _currentTodo = Provider<EntryItem>((ref) => throw UnimplementedError());
final _currentTodo = Provider<EntryItem>(
    (ref) => EntryItem(id: 'dummy', itemDescription: 'dummy'));

class AccountScreen extends HookConsumerWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final item = ref.watch(_currentItem);
    // var item = ref.watch(_currentItem);
    // List<EntryItem> entries = ref.watch(listProvider);
    List<EntryItem> entries = ref.watch(filteredTodos);

    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    final itemIsFocused = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: const Text('リーバーポッドお試し'),
          centerTitle: true,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            // Flexible(flex: 1, child: MyInputItem()),
            Container(
              child: MyInputItem(),
            ),
            Flexible(
              // flex: 2,
              child: ListView(
                children: [
                  for (final i in entries)
                    ListTile(
                      onTap: null,
                      leading: Checkbox(
                        value: ref.read(listProvider.notifier).getStatus(i.id),
                        onChanged: (value) {
                          ref.read(listProvider.notifier).toggle(i.id);
                        },
                      ),
                      title: Text(i.itemDescription),
                      // title: TextFormField(
                      //   initialValue: i.itemDescription,
                      // ),
                      trailing: IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () {
                          ref.read(listProvider.notifier).removeItem(i.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MyInputItem extends ConsumerWidget {
class MyInputItem extends HookConsumerWidget {
  const MyInputItem({Key? key}) : super(key: key);
  // const final formKey = GlobalKey<FormState>();

  // String userinput = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final filter = ref.watch(todoListFilter);

    List<EntryItem> entries = ref.watch(filteredTodos);

    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Form(
        // key: formKey,
        child: SizedBox(
          height: 160,
          child: Column(
            children: [
              TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(labelText: '入力エリア'),
                // onSaved: (input) => userinput = input!,
              ),
              TextButton(
                onPressed: () {
                  debugPrint('---> TextButton onPressed!');
                  // formKey.currentState!.save();
                  EntryItem currentItem = EntryItem(
                      id: UniqueKey().toString(),
                      itemDescription: textEditingController.text);
                  ref.read(listProvider.notifier).addItem(currentItem);
                  // formKey.currentState?.reset();
                  textEditingController.clear();
                },
                child: const Text(
                  '確定',
                  // style: TextStyle(fontSize: 15),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'ステータス',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    'アイテム (${entries.length})',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(
                    width: 120,
                  ),
                  TextButton(
                    onPressed: () => ref.read(todoListFilter.notifier).state =
                        TodoListFilter.all,
                    style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: MaterialStateProperty.all(
                            textColorFor(TodoListFilter.all))),
                    child: const Text(
                      '全',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(todoListFilter.notifier).state =
                        TodoListFilter.active,
                    style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: MaterialStateProperty.all(
                            textColorFor(TodoListFilter.active))),
                    child: const Text(
                      '未',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(todoListFilter.notifier).state =
                        TodoListFilter.completed,
                    style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: MaterialStateProperty.all(
                            textColorFor(TodoListFilter.completed))),
                    child: const Text(
                      '完',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class EntryItem {
  const EntryItem(
      {required this.id, required this.itemDescription, this.status = false});
  // late int index;
  final String id;
  final String itemDescription;
  final bool status;
  @override
  String toString() {
    return 'EntryItem(description: $itemDescription)';
  }

  bool getStats() {
    return status;
  }

  EntryItem copyWith({String? id, String? itemDescription, bool? status}) {
    return EntryItem(
        id: id ?? this.id,
        itemDescription: itemDescription ?? this.itemDescription,
        status: status ?? this.status);
  }
}

class EntryItemNotifier extends StateNotifier<List<EntryItem>> {
  EntryItemNotifier() : super([]);

  void addItem(EntryItem entryitem) {
    state = [...state, entryitem];
  }

  void removeItem(String id) {
    state = [
      for (final todo in state)
        if (todo.id != id) todo,
    ];
  }

  bool getStatus(String id) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == id) return state[i].status;
    }
    return false;
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id != id) todo else todo.copyWith(status: !todo.status),
    ];
  }
}

final listProvider = StateNotifierProvider<EntryItemNotifier, List<EntryItem>>(
  (ref) {
    return EntryItemNotifier();
  },
);

bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

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
