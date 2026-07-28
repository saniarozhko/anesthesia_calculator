import 'package:flutter/material.dart';

class FourScreen extends StatefulWidget {
  const FourScreen({super.key});

  @override
  State<FourScreen> createState() => _FourScreenState();
}

class _FourScreenState extends State<FourScreen> {
  final ScrollController _scrollController = ScrollController();

  int? eyeScore;
  int? motorScore;
  int? brainstemScore;
  int? respirationScore;

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 134, 182, 207);

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
      appBar: AppBar(title: const Text("🧠 FOUR"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            sectionTitle("👁 Глазная реакция (E)"),

            scoreButton(
              "4 — Глаза открыты, слежение или мигание по команде",
              4,
              eyeScore,
              (v) {
                setState(() {
                  eyeScore = v;
                });
              },
            ),

            scoreButton("3 — Глаза открыты, но нет слежения", 3, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            scoreButton(
              "2 — Глаза закрыты, открываются на громкий голос",
              2,
              eyeScore,
              (v) {
                setState(() {
                  eyeScore = v;
                });
              },
            ),

            scoreButton("1 — Глаза закрыты, открываются на боль", 1, eyeScore, (
              v,
            ) {
              setState(() {
                eyeScore = v;
              });
            }),

            scoreButton("0 — Нет реакции", 0, eyeScore, (v) {
              setState(() {
                eyeScore = v;
              });
            }),

            sectionTitle("💪 Двигательная реакция (M)"),

            scoreButton("4 — Выполняет команды", 4, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("3 — Локализует боль", 3, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("2 — Сгибательная реакция на боль", 2, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("1 — Разгибательная реакция", 1, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),

            scoreButton("0 — Нет реакции", 0, motorScore, (v) {
              setState(() {
                motorScore = v;
              });
            }),
            sectionTitle("🧠 Стволовые рефлексы (B)"),

            scoreButton(
              "4 — Зрачковые и корнеальные рефлексы сохранены",
              4,
              brainstemScore,
              (v) {
                setState(() {
                  brainstemScore = v;
                });
              },
            ),

            scoreButton(
              "3 — Один зрачковый или корнеальный рефлекс отсутствует",
              3,
              brainstemScore,
              (v) {
                setState(() {
                  brainstemScore = v;
                });
              },
            ),

            scoreButton(
              "2 — Зрачковый или корнеальный рефлекс отсутствует",
              2,
              brainstemScore,
              (v) {
                setState(() {
                  brainstemScore = v;
                });
              },
            ),

            scoreButton(
              "1 — Зрачковый, корнеальный и кашлевой рефлексы отсутствуют",
              1,
              brainstemScore,
              (v) {
                setState(() {
                  brainstemScore = v;
                });
              },
            ),

            scoreButton(
              "0 — Отсутствуют все стволовые рефлексы",
              0,
              brainstemScore,
              (v) {
                setState(() {
                  brainstemScore = v;
                });
              },
            ),

            sectionTitle("🫁 Дыхание (R)"),

            scoreButton(
              "4 — Самостоятельное дыхание, регулярное",
              4,
              respirationScore,
              (v) {
                setState(() {
                  respirationScore = v;
                });
              },
            ),

            scoreButton(
              "3 — Самостоятельное дыхание, нерегулярное",
              3,
              respirationScore,
              (v) {
                setState(() {
                  respirationScore = v;
                });
              },
            ),

            scoreButton(
              "2 — ИВЛ, но дыхательные попытки есть",
              2,
              respirationScore,
              (v) {
                setState(() {
                  respirationScore = v;
                });
              },
            ),

            scoreButton(
              "1 — ИВЛ, дыхательных попыток нет",
              1,
              respirationScore,
              (v) {
                setState(() {
                  respirationScore = v;
                });
              },
            ),

            scoreButton("0 — Апноэ", 0, respirationScore, (v) {
              setState(() {
                respirationScore = v;
              });
            }),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: calculateFOUR,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  elevation: 4,
                ),

                child: const Text(
                  "Рассчитать FOUR",

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

            // запас снизу, чтобы системная панель телефона
            // не закрывала результат
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void calculateFOUR() {
    if (eyeScore == null ||
        motorScore == null ||
        brainstemScore == null ||
        respirationScore == null) {
      setState(() {
        result = "Выберите все компоненты FOUR";
      });

      scrollToResult();

      return;
    }

    int total = eyeScore! + motorScore! + brainstemScore! + respirationScore!;

    String interpretation;

    if (total == 16) {
      interpretation = "Ясное сознание";
    } else if (total == 15) {
      interpretation = "Умеренное оглушение";
    } else if (total >= 13) {
      interpretation = "Глубокое оглушение";
    } else if (total >= 9) {
      interpretation = "Сопор";
    } else if (total >= 7) {
      interpretation = "Кома I";
    } else if (total >= 1) {
      interpretation = "Кома II";
    } else {
      interpretation = "Кома III";
    }

    setState(() {
      result =
          "FOUR: $total баллов\n\n"
          "(E$eyeScore M$motorScore "
          "B$brainstemScore R$respirationScore)\n\n"
          "Интерпретация:\n"
          "$interpretation";
    });

    scrollToResult();
  }
}
