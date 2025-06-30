import 'package:flutter/material.dart';


class LudoRow extends StatelessWidget {
  final int row;
  final List<GlobalKey> keyRow;
  const LudoRow(this.row,this.keyRow, {super.key});

  List<Flexible> _getColumns() {
    List<Flexible> columns = [];
    for (var i = 0; i < 15; i++) {
      columns.add(Flexible(
        key: keyRow[i],
        child: const AspectRatio(
          aspectRatio: 1 / 1,
          /*child: Container(
            decoration: BoxDecoration(
                border: Border(
                  left: const BorderSide(color: Colors.grey),
                  right: i == 14 ? const BorderSide(color: Colors.white)
                      : BorderSide.none,
                ),
                color: Utility.getColor(row, i)//Colors.transparent,
            ),
          ),*/
        ),
      ));
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[..._getColumns()],
    );
  }
}
