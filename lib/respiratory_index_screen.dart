import 'package:flutter/material.dart';

class RespiratoryIndexScreen extends StatefulWidget {
  const RespiratoryIndexScreen({super.key});

  @override
  State<RespiratoryIndexScreen> createState() => _RespiratoryIndexScreenState();
}

class _RespiratoryIndexScreenState extends State<RespiratoryIndexScreen> {
  final pao2Controller = TextEditingController();

  final fio2Controller = TextEditingController();

  final peepController = TextEditingController();

  bool ventilation = false;

  String result = "";

  Color resultColor = Colors.blue;

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

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),

      child: Text(
        text,

        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🫁 Респираторный индекс"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

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
                    "PaO₂ / FiO₂",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Оценка тяжести ОРДС",

                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            sectionTitle("🩸 Газовый состав крови"),

            inputField("PaO₂", pao2Controller, "мм рт.ст."),

            inputField("FiO₂", fio2Controller, "%"),

            sectionTitle("🫁 Респираторная поддержка"),

            SwitchListTile(
              title: const Text("Пациент на ИВЛ"),

              value: ventilation,

              onChanged: (v) {
                setState(() {
                  ventilation = v;
                });
              },
            ),

            inputField("PEEP", peepController, "см H₂O"),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 65,

              child: ElevatedButton(
                onPressed: calculate,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Рассчитать",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (result.isNotEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: resultColor, width: 2),
                ),

                child: Text(
                  result,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 20,

                    height: 1.5,

                    color: resultColor,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void calculate() {
    double pao2 =
        double.tryParse(pao2Controller.text.replaceAll(",", ".")) ?? 0;

    double fio2 =
        double.tryParse(fio2Controller.text.replaceAll(",", ".")) ?? 0;

    double peep =
        double.tryParse(peepController.text.replaceAll(",", ".")) ?? 0;

    if (pao2 <= 0 || fio2 <= 0) {
      setState(() {
        result = "Введите PaO₂ и FiO₂";

        resultColor = Colors.orange;
      });

      return;
    }

    double pfRatio = pao2 / (fio2 / 100);

    String text;

    if (pfRatio > 300) {
      text =
          "P/F = ${pfRatio.toStringAsFixed(0)}\n\n"
          "✅ ОРДС нет";

      resultColor = Colors.green;
    } else if (pfRatio > 200) {
      text =
          "P/F = ${pfRatio.toStringAsFixed(0)}\n\n"
          "🟡 Лёгкий ОРДС";

      resultColor = Colors.yellow;
    } else if (pfRatio > 100) {
      text =
          "P/F = ${pfRatio.toStringAsFixed(0)}\n\n"
          "🟠 Средний ОРДС";

      resultColor = Colors.orange;
    } else {
      text =
          "P/F = ${pfRatio.toStringAsFixed(0)}\n\n"
          "🔴 Тяжёлый ОРДС";

      resultColor = Colors.red;
    }

    if (ventilation && peep >= 5) {
      text += "\n\nPEEP ≥5 ✔";
    }

    text +=
        "\n\nБерлинские критерии:\n"
        "P/F ≤300 + PEEP ≥5";

    setState(() {
      result = text;
    });
  }
}
