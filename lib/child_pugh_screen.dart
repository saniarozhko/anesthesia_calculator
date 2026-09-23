import 'package:flutter/material.dart';

class ChildPughScreen extends StatefulWidget {
  const ChildPughScreen({super.key});

  @override
  State<ChildPughScreen> createState() => _ChildPughScreenState();
}

class _ChildPughScreenState extends State<ChildPughScreen> {
  // ============================================================
  // РЕЖИМ ВВОДА
  // ============================================================

  bool bilirubinManual = true;
  bool albuminManual = true;
  bool inrManual = true;

  // ============================================================
  // РУЧНЫЕ ЗНАЧЕНИЯ
  // ============================================================

  final TextEditingController bilirubinController = TextEditingController();

  final TextEditingController albuminController = TextEditingController();

  final TextEditingController inrController = TextEditingController();

  // ============================================================
  // ВЫБРАННЫЕ ДИАПАЗОНЫ
  // ============================================================

  int? bilirubinRange;
  int? albuminRange;
  int? inrRange;

  int? ascitesScore;
  int? encephalopathyScore;

  // ============================================================
  // РАСЧЁТ
  // ============================================================

  int? get bilirubinScore {
    if (bilirubinManual) {
      final value = double.tryParse(
        bilirubinController.text.replaceAll(',', '.'),
      );

      if (value == null) return null;

      if (value < 34) return 1;
      if (value <= 51) return 2;
      return 3;
    }

    return bilirubinRange;
  }

  int? get albuminScore {
    if (albuminManual) {
      final value = double.tryParse(
        albuminController.text.replaceAll(',', '.'),
      );

      if (value == null) return null;

      if (value > 35) return 1;
      if (value >= 28) return 2;
      return 3;
    }

    return albuminRange;
  }

  int? get inrScore {
    if (inrManual) {
      final value = double.tryParse(inrController.text.replaceAll(',', '.'));

      if (value == null) return null;

      if (value < 1.7) return 1;
      if (value <= 2.3) return 2;
      return 3;
    }

    return inrRange;
  }

  int? get totalScore {
    final b = bilirubinScore;
    final a = albuminScore;
    final i = inrScore;
    final as = ascitesScore;
    final e = encephalopathyScore;

    if (b == null || a == null || i == null || as == null || e == null) {
      return null;
    }

    return b + a + i + as + e;
  }

  String get childClass {
    final score = totalScore;

    if (score == null) return '';

    if (score <= 6) return 'Класс A';
    if (score <= 9) return 'Класс B';
    return 'Класс C';
  }

  String get classDescription {
    final score = totalScore;

    if (score == null) return '';

    if (score <= 6) return 'Компенсированный';
    if (score <= 9) return 'Субкомпенсированный';
    return 'Декомпенсированный';
  }

  Color get resultColor {
    final score = totalScore;

    if (score == null) {
      return const Color(0xFF86BBD8);
    }

    if (score <= 6) {
      return const Color(0xFF55C98A);
    }

    if (score <= 9) {
      return const Color(0xFFE2B86B);
    }

    return const Color(0xFFE27D7D);
  }

  @override
  void dispose() {
    bilirubinController.dispose();
    albuminController.dispose();
    inrController.dispose();
    super.dispose();
  }

  // ============================================================
  // ОБЩИЕ ЭЛЕМЕНТЫ UI
  // ============================================================

