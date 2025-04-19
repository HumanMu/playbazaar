class Position {
  final int row;
  final int column;

  const Position(this.row, this.column);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Position &&
              runtimeType == other.runtimeType &&
              row == other.row &&
              column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => 'Position($row, $column)';
}

