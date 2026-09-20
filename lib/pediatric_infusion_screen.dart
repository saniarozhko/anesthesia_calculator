import 'package:flutter/material.dart';

class PediatricInfusionScreen extends StatefulWidget {
  const PediatricInfusionScreen({super.key});

  @override
  State<PediatricInfusionScreen> createState() =>
      _PediatricInfusionScreenState();
}

class _PediatricInfusionScreenState extends State<PediatricInfusionScreen> {
  // ============================================================
  // КОНТРОЛЛЕРЫ
  // ============================================================

  final TextEditingController yearsController = TextEditingController();

  final TextEditingController monthsController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  final TextEditingController temperatureController = TextEditingController(
    text: '36.6',
  );

  final TextEditingController respiratoryRateController =
      TextEditingController();

  final TextEditingController stoolCountController = TextEditingController(
    text: '0',
  );

  final TextEditingController oralIntakeController = TextEditingController();

  // ============================================================
  // СОСТОЯНИЕ
  // ============================================================

  int dehydrationDegree = 0;
  bool vomiting = false;
  bool diarrhea = false;
  int diarrheaSeverity = 1;
  bool intestinalParesis = false;
  int paresisDegree = 2;
  bool edema = false;

  bool calculated = false;

  String? errorText;

  // ============================================================
  // РЕЗУЛЬТАТЫ
  // ============================================================

  double? weight;
  double? maintenancePerDay;
  double? dehydrationVolume;
  double? pathologicalLosses;
  double? totalPerDay;

  double? oralPerDay;
  double? ivPerDay;

  double? first8Total;
  double? next16Total;

  double? first8Oral;
  double? next16Oral;

  double? first8Iv;
  double? next16Iv;

  double? first8NaCl;
  double? first8Glucose;

  double? next16NaCl;
  double? next16Glucose;

  double? first8Rate;
  double? next16Rate;

  double? first8NaClRate;
  double? first8GlucoseRate;

  double? next16NaClRate;
  double? next16GlucoseRate;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    yearsController.dispose();
    monthsController.dispose();
    weightController.dispose();
    temperatureController.dispose();
    respiratoryRateController.dispose();
    stoolCountController.dispose();
    oralIntakeController.dispose();

