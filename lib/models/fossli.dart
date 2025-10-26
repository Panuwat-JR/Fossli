class Fossli {
  final int? id;
  final String title;
  final String species;
  final String era;
  final String foundAt;
  final int rarity; 
  final String history;

  const Fossli({
    this.id,
    required this.title,
    required this.species,
    required this.era,
    required this.foundAt,
    required this.rarity,
    required this.history,
  });

  Fossli copyWith({
    int? id,
    String? title,
    String? species,
    String? era,
    String? foundAt,
    int? rarity,
    String? history,
  }) {
    return Fossli(
      id: id ?? this.id,
      title: title ?? this.title,
      species: species ?? this.species,
      era: era ?? this.era,
      foundAt: foundAt ?? this.foundAt,
      rarity: rarity ?? this.rarity,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'species': species,
        'era': era,
        'foundAt': foundAt,
        'rarity': rarity,
        'history': history,
      };

  factory Fossli.fromMap(Map<String, dynamic> m) => Fossli(
        id: m['id'] as int?,
        title: (m['title'] ?? '').toString(),
        species: (m['species'] ?? '').toString(),
        era: (m['era'] ?? '').toString(),
        foundAt: (m['foundAt'] ?? '').toString(),
        rarity: (m['rarity'] ?? 1) is int
            ? (m['rarity'] as int)
            : int.tryParse(m['rarity'].toString()) ?? 1,
        history: (m['history'] ?? '').toString(),
      );
}
