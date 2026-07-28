import 'package:flutter/material.dart';

class InfusionCalculatorScreen extends StatefulWidget {
  const InfusionCalculatorScreen({super.key});

  @override
  State<InfusionCalculatorScreen> createState() =>
      _InfusionCalculatorScreenState();
}

class _InfusionCalculatorScreenState extends State<InfusionCalculatorScreen> {
  final ScrollController _scrollController = ScrollController();

  bool doseToRate = false;

  String selectedDrug = "Норадреналин";

  String selectedConcentration = "0,2% (2 мг/мл)";

  String customUnit = "мг/мл";

  final weightController = TextEditingController();

  final drugVolumeController = TextEditingController();

  final totalVolumeController = TextEditingController();

  final infusionRateController = TextEditingController();

  final targetDoseController = TextEditingController();

  final customConcentrationController = TextEditingController();

  String result = "";

  final Map<String, List<String>> concentrations = {
    "Норадреналин": ["0,2% (2 мг/мл)", "0,1% (1 мг/мл)", "Своя концентрация"],

    "Адреналин": ["0,1% (1 мг/мл)", "0,01% (0,1 мг/мл)", "Своя концентрация"],

    "Допамин": ["40 мг/мл", "20 мг/мл", "10 мг/мл", "Своя концентрация"],

    "Добутамин": ["50 мг/мл", "25 мг/мл", "10 мг/мл", "Своя концентрация"],

    "Пропофол": ["10 мг/мл (1%)", "20 мг/мл (2%)", "Своя концентрация"],

    "Урапидил": ["5 мг/мл", "2,5 мг/мл", "Своя концентрация"],

    "Тиопентал натрия": [
      "25 мг/мл",

      "50 мг/мл",

      "100 мг/мл",

      "Своя концентрация",
    ],

    "Мезатон": [
      "10 мг/мл (1%)",

      "1 мг/мл (0,1%)",

      "0,5 мг/мл (0,05%)",

      "Своя концентрация",
    ],
  };