    super.dispose();
  }

  // ============================================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ============================================================

  double? parseDouble(String text) {
    return double.tryParse(text.replaceAll(',', '.').trim());
  }

  int parseInt(String text) {
    return int.tryParse(text.trim()) ?? 0;
  }

  String formatNumber(double value) {
    if ((value - value.roundToDouble()).abs() < 0.0001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // ОПРЕДЕЛЕНИЕ ВОЗРАСТА В МЕСЯЦАХ
  // ============================================================

  int getTotalMonths() {
    final int years = parseInt(yearsController.text);
    final int months = parseInt(monthsController.text);

    return years * 12 + months;
  }

  // ============================================================
  // ЖП
  //
  // Для детей первого полугодия используем возрастные значения:
  // 1 мес              140 мл/кг
  // 1-2 мес            130 мл/кг
  // 2-3 мес            120 мл/кг
  // 3-4 мес            110 мл/кг
  // 4-6 мес            100 мл/кг
  //
  // После 6 месяцев:
  // до 10 кг            100 мл/кг
  // 10-20 кг            1000 + 50 мл/кг сверх 10
  // >20 кг              1500 + 20 мл/кг сверх 20
  //
  // При отёках ЖП уменьшается на 25%.
  // ============================================================

  double calculateMaintenance(double kg, int totalMonths) {
    double volume;

    if (totalMonths == 1) {
      volume = kg * 140;
    } else if (totalMonths > 1 && totalMonths <= 2) {
      volume = kg * 130;
    } else if (totalMonths > 2 && totalMonths <= 3) {
      volume = kg * 120;
    } else if (totalMonths > 3 && totalMonths <= 4) {
      volume = kg * 110;
    } else if (totalMonths > 4 && totalMonths <= 6) {
      volume = kg * 100;
    } else {
      if (kg <= 10) {
        volume = kg * 100;
      } else if (kg <= 20) {
        volume = 1000 + (kg - 10) * 50;
      } else {
        volume = 1500 + (kg - 20) * 20;
      }
    }

    if (edema) {
      volume *= 0.75;
    }

    return volume;
  }

  // ============================================================
  // ЖВО
  //
  // До 6 мес:
  // I   = 50 мл/кг
  // II  = 75 мл/кг
  // III = 100 мл/кг
  //
  // 6-12 мес:
  // I   = 50 мл/кг
  // II  = 60 мл/кг
  // III = 80 мл/кг
  //
  // > 1 года:
  // I   = 35 мл/кг
  // II  = 50 мл/кг
  // III = 65 мл/кг
  // ============================================================

  double calculateDehydration(double kg, int totalMonths) {
    if (dehydrationDegree == 0) {
      return 0;
    }

    if (totalMonths < 6) {
      switch (dehydrationDegree) {
        case 1:
          return kg * 50;
        case 2:
          return kg * 75;
        case 3:
          return kg * 100;
      }
    }

    if (totalMonths >= 6 && totalMonths < 12) {
      switch (dehydrationDegree) {
        case 1:
          return kg * 50;
        case 2:
          return kg * 60;
        case 3:
          return kg * 80;
      }
    }

    switch (dehydrationDegree) {
      case 1:
        return kg * 35;
      case 2:
        return kg * 50;
      case 3:
        return kg * 65;
    }

    return 0;
  }

  // ============================================================
  // ВОЗРАСТНАЯ НОРМА ЧДД
  //
  // Для расчёта ЖТПП используем усреднённые ориентиры:
  // <5 лет       35/мин
  // 5-9 лет      26/мин
  // 9-12 лет     21/мин
  // >12 лет      18/мин
  // ============================================================

  int respiratoryReference(int totalMonths) {
    final double ageYears = totalMonths / 12.0;

    if (ageYears < 5) {
      return 35;
    }

    if (ageYears < 9) {
      return 26;
    }

    if (ageYears < 12) {
      return 21;
    }

    return 18;
  }

  // ============================================================
  // ЖТПП
  //
  // Гипертермия:
  // 10 мл/кг на каждый градус >37°C
  //
  // Тахипноэ:
  // 15 мл/кг на каждые 20 дыханий сверх возрастной нормы
  //
  // Рвота:
  // 20 мл/кг
  //
  // Диарея:
  // лёгкая       10 мл/кг
  // профузная    30 мл/кг
  //
  // Парез:
  // II степень   20 мл/кг
  // III степень  40 мл/кг
  // ============================================================

  double calculatePathologicalLosses(double kg, int totalMonths) {
    double losses = 0;

    // ----------------------------------------------------------
    // ТЕМПЕРАТУРА
    // ----------------------------------------------------------

    final double? temperature = parseDouble(temperatureController.text);

    if (temperature != null && temperature > 37) {
      losses += (temperature - 37) * 10 * kg;
    }

    // ----------------------------------------------------------
    // ЧДД
    // ----------------------------------------------------------

    final int respiratoryRate = parseInt(respiratoryRateController.text);

    if (respiratoryRate > 0) {
      final int reference = respiratoryReference(totalMonths);

      final int excess = respiratoryRate - reference;

      if (excess > 0) {
        final double respiratoryUnits = excess / 20.0;

        losses += respiratoryUnits * 15 * kg;
      }
    }

    // ----------------------------------------------------------
    // РВОТА
    // ----------------------------------------------------------

    if (vomiting) {
      losses += 20 * kg;
    }

    // ----------------------------------------------------------
    // ДИАРЕЯ
    // ----------------------------------------------------------

    if (diarrhea) {
      final int stoolCount = parseInt(stoolCountController.text);

      final double lossPerEpisode = diarrheaSeverity == 1 ? 10 : 30;

      losses += stoolCount * lossPerEpisode * kg;
    }

    // ----------------------------------------------------------
    // ПАРЕЗ КИШЕЧНИКА
    // ----------------------------------------------------------

    if (intestinalParesis) {
      if (paresisDegree == 2) {
        losses += 20 * kg;
      } else {
        losses += 40 * kg;
      }
    }

    return losses;
  }

  // ============================================================
  // РАСЧЁТ
  // ============================================================

  void calculate() {
    FocusScope.of(context).unfocus();

    setState(() {
      errorText = null;
      calculated = false;
    });

    final int years = parseInt(yearsController.text);
    final int months = parseInt(monthsController.text);

    final double? kg = parseDouble(weightController.text);

    // ----------------------------------------------------------
    // ПРОВЕРКА ВОЗРАСТА
    // ----------------------------------------------------------

    if (months < 0 || months > 11) {
      setState(() {
        errorText = "Месяцы должны быть от 0 до 11.";
      });
      return;
    }

    if (years < 0) {
      setState(() {
        errorText = "Возраст указан некорректно.";
      });
      return;
    }

    if (years == 0 && months == 0) {
      setState(() {
        errorText = "Минимальный возраст для этого калькулятора — 1 месяц.";
      });
      return;
    }

    final int totalMonths = years * 12 + months;

    if (totalMonths < 1) {
      setState(() {
        errorText = "Минимальный возраст для этого калькулятора — 1 месяц.";
      });
      return;
    }

    // ----------------------------------------------------------
    // ПРОВЕРКА ВЕСА
    // ----------------------------------------------------------

    if (kg == null || kg <= 0) {
      setState(() {
        errorText = "Введите корректную массу тела.";
      });
      return;
    }

    if (kg > 200) {
      setState(() {
        errorText =
            "Проверьте массу тела. Для данного калькулятора "
            "введите значение до 200 кг.";
      });
      return;
    }

    // ----------------------------------------------------------
    // РАСЧЁТ
    // ----------------------------------------------------------

    final double maintenance = calculateMaintenance(kg, totalMonths);

    final double dehydration = calculateDehydration(kg, totalMonths);

    final double losses = calculatePathologicalLosses(kg, totalMonths);

    final double total = maintenance + dehydration + losses;

    // ----------------------------------------------------------
    // PER OS = 1/3
    // В/В    = 2/3
    // ----------------------------------------------------------

    final double oral = total / 3;
    final double iv = total * 2 / 3;

    // ----------------------------------------------------------
    // РАСПРЕДЕЛЕНИЕ 8 / 16 ЧАСОВ
    //
    // Для ЖП и ЖТПП:
    // распределяются пропорционально времени.
    //
    // Для ЖВО:
    // 50% + 50%.
    // ----------------------------------------------------------

    final double maintenance8 = maintenance * 8 / 24;

    final double maintenance16 = maintenance * 16 / 24;

    final double losses8 = losses * 8 / 24;

    final double losses16 = losses * 16 / 24;

    final double dehydration8 = dehydration / 2;

    final double dehydration16 = dehydration / 2;

    final double total8 = maintenance8 + losses8 + dehydration8;

    final double total16 = maintenance16 + losses16 + dehydration16;

    // ----------------------------------------------------------
    // PER OS 1/3
    // ----------------------------------------------------------

    final double oral8 = total8 / 3;
    final double oral16 = total16 / 3;

    // ----------------------------------------------------------
    // В/В 2/3
    // ----------------------------------------------------------

    final double iv8 = total8 * 2 / 3;
    final double iv16 = total16 * 2 / 3;

    // ----------------------------------------------------------
    // NaCl 0,9% : Глюкоза 5% = 1 : 1
    // ----------------------------------------------------------

    final double nacl8 = iv8 / 2;
    final double glucose8 = iv8 / 2;

    final double nacl16 = iv16 / 2;
    final double glucose16 = iv16 / 2;

    // ----------------------------------------------------------
    // СКОРОСТЬ
    // ----------------------------------------------------------

    final double rate8 = iv8 / 8;
    final double rate16 = iv16 / 16;

    final double naclRate8 = nacl8 / 8;
    final double glucoseRate8 = glucose8 / 8;

    final double naclRate16 = nacl16 / 16;
    final double glucoseRate16 = glucose16 / 16;

    // ----------------------------------------------------------
    // СОХРАНЕНИЕ
    // ----------------------------------------------------------

    setState(() {
      weight = kg;

      maintenancePerDay = maintenance;
      dehydrationVolume = dehydration;
      pathologicalLosses = losses;
      totalPerDay = total;

      oralPerDay = oral;
      ivPerDay = iv;

      first8Total = total8;
      next16Total = total16;

      first8Oral = oral8;
      next16Oral = oral16;

      first8Iv = iv8;
      next16Iv = iv16;

      first8NaCl = nacl8;
      first8Glucose = glucose8;

      next16NaCl = nacl16;
      next16Glucose = glucose16;

      first8Rate = rate8;
      next16Rate = rate16;

      first8NaClRate = naclRate8;
      first8GlucoseRate = glucoseRate8;

      next16NaClRate = naclRate16;
      next16GlucoseRate = glucoseRate16;

      calculated = true;
    });
  }

  // ============================================================
  // ОЧИСТКА
  // ============================================================

  void clearAll() {
    setState(() {
      yearsController.clear();
      monthsController.clear();
      weightController.clear();

      temperatureController.text = '36.6';
      respiratoryRateController.clear();
      stoolCountController.text = '0';
      oralIntakeController.clear();

      dehydrationDegree = 0;
      vomiting = false;
      diarrhea = false;
      diarrheaSeverity = 1;
      intestinalParesis = false;
      paresisDegree = 2;
      edema = false;

      calculated = false;
      errorText = null;
    });
  }

  // ============================================================
  // UI: TEXT FIELD
  // ============================================================

  Widget inputField({
    required String label,
    required String suffix,
    required TextEditingController controller,
    String? hint,
    bool decimal = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ============================================================
  // UI: РАЗДЕЛ
  // ============================================================

  Widget sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // UI: КНОПКА ВЫБОРА
  // ============================================================

  Widget selectionButton({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF355B70) : const Color(0xFF202020),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF86BBD8) : const Color(0xFF343434),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF86BBD8) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UI: TOGGLE
  // ============================================================

  Widget yesNoToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF343434)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text("Нет")),
              ButtonSegment<bool>(value: true, label: Text("Есть")),
            ],
            selected: {value},
            onSelectionChanged: (selection) {
              onChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI: РЕЗУЛЬТАТ-КАРТОЧКА
  // ============================================================

  Widget resultCard({
    required String title,
    required String value,
    String? subtitle,
    IconData icon = Icons.water_drop_outlined,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF343434)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF3F6F8F),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI: ПЕРИОД 8 / 16
  // ============================================================

  Widget periodCard({
    required String title,
    required double total,
    required double oral,
    required double iv,
    required double nacl,
    required double glucose,
    required double rate,
    required double naclRate,
    required double glucoseRate,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          _line("Общий объём", "${formatNumber(total)} мл", bold: true),

          _line("Per os — 1/3", "${formatNumber(oral)} мл"),

          _line("В/в — 2/3", "${formatNumber(iv)} мл"),

          const Divider(height: 22),

          _line("NaCl 0,9%", "${formatNumber(nacl)} мл"),

          _line("Глюкоза 5%", "${formatNumber(glucose)} мл"),

          const Divider(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF24323A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Скорость В/В",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatNumber(rate)} мл/ч",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _line("NaCl 0,9%", "${formatNumber(naclRate)} мл/ч"),

          _line("Глюкоза 5%", "${formatNumber(glucoseRate)} мл/ч"),
        ],
      ),
    );
  }

  Widget _line(String left, String right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.white : Colors.white70,
              ),
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI: СТЕПЕНЬ ОБЕЗВОЖИВАНИЯ
  // ============================================================

  Widget dehydrationSection() {
    return Column(
      children: [
        selectionButton(
          title: "Нет обезвоживания",
          subtitle: "Нет клинических признаков дегидратации",
          selected: dehydrationDegree == 0,
          onTap: () {
            setState(() {
              dehydrationDegree = 0;
            });
          },
        ),

        selectionButton(
          title: "I степень — лёгкая",
          subtitle:
              "Жажда, сухость слизистых, умеренная слабость; "
              "диурез обычно сохранён",
          selected: dehydrationDegree == 1,
          onTap: () {
            setState(() {
              dehydrationDegree = 1;
            });
          },
        ),

        selectionButton(
          title: "II степень — средняя",
          subtitle:
              "Выраженная жажда, сухие слизистые, запавшие глаза, "
              "снижение тургора, тахикардия, уменьшение диуреза",
          selected: dehydrationDegree == 2,
          onTap: () {
            setState(() {
              dehydrationDegree = 2;
            });
          },
        ),

        selectionButton(
          title: "III степень — тяжёлая",
          subtitle:
              "Резкая вялость/угнетение сознания, холодные конечности, "
              "резко сниженный тургор, выраженное снижение диуреза, "
              "нарушение микроциркуляции, возможный шок",
          selected: dehydrationDegree == 3,
          onTap: () {
            setState(() {
              dehydrationDegree = 3;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // UI: ОШИБКА
  // ============================================================

  Widget errorCard() {
    if (errorText == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF351F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6D3A3A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI: BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("👶 ", style: TextStyle(fontSize: 21)),
            Text(
              "Инфузия у детей",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Очистить",
            onPressed: clearAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ЗАГОЛОВОК
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Text("👶", style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Расчёт инфузионной терапии "
                      "от 1 месяца до взрослого возраста",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // ПАЦИЕНТ
            // ==================================================
            sectionTitle(
              "Пациент",
              subtitle: "Введите возраст и фактическую массу тела",
            ),

            Row(
              children: [
                Expanded(
                  child: inputField(
                    label: "Лет",
                    suffix: "г",
                    controller: yearsController,
                    hint: "Например 2",
                    decimal: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: inputField(
                    label: "Месяцев",
                    suffix: "мес",
                    controller: monthsController,
                    hint: "0–11",
                    decimal: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            inputField(
              label: "Масса тела",
              suffix: "кг",
              controller: weightController,
              hint: "Например 12,5",
            ),

            // ==================================================
            // ОБЕЗВОЖИВАНИЕ
            // ==================================================
            sectionTitle(
              "Степень обезвоживания",
              subtitle: "Выберите клиническую степень дегидратации",
            ),

            dehydrationSection(),

            // ==================================================
            // ЖТПП
            // ==================================================
            sectionTitle(
              "Текущие патологические потери",
              subtitle:
                  "Температуру и ЧДД вводите вручную; "
                  "остальное выбирается",
            ),

            Row(
              children: [
                Expanded(
                  child: inputField(
                    label: "Температура",
                    suffix: "°C",
                    controller: temperatureController,
                    hint: "36,6",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: inputField(
                    label: "ЧДД",
                    suffix: "/мин",
                    controller: respiratoryRateController,
                    hint: "Например 42",
                    decimal: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Builder(
              builder: (context) {
                final int ageMonths = getTotalMonths();

                if (ageMonths > 0) {
                  final int normal = respiratoryReference(ageMonths);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "Ориентировочная возрастная ЧДД: "
                      "$normal/мин",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),

            yesNoToggle(
              title: "Рвота",
              value: vomiting,
              onChanged: (value) {
                setState(() {
                  vomiting = value;
                });
              },
            ),

            yesNoToggle(
              title: "Жидкий стул",
              value: diarrhea,
              onChanged: (value) {
                setState(() {
                  diarrhea = value;
                });
              },
            ),

            if (diarrhea) ...[
              const SizedBox(height: 2),

              Row(
                children: [
                  Expanded(
                    child: inputField(
                      label: "Дефекаций за 12 ч",
                      suffix: "раз",
                      controller: stoolCountController,
                      decimal: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Характер стула",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment<int>(value: 1, label: Text("Лёгкий")),
                            ButtonSegment<int>(
                              value: 2,
                              label: Text("Профузный"),
                            ),
                          ],
                          selected: {diarrheaSeverity},
                          onSelectionChanged: (selection) {
                            setState(() {
                              diarrheaSeverity = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            yesNoToggle(
              title: "Парез кишечника",
              value: intestinalParesis,
              onChanged: (value) {
                setState(() {
                  intestinalParesis = value;
                });
              },
            ),

            if (intestinalParesis)
              Column(
                children: [
                  selectionButton(
                    title: "II степень",
                    subtitle: "Живот вздут, единичные перистальтические шумы",
                    selected: paresisDegree == 2,
                    onTap: () {
                      setState(() {
                        paresisDegree = 2;
                      });
                    },
                  ),
                  selectionButton(
                    title: "III степень",
                    subtitle:
                        "Выраженное вздутие, отсутствует перистальтика, "
                        "возможна рвота кишечным содержимым",
                    selected: paresisDegree == 3,
                    onTap: () {
                      setState(() {
                        paresisDegree = 3;
                      });
                    },
                  ),
                ],
              ),

            yesNoToggle(
              title: "Отеки / необходимость уменьшить ЖП",
              value: edema,
              onChanged: (value) {
                setState(() {
                  edema = value;
                });
              },
            ),

            // ==================================================
            // PER OS
            // ==================================================
            sectionTitle(
              "Поступление жидкости",
              subtitle: "В расчётной схеме: 1/3 per os и 2/3 в/в",
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF343434)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_drink_outlined, color: Color(0xFF86BBD8)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Для автоматического расчёта "
                      "используется фиксированное соотношение "
                      "1/3 per os : 2/3 внутривенно.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // КНОПКИ
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: calculate,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text(
                        "Рассчитать",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F6F8F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: OutlinedButton(
                    onPressed: clearAll,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.clear),
                  ),
                ),
              ],
            ),

            errorCard(),

            // ==================================================
            // РЕЗУЛЬТАТ
            // ==================================================
            if (calculated) ...[
              sectionTitle("Результат за сутки"),

              resultCard(
                title: "ЖП — жизненная потребность",
                value: "${formatNumber(maintenancePerDay!)} мл/сут",
                subtitle: "Физиологическая потребность",
                icon: Icons.water_drop_outlined,
              ),

              resultCard(
                title: "ЖВО — восполнение обезвоживания",
                value: "${formatNumber(dehydrationVolume!)} мл/сут",
                subtitle: dehydrationDegree == 0
                    ? "Обезвоживание не выбрано"
                    : "С учётом возраста и степени дегидратации",
                icon: Icons.opacity_outlined,
              ),

              resultCard(
                title: "ЖТПП — патологические потери",
                value: "${formatNumber(pathologicalLosses!)} мл/сут",
                subtitle: "Температура, ЧДД, рвота, стул, парез",
                icon: Icons.trending_down_outlined,
              ),

              resultCard(
                title: "Общая потребность",
                value: "${formatNumber(totalPerDay!)} мл/сут",
                subtitle: "ЖП + ЖВО + ЖТПП",
                icon: Icons.calculate_outlined,
              ),

              const SizedBox(height: 4),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF24323A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3F6F8F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "СУТОЧНОЕ РАСПРЕДЕЛЕНИЕ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _line(
                      "Per os — 1/3",
                      "${formatNumber(oralPerDay!)} мл/сут",
                      bold: true,
                    ),
                    _line(
                      "В/в — 2/3",
                      "${formatNumber(ivPerDay!)} мл/сут",
                      bold: true,
                    ),
                    const Divider(height: 20),
                    _line("NaCl 0,9%", "${formatNumber(ivPerDay! / 2)} мл/сут"),
                    _line(
                      "Глюкоза 5%",
                      "${formatNumber(ivPerDay! / 2)} мл/сут",
                    ),
                  ],
                ),
              ),

              sectionTitle("Первые 8 часов"),

              periodCard(
                title: "🕗 Первые 8 часов",
                total: first8Total!,
                oral: first8Oral!,
                iv: first8Iv!,
                nacl: first8NaCl!,
                glucose: first8Glucose!,
                rate: first8Rate!,
                naclRate: first8NaClRate!,
                glucoseRate: first8GlucoseRate!,
              ),

              sectionTitle("Последующие 16 часов"),

              periodCard(
                title: "🕓 Последующие 16 часов",
                total: next16Total!,
                oral: next16Oral!,
                iv: next16Iv!,
                nacl: next16NaCl!,
                glucose: next16Glucose!,
                rate: next16Rate!,
                naclRate: next16NaClRate!,
                glucoseRate: next16GlucoseRate!,
              ),

              // =================================================
              // ПРЕДУПРЕЖДЕНИЕ
              // =================================================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF241F18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5A4930)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Расчёт является ориентировочным. "
                        "Он не заменяет оценку гемодинамики, "
                        "электролитов, гликемии, диуреза и "
                        "фактических потерь. При шоке, тяжёлых "
                        "электролитных нарушениях, сердечной/почечной "
                        "недостаточности и других особых состояниях "
                        "объём и состав инфузии требуют индивидуальной коррекции.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Расчётная схема: ЖП + ЖВО + ЖТПП. "
                "ЖП распределяется равномерно. "
                "ЖВО в данном калькуляторе разделяется "
                "поровну между первыми 8 и последующими 16 часами. "
                "Соотношение 1/3 per os : 2/3 в/в и "
                "NaCl 0,9% : глюкоза 5% = 1 : 1 "
                "задано согласно выбранной для приложения схеме.",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  height: 1.45,
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
