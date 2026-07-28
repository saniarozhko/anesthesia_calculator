import 'package:flutter/material.dart';

class TidalVolumeScreen extends StatefulWidget {
  const TidalVolumeScreen({super.key});

  @override
  State<TidalVolumeScreen> createState() => _TidalVolumeScreenState();
}

class _TidalVolumeScreenState extends State<TidalVolumeScreen> {
  bool isMale = true;

  final TextEditingController heightController = TextEditingController();

  String result = "";

  final Color activeColor = const Color.fromARGB(255, 134, 187, 216);

  @override
  void dispose() {
    heightController.dispose();

    super.dispose();
  }

  double parse(String value) {
    return double.tryParse(value.replaceAll(",", ".")) ?? 0;
  }

  Widget genderButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: active ? activeColor : Colors.grey[800],

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
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      margin: const EdgeInsets.only(bottom: 20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        result,

        textAlign: TextAlign.center,

        style: const TextStyle(fontSize: 18, height: 1.5),
      ),
    );
  }

  void calculateTidalVolume() {
    double height = parse(heightController.text);

    if (height <= 0) {
      setState(() {
        result = "Введите рост пациента";
      });

      return;
    }

    double inches = height / 2.54;

    double ibw;

    if (isMale) {
      ibw = 50 + 2.3 * (inches - 60);
    } else {
      ibw = 45.5 + 2.3 * (inches - 60);
    }

    double vt4 = ibw * 4;

    double vt5 = ibw * 5;

    double vt6 = ibw * 6;

    double vt7 = ibw * 7;

    double vt8 = ibw * 8;

    setState(() {
      result =
          "🧬 Идеальная масса тела (IBW)\n"
          "${ibw.toStringAsFixed(1)} кг\n\n"
          "🫁 Дыхательный объём:\n\n"
          "4 мл/кг → "
          "${vt4.toStringAsFixed(0)} мл\n"
          "5 мл/кг → "
          "${vt5.toStringAsFixed(0)} мл\n"
          "⭐ 6 мл/кг → "
          "${vt6.toStringAsFixed(0)} мл\n"
          "7 мл/кг → "
          "${vt7.toStringAsFixed(0)} мл\n"
          "8 мл/кг → "
          "${vt8.toStringAsFixed(0)} мл\n\n"
          "Рекомендации:\n"
          "• ARDS: 4–6 мл/кг IBW\n"
          "• Защитная ИВЛ: 6 мл/кг IBW\n"
          "• Обычная ИВЛ: 6–8 мл/кг IBW";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🫁 Дыхательный объём"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),

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
                    "Расчёт по идеальной массе тела",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text("Формула Devine", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                genderButton("👨 Мужчина", isMale, () {
                  setState(() {
                    isMale = true;
                  });
                }),

                const SizedBox(width: 10),

                genderButton("👩 Женщина", !isMale, () {
                  setState(() {
                    isMale = false;
                  });
                }),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: heightController,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                labelText: "Рост",

                suffixText: "см",

                filled: true,

                fillColor: const Color(0xFF1E1E1E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              height: 60,

              child: ElevatedButton(
                onPressed: calculateTidalVolume,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8FBF),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: const Text(
                  "РАССЧИТАТЬ",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),

              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,

                  axisAlignment: -1,

                  child: FadeTransition(opacity: animation, child: child),
                );
              },

              child: result.isEmpty
                  ? const SizedBox.shrink(key: ValueKey("empty"))
                  : resultCard(),
            ),
          ],
        ),
      ),
    );
  }
}
