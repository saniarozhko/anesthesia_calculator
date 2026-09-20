import 'package:flutter/material.dart';

class PaduaScreen extends StatefulWidget {
  const PaduaScreen({super.key});

  @override
  State<PaduaScreen> createState() => _PaduaScreenState();
}

class _PaduaScreenState extends State<PaduaScreen> {
  // Выбранные факторы
  final Set<int> selectedFactors = {};

  // Факторы Padua
  final List<Map<String, dynamic>> factors = [
    {
      'title': 'Активная опухоль',
      'description': 'Злокачественное новообразование',
      'points': 3,
    },
    {
      'title': 'Предшествующая ВТЭ',
      'description': 'Тромбоз глубоких вен или ТЭЛА в анамнезе',
      'points': 3,
    },
    {
      'title': 'Снижение мобильности ≥3 суток',
      'description':
          'Постельный режим / значительное ограничение двигательной активности',
      'points': 3,
    },
    {
      'title': 'Известная тромбофилия',
      'description': 'Наследственная или приобретённая тромбофилия',
      'points': 3,
    },
    {
      'title': 'Недавняя травма или операция ≤1 месяца',
      'description':
          'Травма или хирургическое вмешательство в течение последнего месяца',
      'points': 2,
    },
    {
      'title': 'Возраст ≥70 лет',
      'description': 'Возраст пациента 70 лет и старше',
      'points': 1,
    },
    {
      'title': 'Сердечная или дыхательная недостаточность',
      'description': 'Наличие сердечной или дыхательной недостаточности',
      'points': 1,
    },
    {
      'title': 'Острый инфаркт миокарда или ишемический инсульт',
      'description': 'Острый ИМ или ишемический инсульт',
      'points': 1,
    },
    {
      'title': 'Острая инфекция или ревматологическое заболевание',
      'description':
          'Острая инфекция или активное ревматологическое заболевание',
      'points': 1,
    },
    {'title': 'ИМТ ≥30 кг/м²', 'description': 'Ожирение', 'points': 1},
    {
      'title': 'Продолжающаяся гормональная терапия',
      'description': 'Текущая гормональная терапия',
      'points': 1,
    },
  ];

  int get totalScore {
    int score = 0;

    for (final index in selectedFactors) {
      score += factors[index]['points'] as int;
    }

    return score;
  }

  bool isSelected(int index) {
    return selectedFactors.contains(index);
  }

  void toggleFactor(int index) {
    setState(() {
      if (selectedFactors.contains(index)) {
        selectedFactors.remove(index);
      } else {
        selectedFactors.add(index);
      }
    });
  }

  String get riskText {
    if (totalScore >= 4) {
      return 'ВЫСОКИЙ РИСК ВТЭ';
    }

    return 'НИЗКИЙ РИСК ВТЭ';
  }

  Color get riskColor {
    if (totalScore >= 4) {
      return Colors.redAccent;
    }

    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Padua',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // Нижняя область результата закреплена
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: riskColor.withOpacity(0.45), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'СУММА БАЛЛОВ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '$totalScore',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),

              Text(
                riskText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                totalScore >= 4
                    ? '≥4 баллов — высокий риск ВТЭ'
                    : '<4 баллов — низкий риск ВТЭ',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        itemCount: factors.length,
        itemBuilder: (context, index) {
          final factor = factors[index];
          final selected = isSelected(index);
          final points = factor['points'] as int;

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => toggleFactor(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selected
                        ? riskColor.withOpacity(0.18)
                        : const Color(0xFF202020),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? riskColor.withOpacity(0.75)
                          : const Color(0xFF343434),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? riskColor.withOpacity(0.25)
                              : const Color(0xFF303030),
                        ),
                        child: Center(
                          child: Icon(
                            selected ? Icons.check : Icons.add,
                            color: selected ? riskColor : Colors.white70,
                            size: 22,
                          ),
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              factor['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.white,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              factor['description'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        '+$points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selected ? riskColor : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