  Widget sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    IconData icon = Icons.science_outlined,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191B1F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF292D32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF86BBD8).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF86BBD8), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget modeSelector({
    required bool manual,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111315),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: manual ? const Color(0xFF2B5367) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Ввести значение',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !manual ? const Color(0xFF2B5367) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Выбрать диапазон',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFF111315),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF292D32)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF86BBD8)),
        ),
      ),
    );
  }

  Widget rangeOption({
    required String title,
    required String description,
    required int score,
    required int? selected,
    required VoidCallback onTap,
  }) {
    final selectedNow = selected == score;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedNow
              ? const Color(0xFF244656)
              : const Color(0xFF111315),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedNow
                ? const Color(0xFF86BBD8)
                : const Color(0xFF292D32),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selectedNow
                    ? const Color(0xFF86BBD8)
                    : const Color(0xFF24282C),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: selectedNow
                        ? const Color(0xFF101114)
                        : Colors.white70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            if (selectedNow)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF86BBD8)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ЛАБОРАТОРНЫЕ ПОКАЗАТЕЛИ
  // ============================================================

  Widget bilirubinCard() {
    return sectionCard(
      title: 'Билирубин',
      subtitle: 'Общий билирубин',
      icon: Icons.water_drop_outlined,
      child: Column(
        children: [
          modeSelector(
            manual: bilirubinManual,
            onChanged: (value) {
              setState(() {
                bilirubinManual = value;
              });
            },
          ),
          const SizedBox(height: 12),
          if (bilirubinManual)
            inputField(
              controller: bilirubinController,
              label: 'Билирубин',
              suffix: 'мкмоль/л',
            )
          else ...[
            rangeOption(
              title: '< 34 мкмоль/л',
              description: '1 балл',
              score: 1,
              selected: bilirubinRange,
              onTap: () {
                setState(() => bilirubinRange = 1);
              },
            ),
            rangeOption(
              title: '34–51 мкмоль/л',
              description: '2 балла',
              score: 2,
              selected: bilirubinRange,
              onTap: () {
                setState(() => bilirubinRange = 2);
              },
            ),
            rangeOption(
              title: '> 51 мкмоль/л',
              description: '3 балла',
              score: 3,
              selected: bilirubinRange,
              onTap: () {
                setState(() => bilirubinRange = 3);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget albuminCard() {
    return sectionCard(
      title: 'Альбумин',
      subtitle: 'Концентрация альбумина',
      icon: Icons.bubble_chart_outlined,
      child: Column(
        children: [
          modeSelector(
            manual: albuminManual,
            onChanged: (value) {
              setState(() {
                albuminManual = value;
              });
            },
          ),
          const SizedBox(height: 12),
          if (albuminManual)
            inputField(
              controller: albuminController,
              label: 'Альбумин',
              suffix: 'г/л',
            )
          else ...[
            rangeOption(
              title: '> 35 г/л',
              description: '1 балл',
              score: 1,
              selected: albuminRange,
              onTap: () {
                setState(() => albuminRange = 1);
              },
            ),
            rangeOption(
              title: '28–35 г/л',
              description: '2 балла',
              score: 2,
              selected: albuminRange,
              onTap: () {
                setState(() => albuminRange = 2);
              },
            ),
            rangeOption(
              title: '< 28 г/л',
              description: '3 балла',
              score: 3,
              selected: albuminRange,
              onTap: () {
                setState(() => albuminRange = 3);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget inrCard() {
    return sectionCard(
      title: 'МНО',
      subtitle: 'Международное нормализованное отношение',
      icon: Icons.bloodtype_outlined,
      child: Column(
        children: [
          modeSelector(
            manual: inrManual,
            onChanged: (value) {
              setState(() {
                inrManual = value;
              });
            },
          ),
          const SizedBox(height: 12),
          if (inrManual)
            inputField(controller: inrController, label: 'МНО', suffix: '')
          else ...[
            rangeOption(
              title: '< 1,7',
              description: '1 балл',
              score: 1,
              selected: inrRange,
              onTap: () {
                setState(() => inrRange = 1);
              },
            ),
            rangeOption(
              title: '1,7–2,3',
              description: '2 балла',
              score: 2,
              selected: inrRange,
              onTap: () {
                setState(() => inrRange = 2);
              },
            ),
            rangeOption(
              title: '> 2,3',
              description: '3 балла',
              score: 3,
              selected: inrRange,
              onTap: () {
                setState(() => inrRange = 3);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // АСЦИТ
  // ============================================================

  Widget ascitesCard() {
    return sectionCard(
      title: 'Асцит',
      subtitle: 'Степень выраженности',
      icon: Icons.opacity_outlined,
      child: Column(
        children: [
          rangeOption(
            title: 'Нет',
            description: 'Асцит отсутствует',
            score: 1,
            selected: ascitesScore,
            onTap: () {
              setState(() => ascitesScore = 1);
            },
          ),
          rangeOption(
            title: 'Умеренный',
            description: 'Контролируется медикаментозной терапией',
            score: 2,
            selected: ascitesScore,
            onTap: () {
              setState(() => ascitesScore = 2);
            },
          ),
          rangeOption(
            title: 'Выраженный',
            description: 'Рефрактерный / плохо контролируемый',
            score: 3,
            selected: ascitesScore,
            onTap: () {
              setState(() => ascitesScore = 3);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ЭНЦЕФАЛОПАТИЯ
  // ============================================================

  Widget encephalopathyCard() {
    return sectionCard(
      title: 'Печёночная энцефалопатия',
      subtitle: 'Клиническая степень',
      icon: Icons.psychology_outlined,
      child: Column(
        children: [
          rangeOption(
            title: 'Нет',
            description: 'Энцефалопатия отсутствует',
            score: 1,
            selected: encephalopathyScore,
            onTap: () {
              setState(() => encephalopathyScore = 1);
            },
          ),
          rangeOption(
            title: 'I–II степень',
            description:
                'Нарушения сна, инверсия сна–бодрствования, спутанность',
            score: 2,
            selected: encephalopathyScore,
            onTap: () {
              setState(() => encephalopathyScore = 2);
            },
          ),
          rangeOption(
            title: 'III–IV степень',
            description: 'Сопор, выраженное нарушение сознания, кома',
            score: 3,
            selected: encephalopathyScore,
            onTap: () {
              setState(() => encephalopathyScore = 3);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // РЕЗУЛЬТАТ
  // ============================================================

  Widget resultCard() {
    final score = totalScore;

    if (score == null) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF191B1F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF292D32)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white38),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Заполните все пять критериев для расчёта Child–Pugh.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final color = resultColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.20), const Color(0xFF191B1F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.50)),
      ),
      child: Column(
        children: [
          const Text(
            'РЕЗУЛЬТАТ CHILD–PUGH',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 52,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  '/ 15 баллов',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            childClass,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            classDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _resultLine('Класс A', '5–6 баллов'),
                _resultLine('Класс B', '7–9 баллов'),
                _resultLine('Класс C', '10–15 баллов'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultLine(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101114),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Child–Pugh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF18242B),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: const Color(0xFF283941)),
                ),
                child: const Row(
                  children: [
                    Text('🔬', style: TextStyle(fontSize: 30)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Child–Pugh',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Оценка тяжести цирроза печени',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bilirubinCard(),
              albuminCard(),
              inrCard(),
              ascitesCard(),
              encephalopathyCard(),
              resultCard(),
              const SizedBox(height: 18),
              const Text(
                'Child–Pugh: билирубин, альбумин, МНО, асцит и печёночная энцефалопатия.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
