import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fossli.dart';
import '../providers/fossli_provider.dart';
import 'fossli_detail_screen.dart';
import 'fossli_form_screen.dart';
import '../ui/skin.dart';
import '../ui/widgets.dart';

class FossliListScreen extends StatefulWidget {
  const FossliListScreen({super.key});
  @override
  State<FossliListScreen> createState() => _FossliListScreenState();
}

class _FossliListScreenState extends State<FossliListScreen> {
  final _searchCtrl = TextEditingController();
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FossliProvider>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: fossilGradientBg(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Fossli'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(84), 
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), 
              child: Glass(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: prov.search,
                  decoration: InputDecoration(
                    hintText: 'ค้นหา: ชื่อ / สปีชีส์ / ยุค / สถานที่ / ประวัติ',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Tooltip(
                      message: prov.sortByRarityDesc ? 'เรียงปกติ' : 'เรียงตามความหายาก',
                      child: IconButton(
                        onPressed: prov.toggleSortByRarityDesc,
                        icon: Icon(prov.sortByRarityDesc ? Icons.sort : Icons.star_half),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          child: prov.items.isEmpty
              ? Center(
                  child: Glass(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.inbox_outlined, size: 42),
                        SizedBox(height: 10),
                        Text('ยังไม่มีข้อมูล ลองกด “เพิ่ม” ที่มุมขวาล่าง', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: prov.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _FossliCard(
                    index: i,
                    fossli: prov.items[i],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FossliDetailScreen(fossli: prov.items[i], index: i),
                        ),
                      );
                    },
                    onDelete: () async {
                      final f = prov.items[i];
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('ลบรายการนี้?'),
                          content: Text('คุณแน่ใจว่าจะลบ "${f.title}"'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ลบ')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await context.read<FossliProvider>().delete(f.id!);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบ "${f.title}" แล้ว')),
                        );
                      }
                    },
                  ),
                ),
        ),
        floatingActionButton: FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FossliFormScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('เพิ่ม'),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

class _FossliCard extends StatelessWidget {
  const _FossliCard({
    required this.index,
    required this.fossli,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final Fossli fossli;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(blurRadius: 24, offset: Offset(0, 12), color: Color(0x14000000)),
          ],
          border: Border.all(color: cs.secondary.withOpacity(.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fossli.title.isEmpty ? '(ไม่มีชื่อ)' : fossli.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .2),
              ),
            ),
            const SizedBox(width: 12),
            _RarityChip(rarity: fossli.rarity),
          ],
        ),
      ),
    );
  }
}


class _RarityChip extends StatelessWidget {
  const _RarityChip({required this.rarity, this.maxStars = 5});
  final int rarity;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = rarity.clamp(0, maxStars);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiary.withOpacity(.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(r, (_) => const Icon(Icons.star, size: 16)),
          ...List.generate(maxStars - r, (_) => const Icon(Icons.star_border, size: 16)),
        ],
      ),
    );
  }
}
