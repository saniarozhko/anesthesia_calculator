import 'package:flutter/material.dart';

class GenevaScreen extends StatefulWidget {
  const GenevaScreen({super.key});

  @override
  State<GenevaScreen> createState() => _GenevaScreenState();
}

class _GenevaScreenState extends State<GenevaScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController ageController = TextEditingController();

  bool previousPEDVT = false;

  bool surgeryFracture = false;

  bool cancer = false;

  bool legPain = false;

  bool hemoptysis = false;

  int? heartRate;

  bool dvtSigns = false;

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 134, 187, 216);

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

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          text,

          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget choiceButton(String text, bool active, VoidCallback onTap) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(vertical: 4),

      child: ElevatedButton(
        onPressed: onTap,

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

  Widget inputField(
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: TextField(
        controller: controller,

        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        decoration: InputDecoration(
          labelText: label,

          suffixText: suffix,

          filled: true,

          fillColor: const Color(0xFF1E1E1E),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🫁 Geneva"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            sectionTitle("👤 Основные данные"),

            inputField("Возраст", ageController, "лет"),

            sectionTitle("🩺 Анамнез"),

            choiceButton("Перенесённая ТГВ/ТЭЛА (+3)", previousPEDVT, () {
              setState(() {
                previousPEDVT = !previousPEDVT;
              });
            }),

            choiceButton(
              "Операция под общей анестезией или перелом нижней конечности за последний месяц (+2)",

              surgeryFracture,

              () {
                setState(() {
                  surgeryFracture = !surgeryFracture;
                });
              },
            ),

            choiceButton(
              "Активное онкологическое заболевание (+2)",

              cancer,

              () {
                setState(() {
                  cancer = !cancer;
                });
              },
            ),

            sectionTitle("💧 Симптомы"),

            choiceButton(
              "Односторонняя боль в нижней конечности (+3)",

              legPain,

              () {
                setState(() {
                  legPain = !legPain;
                });
              },
            ),

            choiceButton("Кровохарканье (+2)", hemoptysis, () {
              setState(() {
                hemoptysis = !hemoptysis;
              });
            }),

            sectionTitle("❤️ Частота сердечных сокращений"),

            choiceButton("<75 уд/мин", heartRate == 0, () {
              setState(() {
                heartRate = 0;
              });
            }),

            choiceButton("75–94 уд/мин (+3)", heartRate == 3, () {
              setState(() {
                heartRate = 3;
              });
            }),

            choiceButton("≥95 уд/мин (+5)", heartRate == 5, () {
              setState(() {
                heartRate = 5;
              });
            }),

            sectionTitle("🦵 Признаки ТГВ"),

            choiceButton(
              "Боль при пальпации глубоких вен + односторонний отёк (+4)",

              dvtSigns,

              () {
                setState(() {
                  dvtSigns = !dvtSigns;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 70,

              child: ElevatedButton(
                onPressed: calculateGeneva,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  elevation: 4,
                ),

                child: const Text(
                  "Рассчитать Geneva",

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

            // запас снизу, чтобы результат
            // не перекрывался системной панелью телефона
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void calculateGeneva() {
    if (ageController.text.isEmpty || heartRate == null) {
      setState(() {
        result = "⚠️ Заполните все параметры Geneva";
      });

      scrollToResult();

      return;
    }

    int age = int.tryParse(ageController.text) ?? 0;

    int score = 0;

    if (age > 65) {
      score += 1;
    }

    if (previousPEDVT) {
      score += 3;
    }

    if (surgeryFracture) {
      score += 2;
    }

    if (cancer) {
      score += 2;
    }

    if (legPain) {
      score += 3;
    }

    if (hemoptysis) {
      score += 2;
    }

    score += heartRate!;

    if (dvtSigns) {
      score += 4;
    }

    String interpretation;

    if (score <= 3) {
      interpretation = "Низкая вероятность ТЭЛА";
    } else if (score <= 10) {
      interpretation = "Промежуточная вероятность ТЭЛА";
    } else {
      interpretation = "Высокая вероятность ТЭЛА";
    }

    setState(() {
      result =
          "🫁 Geneva\n\n"
          "Баллы: $score\n\n"
          "$interpretation";
    });

    scrollToResult();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    ageController.dispose();

    super.dispose();
  }
}
