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

  @override
  void initState() {
    super.initState();
    _generateColors();
  }

  void _generateColors() {
    final random = UniqueKey().hashCode;
    final List<Color> baseColors = List.generate(10, (i) => Color((random + i * 123456) | 0xFF000000));
    colors = [...baseColors, ...baseColors];
    colors.shuffle();
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
      appBar: AppBar(title: const Text('Memorama --- Benitez Lozano Eduardo Carlos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            final isRevealed = revealed.contains(index) || found[index];
            return GestureDetector(
              onTap: () => _onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isRevealed ? colors[index] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
