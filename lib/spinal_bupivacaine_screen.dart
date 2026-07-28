import 'package:flutter/material.dart';

class SpinalBupivacaineScreen extends StatefulWidget {
  const SpinalBupivacaineScreen({super.key});

  @override
  State<SpinalBupivacaineScreen> createState() =>
      _SpinalBupivacaineScreenState();
}

class _SpinalBupivacaineScreenState extends State<SpinalBupivacaineScreen> {
  final TextEditingController heightController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  double? bmi;

  double? baseDose;

  double? correction;

  double? finalDose;

  double? volume;

  void calculate() {
    double height =
        double.tryParse(heightController.text.replaceAll(",", ".")) ?? 0;

    double weight =
        double.tryParse(weightController.text.replaceAll(",", ".")) ?? 0;

    if (height <= 0 || weight <= 0) {
      return;
    }

    double heightM = height / 100;

    double calculatedBMI = weight / (heightM * heightM);

    double dose;

    // Расчёт базовой дозы по росту

    if (height <= 150) {
      dose = 8;
    } else if (height < 160) {
      dose = 10 + ((height - 150) / 0.5) * 0.1;
    } else if (height < 180) {
      dose = 12 + ((height - 160) / 0.5) * 0.075;
    } else {
      dose = 15;
    }

    double correctionPercent = 0;

    double finalPercent = 100;

    if (calculatedBMI > 25) {
      correctionPercent = (calculatedBMI - 25) * 2;

      finalPercent = 100 - correctionPercent;
    }

    double resultDose = dose * finalPercent / 100;

    double resultVolume = resultDose / 5;

    setState(() {
      bmi = calculatedBMI;

      baseDose = dose;

      correction = correctionPercent;

      finalDose = resultDose;

      volume = resultVolume;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,

        duration: const Duration(milliseconds: 500),

        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    heightController.dispose();

    weightController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,

          keyboardType: const TextInputType.numberWithOptions(decimal: true),

          decoration: InputDecoration(
            hintText: hint,

            filled: true,

            fillColor: const Color(0xFF1E1E1E),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Бупивакаин 0,5% для СМА")),

      body: ListView(
        controller: scrollController,

        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            "Расчёт дозы гипербарического бупивакаина "
            "по росту и ИМТ",

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 25),

          inputField("Рост пациента (см)", heightController, "Введите рост"),

          const SizedBox(height: 20),

          inputField("Вес пациента (кг)", weightController, "Введите вес"),

          const SizedBox(height: 25),

          ElevatedButton(
            onPressed: calculate,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF86BBD8),

              foregroundColor: Colors.black,

              padding: const EdgeInsets.symmetric(vertical: 15),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: const Text(
              "РАССЧИТАТЬ",

              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 40),

          if (finalDose != null)
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFF86BBD8)),
              ),

              child: Column(
                children: [
                  const Text(
                    "РЕЗУЛЬТАТ",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "ИМТ: "
                    "${bmi!.toStringAsFixed(1)} кг/м²",

                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Базовая доза по росту:\n"
                    "${baseDose!.toStringAsFixed(2)} мг",

                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Коррекция по ИМТ:\n"
                    "-${correction!.toStringAsFixed(1)} %",

                    textAlign: TextAlign.center,
                  ),

                  const Divider(height: 30),

                  const Text(
                    "💉 Бупивакаин 0,5%",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${finalDose!.toStringAsFixed(1)} мг",

                    style: const TextStyle(
                      fontSize: 26,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "${volume!.toStringAsFixed(2)} мл",

                    style: const TextStyle(
                      fontSize: 24,

                      color: Color(0xFF95C7F3),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
