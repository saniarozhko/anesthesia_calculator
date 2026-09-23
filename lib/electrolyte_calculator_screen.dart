import 'package:flutter/material.dart';

class ElectrolyteCalculatorScreen extends StatefulWidget {
  const ElectrolyteCalculatorScreen({super.key});

  @override
  State<ElectrolyteCalculatorScreen> createState() =>
      _ElectrolyteCalculatorScreenState();
}

class _ElectrolyteCalculatorScreenState
    extends State<ElectrolyteCalculatorScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _resultsKey = GlobalKey();

  final TextEditingController yearsController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final TextEditingController sodiumController = TextEditingController();
  final TextEditingController sodiumTargetController = TextEditingController(
    text: '140',
  );
  final TextEditingController sodiumMaxRiseController = TextEditingController(
    text: '8',
  );

  final TextEditingController potassiumController = TextEditingController();
  final TextEditingController potassiumTargetController = TextEditingController(
    text: '4.0',
  );

  final TextEditingController chlorideController = TextEditingController();
  final TextEditingController chlorideTargetController = TextEditingController(
    text: '103',
  );

  final TextEditingController calciumController = TextEditingController();

  final TextEditingController magnesiumController = TextEditingController();

  bool female = false;
  bool centralLine = false;
  bool ionizedCalcium = true;

  // false = обычная коррекция
  // true = тяжёлая / симптомная гипомагниемия
  bool severeMagnesium = false;

  String? errorText;

  NaResult? naResult;
  KResult? kResult;
  ClResult? clResult;
  CaResult? caResult;
  MgResult? mgResult;

  @override
  void dispose() {
    _scrollController.dispose();

    yearsController.dispose();
    monthsController.dispose();
    weightController.dispose();

    sodiumController.dispose();
    sodiumTargetController.dispose();
    sodiumMaxRiseController.dispose();

    potassiumController.dispose();
    potassiumTargetController.dispose();

    chlorideController.dispose();
    chlorideTargetController.dispose();

    calciumController.dispose();

    magnesiumController.dispose();

    super.dispose();
  }

  double? parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim());
  }

  int parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  int get ageMonths {
    return parseInt(yearsController.text) * 12 +
        parseInt(monthsController.text);
  }

  bool get isChild {
    return ageMonths < 216;
  }

  double get tbwFactor {
    if (isChild) {
      return 0.60;
    }

    return female ? 0.50 : 0.60;
  }

  String format(double value, {int digits = 1}) {
    if ((value - value.roundToDouble()).abs() < 0.0001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(digits);
  }

  void clearResults() {
    naResult = null;
    kResult = null;
    clResult = null;
    caResult = null;
    mgResult = null;
    errorText = null;
  }

  void calculate() {
    FocusScope.of(context).unfocus();

    setState(clearResults);

    final double? weight = parseDouble(weightController.text);

    if (weight == null || weight <= 0) {
      setState(() {
        errorText = 'Введите корректную массу тела.';
      });
      return;
    }

    final int months = parseInt(monthsController.text);

    if (months < 0 || months > 11) {
      setState(() {
        errorText = 'Количество месяцев должно быть от 0 до 11.';
      });
      return;
    }

    final bool hasNa = sodiumController.text.trim().isNotEmpty;

    final bool hasK = potassiumController.text.trim().isNotEmpty;

    final bool hasCl = chlorideController.text.trim().isNotEmpty;

    final bool hasCa = calciumController.text.trim().isNotEmpty;

    final bool hasMg = magnesiumController.text.trim().isNotEmpty;

    if (!hasNa && !hasK && !hasCl && !hasCa && !hasMg) {
      setState(() {
        errorText = 'Введите хотя бы один электролит.';
      });
      return;
    }

    String? localError;

    // ==========================================================
    // Na
    // ==========================================================

    if (hasNa) {
      final double? current = parseDouble(sodiumController.text);

      final double? target = parseDouble(sodiumTargetController.text);

      final double? maxRise = parseDouble(sodiumMaxRiseController.text);

      if (current == null ||
          target == null ||
          maxRise == null ||
          maxRise <= 0) {
        localError = 'Проверьте значения Na⁺.';
      } else if (current >= target) {
        localError = 'Целевой Na⁺ должен быть выше текущего.';
      } else {
        final double fullDeficit = tbwFactor * weight * (target - current);

        final double safeTarget = (current + maxRise) < target
            ? current + maxRise
            : target;

        final double correctionAmount =
            tbwFactor * weight * (safeTarget - current);

        const double naInNacl09 = 0.154;
        const double naInNacl10 = 1.711;

        final double volume09 = correctionAmount / naInNacl09;

        final double volume10 = correctionAmount / naInNacl10;

        naResult = NaResult(
          fullDeficit: fullDeficit,
          correctionAmount: correctionAmount,
          safeTarget: safeTarget,
          allowedRise: safeTarget - current,
          volume09: volume09,
          volume10: volume10,
          rate09: volume09 / 24,
          rate10: volume10 / 24,
        );
      }
    }

    // ==========================================================
    // K
    // ==========================================================

    if (hasK && localError == null) {
      final double? current = parseDouble(potassiumController.text);

      final double? target = parseDouble(potassiumTargetController.text);

      if (current == null || target == null) {
        localError = 'Проверьте значения K⁺.';
      } else if (current >= target) {
        localError = 'Целевой K⁺ должен быть выше текущего.';
      } else {
        final double deficit = 0.4 * weight * (target - current);

        const double kclMmolPerMl = 1.0;

        final double volumeKcl = deficit / kclMmolPerMl;

        final double maxRate = isChild ? weight * 0.2 : (centralLine ? 20 : 10);

        final double rate = maxRate;

        final double duration = rate > 0 ? deficit / rate : 0;

        kResult = KResult(
          deficit: deficit,
          volumeKcl: volumeKcl,
          rate: rate,
          duration: duration,
        );
      }
    }

    // ==========================================================
    // Cl
    // ==========================================================

    if (hasCl && localError == null) {
      final double? current = parseDouble(chlorideController.text);

      final double? target = parseDouble(chlorideTargetController.text);

      if (current == null || target == null) {
        localError = 'Проверьте значения Cl⁻.';
      } else if (current >= target) {
        localError = 'Целевой Cl⁻ должен быть выше текущего.';
      } else {
        final double deficit = tbwFactor * weight * (target - current);

        const double clNacl09 = 0.154;
        const double clNacl10 = 1.711;

        final double volume09 = deficit / clNacl09;

        final double volume10 = deficit / clNacl10;

        clResult = ClResult(
          deficit: deficit,
          volume09: volume09,
          volume10: volume10,
          rate09: volume09 / 24,
          rate10: volume10 / 24,
        );
      }
    }

    // ==========================================================
    // Ca
    // ==========================================================

    if (hasCa && localError == null) {
      final double? current = parseDouble(calciumController.text);

      if (current == null) {
        localError = 'Проверьте значение Ca²⁺.';
      } else {
        final bool low = ionizedCalcium ? current < 1.10 : current < 2.10;

        if (!low) {
          localError =
              'Введённый Ca не соответствует гипокальциемии '
              'по выбранному типу анализа.';
        } else {
          final double calciumGluconateMg = isChild ? weight * 44.5 : 1500;

          final double calciumGluconateMl = calciumGluconateMg / 100;

          final double elementalCaMmol = calciumGluconateMl * 0.465;

          final double calciumChlorideMl = elementalCaMmol / 1.36;

          caResult = CaResult(
            calciumGluconateMg: calciumGluconateMg,
            calciumGluconateMl: calciumGluconateMl,
            elementalCaMmol: elementalCaMmol,
            calciumChlorideMl: calciumChlorideMl,
            pediatric: isChild,
          );
        }
      }
    }

    // ==========================================================
    // Mg
    // ==========================================================

    if (hasMg && localError == null) {
      final double? current = parseDouble(magnesiumController.text);

      if (current == null || current < 0) {
        localError = 'Проверьте значение Mg²⁺.';
      } else {
        // Ориентировочная граница гипомагниемии.
        // Референс конкретной лаборатории может отличаться.
        if (current >= 0.70) {
          localError =
              'Введённый Mg²⁺ не соответствует гипомагниемии '
              'по выбранному ориентиру.';
        } else {
          double doseMmol;

          if (isChild) {
            // Педиатрическая IV коррекция:
            // обычная коррекция — 0,2 ммоль/кг.
            // тяжёлая / симптомная — до 0,4 ммоль/кг.
            doseMmol = weight * (severeMagnesium ? 0.4 : 0.2);

            // Максимум 8 ммоль.
            if (doseMmol > 8) {
              doseMmol = 8;
            }
          } else {
            // Взрослые.
            //
            // Обычная коррекция:
            // 1 г MgSO4 ≈ 4,06 ммоль Mg²+.
            //
            // Тяжёлая / симптомная:
            // 4 г MgSO4 ≈ 16,24 ммоль Mg²+.
            doseMmol = severeMagnesium ? 16.24 : 4.06;
          }

          // ==================================================
          // MgSO4 25%
          //
          // 25% раствор:
          // 250 мг MgSO4 / мл
          // ≈ 1 ммоль Mg²+ / мл
          //
          // Поэтому:
          // объём (мл) = доза (ммоль) / 1
          // ==================================================

          const double mmolPerMl = 1.0;
          const double mgPerMl = 250.0;

          final double volume25 = doseMmol / mmolPerMl;

          final double magnesiumSulfateMg = volume25 * mgPerMl;

          final double magnesiumSulfateG = magnesiumSulfateMg / 1000;

          double infusionHours;

          if (isChild) {
            // Ориентировочное медленное введение.
            infusionHours = severeMagnesium ? 2.0 : 4.0;
          } else {
            infusionHours = severeMagnesium ? 10.0 / 60.0 : 1.0;
          }

          final double mlPerHour = volume25 / infusionHours;

          mgResult = MgResult(
            current: current,
            doseMmol: doseMmol,
            magnesiumSulfateMg: magnesiumSulfateMg,
            magnesiumSulfateG: magnesiumSulfateG,
            volume25: volume25,
            infusionHours: infusionHours,
            mlPerHour: mlPerHour,
            pediatric: isChild,
            severe: severeMagnesium,
          );
        }
      }
    }

    if (localError != null) {
      setState(() {
        errorText = localError;
      });
      return;
    }

    if (naResult != null ||
        kResult != null ||
        clResult != null ||
        caResult != null ||
        mgResult != null) {
      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? context = _resultsKey.currentContext;

        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            alignment: 0.04,
          );
        }
      });
    }
  }

  // ==========================================================
  // INPUT
  // ==========================================================

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

  Widget sectionTitle(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF3F6F8F),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget resultCard({
    required String title,
    required String value,
    String? subtitle,
    IconData icon = Icons.water_drop_outlined,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF343434)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF3F6F8F),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget warning(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF241F18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5A4930)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NA RESULT
  // ==========================================================

  Widget sodiumResult() {
    if (naResult == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Na⁺ — натрий',
          'Коррекция ограничена выбранным приростом за 24 часа',
          Icons.water_drop_outlined,
        ),
        resultCard(
          title: 'Дефицит Na⁺',
          value: '${format(naResult!.fullDeficit)} ммоль',
          subtitle: 'Полный расчётный дефицит.',
        ),
        resultCard(
          title: 'NaCl 0,9%',
          value: '${format(naResult!.volume09)} мл',
          subtitle: '${format(naResult!.rate09, digits: 2)} мл/ч',
        ),
        resultCard(
          title: 'NaCl 10%',
          value: '${format(naResult!.volume10, digits: 2)} мл',
          subtitle: '${format(naResult!.rate10, digits: 2)} мл/ч',
        ),
        warning(
          'Расчёт объёма для коррекции ограничен приростом '
          '+${format(naResult!.allowedRise)} ммоль/л за 24 ч. '
          'Расчётный безопасный целевой Na⁺: '
          '${format(naResult!.safeTarget)} ммоль/л. '
          'Фактический Na⁺ необходимо повторно контролировать.',
        ),
      ],
    );
  }

  // ==========================================================
  // K RESULT
  // ==========================================================

  Widget potassiumResult() {
    if (kResult == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'K⁺ — калий',
          'Расчёт дефицита KCl 7,5%',
          Icons.bolt_outlined,
        ),
        resultCard(
          title: 'Дефицит K⁺',
          value: '${format(kResult!.deficit)} ммоль',
          icon: Icons.bolt_outlined,
        ),
        resultCard(
          title: 'KCl 7,5%',
          value: '${format(kResult!.volumeKcl, digits: 2)} мл',
          subtitle:
              '${format(kResult!.rate, digits: 2)} мл/ч '
              'концентрата при расчётной максимальной скорости',
        ),
        warning(
          'KCl 7,5% не вводить болюсом. Нужны разведение, '
          'инфузомат и контроль K⁺/ЭКГ. Скорость зависит от '
          'концентрации приготовленного раствора и венозного доступа.',
        ),
      ],
    );
  }

  // ==========================================================
  // CL RESULT
  // ==========================================================

  Widget chlorideResult() {
    if (clResult == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Cl⁻ — хлор',
          'Расчёт дефицита и NaCl',
          Icons.science_outlined,
        ),
        resultCard(
          title: 'Дефицит Cl⁻',
          value: '${format(clResult!.deficit)} ммоль',
          icon: Icons.science_outlined,
        ),
        resultCard(
          title: 'NaCl 0,9%',
          value: '${format(clResult!.volume09)} мл',
          subtitle: '${format(clResult!.rate09, digits: 2)} мл/ч',
        ),
        resultCard(
          title: 'NaCl 10%',
          value: '${format(clResult!.volume10, digits: 2)} мл',
          subtitle: '${format(clResult!.rate10, digits: 2)} мл/ч',
        ),
        warning(
          'При гипохлоремии необходимо учитывать причину '
          'нарушения, объёмный статус и кислотно-основное состояние.',
        ),
      ],
    );
  }

  // ==========================================================
  // CA RESULT
  // ==========================================================

  Widget calciumResult() {
    if (caResult == null) {
      return const SizedBox();
    }

    final double maximumMgPerMinute = caResult!.pediatric ? 100 : 200;

    final double minimumMinutes =
        caResult!.calciumGluconateMg / maximumMgPerMinute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Ca²⁺ — кальций',
          'Расчёт дозы коррекции гипокальциемии',
          Icons.bloodtype_outlined,
        ),
        resultCard(
          title: 'Глюконат кальция 10%',
          value: '${format(caResult!.calciumGluconateMl, digits: 1)} мл',
          subtitle: '${format(caResult!.calciumGluconateMg, digits: 0)} мг',
          icon: Icons.bloodtype_outlined,
        ),
        resultCard(
          title: 'CaCl₂ 10%',
          value: '${format(caResult!.calciumChlorideMl, digits: 1)} мл',
          subtitle: 'Эквивалент по элементарному Ca²⁺',
        ),
        resultCard(
          title: 'Минимальное время введения',
          value: '${format(minimumMinutes, digits: 1)} мин',
          subtitle:
              'Не превышая ${format(maximumMgPerMinute, digits: 0)} мг/мин 10% calcium gluconate',
        ),
        warning(
          '10% calcium gluconate необходимо разводить перед '
          'введением. Контролировать Ca²⁺ и по показаниям ЭКГ. '
          'CaCl₂ содержит больше элементарного кальция на мл '
          'и требует особенно осторожного применения.',
        ),
      ],
    );
  }

  // ==========================================================
  // MG RESULT
  // ==========================================================

  Widget magnesiumResult() {
    if (mgResult == null) {
      return const SizedBox();
    }

    final MgResult result = mgResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Mg²⁺ — магний',
          result.pediatric
              ? 'Педиатрическая IV коррекция гипомагниемии'
              : 'Коррекция гипомагниемии MgSO₄',
          Icons.science_rounded,
        ),

        resultCard(
          title: 'Mg²⁺ текущий',
          value: '${format(result.current, digits: 2)} ммоль/л',
          subtitle: result.severe
              ? 'Выбрана тяжёлая / симптомная гипомагниемия'
              : 'Выбрана обычная коррекция',
          icon: Icons.science_rounded,
        ),

        resultCard(
          title: 'Расчётная доза Mg²⁺',
          value: '${format(result.doseMmol, digits: 2)} ммоль',
          subtitle: result.pediatric
              ? 'Расчёт по массе тела с ограничением максимум 8 ммоль'
              : 'Доза указана как количество Mg²⁺',
          icon: Icons.bolt_outlined,
        ),

        resultCard(
          title: 'MgSO₄ 25%',
          value: '${format(result.volume25, digits: 2)} мл',
          subtitle:
              '${format(result.magnesiumSulfateG, digits: 2)} г MgSO₄ '
              '(${format(result.magnesiumSulfateMg, digits: 0)} мг)',
          icon: Icons.medication_outlined,
        ),

        resultCard(
          title: 'Ориентировочное время введения',
          value: result.infusionHours < 1
              ? '${format(result.infusionHours * 60, digits: 0)} мин'
              : '${format(result.infusionHours, digits: 1)} ч',
          subtitle:
              '${format(result.mlPerHour, digits: 2)} мл/ч '
              'MgSO₄ 25%',
          icon: Icons.timer_outlined,
        ),

        warning(
          result.pediatric
              ? 'Для детей: IV Mg²⁺ обычно 0,1–0,2 ммоль/кг, '
                    'при тяжёлой симптоматике возможно до 0,4 ммоль/кг, '
                    'максимум 8 ммоль. MgSO₄ 25% является концентрированным '
                    'раствором и перед введением должен быть разведен '
                    'согласно локальному протоколу. Контролировать Mg²⁺, '
                    'АД, ЧДД и диурез.'
              : 'При тяжёлой/симптомной гипомагниемии требуется '
                    'внутривенная коррекция под мониторингом. MgSO₄ 25% '
                    'является концентрированным раствором и перед IV '
                    'введением должен быть разведён согласно локальному '
                    'протоколу. Особая осторожность при снижении функции '
                    'почек, олигурии и анурии. Контролировать Mg²⁺, АД, '
                    'ЧДД, рефлексы и ЭКГ по показаниям.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡ ', style: TextStyle(fontSize: 20)),
            Text(
              'Электролитный расчёт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Очистить',
            onPressed: () {
              setState(() {
                yearsController.clear();
                monthsController.clear();
                weightController.clear();

                sodiumController.clear();
                sodiumTargetController.text = '140';
                sodiumMaxRiseController.text = '8';

                potassiumController.clear();
                potassiumTargetController.text = '4.0';

                chlorideController.clear();
                chlorideTargetController.text = '103';

                calciumController.clear();

                magnesiumController.clear();

                female = false;
                centralLine = false;
                ionizedCalcium = true;
                severeMagnesium = false;

                clearResults();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
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
                  Text('⚡', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Электролитный расчёт '
                      'для детей и взрослых',
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
            // PATIENT
            // ==================================================
            sectionTitle(
              'Пациент',
              'Введите возраст и массу тела.',
              Icons.person_outline,
            ),

            Row(
              children: [
                Expanded(
                  child: inputField(
                    label: 'Лет',
                    suffix: 'г',
                    controller: yearsController,
                    hint: '45',
                    decimal: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: inputField(
                    label: 'Месяцев',
                    suffix: 'мес',
                    controller: monthsController,
                    hint: '0',
                    decimal: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            inputField(
              label: 'Масса тела',
              suffix: 'кг',
              controller: weightController,
              hint: '80',
            ),

            const SizedBox(height: 12),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Мужчина'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Женщина'),
                  icon: Icon(Icons.female),
                ),
              ],
              selected: {female},
              onSelectionChanged: (selection) {
                setState(() {
                  female = selection.first;
                });
              },
            ),

            // ==================================================
            // NA
            // ==================================================
            sectionTitle(
              'Na⁺ — натрий',
              'Оставьте пустым, если Na⁺ не требуется считать.',
              Icons.water_drop_outlined,
            ),

            inputField(
              label: 'Na⁺ текущий',
              suffix: 'ммоль/л',
              controller: sodiumController,
              hint: '120',
            ),

            const SizedBox(height: 10),

            inputField(
              label: 'Целевой Na⁺',
              suffix: 'ммоль/л',
              controller: sodiumTargetController,
              hint: '140',
            ),

            const SizedBox(height: 10),

            inputField(
              label: 'Максимальный прирост за 24 ч',
              suffix: 'ммоль/л',
              controller: sodiumMaxRiseController,
              hint: '8',
            ),

            // ==================================================
            // K
            // ==================================================
            sectionTitle(
              'K⁺ — калий',
              'Оставьте пустым, если K⁺ не требуется считать.',
              Icons.bolt_outlined,
            ),

            inputField(
              label: 'K⁺ текущий',
              suffix: 'ммоль/л',
              controller: potassiumController,
              hint: '2,8',
            ),

            const SizedBox(height: 10),

            inputField(
              label: 'Целевой K⁺',
              suffix: 'ммоль/л',
              controller: potassiumTargetController,
              hint: '4,0',
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Венозный доступ для KCl',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Периферический'),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Центральный'),
                      ),
                    ],
                    selected: {centralLine},
                    onSelectionChanged: (selection) {
                      setState(() {
                        centralLine = selection.first;
                      });
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // CL
            // ==================================================
            sectionTitle(
              'Cl⁻ — хлор',
              'Оставьте пустым, если Cl⁻ не требуется считать.',
              Icons.science_outlined,
            ),

            inputField(
              label: 'Cl⁻ текущий',
              suffix: 'ммоль/л',
              controller: chlorideController,
              hint: '88',
            ),

            const SizedBox(height: 10),

            inputField(
              label: 'Целевой Cl⁻',
              suffix: 'ммоль/л',
              controller: chlorideTargetController,
              hint: '103',
            ),

            // ==================================================
            // CA
            // ==================================================
            sectionTitle(
              'Ca²⁺ — кальций',
              'Оставьте пустым, если Ca²⁺ не требуется считать.',
              Icons.bloodtype_outlined,
            ),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Ионизированный')),
                ButtonSegment<bool>(value: false, label: Text('Общий')),
              ],
              selected: {ionizedCalcium},
              onSelectionChanged: (selection) {
                setState(() {
                  ionizedCalcium = selection.first;
                });
              },
            ),

            const SizedBox(height: 10),

            inputField(
              label: ionizedCalcium ? 'iCa²⁺' : 'Общий Ca',
              suffix: 'ммоль/л',
              controller: calciumController,
              hint: ionizedCalcium ? '0,88' : '1,75',
            ),

            // ==================================================
            // MG
            // ==================================================
            sectionTitle(
              'Mg²⁺ — магний',
              'Оставьте пустым, если Mg²⁺ не требуется считать.',
              Icons.science_rounded,
            ),

            inputField(
              label: 'Mg²⁺ текущий',
              suffix: 'ммоль/л',
              controller: magnesiumController,
              hint: '0,55',
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выраженность гипомагниемии',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('Обычная')),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Тяжёлая / симптомная'),
                      ),
                    ],
                    selected: {severeMagnesium},
                    onSelectionChanged: (selection) {
                      setState(() {
                        severeMagnesium = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 9),
                  Text(
                    isChild
                        ? 'Дети: 0,2 ммоль/кг при обычной '
                              'коррекции; до 0,4 ммоль/кг при '
                              'тяжёлой симптоматике, максимум 8 ммоль.'
                        : severeMagnesium
                        ? 'Взрослые: расчёт 4 г MgSO₄ '
                              'для тяжёлой/симптомной гипомагниемии.'
                        : 'Взрослые: начальная медленная '
                              'доза 1 г MgSO₄.',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // CALCULATE
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text(
                  'Рассчитать',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            if (errorText != null) ...[
              const SizedBox(height: 12),
              warning(errorText!),
            ],

            // ==================================================
            // RESULTS
            // ==================================================
            if (naResult != null ||
                kResult != null ||
                clResult != null ||
                caResult != null ||
                mgResult != null)
              Container(
                key: _resultsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle(
                      'Результаты',
                      'Показаны только заполненные электролиты.',
                      Icons.analytics_outlined,
                    ),

                    sodiumResult(),
                    potassiumResult(),
                    chlorideResult(),
                    calciumResult(),
                    magnesiumResult(),

                    const SizedBox(height: 18),

                    warning(
                      'Расчёт является вспомогательным инструментом. '
                      'Перед коррекцией электролитов необходимо учитывать '
                      'клиническое состояние, функцию почек, диурез, '
                      'ЭКГ и повторные лабораторные показатели.',
                    ),
                  ],
                ),
              ),

            // ==================================================
            // BOTTOM SPACE
            // ==================================================
            const SizedBox(height: 70),

            const Center(
              child: Text(
                'Электролитный расчёт • вспомогательный инструмент',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// Na RESULT
// ==========================================================

class NaResult {
  final double fullDeficit;
  final double correctionAmount;
  final double safeTarget;
  final double allowedRise;
  final double volume09;
  final double volume10;
  final double rate09;
  final double rate10;

  NaResult({
    required this.fullDeficit,
    required this.correctionAmount,
    required this.safeTarget,
    required this.allowedRise,
    required this.volume09,
    required this.volume10,
    required this.rate09,
    required this.rate10,
  });
}

// ==========================================================
// K RESULT
// ==========================================================

class KResult {
  final double deficit;
  final double volumeKcl;
  final double rate;
  final double duration;

  KResult({
    required this.deficit,
    required this.volumeKcl,
    required this.rate,
    required this.duration,
  });
}

// ==========================================================
// Cl RESULT
// ==========================================================

class ClResult {
  final double deficit;
  final double volume09;
  final double volume10;
  final double rate09;
  final double rate10;

  ClResult({
    required this.deficit,
    required this.volume09,
    required this.volume10,
    required this.rate09,
    required this.rate10,
  });
}

// ==========================================================
// Ca RESULT
// ==========================================================

class CaResult {
  final double calciumGluconateMg;
  final double calciumGluconateMl;
  final double elementalCaMmol;
  final double calciumChlorideMl;
  final bool pediatric;

  CaResult({
    required this.calciumGluconateMg,
    required this.calciumGluconateMl,
    required this.elementalCaMmol,
    required this.calciumChlorideMl,
    required this.pediatric,
  });
}

// ==========================================================
// Mg RESULT
// ==========================================================

class MgResult {
  final double current;
  final double doseMmol;
  final double magnesiumSulfateMg;
  final double magnesiumSulfateG;
  final double volume25;
  final double infusionHours;
  final double mlPerHour;
  final bool pediatric;
  final bool severe;

  MgResult({
    required this.current,
    required this.doseMmol,
    required this.magnesiumSulfateMg,
    required this.magnesiumSulfateG,
    required this.volume25,
    required this.infusionHours,
    required this.mlPerHour,
    required this.pediatric,
    required this.severe,
  });
}
