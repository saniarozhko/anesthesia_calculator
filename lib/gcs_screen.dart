import 'package:flutter/material.dart';

class GcsScreen extends StatefulWidget {
  const GcsScreen({super.key});

  @override
  State<GcsScreen> createState() => _GcsScreenState();
}

class _GcsScreenState extends State<GcsScreen> {
  final ScrollController _scrollController = ScrollController();

  int? eyeScore;
  int? verbalScore;
  int? motorScore;

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 136, 187, 214);

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scoreButton(
    String text,
    int value,
    int? selected,
    Function(int) onTap,
  ) {
    bool active = selected == value;

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(vertical: 4),

      child: ElevatedButton(
        onPressed: () {
          onTap(value);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: active ? activeColor : Colors.grey[800],

          foregroundColor: Colors.white,

          elevation: active ? 3 : 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          padding: const EdgeInsets.symmetric(vertical: 14),
        ),

        child: Text(text, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👁 Шкала ШКГ"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            sectionTitle("👁 Открывание глаз (E)"),

            scoreButton("4 — Спонтанное открывание глаз", 4, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            scoreButton("3 — На голос", 3, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            scoreButton("2 — На боль", 2, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            scoreButton("1 — Отсутствует", 1, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            sectionTitle("🗣 Речевая реакция (V)"),

            scoreButton("5 — Ориентирован", 5, verbalScore, (v) {
              setState(() {
                verbalScore = v;
              });
            }),

            scoreButton("4 — Спутанная речь", 4, verbalScore, (v) {
              setState(() {
                verbalScore = v;
              });
            }),

            scoreButton("3 — Неподходящие слова", 3, verbalScore, (v) {
              setState(() {
                verbalScore = v;
              });
            }),

            scoreButton("2 — Нечленораздельные звуки", 2, verbalScore, (v) {
              setState(() {
                verbalScore = v;
              });
            }),

            scoreButton("1 — Нет речи", 1, verbalScore, (v) {
              setState(() {
                verbalScore = v;
              });
            }),
            sectionTitle("💪 Двигательная реакция (M)"),

            scoreButton("6 — Выполняет команды", 6, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("5 — Локализует боль", 5, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("4 — Отдёргивает конечность", 4, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("3 — Патологическое сгибание", 3, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("2 — Разгибание", 2, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("1 — Нет реакции", 1, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 70,

              child: ElevatedButton(
                onPressed: calculateGCS,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  elevation: 4,
                ),

                child: const Text(
                  "Рассчитать ШКГ",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Text(
                result,

                textAlign: TextAlign.center,

                style: const TextStyle(fontSize: 20, height: 1.5),
              ),
            ),

            // запас снизу для телефонов,
            // чтобы нижняя панель навигации
            // не перекрывала результат
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void calculateGCS() {
    if (eyeScore == null || verbalScore == null || motorScore == null) {
      setState(() {
        result = "Выберите все компоненты ШКГ";
      });

      scrollToResult();

      return;
    }

    int total = eyeScore! + verbalScore! + motorScore!;

    String interpretation;

    if (total == 15) {
      interpretation = "Ясное сознание";
    } else if (total >= 13) {
      interpretation = "Умеренное оглушение";
    } else if (total >= 10) {
      interpretation = "Глубокое оглушение";
    } else if (total >= 8) {
      interpretation = "Сопор";
    } else if (total >= 6) {
      interpretation = "Умеренная кома";
    } else if (total >= 4) {
      interpretation = "Глубокая кома";
    } else {
      interpretation = "Запредельная кома";
    }

    setState(() {
      result =
          "👁 ШКГ: $total баллов\n\n"
          "(E$eyeScore "
          "V$verbalScore "
          "M$motorScore)\n\n"
          "Интерпретация:\n"
          "$interpretation";
    });

    scrollToResult();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
}
