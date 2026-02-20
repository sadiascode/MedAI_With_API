class NoteModel {
  final String note;

  const NoteModel({
    required this.note,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    try {
      return NoteModel(
        note: json['note'] as String? ?? '',
      );
    } catch (e) {
      throw Exception('Error parsing NoteModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
    };
  }

  factory NoteModel.empty() {
    return const NoteModel(
      note: '',
    );
  }

  @override
  String toString() {
    return 'NoteModel(note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.note == note;
  }

  @override
  int get hashCode => note.hashCode;
}
