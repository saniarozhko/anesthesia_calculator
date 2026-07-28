import 'package:flutter/material.dart';
import 'dart:math';

class RenalFunctionScreen extends StatefulWidget {
  const RenalFunctionScreen({super.key});

  @override
  State<RenalFunctionScreen> createState() => _RenalFunctionScreenState();
}

class _RenalFunctionScreenState extends State<RenalFunctionScreen> {
  String formula = "CKD-EPI";

  String gender = "";

  String creatinineUnit = "мкмоль/л";

  final ageController = TextEditingController();

  final weightController = TextEditingController();

  final creatinineController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 146, 200, 230);

  @override
  void dispose() {
    ageController.dispose();

    weightController.dispose();

    creatinineController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  double parse(String value) {
    return double.tryParse(value.replaceAll(",", ".")) ?? 0;
  }

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 500),

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

  Widget choiceButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? activeColor : Colors.grey.shade800,

            foregroundColor: Colors.white,

            minimumSize: const Size(0, 50),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          onPressed: onTap,

          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: TextField(
        controller: controller,

        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        decoration: InputDecoration(
          labelText: label,

          filled: true,

          fillColor: const Color(0xFF1E1E1E),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget resultCard() {
    if (result.isEmpty) {
      return const SizedBox();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),

      curve: Curves.easeOut,

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(top: 20, bottom: 120),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: activeColor, width: 1.5),
        ),

        child: Text(
          result,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🧬 Расчёт СКФ"), centerTitle: true),

      body: SingleChildScrollView(
        controller: scrollController,

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            sectionTitle("📐 Формула"),

            Row(
              children: [
                choiceButton("CKD-EPI", formula == "CKD-EPI", () {
                  setState(() {
                    formula = "CKD-EPI";
                  });
                }),

                choiceButton("Кокрофт–Голт", formula == "Кокрофт–Голт", () {
                  setState(() {
                    formula = "Кокрофт–Голт";
                  });
                }),
              ],
            ),

            sectionTitle("👤 Пол пациента"),

            Row(
              children: [
                choiceButton("👨 Мужчина", gender == "М", () {
                  setState(() {
                    gender = "М";
                  });
                }),

                choiceButton("👩 Женщина", gender == "Ж", () {
                  setState(() {
                    gender = "Ж";
                  });
                }),
              ],
            ),

            sectionTitle("📋 Данные пациента"),

            inputField("Возраст (лет)", ageController),

            if (formula == "Кокрофт–Голт")
              inputField("Масса тела (кг)", weightController),

            Row(
              children: [
                Expanded(child: inputField("Креатинин", creatinineController)),

                const SizedBox(width: 8),

                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: creatinineUnit == "мкмоль/л"
                            ? activeColor
                            : Colors.grey.shade700,
                      ),

                      onPressed: () {
                        setState(() {
                          creatinineUnit = "мкмоль/л";
                        });
                      },

                      child: const Text("мкмоль/л"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: creatinineUnit == "мг/дл"
                            ? activeColor
                            : Colors.grey.shade700,
                      ),

                      onPressed: () {
                        setState(() {
                          creatinineUnit = "мг/дл";
                        });
                      },

                      child: const Text("мг/дл"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: calculateRenalFunction,

                child: const Text(
                  "РАССЧИТАТЬ СКФ",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            resultCard(),
          ],
        ),
      ),
    );
  }

  void calculateRenalFunction() {
    double? age = double.tryParse(ageController.text.replaceAll(",", "."));

    double? creatinine = double.tryParse(
      creatinineController.text.replaceAll(",", "."),
    );

    double? weight = double.tryParse(
      weightController.text.replaceAll(",", "."),
    );

    if (age == null ||
        creatinine == null ||
        gender.isEmpty ||
        (formula == "Кокрофт–Голт" && weight == null)) {
      setState(() {
        result = "⚠️ Заполните все обязательные поля";
      });

      scrollToResult();

      return;
    }

    double creatinineMg = creatinineUnit == "мкмоль/л"
        ? creatinine / 88.4
        : creatinine;

    if (formula == "CKD-EPI") {
      double kappa = gender == "Ж" ? 0.7 : 0.9;

      double alpha = gender == "Ж" ? -0.241 : -0.302;

      double ratio = creatinineMg / kappa;

      double egfr =
          142 *
          pow(min(ratio, 1), alpha).toDouble() *
          pow(max(ratio, 1), -1.200).toDouble() *
          pow(0.9938, age).toDouble();

      if (gender == "Ж") {
        egfr *= 1.012;
      }

      setState(() {
        result =
            "🧬 CKD-EPI\n\n"
            "СКФ:\n"
            "${egfr.toStringAsFixed(1)} "
            "мл/мин/1,73 м²\n\n"
            "${ckdClassification(egfr)}";
      });
    } else {
      double clearance = ((140 - age) * weight!) / (72 * creatinineMg);

      if (gender == "Ж") {
        clearance *= 0.85;
      }

      setState(() {
        result =
            "🧬 Кокрофт–Голт\n\n"
            "Клиренс креатинина:\n"
            "${clearance.toStringAsFixed(1)} "
            "мл/мин\n\n"
            "Масса тела: "
            "${weight.toStringAsFixed(1)} кг";
      });
    }

    scrollToResult();
  }

  String ckdClassification(double egfr) {
    if (egfr >= 90) {
      return "ХБП C1\n"
          "Нормальная или высокая СКФ";
    }

    if (egfr >= 60) {
      return "ХБП C2\n"
          "Незначительное снижение СКФ";
    }

    if (egfr >= 45) {
      return "ХБП C3a\n"
          "Умеренное снижение СКФ";
    }

    if (egfr >= 30) {
      return "ХБП C3b\n"
          "Значительное снижение СКФ";
    }

    if (egfr >= 15) {
      return "ХБП C4\n"
          "Тяжёлое снижение СКФ";
    }

    return "ХБП C5\n"
        "Терминальная почечная недостаточность";
  }
}
