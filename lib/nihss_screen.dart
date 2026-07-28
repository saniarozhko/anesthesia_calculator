import 'package:flutter/material.dart';

class NihssScreen extends StatefulWidget {
  const NihssScreen({super.key});

  @override
  State<NihssScreen> createState() => _NihssScreenState();
}

class _NihssScreenState extends State<NihssScreen> {
  final Map<String, int> scores = {};

  final ScrollController scrollController = ScrollController();

  String warning = "";

  bool showResult = false;

  final List<Map<String, dynamic>> items = [
    {
      "id": "loc",
      "title": "1. Сознание (LOC)",
      "options": [
        "0 — бодрствует",
        "1 — сонливый, реагирует",
        "2 — требует стимуляции",
        "3 — нет реакции",
      ],
      "points": [0, 1, 2, 3],
    },

    {
      "id": "questions",
      "title": "2. Вопросы (месяц, возраст)",
      "options": [
        "0 — оба правильные",
        "1 — один правильный",
        "2 — оба неправильные",
      ],
      "points": [0, 1, 2],
    },

    {
      "id": "commands",
      "title": "3. Команды",
      "options": [
        "0 — выполняет обе",
        "1 — выполняет одну",
        "2 — не выполняет",
      ],
      "points": [0, 1, 2],
    },

    {
      "id": "gaze",
      "title": "4. Взгляд",
      "options": ["0 — нормально", "1 — частичный парез", "2 — полный парез"],
      "points": [0, 1, 2],
    },

    {
      "id": "vision",
      "title": "5. Поля зрения",
      "options": [
        "0 — нет нарушения",
        "1 — частичная геманопсия",
        "2 — полная геманопсия",
        "3 — двусторонняя слепота",
      ],
      "points": [0, 1, 2, 3],
    },

    {
      "id": "face",
      "title": "6. Лицевой парез",
      "options": ["0 — нет", "1 — лёгкий", "2 — умеренный", "3 — полный"],
      "points": [0, 1, 2, 3],
    },

    {
      "id": "armRight",
      "title": "7. Рука правая",
      "options": [
        "0 — нет слабости",
        "1 — дрожание/слабость",
        "2 — падение до 10 сек",
        "3 — нет удержания",
        "4 — нет движения",
      ],
      "points": [0, 1, 2, 3, 4],
    },

    {
      "id": "armLeft",
      "title": "8. Рука левая",
      "options": [
        "0 — нет слабости",
        "1 — дрожание/слабость",
        "2 — падение до 10 сек",
        "3 — нет удержания",
        "4 — нет движения",
      ],
      "points": [0, 1, 2, 3, 4],
    },

    {
      "id": "legRight",
      "title": "9. Нога правая",
      "options": [
        "0 — нет слабости",
        "1 — слабость",
        "2 — падение",
        "3 — нет удержания",
        "4 — нет движения",
      ],
      "points": [0, 1, 2, 3, 4],
    },

    {
      "id": "legLeft",
      "title": "10. Нога левая",
      "options": [
        "0 — нет слабости",
        "1 — слабость",
        "2 — падение",
        "3 — нет удержания",
        "4 — нет движения",
      ],
      "points": [0, 1, 2, 3, 4],
    },

    {
      "id": "ataxia",
      "title": "11. Атаксия",
      "options": ["0 — нет", "1 — одна конечность", "2 — две конечности"],
      "points": [0, 1, 2],
    },

    {
      "id": "sensory",
      "title": "12. Чувствительность",
      "options": ["0 — нет нарушения", "1 — снижение", "2 — выраженная потеря"],
      "points": [0, 1, 2],
    },

    {
      "id": "language",
      "title": "13. Афазия",
      "options": ["0 — нет", "1 — лёгкая", "2 — тяжёлая", "3 — мутизм"],
      "points": [0, 1, 2, 3],
    },

    {
      "id": "dysarthria",
      "title": "14. Дизартрия",
      "options": ["0 — нет", "1 — лёгкая", "2 — выраженная"],
      "points": [0, 1, 2],
    },

    {
      "id": "neglect",
      "title": "15. Игнорирование",
      "options": ["0 — нет", "1 — частичное", "2 — выраженное"],
      "points": [0, 1, 2],
    },
  ];

  int get total {
    int sum = 0;

    for (final value in scores.values) {
      sum += value;
    }

    return sum;
  }

  bool isComplete() {
    for (final item in items) {
      if (!scores.containsKey(item["id"])) {
        return false;
      }
    }

    return true;
  }

  String severity() {
    if (total == 0) {
      return "Нет признаков инсульта";
    }

    if (total <= 4) {
      return "Лёгкий инсульт";
    }

    if (total <= 15) {
      return "Среднетяжёлый инсульт";
    }

    if (total <= 20) {
      return "Тяжёлый инсульт";
    }

    return "Очень тяжёлый инсульт";
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  Widget optionCard(String id, String text, int value) {
    final bool active = scores[id] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          scores[id] = value;

          // после изменения выбора результат скрываем
          showResult = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: const EdgeInsets.symmetric(vertical: 4),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: active ? const Color(0xFF90CAF9) : const Color(0xFF252525),

          borderRadius: BorderRadius.circular(14),
        ),

        child: Text(
          text,

          style: TextStyle(
            fontSize: 16,

            color: active ? Colors.black : Colors.white,

            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget section(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 15),

        Text(
          item["title"],

          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        for (int i = 0; i < item["options"].length; i++)
          optionCard(item["id"], item["options"][i], item["points"][i]),
      ],
    );
  }

  void calculateNIHSS() {
    if (!isComplete()) {
      setState(() {
        warning = "⚠️ Заполните все пункты NIHSS";
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            warning = "";
          });
        }
      });

      return;
    }

    setState(() {
      showResult = true;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 700),

          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget resultCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),

      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),

            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),

          child: FadeTransition(opacity: animation, child: child),
        );
      },

      child: showResult
          ? Container(
              key: ValueKey(total),

              width: double.infinity,

              margin: const EdgeInsets.only(top: 25, bottom: 120),

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(color: const Color(0xFF90CAF9)),
              ),

              child: Column(
                children: [
                  Text(
                    "🧠 NIHSS: $total баллов",

                    style: const TextStyle(
                      fontSize: 25,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    severity(),

                    style: const TextStyle(
                      fontSize: 20,

                      color: Color(0xFF90CAF9),

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Шкала NIHSS: 0–42 балла",

                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget warningCard() {
    if (warning.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: warning.isEmpty ? 0 : 1,

      duration: const Duration(milliseconds: 300),

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(bottom: 15),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: const Color(0xFF4A1F1F),

          borderRadius: BorderRadius.circular(14),
        ),

        child: Text(
          warning,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 16,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 NIHSS — инсульт"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        controller: scrollController,

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(16),
              ),

              child: const Column(
                children: [
                  Text(
                    "National Institutes of Health Stroke Scale",

                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Оценка тяжести ишемического инсульта",

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            warningCard(),

            for (var item in items) section(item),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 65,

              child: ElevatedButton(
                onPressed: calculateNIHSS,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: const Text(
                  "Рассчитать NIHSS",

                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            resultCard(),
          ],
        ),
      ),
    );
  }
}
