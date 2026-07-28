import 'package:flutter/material.dart';

class WellsScreen extends StatefulWidget {
  const WellsScreen({super.key});

  @override
  State<WellsScreen> createState() => _WellsScreenState();
}

class _WellsScreenState extends State<WellsScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<bool> selected = List.filled(7, false);

  final List<String> criteria = [
    "🦵 Клинические признаки ТГВ\n"
        "Боль при пальпации глубоких вен + отёк ноги",

    "⚠️ ТЭЛА более вероятна,\n"
        "чем альтернативный диагноз",

    "❤️ ЧСС > 100/мин",

    "🛏 Иммобилизация ≥ 3 суток\n"
        "или операция за последние 4 недели",

    "🔄 ТГВ или ТЭЛА в анамнезе",

    "🩸 Кровохарканье",

    "🎗 Активное онкологическое заболевание",
  ];

  final List<double> points = [3.0, 3.0, 1.5, 1.5, 1.5, 1.0, 1.0];

  double get score {
    double result = 0;

    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        result += points[i];
      }
    }

    return result;
  }

  String get resultText {
    if (score <= 4) {
      return "ТЭЛА маловероятна\n"
          "≤ 4 баллов";
    } else {
      return "ТЭЛА вероятна\n"
          "> 4 баллов";
    }
  }

  Color get resultColor {
    if (score <= 4) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  void calculate() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,

        duration: const Duration(milliseconds: 500),

        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wells — риск ТЭЛА")),

      body: ListView(
        controller: _scrollController,

        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            "Шкала Wells для оценки вероятности ТЭЛА",

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            "≤4 баллов — ТЭЛА маловероятна\n"
            ">4 баллов — ТЭЛА вероятна",

            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          ...List.generate(criteria.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selected[index] = !selected[index];
                });
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 12),

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: selected[index]
                      ? const Color(0xFF29485C)
                      : const Color(0xFF202020),

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: selected[index]
                        ? const Color(0xFF86BBD8)
                        : const Color(0xFF343434),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      criteria[index],

                      style: const TextStyle(
                        fontSize: 16,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "+${points[index]} балл",

                      style: const TextStyle(
                        color: Color(0xFF95C7F3),

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Text(
              "Текущая сумма: "
              "${score.toStringAsFixed(1)} балла",

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: calculate,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF86BBD8),

              foregroundColor: Colors.black,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              padding: const EdgeInsets.symmetric(vertical: 14),
            ),

            child: const Text(
              "РАССЧИТАТЬ",

              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(color: resultColor),
            ),

            child: Column(
              children: [
                const Text(
                  "Результат Wells",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "${score.toStringAsFixed(1)} балла\n\n"
                  "$resultText",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 17,

                    color: resultColor,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
