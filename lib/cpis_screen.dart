import 'package:flutter/material.dart';

class CpisScreen extends StatefulWidget {
  const CpisScreen({super.key});

  @override
  State<CpisScreen> createState() => _CpisScreenState();
}

class _CpisScreenState extends State<CpisScreen> {
  int temperature = 0;
  int leukocytes = 0;
  int secretion = 0;
  int oxygenation = 0;
  int xray = 0;
  int microbiology = 0;

  int get total =>
      temperature + leukocytes + secretion + oxygenation + xray + microbiology;

  String get interpretation {
    if (total >= 6) {
      return "Высокая вероятность ВАП";
    } else {
      return "Низкая вероятность ВАП";
    }
  }

  Color get resultColor {
    if (total >= 6) {
      return const Color(0xFFEF9A9A);
    } else {
      return const Color(0xFF90CAF9);
    }
  }

  Widget optionCard(
    String title,
    List<String> options,
    int value,
    Function(int) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF252525),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...List.generate(options.length, (index) {
            bool active = value == index;

            return GestureDetector(
              onTap: () {
                onChanged(index);
              },

              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF546E7A)
                      : const Color(0xFF1E1E1E),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Icon(
                      active ? Icons.check_circle : Icons.circle_outlined,

                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        options[index],

                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🫁 CPIS — ВАП/пневмония"),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),

                children: [
                  optionCard(
                    "🌡 Температура",

                    ["<36.5 или >38.4 °C — 0 баллов", "36.5–38.4 °C — 1 балл"],

                    temperature,

                    (v) {
                      setState(() {
                        temperature = v;
                      });
                    },
                  ),

                  optionCard(
                    "🩸 Лейкоциты",

                    [
                      "≥4000 или ≤11000 — 0 баллов",

                      "<4000 или >11000 — 1 балл",
                    ],

                    leukocytes,

                    (v) {
                      setState(() {
                        leukocytes = v;
                      });
                    },
                  ),

                  optionCard(
                    "🫁 Трахеальный секрет",

                    ["Нет/скудный — 0 баллов", "Обильный гнойный — 1 балл"],

                    secretion,

                    (v) {
                      setState(() {
                        secretion = v;
                      });
                    },
                  ),

                  optionCard(
                    "🩸 Оксигенация PaO₂/FiO₂",

                    [">240 — 0 баллов", "≤240 — 1 балл"],

                    oxygenation,

                    (v) {
                      setState(() {
                        oxygenation = v;
                      });
                    },
                  ),

                  optionCard(
                    "🩻 Рентген грудной клетки",

                    [
                      "Нет инфильтратов — 0 баллов",

                      "Диффузные/очаговые инфильтраты — 1 балл",
                    ],

                    xray,

                    (v) {
                      setState(() {
                        xray = v;
                      });
                    },
                  ),

                  optionCard(
                    "🦠 Микробиология",

                    ["Нет роста — 0 баллов", "Положительный посев — 1 балл"],

                    microbiology,

                    (v) {
                      setState(() {
                        microbiology = v;
                      });
                    },
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),

              curve: Curves.easeOut,

              margin: const EdgeInsets.only(bottom: 20),

              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  Text(
                    "CPIS = $total баллов",

                    style: const TextStyle(
                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    interpretation,

                    style: TextStyle(
                      color: resultColor,

                      fontSize: 18,

                      fontWeight: FontWeight.bold,
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
}
