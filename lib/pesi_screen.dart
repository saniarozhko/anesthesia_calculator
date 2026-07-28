import 'package:flutter/material.dart';

class PesiScreen extends StatefulWidget {
  const PesiScreen({super.key});

  @override
  State<PesiScreen> createState() => _PesiScreenState();
}

class _PesiScreenState extends State<PesiScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController ageController = TextEditingController();

  String? gender;

  bool oncology = false;
  bool heartFailure = false;
  bool lungDisease = false;

  int? heartRate;
  int? systolicPressure;
  int? respiratoryRate;
  int? temperature;
  int? oxygen;

  bool? alteredMentalStatus;

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 146, 200, 230);

  @override
  void dispose() {
    ageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
        keyboardType: TextInputType.number,
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

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🫁 PESI"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            sectionTitle("👤 Основные данные"),

            inputField("Возраст", ageController, "лет"),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: choiceButton("♂ Мужчина (+10)", gender == "М", () {
                    setState(() {
                      gender = "М";
                    });
                  }),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: choiceButton("♀ Женщина", gender == "Ж", () {
                    setState(() {
                      gender = "Ж";
                    });
                  }),
                ),
              ],
            ),

            sectionTitle("🩺 Сопутствующие заболевания"),

            choiceButton("Онкология (+30)", oncology, () {
              setState(() {
                oncology = !oncology;
              });
            }),

            choiceButton("ХСН (+10)", heartFailure, () {
              setState(() {
                heartFailure = !heartFailure;
              });
            }),

            choiceButton(
              "Хроническое заболевание лёгких (+10)",
              lungDisease,
              () {
                setState(() {
                  lungDisease = !lungDisease;
                });
              },
            ),

            sectionTitle("📊 Клинические параметры"),

            sectionTitle("❤️ ЧСС"),

            choiceButton("<110 уд/мин", heartRate == 0, () {
              setState(() {
                heartRate = 0;
              });
            }),

            choiceButton("≥110 уд/мин (+20)", heartRate == 20, () {
              setState(() {
                heartRate = 20;
              });
            }),

            sectionTitle("🩸 САД"),

            choiceButton("≥100 мм рт.ст.", systolicPressure == 0, () {
              setState(() {
                systolicPressure = 0;
              });
            }),

            choiceButton("<100 мм рт.ст. (+30)", systolicPressure == 30, () {
              setState(() {
                systolicPressure = 30;
              });
            }),

            sectionTitle("🫁 ЧДД"),

            choiceButton("<30 /мин", respiratoryRate == 0, () {
              setState(() {
                respiratoryRate = 0;
              });
            }),

            choiceButton("≥30 /мин (+20)", respiratoryRate == 20, () {
              setState(() {
                respiratoryRate = 20;
              });
            }),

            sectionTitle("🌡 Температура"),

            choiceButton("≥36 °C", temperature == 0, () {
              setState(() {
                temperature = 0;
              });
            }),

            choiceButton("<36 °C (+20)", temperature == 20, () {
              setState(() {
                temperature = 20;
              });
            }),

            sectionTitle("🩸 SpO₂"),

            choiceButton("≥90 %", oxygen == 0, () {
              setState(() {
                oxygen = 0;
              });
            }),

            choiceButton("<90 % (+20)", oxygen == 20, () {
              setState(() {
                oxygen = 20;
              });
            }),

            sectionTitle("🧠 Нарушение сознания"),

            choiceButton("Нет", alteredMentalStatus == false, () {
              setState(() {
                alteredMentalStatus = false;
              });
            }),

            choiceButton("Да (+60)", alteredMentalStatus == true, () {
              setState(() {
                alteredMentalStatus = true;
              });
            }),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 70,

              child: ElevatedButton(
                onPressed: calculatePESI,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Рассчитать PESI",
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

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void calculatePESI() {
    if (ageController.text.isEmpty ||
        gender == null ||
        heartRate == null ||
        systolicPressure == null ||
        respiratoryRate == null ||
        temperature == null ||
        oxygen == null ||
        alteredMentalStatus == null) {
      setState(() {
        result = "⚠️ Заполните все параметры PESI";
      });

      scrollToResult();

      return;
    }

    int age = int.tryParse(ageController.text) ?? 0;

    int score = age;

    if (gender == "М") {
      score += 10;
    }

    if (oncology) {
      score += 30;
    }

    if (heartFailure) {
      score += 10;
    }

    if (lungDisease) {
      score += 10;
    }

    score += heartRate!;
    score += systolicPressure!;
    score += respiratoryRate!;
    score += temperature!;
    score += oxygen!;

    if (alteredMentalStatus == true) {
      score += 60;
    }

    String pesiClass;
    String mortality;

    if (score <= 65) {
      pesiClass = "Класс I — очень низкий риск";

      mortality = "0–1,6%";
    } else if (score <= 85) {
      pesiClass = "Класс II — низкий риск";

      mortality = "1,7–3,5%";
    } else if (score <= 105) {
      pesiClass = "Класс III — умеренный риск";

      mortality = "3,2–7,1%";
    } else if (score <= 125) {
      pesiClass = "Класс IV — высокий риск";

      mortality = "4,0–11,4%";
    } else {
      pesiClass = "Класс V — очень высокий риск";

      mortality = "10,0–24,5%";
    }

    setState(() {
      result =
          "🫁 PESI: $score баллов\n\n"
          "$pesiClass\n\n"
          "30-дневная летальность: $mortality";
    });

    scrollToResult();
  }
}
