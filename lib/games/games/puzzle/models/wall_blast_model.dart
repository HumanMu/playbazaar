import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'wall_blast_model.g.dart';

@HiveType(typeId: 0)
class WallBlastModel extends HiveObject {
  @HiveField(0)
  int x;

  @HiveField(1)
  int y;

  @HiveField(2)
  Color color;

  @HiveField(3)
  bool isMatched;

  WallBlastModel({
    required this.x,
    required this.y,
    required this.color,
    this.isMatched = false,
  });

  WallBlastModel copyWith({
    int? x,
    int? y,
    Color? color,
    bool? isMatched,
  }) {
    return WallBlastModel(
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WallBlastModel &&
        x == other.x &&
        y == other.y &&
        color == other.color;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ color.hashCode;
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 1;

  @override
  Color read(BinaryReader reader) {
    final r = reader.readInt();
    final g = reader.readInt();
    final b = reader.readInt();
    final a = reader.readInt();
    return Color.fromARGB(a, r, g, b);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.r.toInt());
    writer.writeInt(obj.g.toInt());
    writer.writeInt(obj.b.toInt());
    writer.writeInt(obj.a.toInt());
  }
}