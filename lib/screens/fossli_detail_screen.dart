import 'package:flutter/material.dart';
import '../models/fossli.dart';
import 'fossli_form_screen.dart';
import '../ui/skin.dart';
import '../ui/widgets.dart';

class FossliDetailScreen extends StatelessWidget {
  const FossliDetailScreen({super.key, required this.fossli, required this.index});
  final Fossli fossli;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: fossilGradientBg(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('รายละเอียดฟอสซิล'),
          actions: [
            IconButton(
              tooltip: 'แก้ไข',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => FossliFormScreen(fossli: fossli)));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Glass(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.secondary.withOpacity(.25),
                    child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fossli.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Glass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('ข้อมูลจำแนก', icon: Icons.local_florist_outlined),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text(fossli.species)),
                    Chip(label: Text(fossli.era)),
                  ]),
                  const SizedBox(height: 12),
                  const SectionTitle('รายละเอียด', icon: Icons.info_outline),
                  const SizedBox(height: 6),
                  _tile('สถานที่ค้นพบ', fossli.foundAt, Icons.place_outlined),
                  _tileStars('ความหายาก (1–5)', fossli.rarity, Icons.star),
                  _tile('ประวัติ/หมายเหตุ', fossli.history.isEmpty ? '-' : fossli.history, Icons.article_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value),
          ]),
        ),
      ]),
    );
  }


  Widget _tileStars(String title, int rarity, IconData icon, {int maxStars = 5}) {
    final r = rarity.clamp(0, maxStars);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(
              children: [
                ...List.generate(r, (_) => const Icon(Icons.star, size: 18)),
                ...List.generate(maxStars - r, (_) => const Icon(Icons.star_border, size: 18)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}
