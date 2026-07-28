import 'package:flutter/material.dart';

class RassScreen extends StatefulWidget {
  const RassScreen({super.key});

  @override
  State<RassScreen> createState() => _RassScreenState();
}

class _RassScreenState extends State<RassScreen> {
  int? selectedScore;

  final ScrollController _scrollController = ScrollController();

  final Color activeColor = const Color.fromARGB(255, 144, 202, 249);

  final List<RassLevel> rassLevels = [
    RassLevel(
      score: 4,
      title: "Буйный, агрессивный",
      description: "Опасен, агрессия, угроза окружающим",
    ),
    RassLevel(
      score: 3,
      title: "Очень возбуждён",
      description: "Тянет трубки/катетеры, пытается встать",
    ),
    RassLevel(
      score: 2,
      title: "Возбуждён",
      description: "Частые бесцельные движения, тревожность",
    ),
    RassLevel(
      score: 1,
      title: "Беспокойный",
      description: "Тревожен, неусидчив, беспокоится",
    ),
    RassLevel(
      score: 0,
      title: "Бодрствует, спокоен",
      description: "Контактный, спокойное поведение",
    ),
    RassLevel(
      score: -1,
      title: "Сонливый",
      description: "Открывает глаза на голос более 10 секунд",
    ),
    RassLevel(
      score: -2,
      title: "Лёгкая седация",
      description: "Пробуждение на голос менее 10 секунд",
    ),
    RassLevel(
      score: -3,
      title: "Умеренная седация",
      description: "Движение или открывание глаз на голос",
    ),
    RassLevel(
      score: -4,
      title: "Глубокая седация",
      description: "Реакция только на физическую стимуляцию",
    ),
    RassLevel(
      score: -5,
      title: "Не пробуждается",
      description: "Нет реакции на голос и физический стимул",
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget rassCard(RassLevel level) {
    final bool active = selectedScore == level.score;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedScore = level.score;
        });

        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? activeColor : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? activeColor : Colors.transparent,
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
                level.score > 0 ? "+${level.score}" : "${level.score}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: active ? const Color(0xFF1565C0) : Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.black : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    level.description,
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

  @override
  Widget build(BuildContext context) {
    final RassLevel? selected = selectedScore == null
        ? null
        : rassLevels.firstWhere((item) => item.score == selectedScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text("😴 RASS — шкала седации"),
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
                    "Richmond Agitation-Sedation Scale",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Выберите уровень седации пациента",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            ...rassLevels.map((level) => rassCard(level)),

            const SizedBox(height: 20),

            if (selected != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: activeColor),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text(
                      "RASS: ${selected.score}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      selected.title,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        color: activeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      selected.description,
                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 15, color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class RassLevel {
  final int score;
  final String title;
  final String description;

  const RassLevel({
    required this.score,
    required this.title,
    required this.description,
  });
}
