import 'package:flutter/material.dart';

class Cha2ds2VascScreen extends StatefulWidget {
  const Cha2ds2VascScreen({super.key});

  @override
  State<Cha2ds2VascScreen> createState() => _Cha2ds2VascScreenState();
}

class _Cha2ds2VascScreenState extends State<Cha2ds2VascScreen> {
  bool chf = false;
  bool hypertension = false;
  bool diabetes = false;

  bool vascular = false;

  bool sexFemale = false;

  int age = 0;

  String result = "";

  int calculateScore() {
    int score = 0;

    // C - сердечная недостаточность
    if (chf) score += 1;

    // H - гипертония
    if (hypertension) score += 1;

    // A2 - возраст ≥75
    if (age >= 75) {
      score += 2;
    }

    // D - диабет
    if (diabetes) score += 1;

    // S2 - инсульт/ТИА/эмболия
    // добавляем отдельной переменной ниже

    // V - сосудистое заболевание
    if (vascular) score += 1;

    // A - возраст 65-74
    if (age >= 65 && age < 75) {
      score += 1;
    }

    // Sc - женский пол
    if (sexFemale) {
      score += 1;
    }

    return score;
  }

  void calculate() {
    int score = calculateScore();

    String risk;

    if (score == 0) {
      risk = "Очень низкий риск";
    } else if (score == 1) {
      risk = "Низкий риск";
    } else if (score <= 3) {
      risk = "Умеренный риск";
    } else {
      risk = "Высокий риск";
    }

    setState(() {
      result =
          "CHA₂DS₂-VASc: $score балл(ов)\n\n"
          "$risk";
    });
  }

  Widget optionCard(String title, bool value, VoidCallback onTap, int points) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: value ? const Color(0xFF1976D2) : const Color(0xFF252525),

          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,

              color: Colors.white,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 17,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text("+$points", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("❤️ CHA₂DS₂-VASc"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            const Text(
              "Оценка риска инсульта при ФП",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            optionCard("Сердечная недостаточность / ЛЖ дисфункция", chf, () {
              setState(() {
                chf = !chf;
              });
            }, 1),

            optionCard("Артериальная гипертензия", hypertension, () {
              setState(() {
                hypertension = !hypertension;
              });
            }, 1),

            DropdownButtonFormField<int>(
              value: age,

              decoration: const InputDecoration(
                labelText: "Возраст",

                border: OutlineInputBorder(),
              ),

              items: [
                const DropdownMenuItem(value: 0, child: Text("Нет")),

                const DropdownMenuItem(
                  value: 66,
                  child: Text("65–74 года (+1)"),
                ),

                const DropdownMenuItem(value: 76, child: Text("≥75 лет (+2)")),
              ],

              onChanged: (v) {
                setState(() {
                  age = v!;
                });
              },
            ),

            optionCard("Сахарный диабет", diabetes, () {
              setState(() {
                diabetes = !diabetes;
              });
            }, 1),

            optionCard(
              "Сосудистое заболевание (ИМ, ПАБ, атеросклероз)",
              vascular,
              () {
                setState(() {
                  vascular = !vascular;
                });
              },
              1,
            ),

            optionCard("Женский пол", sexFemale, () {
              setState(() {
                sexFemale = !sexFemale;
              });
            }, 1),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                onPressed: calculate,

                child: const Text("РАССЧИТАТЬ", style: TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(height: 25),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),

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

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
