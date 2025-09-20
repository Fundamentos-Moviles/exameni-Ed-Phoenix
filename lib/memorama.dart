import 'package:flutter/material.dart';

class Memorama extends StatefulWidget {
  const Memorama({super.key});

  @override
  State<Memorama> createState() => _MemoramaState();
}

class _MemoramaState extends State<Memorama> {
  List<Color> colors = [];
  List<int> revealed = [];
  List<bool> found = List.filled(20, false);
  int numPairs = 10; // Número base de pares de colores

  @override
  void initState() {
    super.initState();
    _generateColors(20);
  }

  void _generateColors(int totalItems) {
    final random = UniqueKey().hashCode;
    int pairs = (totalItems / 2).floor();
    final List<Color> baseColors = List.generate(pairs, (i) => Color((random + i * 123456) | 0xFF000000));
    colors = [...baseColors, ...baseColors];
    colors = colors.take(totalItems).toList();
    colors.shuffle();
    found = List.filled(totalItems, false);
    revealed.clear();
  }

  void _onTap(int index) async {
    if (revealed.length == 2 || found[index]) return;
    setState(() {
      revealed.add(index);
    });
    if (revealed.length == 2) {
      final first = revealed[0];
      final second = revealed[1];
      if (colors[first] == colors[second]) {
        setState(() {
          found[first] = true;
          found[second] = true;
          revealed.clear();
        });
        // Verificar si el usuario ha ganado
        if (found.every((f) => f)) {
          Future.delayed(const Duration(milliseconds: 300), () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('¡Felicidades!'),
                content: const Text('Has ganado'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          });
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        setState(() {
          revealed.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Memorama --- Benitez Lozano Eduardo Carlos',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 28, color: Colors.black),
              label: const Text(
                'Reiniciar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  // Se recalcula el número de cuadros al reiniciar
                  revealed.clear();
                  found = List.filled(colors.length, false);
                  _generateColors(colors.length);
                });
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double gridWidth = constraints.maxWidth;
            double gridHeight = constraints.maxHeight;
            int crossAxisCount = 4;
            double spacing = 10;
            double itemSize = (gridWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
            int numRows = (gridHeight / (itemSize + spacing)).floor();
            int totalItems = crossAxisCount * numRows;
            if (colors.length != totalItems) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _generateColors(totalItems);
                });
              });
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final isRevealed = revealed.contains(index) || found[index];
                return GestureDetector(
                  onTap: () => _onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      color: isRevealed ? colors[index] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
