// =============================================================
// WIDGET STATUS LABEL (Modul II - widget kustom reusable)
// =============================================================
// Menampilkan titik berwarna + teks status karakter:
//   Alive   -> hijau
//   Dead    -> merah
//   unknown -> abu-abu
// Dipakai di halaman Characters, Detail, dan Favorites.
import 'package:flutter/material.dart';

class StatusLabel extends StatelessWidget {
  final String status;

  const StatusLabel({super.key, required this.status});

  // switch untuk menentukan warna berdasarkan status.
  // toLowerCase() agar "Alive" dan "alive" dianggap sama.
  Color get _color {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Row selebar isinya saja
      children: [
        // Titik bulat berwarna
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: _color)),
      ],
    );
  }
}
