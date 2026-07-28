import 'package:flutter/material.dart';

class ApacheIIScreen extends StatefulWidget {
  const ApacheIIScreen({super.key});

  @override
  State<ApacheIIScreen> createState() => _ApacheIIScreenState();
}

class _ApacheIIScreenState extends State<ApacheIIScreen> {
  final ScrollController _scrollController = ScrollController();

  final ageController = TextEditingController();
  final tempController = TextEditingController();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final hrController = TextEditingController();
  final rrController = TextEditingController();
  final fio2Controller = TextEditingController();
  final pao2Controller = TextEditingController();
  final phController = TextEditingController();
  final sodiumController = TextEditingController();
  final potassiumController = TextEditingController();
  final creatinineController = TextEditingController();
  final hematocritController = TextEditingController();
  final wbcController = TextEditingController();
  final gcsController = TextEditingController();

  String patientType = "Терапевтический";

  bool vasopressor = false;

  bool acuteRenalFailure = false;

  bool chronicFailure = false;

  String result = "";

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: TextField(
        controller: controller,

        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        decoration: InputDecoration(
          labelText: label,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 700),

          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏥 APACHE II"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,

        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 150,
        ),

        child: Column(
          children: [
            inputField("Возраст (лет)", ageController),

            inputField("Температура (°C)", tempController),

            const SizedBox(height: 10),

            const Text(
              "Артериальное давление",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            inputField("Систолическое АД", systolicController),

            inputField("Диастолическое АД", diastolicController),

            inputField("ЧСС (уд/мин)", hrController),

            inputField("ЧДД (дых/мин)", rrController),

            const SizedBox(height: 10),

            const Text(
              "Газовый состав крови",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            inputField("FiO₂ (%)", fio2Controller),

            inputField("PaO₂ (мм рт.ст.)", pao2Controller),

            inputField("pH", phController),

            inputField("Na⁺ (ммоль/л)", sodiumController),

            inputField("K⁺ (ммоль/л)", potassiumController),

            inputField("Креатинин (мкмоль/л)", creatinineController),

            inputField("Гематокрит (%)", hematocritController),

            inputField("Лейкоциты (×10⁹/л)", wbcController),

            inputField("ШКГ", gcsController),

            const SizedBox(height: 15),

            const Text(
              "Статус пациента",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            DropdownButton<String>(
              value: patientType,

              isExpanded: true,

              items: const [
                DropdownMenuItem(
                  value: "Терапевтический",
                  child: Text("Терапевтический"),
                ),

                DropdownMenuItem(
                  value: "После плановой операции",
                  child: Text("После плановой операции"),
                ),

                DropdownMenuItem(
                  value: "После экстренной операции",
                  child: Text("После экстренной операции"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  patientType = value!;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Вазопрессорная поддержка"),

              subtitle: const Text("Норадреналин, адреналин, допамин и др."),

              value: vasopressor,

              onChanged: (value) {
                setState(() {
                  vasopressor = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Острая почечная недостаточность"),

              subtitle: const Text("Удвоение баллов креатинина"),

              value: acuteRenalFailure,

              onChanged: (value) {
                setState(() {
                  acuteRenalFailure = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Тяжёлая хроническая недостаточность / иммунодефицит",
              ),

              subtitle: const Text("Цирроз, диализ, тяжёлая ХСН, ХДН"),

              value: chronicFailure,

              onChanged: (value) {
                setState(() {
                  chronicFailure = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                onPressed: calculateApache,

                child: const Text(
                  "РАССЧИТАТЬ APACHE II",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF1E1E1E),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Text(
                  result,

                  textAlign: TextAlign.center,

                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            // дополнительное место снизу,
            // чтобы системная панель телефона не закрывала результат
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void calculateApache() {
    List<String> emptyFields = [];

    if (ageController.text.isEmpty) emptyFields.add("Возраст");
    if (tempController.text.isEmpty) emptyFields.add("Температура");
    if (systolicController.text.isEmpty) emptyFields.add("САД");
    if (diastolicController.text.isEmpty) emptyFields.add("ДАД");
    if (hrController.text.isEmpty) emptyFields.add("ЧСС");
    if (rrController.text.isEmpty) emptyFields.add("ЧДД");
    if (fio2Controller.text.isEmpty) emptyFields.add("FiO₂");
    if (pao2Controller.text.isEmpty) emptyFields.add("PaO₂");
    if (phController.text.isEmpty) emptyFields.add("pH");
    if (sodiumController.text.isEmpty) emptyFields.add("Na⁺");
    if (potassiumController.text.isEmpty) emptyFields.add("K⁺");
    if (creatinineController.text.isEmpty) emptyFields.add("Креатинин");
    if (hematocritController.text.isEmpty) emptyFields.add("Гематокрит");
    if (wbcController.text.isEmpty) emptyFields.add("Лейкоциты");
    if (gcsController.text.isEmpty) emptyFields.add("ШКГ");

    if (emptyFields.isNotEmpty) {
      setState(() {
        result =
            "⚠️ Не все данные введены:\n\n"
            "${emptyFields.join("\n")}";
      });

      scrollToResult();

      return;
    }

    double score = 0;

    double age = double.parse(ageController.text);
    double temp = double.parse(tempController.text);
    double systolic = double.parse(systolicController.text);
    double diastolic = double.parse(diastolicController.text);
    double hr = double.parse(hrController.text);
    double rr = double.parse(rrController.text);
    double fio2 = double.parse(fio2Controller.text);
    double pao2 = double.parse(pao2Controller.text);
    double ph = double.parse(phController.text);
    double sodium = double.parse(sodiumController.text);
    double potassium = double.parse(potassiumController.text);
    double creatinine = double.parse(creatinineController.text);
    double hematocrit = double.parse(hematocritController.text);
    double wbc = double.parse(wbcController.text);
    double gcs = double.parse(gcsController.text);

    // Возраст

    if (age >= 45 && age <= 54) {
      score += 2;
    } else if (age >= 55 && age <= 64) {
      score += 3;
    } else if (age >= 65 && age <= 74) {
      score += 5;
    } else if (age >= 75) {
      score += 6;
    }

    // ШКГ

    score += (15 - gcs);

    // Температура

    if (temp >= 41) {
      score += 4;
    } else if (temp >= 39) {
      score += 3;
    } else if (temp < 34) {
      score += 4;
    } else if (temp < 36) {
      score += 1;
    }

    // MAP

    double map = (systolic + 2 * diastolic) / 3;

    if (map < 50) {
      score += 4;
    } else if (map < 70) {
      score += 2;
    }

    // ЧСС

    if (hr >= 180) {
      score += 4;
    } else if (hr >= 140) {
      score += 3;
    } else if (hr < 40) {
      score += 4;
    } else if (hr < 55) {
      score += 3;
    }

    // ЧДД

    if (rr >= 50) {
      score += 4;
    } else if (rr >= 35) {
      score += 3;
    } else if (rr < 10) {
      score += 1;
    }

    // Оксигенация

    if (fio2 >= 50) {
      if (pao2 < 60) {
        score += 4;
      } else if (pao2 < 70) {
        score += 3;
      }
    } else {
      if (pao2 < 55) {
        score += 3;
      }
    }

    // pH

    if (ph < 7.15) {
      score += 4;
    } else if (ph < 7.25) {
      score += 2;
    } else if (ph > 7.7) {
      score += 4;
    } else if (ph > 7.6) {
      score += 3;
    }

    // Натрий

    if (sodium >= 180 || sodium < 120) {
      score += 4;
    } else if (sodium >= 160 || sodium < 130) {
      score += 2;
    }

    // Калий

    if (potassium >= 7) {
      score += 4;
    } else if (potassium >= 6) {
      score += 3;
    } else if (potassium < 2.5) {
      score += 4;
    } else if (potassium < 3) {
      score += 2;
    }

    // Креатинин

    double creatininePoints = 0;

    if (creatinine >= 300) {
      creatininePoints = 4;
    } else if (creatinine >= 170) {
      creatininePoints = 2;
    }

    if (acuteRenalFailure) {
      creatininePoints *= 2;
    }

    score += creatininePoints;

    // Гематокрит

    if (hematocrit >= 60 || hematocrit < 20) {
      score += 4;
    }

    // Лейкоциты

    if (wbc >= 40 || wbc < 1) {
      score += 4;
    }

    // Хронические заболевания

    if (chronicFailure) {
      if (patientType == "После плановой операции") {
        score += 2;
      } else {
        score += 5;
      }
    }

    double mortality;

    String risk;

    if (score <= 4) {
      mortality = 4;
      risk = "Низкий риск";
    } else if (score <= 9) {
      mortality = 8;
      risk = "Умеренный риск";
    } else if (score <= 14) {
      mortality = 15;
      risk = "Средний риск";
    } else if (score <= 19) {
      mortality = 25;
      risk = "Высокий риск";
    } else if (score <= 29) {
      mortality = 40;
      risk = "Очень высокий риск";
    } else {
      mortality = 70;
      risk = "Крайне высокий риск";
    }

    String additional = "";

    if (vasopressor) {
      additional += "\n⚠️ Вазопрессоры";
    }

    if (acuteRenalFailure) {
      additional += "\n⚠️ ОПН";
    }

    setState(() {
      result =
          "🏥 APACHE II\n\n"
          "Баллы: ${score.toInt()}\n\n"
          "Оценочная летальность: "
          "${mortality.toInt()} %\n\n"
          "Риск: $risk"
          "$additional";
    });

    // автоматически опускаем экран к результату

    scrollToResult();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    ageController.dispose();
    tempController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
    hrController.dispose();
    rrController.dispose();
    fio2Controller.dispose();
    pao2Controller.dispose();
    phController.dispose();
    sodiumController.dispose();
    potassiumController.dispose();
    creatinineController.dispose();
    hematocritController.dispose();
    wbcController.dispose();
    gcsController.dispose();

    super.dispose();
  }
}
