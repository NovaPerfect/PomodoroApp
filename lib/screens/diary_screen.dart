import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../repositories/diary_repository.dart';
import '../theme/app_theme.dart';
import 'package:untitled/l10n/app_localizations.dart';

const List<Map<String, String>> kMoods = [
  {'emoji': '😭', 'image': 'assets/images/mood_1.png'},
  {'emoji': '😞', 'image': 'assets/images/mood_2.png'},
  {'emoji': '😐', 'image': 'assets/images/mood_3.png'},
  {'emoji': '😊', 'image': 'assets/images/mood_4.png'},
  {'emoji': '🤩', 'image': 'assets/images/mood_5.png'},
];

/// Локализованные названия настроений по индексу (0–4).
String moodLabel(int index, AppLocalizations l10n) {
  switch (index) {
    case 0: return l10n.moodTerrible;
    case 1: return l10n.moodBad;
    case 2: return l10n.moodOkay;
    case 3: return l10n.moodGood;
    case 4: return l10n.moodGreat;
    default: return '';
  }
}

// ════════════════════════════════════════
//  ЭКРАН СПИСКА
// ════════════════════════════════════════
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diary,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.diarySubtitle,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<List<DiaryData>>(
                stream: DiaryRepository().watchEntries(_uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('(。•́︿•̀。)',
                              style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noDiaryEntries,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) {
                      final entry = entries[i];
                      return _DiaryCard(
                        entry: entry,
                        onDelete: () =>
                            DiaryRepository().deleteEntry(_uid, entry.id),
                        onEdit: () => _openEditor(context, entry: entry),
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
        onPressed: () => _openEditor(context),
        backgroundColor: AppColors.accent2,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_rounded, size: 26),
      ),
    );
  }

  void _openEditor(BuildContext context, {DiaryData? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditorScreen(entry: entry),
      ),
    );
  }
}

