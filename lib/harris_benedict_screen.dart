import 'package:flutter/material.dart';

class HarrisBenedictScreen extends StatefulWidget {
  const HarrisBenedictScreen({super.key});

  @override
  State<HarrisBenedictScreen> createState() => _HarrisBenedictScreenState();
}

class _HarrisBenedictScreenState extends State<HarrisBenedictScreen> {
  String gender = "";

  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final ageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  double activity = 1.2;

  String result = "";

  final Color activeColor = const Color(0xFF86BBD8);

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  double parse(String value) {
    return double.tryParse(value.replaceAll(",", ".")) ?? 0;
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

  Widget choiceButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),

        child: ElevatedButton(
          onPressed: onTap,

          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? activeColor : Colors.grey[800],

            minimumSize: const Size(0, 50),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          child: Text(text, style: const TextStyle(fontSize: 17)),
        ),
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

        margin: const EdgeInsets.only(top: 20, bottom: 120),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: activeColor),
        ),

        child: Text(
          result,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
      ),
    );
  }

  void calculate() {
    if (gender.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        ageController.text.isEmpty) {
      setState(() {
        result = "⚠️ Заполните все данные";
      });

      return;
    }

    double weight = parse(weightController.text);

    double height = parse(heightController.text);

    double age = parse(ageController.text);

    if (weight <= 0 || height <= 0 || age <= 0) {
      setState(() {
        result = "⚠️ Проверьте введённые данные";
      });

      return;
    }

    double bmr;

    if (gender == "М") {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    double total = bmr * activity;

    setState(() {
      result =
          "🔥 Основной обмен\n"
          "${bmr.toStringAsFixed(0)} ккал/сут\n\n"
          "⚡ Суточная энергопотребность\n"
          "${total.toStringAsFixed(0)} ккал/сут";
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍽 Харрис–Бенедикт"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        controller: scrollController,

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

        child: Column(
          children: [
            const Text(
              "Расчёт энергетической потребности",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

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

            const SizedBox(height: 15),

            inputField("Вес", weightController, "кг"),

            inputField("Рост", heightController, "см"),

            inputField("Возраст", ageController, "лет"),

            const SizedBox(height: 15),

            DropdownButtonFormField<double>(
              value: activity,

              decoration: InputDecoration(
                labelText: "Коэффициент активности",

                filled: true,

                fillColor: const Color(0xFF1E1E1E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              items: const [
                DropdownMenuItem(value: 1.2, child: Text("1.2 — покой")),

                DropdownMenuItem(value: 1.375, child: Text("1.375 — низкая")),

                DropdownMenuItem(value: 1.55, child: Text("1.55 — умеренная")),

                DropdownMenuItem(value: 1.725, child: Text("1.725 — высокая")),
              ],

              onChanged: (v) {
                setState(() {
                  activity = v!;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                onPressed: calculate,

                child: const Text(
                  "РАССЧИТАТЬ",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (result.isNotEmpty) resultCard(),
          ],
        ),
      ),
    );
  }
}
