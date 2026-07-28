import 'package:flutter/material.dart';

class HuntHessScreen extends StatefulWidget {
  const HuntHessScreen({super.key});

  @override
  State<HuntHessScreen> createState() => _HuntHessScreenState();
}

class _HuntHessScreenState extends State<HuntHessScreen> {
  int? selectedIndex;

  final List<Map<String, dynamic>> levels = [
    {
      "score": "0",
      "title": "Неразорвавшаяся аневризма",
      "desc": "САК отсутствует",
      "risk": "—",
    },
    {
      "score": "I",
      "title": "Лёгкая симптоматика",
      "desc": "Головная боль, ригидность шеи",
      "risk": "Хороший прогноз",
    },
    {
      "score": "II",
      "title": "Умеренная симптоматика",
      "desc": "Выраженная головная боль, без очагового дефицита",
      "risk": "Благоприятный прогноз",
    },
    {
      "score": "III",
      "title": "Сонливость",
      "desc": "Спутанность сознания, лёгкий дефицит",
      "risk": "Промежуточный риск",
    },
    {
      "score": "IV",
      "title": "Тяжёлое состояние",
      "desc": "Ступор, выраженный неврологический дефицит",
      "risk": "Высокий риск",
    },
    {
      "score": "V",
      "title": "Кома",
      "desc": "Глубокое угнетение сознания",
      "risk": "Очень высокий риск",
    },
  ];

  Widget levelCard(Map<String, dynamic> item, int index) {
    bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.symmetric(vertical: 6),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: active ? const Color(0xFF90CAF9) : const Color(0xFF252525),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: active ? const Color(0xFF90CAF9) : Colors.transparent,

            width: 2,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 55,

              height: 55,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: active ? Colors.white : const Color(0xFF37474F),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Text(
                item["score"],

                style: TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,

                  color: active ? Colors.blue : Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    item["title"],

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight: FontWeight.bold,

                      color: active ? Colors.black : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item["desc"],

                    style: TextStyle(
                      fontSize: 14,

                      color: active ? Colors.black87 : Colors.grey[400],
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

  Widget resultBlock() {
    if (selectedIndex == null) {
      return const SizedBox();
    }

    final item = levels[selectedIndex!];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),

      child: Container(
        key: ValueKey(selectedIndex),

        width: double.infinity,

        padding: const EdgeInsets.all(14),

        margin: const EdgeInsets.only(top: 12),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: const Color(0xFF90CAF9)),
        ),

        child: Column(
          children: [
            Text(
              "Hunt–Hess ${item["score"]}",

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              item["risk"],

              style: const TextStyle(
                color: Color(0xFF90CAF9),

                fontSize: 17,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Hunt–Hess — САК"),

        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 10),

                  itemCount: levels.length,

                  itemBuilder: (context, index) {
                    return levelCard(levels[index], index);
                  },
                ),
              ),

              resultBlock(),

              // запас снизу
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