  final Color buttonColor = const Color.fromARGB(255, 84, 145, 196);

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 600),

          curve: Curves.easeOut,
        );
      }
    });
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

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          text,

          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💉 Инфузии"), centerTitle: true),

      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,

          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              sectionTitle("Режим расчёта"),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          doseToRate = false;

                          result = "";
                        });
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: !doseToRate
                            ? buttonColor
                            : const Color(0xFF424242),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text("Скорость → Доза"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          doseToRate = true;

                          result = "";
                        });
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: doseToRate
                            ? buttonColor
                            : const Color(0xFF424242),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text("Доза → Скорость"),
                    ),
                  ),
                ],
              ),

              sectionTitle("💊 Препарат"),

              DropdownButtonFormField<String>(
                value: selectedDrug,

                decoration: InputDecoration(
                  filled: true,

                  fillColor: const Color(0xFF1E1E1E),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                items: concentrations.keys
                    .map(
                      (drug) =>
                          DropdownMenuItem(value: drug, child: Text(drug)),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    selectedDrug = value!;

                    selectedConcentration = concentrations[selectedDrug]!.first;
                  });
                },
              ),

              sectionTitle("🧪 Концентрация"),

              DropdownButtonFormField<String>(
                value: selectedConcentration,

                decoration: InputDecoration(
                  filled: true,

                  fillColor: const Color(0xFF1E1E1E),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                items: concentrations[selectedDrug]!
                    .map(
                      (conc) =>
                          DropdownMenuItem(value: conc, child: Text(conc)),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    selectedConcentration = value!;
                  });
                },
              ),

              inputField("Вес пациента", weightController, "кг"),

              inputField(
                "Объём препарата из ампулы",
                drugVolumeController,
                "мл",
              ),

              inputField(
                "Общий объём готового раствора",
                totalVolumeController,
                "мл",
              ),

              if (!doseToRate)
                inputField(
                  "Скорость инфузомата",
                  infusionRateController,
                  "мл/ч",
                ),

              if (doseToRate)
                inputField(
                  "Целевая доза",
                  targetDoseController,

                  selectedDrug == "Пропофол" ||
                          selectedDrug == "Тиопентал натрия"
                      ? "мг/кг/ч"
                      : "мкг/кг/мин",
                ),

              if (selectedConcentration == "Своя концентрация") ...[
                sectionTitle("✏️ Своя концентрация"),

                DropdownButtonFormField<String>(
                  value: customUnit,

                  decoration: InputDecoration(
                    filled: true,

                    fillColor: const Color(0xFF1E1E1E),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  items: const ["мг/мл", "мкг/мл", "%"]
                      .map(
                        (unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      customUnit = value!;
                    });
                  },
                ),

                inputField(
                  "Концентрация",

                  customConcentrationController,

                  customUnit,
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                height: 70,

                child: ElevatedButton(
                  onPressed: () {
                    if (doseToRate) {
                      calculateRate();
                    } else {
                      calculateDose();
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    doseToRate ? "Рассчитать скорость" : "Рассчитать дозу",

                    style: const TextStyle(
                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (result.isNotEmpty)
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Text(
                    result,

                    style: const TextStyle(fontSize: 20, height: 1.5),
                  ),
                ),

              // запас места снизу,
              // чтобы результат не перекрывался кнопками телефона
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  double readNumber(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;
  }

  double getConcentrationMgMl() {
    if (selectedConcentration == "Своя концентрация") {
      double value = readNumber(customConcentrationController);

      if (customUnit == "мг/мл") {
        return value;
      }

      if (customUnit == "мкг/мл") {
        return value / 1000;
      }

      if (customUnit == "%") {
        return value * 10;
      }
    }

    if (selectedConcentration.contains("2 мг/мл")) return 2;

    if (selectedConcentration.contains("1 мг/мл")) return 1;

    if (selectedConcentration.contains("0,1 мг/мл")) return 0.1;

    if (selectedConcentration.contains("40 мг/мл")) return 40;

    if (selectedConcentration.contains("20 мг/мл")) return 20;

    if (selectedConcentration.contains("10 мг/мл")) return 10;

    if (selectedConcentration.contains("50 мг/мл")) return 50;

    if (selectedConcentration.contains("25 мг/мл")) return 25;

    if (selectedConcentration.contains("5 мг/мл")) return 5;

    if (selectedConcentration.contains("2,5 мг/мл")) return 2.5;

    if (selectedConcentration.contains("0,5 мг/мл")) return 0.5;

    return 0;
  }

  bool isVasoactive() {
    return selectedDrug == "Норадреналин" ||
        selectedDrug == "Адреналин" ||
        selectedDrug == "Допамин" ||
        selectedDrug == "Добутамин" ||
        selectedDrug == "Мезатон";
  }

  void calculateDose() {
    double weight = readNumber(weightController);

    double drugVolume = readNumber(drugVolumeController);

    double totalVolume = readNumber(totalVolumeController);

    double rate = readNumber(infusionRateController);

    if (weight <= 0 || drugVolume <= 0 || totalVolume <= 0 || rate <= 0) {
      setState(() {
        result = "Введите все данные";
      });

      scrollToResult();

      return;
    }

    double drugMg = getConcentrationMgMl() * drugVolume;

    double solutionMgMl = drugMg / totalVolume;

    double mgHour = solutionMgMl * rate;

    String output;

    if (isVasoactive()) {
      double dose = mgHour * 1000 / weight / 60;

      if (selectedDrug == "Норадреналин") {
        dose = dose / 2;

        output =
            "Норадреналин\n\n"
            "Доза: "
            "${dose.toStringAsFixed(2)} "
            "мкг/кг/мин\n"
            "*расчёт на активное вещество (основание)";
      } else {
        output =
            "$selectedDrug\n\n"
            "Доза: "
            "${dose.toStringAsFixed(2)} "
            "мкг/кг/мин";
      }
    } else {
      double dose = mgHour / weight;

      output =
          "$selectedDrug\n\n"
          "Доза: "
          "${dose.toStringAsFixed(2)} "
          "мг/кг/ч";
    }

    setState(() {
      result = output;
    });

    scrollToResult();
  }

  void calculateRate() {
    double weight = readNumber(weightController);

    double totalVolume = readNumber(totalVolumeController);

    double drugVolume = readNumber(drugVolumeController);

    double target = readNumber(targetDoseController);

    if (weight <= 0 || totalVolume <= 0 || drugVolume <= 0 || target <= 0) {
      setState(() {
        result = "Введите все данные";
      });

      scrollToResult();

      return;
    }

    double solutionMgMl = getConcentrationMgMl() * drugVolume / totalVolume;

    double requiredMgHour;

    if (isVasoactive()) {
      requiredMgHour = target * weight * 60 / 1000;

      if (selectedDrug == "Норадреналин") {
        requiredMgHour = requiredMgHour * 2;
      }
    } else {
      requiredMgHour = target * weight;
    }

    double speed = requiredMgHour / solutionMgMl;

    String output;

    if (selectedDrug == "Норадреналин") {
      output =
          "Норадреналин\n\n"
          "Скорость: "
          "${speed.toStringAsFixed(2)} мл/ч\n"
          "*расчёт на активное вещество (основание)";
    } else {
      output =
          "$selectedDrug\n\n"
          "Скорость: "
          "${speed.toStringAsFixed(2)} мл/ч";
    }

    setState(() {
      result = output;
    });

    scrollToResult();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    weightController.dispose();

    drugVolumeController.dispose();

    totalVolumeController.dispose();

    infusionRateController.dispose();

    targetDoseController.dispose();

    customConcentrationController.dispose();

    super.dispose();
  }
}