// ════════════════════════════════════════
//  КАРТОЧКА
// ════════════════════════════════════════
class _DiaryCard extends StatelessWidget {
  final DiaryData entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DiaryCard({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatDate(DateTime dt) {
    final months = [
      'jan','feb','mar','apr','may','jun',
      'jul','aug','sep','oct','nov','dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _extractPlainText(String content) {
    try {
      final json = jsonDecode(content) as List;
      return json.map((op) => op['insert'] ?? '').join().trim();
    } catch (_) {
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n       = AppLocalizations.of(context)!;
    final bool hasTitle   = entry.title.trim().isNotEmpty;
    final plainText  = _extractPlainText(entry.content);
    final bool hasContent = plainText.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (entry.moodIndex >= 0) ...[
                    _MoodIcon(
                      imagePath: kMoods[entry.moodIndex]['image']!,
                      emoji: kMoods[entry.moodIndex]['emoji']!,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      hasTitle ? entry.title : l10n.untitled,
                      style: TextStyle(
                        color: hasTitle
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: hasTitle
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(entry.createdAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hasContent ? plainText : l10n.noContent,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                  fontStyle:
                      hasContent ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.delete,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(l10n.confirmDelete,
            style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
//  РЕДАКТОР
// ════════════════════════════════════════
class DiaryEditorScreen extends StatefulWidget {
  final DiaryData? entry;
  const DiaryEditorScreen({super.key, this.entry});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  late final TextEditingController _titleController;
  late final QuillController       _quillController;
  int _selectedMood = -1;
  bool _isSaving = false;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.entry?.title ?? '');
    _selectedMood = widget.entry?.moodIndex ?? -1;
    _quillController = _buildQuillController(widget.entry?.content);
  }

  QuillController _buildQuillController(String? content) {
    if (content == null || content.isEmpty) {
      return QuillController.basic();
    }
    try {
      final json     = jsonDecode(content) as List;
      final document = Document.fromJson(json);
      return QuillController(
        document:  document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      final doc = Document()..insert(0, content);
      return QuillController(
        document:  doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    _isSaving = true;

    final title   = _titleController.text.trim();
    final content = jsonEncode(
        _quillController.document.toDelta().toJson());

    try {
      if (widget.entry != null) {
        await DiaryRepository().updateEntry(
          _uid,
          DiaryData(
            id:        widget.entry!.id,
            title:     title,
            content:   content,
            createdAt: widget.entry!.createdAt,
            moodIndex: _selectedMood,
          ),
        );
      } else {
        await DiaryRepository().addEntry(
          _uid,
          DiaryData(
            id:        '',
            title:     title,
            content:   content,
            createdAt: DateTime.now(),
            moodIndex: _selectedMood,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final isNew = widget.entry == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.newDiaryEntry : l10n.editDiaryEntry),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textMuted),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: AppColors.accent2,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── название ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: AppColors.accent2,
              decoration: InputDecoration(
                hintText: '${l10n.untitled}...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          // ── настроение ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.moodQuestion,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(kMoods.length, (i) {
                    final isSelected = _selectedMood == i;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedMood = _selectedMood == i ? -1 : i;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MoodIcon(
                              imagePath: kMoods[i]['image']!,
                              emoji: kMoods[i]['emoji']!,
                              size: isSelected ? 26 : 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              moodLabel(i, l10n),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                                fontSize: 8,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withValues(alpha: 0.06)),

          // ── текст ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: QuillEditor.basic(
                controller: _quillController,
                config: QuillEditorConfig(
                  placeholder: l10n.diaryPlaceholder,
                  padding: EdgeInsets.zero,
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      TextStyle(
                        fontFamily: 'Comfortaa',
                        color: AppColors.textMuted,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                    paragraph: DefaultTextBlockStyle(
                      const TextStyle(
                        fontFamily: 'Comfortaa',
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── тулбар форматирования ──
          _QuillToolbar(controller: _quillController),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
//  КАСТОМНЫЙ ТУЛБАР
// ════════════════════════════════════════
class _QuillToolbar extends StatefulWidget {
  final QuillController controller;
  const _QuillToolbar({required this.controller});

  @override
  State<_QuillToolbar> createState() => _QuillToolbarState();
}

class _QuillToolbarState extends State<_QuillToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  static const _defaultSize = 16;
  static const _fontSizes = [8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48, 64];

  void _rebuild() => setState(() {});

  String? get _currentSize {
    final attr = widget.controller.getSelectionStyle().attributes['size'];
    return attr?.value?.toString();
  }

  void _applySize(int? size) {
    widget.controller.formatSelection(
      Attribute('size', AttributeScope.inline, size?.toString()),
    );
    setState(() {});
  }

  bool _isActive(String key) =>
      widget.controller.getSelectionStyle().attributes.containsKey(key);

  // Для блочных атрибутов (list, align) нужно проверять и значение
  bool _isActiveValue(Attribute attr) {
    final a = widget.controller.getSelectionStyle().attributes[attr.key];
    return a != null && a.value == attr.value;
  }

  void _toggle(Attribute attr) {
    final isOn = attr.key == Attribute.ul.key || attr.key == Attribute.ol.key
        ? _isActiveValue(attr)
        : _isActive(attr.key);
    widget.controller.formatSelection(
      isOn ? Attribute(attr.key, attr.scope, null) : attr,
    );
    setState(() {});
  }

  String _toHex(Color c) {
    final r = (c.r * 255.0).round().clamp(0, 255);
    final g = (c.g * 255.0).round().clamp(0, 255);
    final b = (c.b * 255.0).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  void _showColorDialog() {
    const textColors = [
      Colors.white,       Color(0xFFEF5350), Color(0xFFFF9800),
      Color(0xFFFFEB3B),  Color(0xFF66BB6A), Color(0xFF42A5F5),
      Color(0xFFAB47BC),  Color(0xFFEC407A), Color(0xFF26C6DA),
      Color(0xFF8D6E63),  Color(0xFF78909C), Colors.black,
    ];
    const bgColors = [
      Color(0xFFFFF9C4), Color(0xFFFFCCBC), Color(0xFFF8BBD0),
      Color(0xFFE1BEE7), Color(0xFFBBDEFB), Color(0xFFB2EBF2),
      Color(0xFFB2DFDB), Color(0xFFC8E6C9), Color(0xFFFFE0B2),
      Color(0xFFD7CCC8), Color(0xFFCFD8DC), Color(0xFFFFFFFF),
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _colorSection(ctx, 'Text color', textColors,
                  onClear: () => widget.controller
                      .formatSelection(const ColorAttribute(null)),
                  onSelect: (c) => widget.controller
                      .formatSelection(ColorAttribute(_toHex(c)))),
              const SizedBox(height: 16),
              _colorSection(ctx, 'Highlight', bgColors,
                  onClear: () => widget.controller
                      .formatSelection(const BackgroundAttribute(null)),
                  onSelect: (c) => widget.controller
                      .formatSelection(BackgroundAttribute(_toHex(c)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorSection(
    BuildContext ctx,
    String label,
    List<Color> colors, {
    required VoidCallback onClear,
    required void Function(Color) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            GestureDetector(
              onTap: () { onClear(); Navigator.pop(ctx); },
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.textMuted.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.format_clear_rounded,
                    size: 14, color: AppColors.textMuted),
              ),
            ),
            ...colors.map((c) => GestureDetector(
              onTap: () { onSelect(c); Navigator.pop(ctx); },
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }


  PopupMenuItem<Attribute> _alignItem(
      Attribute attr, IconData icon, String label) {
    return PopupMenuItem(
      value: attr,
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14)),
      ]),
    );
  }

  Widget _btn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent2.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18,
            color: active ? AppColors.accent2 : AppColors.textMuted),
      ),
    );
  }


  Widget _divider() => Container(
        width: 1, height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.white.withValues(alpha: 0.1),
      );

  @override
  Widget build(BuildContext context) {
    final isBold      = _isActive(Attribute.bold.key);
    final isItalic    = _isActive(Attribute.italic.key);
    final isUnderline = _isActive(Attribute.underline.key);
    final isStrike    = _isActive(Attribute.strikeThrough.key);
    final isBullet    = _isActiveValue(Attribute.ul);
    final isOrdered   = _isActiveValue(Attribute.ol);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 20),
        child: Row(
          children: [
            // Форматирование текста
            _btn(Icons.format_bold_rounded, isBold,
                () => _toggle(Attribute.bold)),
            _btn(Icons.format_italic_rounded, isItalic,
                () => _toggle(Attribute.italic)),
            _btn(Icons.format_underline_rounded, isUnderline,
                () => _toggle(Attribute.underline)),
            _btn(Icons.format_strikethrough_rounded, isStrike,
                () => _toggle(Attribute.strikeThrough)),

            _divider(),

            // Размер шрифта
            PopupMenuButton<int?>(
              padding: EdgeInsets.zero,
              color: AppColors.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: _applySize,
              itemBuilder: (_) => _fontSizes.map((size) {
                final isSelected = _currentSize == size.toString();
                return PopupMenuItem<int?>(
                  value: size,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$size',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent2
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.accent2, size: 16),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _currentSize != null
                      ? AppColors.accent2.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _currentSize ?? '$_defaultSize',
                    style: TextStyle(
                      color: _currentSize != null
                          ? AppColors.accent2
                          : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            _divider(),

            // Цвета
            _btn(Icons.palette_outlined, false, _showColorDialog),

            _divider(),

            // Выравнивание
            PopupMenuButton<Attribute>(
              padding: EdgeInsets.zero,
              color: AppColors.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (attr) =>
                  widget.controller.formatSelection(attr),
              itemBuilder: (_) => [
                _alignItem(Attribute.leftAlignment,
                    Icons.format_align_left_rounded, 'Left'),
                _alignItem(Attribute.centerAlignment,
                    Icons.format_align_center_rounded, 'Center'),
                _alignItem(Attribute.rightAlignment,
                    Icons.format_align_right_rounded, 'Right'),
                _alignItem(Attribute.justifyAlignment,
                    Icons.format_align_justify_rounded, 'Justify'),
              ],
              child: Container(
                width: 36, height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.format_align_left_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
            ),

            _divider(),

            // Списки
            _btn(Icons.format_list_bulleted_rounded, isBullet,
                () => _toggle(Attribute.ul)),
            _btn(Icons.format_list_numbered_rounded, isOrdered,
                () => _toggle(Attribute.ol)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  ИКОНКА НАСТРОЕНИЯ
// ════════════════════════════════════════
class _MoodIcon extends StatelessWidget {
  final String imagePath;
  final String emoji;
  final double size;

  const _MoodIcon({
    required this.imagePath,
    required this.emoji,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      errorBuilder: (_, _, _) =>
          Text(emoji, style: TextStyle(fontSize: size * 0.8)),
    );
  }
}
