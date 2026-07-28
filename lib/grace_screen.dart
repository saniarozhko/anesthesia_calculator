import 'package:flutter/material.dart';

class GraceScreen extends StatefulWidget {
  const GraceScreen({super.key});

  @override
  State<GraceScreen> createState() => _GraceScreenState();
}

class _GraceScreenState extends State<GraceScreen> {
  final ageController = TextEditingController();
  final hrController = TextEditingController();
  final sbpController = TextEditingController();
  final creatinineController = TextEditingController();
  final troponinController = TextEditingController();

  bool cardiacArrest = false;
  bool stDeviation = false;
  bool heartFailure = false;

  String result = "";

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
      appBar: AppBar(title: const Text("❤️ GRACE — ОКС"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            inputField("Возраст", ageController, "лет"),

            inputField("ЧСС", hrController, "/мин"),

            inputField("САД", sbpController, "мм рт.ст."),

            inputField("Креатинин", creatinineController, "мкмоль/л"),

            inputField("Тропонин", troponinController, "×ВГН"),

            SwitchListTile(
              title: const Text("Остановка сердца при поступлении"),

              value: cardiacArrest,

              onChanged: (v) {
                setState(() {
                  cardiacArrest = v;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Депрессия ST"),

              value: stDeviation,

              onChanged: (v) {
                setState(() {
                  stDeviation = v;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Признаки сердечной недостаточности"),

              value: heartFailure,

              onChanged: (v) {
                setState(() {
                  heartFailure = v;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                onPressed: calculateGRACE,

                child: const Text(
                  "РАССЧИТАТЬ GRACE",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            AnimatedContainer(
              duration: const Duration(milliseconds: 400),

              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Text(
                result,

                textAlign: TextAlign.center,

                style: const TextStyle(fontSize: 20),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void calculateGRACE() {
    if (ageController.text.isEmpty ||
        hrController.text.isEmpty ||
        sbpController.text.isEmpty ||
        creatinineController.text.isEmpty ||
        troponinController.text.isEmpty) {
      setState(() {
        result = "Заполните все данные";
      });

      return;
    }

    double age = double.parse(ageController.text);

    double hr = double.parse(hrController.text);

    double sbp = double.parse(sbpController.text);

    double creat = double.parse(creatinineController.text);

    double trop = double.parse(troponinController.text);

    int score = 0;

    // возраст

    if (age >= 75) {
      score += 100;
    } else if (age >= 65) {
      score += 73;
    } else if (age >= 55) {
      score += 47;
    } else if (age >= 45) {
      score += 36;
    }

    // ЧСС

    if (hr >= 200) {
      score += 46;
    } else if (hr >= 150) {
      score += 24;
    } else if (hr >= 100) {
      score += 10;
    } else if (hr >= 70) {
      score += 3;
    }

    // САД

    if (sbp < 80) {
      score += 58;
    } else if (sbp < 100) {
      score += 53;
    } else if (sbp < 120) {
      score += 43;
    } else if (sbp < 140) {
      score += 34;
    }

    // креатинин

    if (creat >= 350) {
      score += 28;
    } else if (creat >= 200) {
      score += 20;
    } else if (creat >= 120) {
      score += 10;
    }

    // тропонин

    if (trop > 10) {
      score += 58;
    } else if (trop > 3) {
      score += 28;
    } else if (trop > 1) {
      score += 14;
    }

    if (cardiacArrest) {
      score += 39;
    }

    if (stDeviation) {
      score += 28;
    }

    if (heartFailure) {
      score += 39;
    }

    String risk;

    if (score < 109) {
      risk = "Низкий риск";
    } else if (score < 140) {
      risk = "Средний риск";
    } else {
      risk = "Высокий риск";
    }

    setState(() {
      result =
          "GRACE: $score баллов\n\n"
          "$risk";
    });
  }
}
