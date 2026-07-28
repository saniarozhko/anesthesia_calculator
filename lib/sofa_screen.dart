import 'package:flutter/material.dart';

class SofaScreen extends StatefulWidget {
  const SofaScreen({super.key});

  @override
  State<SofaScreen> createState() => _SofaScreenState();
}

class _SofaScreenState extends State<SofaScreen> {
  final ScrollController _scrollController = ScrollController();

  final pao2Controller = TextEditingController();
  final fio2Controller = TextEditingController();

  final plateletsController = TextEditingController();

  final bilirubinController = TextEditingController();

  // САД и ДАД вместо MAP
  final sadController = TextEditingController();
  final dadController = TextEditingController();

  final gcsController = TextEditingController();

  final creatinineController = TextEditingController();

  final urineController = TextEditingController();

  final weightController = TextEditingController();

  final drugAmountController = TextEditingController();

  final solutionVolumeController = TextEditingController();

  final infusionRateController = TextEditingController();

  bool ventilation = false;

  bool vasopressor = false;

  String selectedDrug = "Норадреналин";

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 134, 187, 216);

  @override
  void dispose() {
    _scrollController.dispose();

    pao2Controller.dispose();
    fio2Controller.dispose();

    plateletsController.dispose();

    bilirubinController.dispose();

    sadController.dispose();
    dadController.dispose();

    gcsController.dispose();

    creatinineController.dispose();

    urineController.dispose();

    weightController.dispose();

    drugAmountController.dispose();

    solutionVolumeController.dispose();

    infusionRateController.dispose();

    super.dispose();
  }

  double parse(String value) {
    return double.tryParse(value.replaceAll(",", ".")) ?? 0;
  }

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,

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

  Widget choiceButton(String text, bool active, VoidCallback onTap) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(vertical: 4),

      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: active ? activeColor : Colors.grey[800],

          foregroundColor: Colors.white,

          padding: const EdgeInsets.symmetric(vertical: 14),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        child: Text(text, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  Widget resultCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),

      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),

            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),

          child: FadeTransition(opacity: animation, child: child),
        );
      },

      child: Container(
        key: ValueKey(result),

        width: double.infinity,

        margin: const EdgeInsets.only(top: 20, bottom: 100),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: activeColor, width: 1),
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
      appBar: AppBar(title: const Text("🩸 SOFA"), centerTitle: true),

      body: SingleChildScrollView(
        controller: _scrollController,

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

        child: Column(
          children: [
            sectionTitle("🫁 1. Дыхательная система"),

            inputField("PaO₂", pao2Controller, "мм рт.ст."),

            inputField("FiO₂", fio2Controller, "%"),

            choiceButton("ИВЛ", ventilation, () {
              setState(() {
                ventilation = !ventilation;
              });
            }),

            sectionTitle("🩸 2. Коагуляция"),

            inputField("Тромбоциты", plateletsController, "×10⁹/л"),

            sectionTitle("🟡 3. Печень"),

            inputField("Билирубин", bilirubinController, "мкмоль/л"),

            sectionTitle("❤️ 4. Сердечно-сосудистая система"),

            inputField("САД", sadController, "мм рт.ст."),

            inputField("ДАД", dadController, "мм рт.ст."),

            if (sadController.text.isNotEmpty && dadController.text.isNotEmpty)
              Text(
                "MAP рассчитывается автоматически",

                style: TextStyle(color: Colors.grey[400]),
              ),

            choiceButton("Вазопрессоры", vasopressor, () {
              setState(() {
                vasopressor = !vasopressor;
              });
            }),

            if (vasopressor) ...[
              DropdownButtonFormField<String>(
                value: selectedDrug,

                decoration: const InputDecoration(
                  labelText: "Препарат",

                  filled: true,

                  fillColor: Color(0xFF1E1E1E),

                  border: OutlineInputBorder(),
                ),

                items:
                    const ["Норадреналин", "Адреналин", "Допамин", "Добутамин"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),

                onChanged: (value) {
                  setState(() {
                    selectedDrug = value!;
                  });
                },
              ),

              inputField("Количество препарата", drugAmountController, "мг"),

              inputField("Объём раствора", solutionVolumeController, "мл"),

              inputField("Скорость инфузии", infusionRateController, "мл/ч"),

              inputField("Вес пациента", weightController, "кг"),
            ],

            sectionTitle("🧠 5. Центральная нервная система"),

            inputField("ШКГ", gcsController, "баллы"),

            sectionTitle("🧬 6. Почки"),

            inputField("Креатинин", creatinineController, "мкмоль/л"),

            inputField("Диурез", urineController, "мл/сут"),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 65,

              child: ElevatedButton(
                onPressed: calculateSOFA,

                child: const Text(
                  "Рассчитать SOFA",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (result.isNotEmpty) resultCard(),
          ],
        ),
      ),
    );
  }

  double calculateVasopressorDose() {
    double amount = parse(drugAmountController.text);

    double volume = parse(solutionVolumeController.text);

    double rate = parse(infusionRateController.text);

    double weight = parse(weightController.text);

    if (amount <= 0 || volume <= 0 || rate <= 0 || weight <= 0) {
      return 0;
    }

    double mcg = amount * 1000;

    double concentration = mcg / volume;

    double mcgHour = concentration * rate;

    double mcgMinute = mcgHour / 60;

    return mcgMinute / weight;
  }

  void calculateSOFA() {
    double pao2 = parse(pao2Controller.text);

    double fio2 = parse(fio2Controller.text);

    double platelets = parse(plateletsController.text);

    double bilirubin = parse(bilirubinController.text);

    double sad = parse(sadController.text);

    double dad = parse(dadController.text);

    // автоматический расчёт MAP

    double map = 0;

    if (sad > 0 && dad > 0) {
      map = dad + ((sad - dad) / 3);
    }

    double gcs = parse(gcsController.text);

    double creatinine = parse(creatinineController.text);

    double urine = parse(urineController.text);

    int respiratory = 0;

    int coagulation = 0;

    int liver = 0;

    int cardiovascular = 0;

    int cns = 0;

    int renal = 0;

    // =========================
    // ДЫХАНИЕ
    // =========================

    if (fio2 > 0) {
      double ratio = pao2 / (fio2 / 100);

      if (ratio < 100 && ventilation) {
        respiratory = 4;
      } else if (ratio < 200 && ventilation) {
        respiratory = 3;
      } else if (ratio < 300) {
        respiratory = 2;
      } else if (ratio < 400) {
        respiratory = 1;
      }
    }

    // =========================
    // КОАГУЛЯЦИЯ
    // =========================

    if (platelets > 0) {
      if (platelets < 20) {
        coagulation = 4;
      } else if (platelets < 50) {
        coagulation = 3;
      } else if (platelets < 100) {
        coagulation = 2;
      } else if (platelets < 150) {
        coagulation = 1;
      }
    }

    // =========================
    // ПЕЧЕНЬ
    // =========================

    if (bilirubin > 0) {
      if (bilirubin > 204) {
        liver = 4;
      } else if (bilirubin >= 102) {
        liver = 3;
      } else if (bilirubin >= 33) {
        liver = 2;
      } else if (bilirubin >= 20) {
        liver = 1;
      }
    }

    // =========================
    // ССС
    // =========================

    double vasoDose = 0;

    if (vasopressor) {
      vasoDose = calculateVasopressorDose();

      if (selectedDrug == "Допамин") {
        if (vasoDose <= 5) {
          cardiovascular = 2;
        } else if (vasoDose <= 15) {
          cardiovascular = 3;
        } else {
          cardiovascular = 4;
        }
      } else if (selectedDrug == "Норадреналин" ||
          selectedDrug == "Адреналин") {
        if (vasoDose <= 0.1) {
          cardiovascular = 3;
        } else {
          cardiovascular = 4;
        }
      } else if (selectedDrug == "Добутамин") {
        cardiovascular = 2;
      }
    } else {
      if (map > 0 && map < 70) {
        cardiovascular = 1;
      }
    }

    // =========================
    // ЦНС
    // =========================

    if (gcs > 0) {
      if (gcs < 6) {
        cns = 4;
      } else if (gcs <= 9) {
        cns = 3;
      } else if (gcs <= 12) {
        cns = 2;
      } else if (gcs <= 14) {
        cns = 1;
      }
    }

    // =========================
    // ПОЧКИ
    // =========================

    if (creatinine > 0 || urine > 0) {
      if (creatinine > 440 || urine < 200) {
        renal = 4;
      } else if (creatinine >= 300) {
        renal = 3;
      } else if (creatinine >= 171) {
        renal = 2;
      } else if (creatinine >= 110) {
        renal = 1;
      }
    }

    int total =
        respiratory + coagulation + liver + cardiovascular + cns + renal;

    String risk;

    String mortality;

    if (total <= 6) {
      risk = "Низкий риск";

      mortality = "<10%";
    } else if (total <= 9) {
      risk = "Умеренный риск";

      mortality = "15–25%";
    } else if (total <= 12) {
      risk = "Высокий риск";

      mortality = "40–50%";
    } else if (total <= 14) {
      risk = "Очень высокий риск";

      mortality = "50–60%";
    } else {
      risk = "Крайне высокий риск";

      mortality = ">70%";
    }

    String cardioText = "";

    if (sad > 0 && dad > 0) {
      cardioText +=
          "\nСАД: ${sad.toInt()} мм рт.ст.\n"
          "ДАД: ${dad.toInt()} мм рт.ст.\n"
          "MAP: ${map.toStringAsFixed(0)} мм рт.ст.\n";
    }

    if (vasopressor) {
      cardioText +=
          "\nВазопрессор: $selectedDrug\n"
          "Доза: "
          "${vasoDose.toStringAsFixed(3)} "
          "мкг/кг/мин";
    }

    setState(() {
      result =
          "🩸 SOFA: $total / 24\n\n"
          "🫁 Дыхание: $respiratory\n"
          "🩸 Коагуляция: $coagulation\n"
          "🟡 Печень: $liver\n"
          "❤️ ССС: $cardiovascular\n"
          "🧠 ЦНС: $cns\n"
          "🧬 Почки: $renal\n"
          "$cardioText\n"
          "--------------------\n"
          "Риск: $risk\n"
          "Ожидаемая летальность: $mortality";
    });

    scrollToResult();
  }
}
