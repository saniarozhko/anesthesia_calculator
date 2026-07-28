import 'package:flutter/material.dart';

class ParklandScreen extends StatefulWidget {
  const ParklandScreen({super.key});

  @override
  State<ParklandScreen> createState() => _ParklandScreenState();
}

class _ParklandScreenState extends State<ParklandScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController weightController = TextEditingController();

  final TextEditingController burnController = TextEditingController();

  final TextEditingController timeController = TextEditingController();

  double? total24;

  double? first8;

  double? next16;

  double? remaining;

  double? rate;

  String error = "";

  void scrollToResult() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 600),

          curve: Curves.easeOut,
        );
      }
    });
  }

  double parseNumber(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;
  }

  void calculate() {
    double weight = parseNumber(weightController);

    double burn = parseNumber(burnController);

    double hours = parseNumber(timeController);

    if (weight <= 0 || burn <= 0 || hours < 0) {
      setState(() {
        error = "⚠️ Проверьте введённые данные";
      });

      scrollToResult();

      return;
    }

    if (hours > 24) {
      setState(() {
        error = "⚠️ Время от ожога не может быть больше 24 часов";
      });

      scrollToResult();

      return;
    }

    error = "";

    double volume24 = 4 * weight * burn;

    double volumeFirst8 = volume24 / 2;

    double volumeNext16 = volume24 / 2;

    double currentRemaining = 0;

    double currentRate = 0;

    if (hours < 8) {
      double alreadyGiven = volumeFirst8 * (hours / 8);

      currentRemaining = volumeFirst8 - alreadyGiven;

      double leftHours = 8 - hours;

      currentRate = currentRemaining / leftHours;
    } else if (hours < 24) {
      double secondPeriodHours = hours - 8;

      double alreadySecond = volumeNext16 * (secondPeriodHours / 16);

      currentRemaining = volumeNext16 - alreadySecond;

      double leftHours = 16 - secondPeriodHours;

      currentRate = currentRemaining / leftHours;
    } else {
      currentRemaining = 0;

      currentRate = 0;
    }

    setState(() {
      total24 = volume24;

      first8 = volumeFirst8;

      next16 = volumeNext16;

      remaining = currentRemaining;

      rate = currentRate;
    });

    scrollToResult();
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: TextField(
        controller: controller,

        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        decoration: InputDecoration(
          labelText: label,

          suffixText: suffix,

          filled: true,

          fillColor: const Color(0xFF252525),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget resultCard() {
    if (total24 == null && error.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFB85C38)),
      ),

      child: error.isNotEmpty
          ? Text(
              error,

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 20),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "🔥 Результат",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text(
                  "Объём за 24 часа: "
                  "${total24!.toStringAsFixed(0)} мл",
                ),

                Text(
                  "Первые 8 часов: "
                  "${first8!.toStringAsFixed(0)} мл",
                ),

                Text(
                  "Следующие 16 часов: "
                  "${next16!.toStringAsFixed(0)} мл",
                ),

                const Divider(),

                Text(
                  "Осталось в текущем периоде: "
                  "${remaining!.toStringAsFixed(0)} мл",
                ),

                const SizedBox(height: 8),

                Text(
                  "Скорость инфузии: "
                  "${rate!.toStringAsFixed(0)} мл/ч",

                  style: const TextStyle(
                    color: Color(0xFF90CAF9),

                    fontWeight: FontWeight.bold,

                    fontSize: 18,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Формула Паркланда"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        controller: _scrollController,

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
                    "Расчёт объёма инфузии при ожогах",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "4 × масса (кг) × % ожога",

                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            inputField("Вес пациента", weightController, "кг"),

            inputField("Площадь ожога TBSA", burnController, "%"),

            inputField("Время от момента ожога", timeController, "ч"),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C38),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                onPressed: calculate,

                child: const Text("Рассчитать", style: TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(height: 20),

            resultCard(),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    weightController.dispose();

    burnController.dispose();

    timeController.dispose();

    super.dispose();
  }
}
