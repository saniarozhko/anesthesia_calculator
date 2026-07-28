import 'package:flutter/material.dart';

class KillipScreen extends StatefulWidget {
  const KillipScreen({super.key});

  @override
  State<KillipScreen> createState() => _KillipScreenState();
}

class _KillipScreenState extends State<KillipScreen> {
  int? selected;

  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> classes = [
    {
      "class": "I",
      "title": "Нет сердечной недостаточности",
      "desc": "Нет признаков СН, нет хрипов, нет III тона",
      "risk": "Низкий риск",
    },

    {
      "class": "II",
      "title": "Лёгкая СН",
      "desc": "Хрипы <50% лёгочных полей, III тон, венозная гипертензия",
      "risk": "Умеренный риск",
    },

    {
      "class": "III",
      "title": "Отёк лёгких",
      "desc": "Выраженные влажные хрипы >50% лёгочных полей",
      "risk": "Высокий риск",
    },

    {
      "class": "IV",
      "title": "Кардиогенный шок",
      "desc": "Гипотония, признаки гипоперфузии органов",
      "risk": "Очень высокий риск",
    },
  ];

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  void selectClass(int index) {
    setState(() {
      selected = index;
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

  Widget classCard(Map<String, dynamic> item, int index) {
    bool active = selected == index;

    return GestureDetector(
      onTap: () {
        selectClass(index);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: active ? const Color(0xFFEF9A9A) : const Color(0xFF252525),

          borderRadius: BorderRadius.circular(16),
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
                item["class"],

                style: TextStyle(
                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                  color: active ? Colors.red : Colors.white,
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

  Widget resultCard() {
    if (selected == null) {
      return const SizedBox();
    }

    final result = classes[selected!];

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
        key: ValueKey(selected),

        width: double.infinity,

        margin: const EdgeInsets.only(top: 20, bottom: 120),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: const Color(0xFFEF9A9A)),
        ),

        child: Column(
          children: [
            Text(
              "Killip ${result["class"]}",

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              result["title"],

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(
              result["risk"],

              style: const TextStyle(
                color: Color(0xFFEF9A9A),

                fontSize: 18,

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
        title: const Text("❤️ Killip — СН при ОИМ"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        controller: scrollController,

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(16),
              ),

              child: const Text(
                "Класс Killip при остром инфаркте миокарда",

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            for (int i = 0; i < classes.length; i++) classCard(classes[i], i),

            resultCard(),
          ],
        ),
      ),
    );
  }
}
