import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fossli.dart';
import '../providers/fossli_provider.dart';
import '../ui/skin.dart';
import '../ui/widgets.dart';

class FossliFormScreen extends StatefulWidget {
  final Fossli? fossli;
  const FossliFormScreen({super.key, this.fossli});

  @override
  State<FossliFormScreen> createState() => _FossliFormScreenState();
}

class _FossliFormScreenState extends State<FossliFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _eraCtrl = TextEditingController();
  final _foundAtCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  int _rarity = 1;

  bool get _isEdit => widget.fossli != null;

  @override
  void initState() {
    super.initState();
    final f = widget.fossli;
    if (f != null) {
      _titleCtrl.text = f.title;
      _speciesCtrl.text = f.species;
      _eraCtrl.text = f.era;
      _foundAtCtrl.text = f.foundAt;
      _historyCtrl.text = f.history;
      _rarity = f.rarity;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _speciesCtrl.dispose(); _eraCtrl.dispose();
    _foundAtCtrl.dispose(); _historyCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label, hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: fossilGradientBg(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_isEdit ? 'แก้ไขฟอสซิล' : 'เพิ่มฟอสซิล'),
          actions: [
            if (_isEdit)
              IconButton(tooltip: 'ลบ', icon: const Icon(Icons.delete_outline), onPressed: _onDelete),
            IconButton(tooltip: 'บันทึก', icon: const Icon(Icons.save_outlined), onPressed: _onSave),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Glass(
                child: Column(children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: _dec('ชื่อฟอสซิล', hint: 'เช่น Taung Child', icon: Icons.label_outline),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _speciesCtrl,
                    decoration: _dec('สปีชีส์ (ชื่อวิทยาศาสตร์)', hint: 'เช่น Australopithecus africanus', icon: Icons.biotech_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกสปีชีส์' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _eraCtrl,
                    decoration: _dec('ยุคสมัย', hint: 'เช่น Pliocene', icon: Icons.timeline_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกยุคสมัย' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _foundAtCtrl,
                    decoration: _dec('สถานที่ค้นพบ', hint: 'ประเทศ/จังหวัด/ไซต์', icon: Icons.place_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกสถานที่' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('ความหายาก'),
                      Expanded(
                        child: Slider(
                          value: _rarity.toDouble(), min: 1, max: 5, divisions: 4, label: '$_rarity/5',
                          onChanged: (v) => setState(() => _rarity = v.round()),
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.star, size: 16),
                        label: Text('R$_rarity'),
                        backgroundColor: cs.secondary.withOpacity(.25),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _historyCtrl,
                    decoration: _dec('ประวัติ/หมายเหตุ', hint: 'แหล่งอ้างอิง ปีที่ค้นพบ ผู้ค้นพบ ฯลฯ', icon: Icons.article_outlined),
                    minLines: 3, maxLines: 6,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(onPressed: _onSave, icon: const Icon(Icons.save_outlined), label: const Text('บันทึก')),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final f = Fossli(
      id: widget.fossli?.id,
      title: _titleCtrl.text.trim(),
      species: _speciesCtrl.text.trim(),
      era: _eraCtrl.text.trim(),
      foundAt: _foundAtCtrl.text.trim(),
      rarity: _rarity,
      history: _historyCtrl.text.trim(),
    );
    final prov = context.read<FossliProvider>();
    if (_isEdit) { await prov.update(f); } else { await prov.add(f); }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'บันทึกการแก้ไขแล้ว' : 'เพิ่มรายการแล้ว')),
    );
  }

  Future<void> _onDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: const Text('การลบไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok == true && widget.fossli?.id != null) {
      await context.read<FossliProvider>().delete(widget.fossli!.id!);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบแล้ว')));
    }
  }
}
