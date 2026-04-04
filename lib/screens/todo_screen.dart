import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repositories/todo_repository.dart';
import '../repositories/stats_repository.dart';
import '../theme/app_theme.dart';
import 'package:untitled/l10n/app_localizations.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _todoRepo  = TodoRepository();
  final _statsRepo = StatsRepository();
  final _controller = TextEditingController();
  List<TodoData> _currentTodos = [];

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  void _saveTodoToStats(String title, String id) {
    final today = DateTime.now();
    final key = StatsRepository.dateKey(
        DateTime(today.year, today.month, today.day));
    _statsRepo.addCompletedTodo(_uid, key, id, title);
  }

  void _removeFromStats(TodoData todo) {
    final date = todo.completedAt ?? DateTime.now();
    final key = StatsRepository.dateKey(
        DateTime(date.year, date.month, date.day));
    _statsRepo.removeCompletedTodo(_uid, key, todo.id);
  }

  void _updateTodoTitleInStats(String id, String newTitle) {
    _statsRepo.updateTodoTitleInStats(_uid, id, newTitle);
  }

  int _nextOrder() => _currentTodos.isEmpty
      ? 0
      : _currentTodos.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;

  Future<void> _addTodo(String title) async {
    if (title.trim().isEmpty) return;
    await _todoRepo.addTodo(_uid, title.trim(), order: _nextOrder());
    _controller.clear();
  }

  void _editTodo(TodoData todo) {
    final l10n = AppLocalizations.of(context)!;
    final editController = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.editDiaryEntry,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: editController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: l10n.newTask,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.textMuted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final newTitle = editController.text.trim();
              if (newTitle.isNotEmpty) {
                if (todo.isDone) _updateTodoTitleInStats(todo.id, newTitle);
                _todoRepo.updateTodo(_uid, todo.copyWith(title: newTitle));
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save,
                style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showAddSheet() {
    _controller.clear();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.newTask,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              cursorColor: AppColors.accent,
              onSubmitted: (val) {
                _addTodo(val);
                Navigator.pop(ctx);
              },
              decoration: InputDecoration(
                hintText: l10n.taskTitleHint,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.accent)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addTodo(_controller.text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.add,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.tasks,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.tasksSubtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- list ---
            Expanded(
              child: StreamBuilder<List<TodoData>>(
                stream: _todoRepo.watchTodos(_uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todos = snapshot.data ?? [];
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _currentTodos = todos);
                  });
                  final undoneTodos = todos.where((t) => !t.isDone).toList();
                  final doneTodos = todos.where((t) => t.isDone).toList();
                  final sorted = [...undoneTodos, ...doneTodos];

                  if (sorted.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('(´• ω •`)',
                              style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 12),
                          Text(l10n.noTasks,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sorted.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      if (oldIndex >= undoneTodos.length) return;
                      if (newIndex >= undoneTodos.length) newIndex = undoneTodos.length - 1;
                      final reordered = [...undoneTodos];
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      _todoRepo.reorderTodos(_uid, [...reordered, ...doneTodos]);
                    },
                    itemBuilder: (ctx, i) {
                      final todo = sorted[i];
                      return Dismissible(
                        key: Key(todo.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _todoRepo.deleteTodo(_uid, todo.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        child: ReorderableDragStartListener(
                          index: i,
                          enabled: !todo.isDone,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: todo.isDone
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: GestureDetector(
                                onTap: () {
                                  final newDone = !todo.isDone;
                                  _todoRepo.updateTodo(
                                    _uid,
                                    todo.copyWith(
                                      isDone: newDone,
                                      completedAt: newDone ? DateTime.now() : null,
                                      clearCompletedAt: !newDone,
                                    ),
                                  );
                                  if (newDone) {
                                    _saveTodoToStats(todo.title, todo.id);
                                  } else {
                                    _removeFromStats(todo);
                                  }
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: todo.isDone
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                      width: 2,
                                    ),
                                    color: todo.isDone
                                        ? AppColors.success.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                  ),
                                  child: todo.isDone
                                      ? const Icon(Icons.check,
                                          size: 14, color: AppColors.success)
                                      : null,
                                ),
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  color: todo.isDone
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontSize: 15,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppColors.textMuted, size: 20),
                                color: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onSelected: (value) {
                                  if (value == 'edit') _editTodo(todo);
                                  if (value == 'delete') _todoRepo.deleteTodo(_uid, todo.id);
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      const Icon(Icons.edit_outlined,
                                          color: AppColors.textMuted, size: 18),
                                      const SizedBox(width: 10),
                                      Text(l10n.editDiaryEntry,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary)),
                                    ]),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      const Icon(Icons.delete_outline,
                                          color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 10),
                                      Text(l10n.delete,
                                          style: const TextStyle(
                                              color: Colors.redAccent)),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
