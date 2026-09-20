import 'package:flutter/material.dart';

class EvansBurnScreen extends StatefulWidget {
const EvansBurnScreen({super.key});

@override
State<EvansBurnScreen> createState() =>
_EvansBurnScreenState();
}

class _EvansBurnScreenState
extends State<EvansBurnScreen> {
final ScrollController _scrollController =
ScrollController();

final GlobalKey _resultKey = GlobalKey();

final TextEditingController yearsController =
TextEditingController();

final TextEditingController monthsController =
TextEditingController();

final TextEditingController weightController =
TextEditingController();

final TextEditingController burnController =
TextEditingController();

final TextEditingController hoursSinceBurnController =
TextEditingController();

EvansResult? result;
String? errorText;

@override
void dispose() {
_scrollController.dispose();

yearsController.dispose();
monthsController.dispose();
weightController.dispose();
burnController.dispose();
hoursSinceBurnController.dispose();

super.dispose();

}

double? parseDouble(String value) {
return double.tryParse(
value.replaceAll(',', '.').trim(),
);
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

String format(
double value, {
int digits = 1,
}) {
if ((value - value.roundToDouble()).abs() <
0.0001) {
return value.round().toString();
}

return value.toStringAsFixed(digits);

}

void calculate() {
FocusScope.of(context).unfocus();

setState(() {
  result = null;
  errorText = null;
});

final double? weight =
    parseDouble(weightController.text);

final double? burn =
    parseDouble(burnController.text);

final double? hours =
    parseDouble(
  hoursSinceBurnController.text,
);

final int months =
    parseInt(monthsController.text);

if (weight == null || weight <= 0) {
  setState(() {
    errorText =
        'Введите корректную массу тела.';
  });
  return;
}

if (months < 0 || months > 11) {
  setState(() {
    errorText =
        'Количество месяцев должно быть от 0 до 11.';
  });
  return;
}

if (burn == null ||
    burn <= 0 ||
    burn > 100) {
  setState(() {
    errorText =
        'Площадь ожога должна быть больше 0 и не превышать 100%.';
  });
  return;
}

if (hours == null ||
    hours < 0 ||
    hours >= 8) {
  setState(() {
    errorText =
        'Введите время от ожога от 0 до менее 8 часов.';
  });
  return;
}

// ==========================================================
// КЛАССИЧЕСКАЯ ФОРМУЛА ЭВАНСА
//
// За первые 24 часа:
//
// Кристаллоид:
// 1 мл × кг × % ожога
//
// Коллоид:
// 1 мл × кг × % ожога
//
// 5% глюкоза:
// 2000 мл
//
// Половина расчётного объёма за первые 8 часов.
// Вторая половина — в последующие 16 часов.
// ==========================================================

final double crystalloid24 =
    weight * burn;

final double colloid24 =
    weight * burn;

const double glucose24 =
    2000;

final double total24 =
    crystalloid24 +
    colloid24 +
    glucose24;

final double first8Crystalloid =
    crystalloid24 / 2;

final double first8Colloid =
    colloid24 / 2;

final double first8Glucose =
    glucose24 / 2;

final double first8Total =
    first8Crystalloid +
    first8Colloid +
    first8Glucose;

final double next16Total =
    first8Total;

final double remainingFirst8Hours =
    8 - hours;

final double first8CrystalloidRate =
    first8Crystalloid /
        remainingFirst8Hours;

final double first8GlucoseRate =
    first8Glucose /
        remainingFirst8Hours;

final double next16CrystalloidRate =
    first8Crystalloid / 16;

final double next16GlucoseRate =
    first8Glucose / 16;

setState(() {
  result = EvansResult(
    crystalloid24:
        crystalloid24,
    colloid24:
        colloid24,
    glucose24:
        glucose24,
    total24:
        total24,
    first8Total:
        first8Total,
    next16Total:
        next16Total,
    first8CrystalloidRate:
        first8CrystalloidRate,
    first8GlucoseRate:
        first8GlucoseRate,
    next16CrystalloidRate:
        next16CrystalloidRate,
    next16GlucoseRate:
        next16GlucoseRate,
    hoursSinceBurn:
        hours,
    remainingFirst8Hours:
        remainingFirst8Hours,
    pediatric:
        isChild,
  );
});

WidgetsBinding.instance.addPostFrameCallback((_) {
  final BuildContext? resultContext =
      _resultKey.currentContext;

  if (resultContext != null) {
    Scrollable.ensureVisible(
      resultContext,
      duration:
          const Duration(
        milliseconds: 500,
      ),
      curve:
          Curves.easeOutCubic,
      alignment: 0.04,
    );
  }
});

}

void clearAll() {
setState(() {
yearsController.clear();
monthsController.clear();
weightController.clear();
burnController.clear();
hoursSinceBurnController.clear();

  result = null;
  errorText = null;
});

}

Widget inputField({
required String label,
required String suffix,
required TextEditingController controller,
String? hint,
bool decimal = true,
}) {
return TextField(
controller: controller,
keyboardType:
TextInputType.numberWithOptions(
decimal: decimal,
),
decoration: InputDecoration(
labelText: label,
hintText: hint,
suffixText: suffix,
filled: true,
fillColor:
const Color(0xFF1E1E1E),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
16,
),
),
),
);
}

Widget sectionTitle(
String title,
String subtitle,
IconData icon,
) {
return Padding(
padding: const EdgeInsets.only(
top: 20,
bottom: 10,
),
child: Row(
children: [
Container(
width: 42,
height: 42,
decoration:
const BoxDecoration(
color: Color(0xFF7A5735),
shape: BoxShape.circle,
),
child: Icon(
icon,
color:
Colors.white,
),
),

      const SizedBox(
        width: 11,
      ),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              subtitle,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Colors.grey,
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
IconData icon =
Icons.water_drop_outlined,
}) {
return Container(
width: double.infinity,
margin:
const EdgeInsets.only(
bottom: 9,
),
padding:
const EdgeInsets.all(
15,
),
decoration:
BoxDecoration(
color:
const Color(0xFF202020),
borderRadius:
BorderRadius.circular(
18,
),
border: Border.all(
color:
const Color(0xFF343434),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 42,
height: 42,
decoration:
const BoxDecoration(
color:
Color(0xFF7A5735),
shape: BoxShape.circle,
),
child: Icon(
icon,
color:
Colors.white,
),
),

      const SizedBox(
        width: 12,
      ),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.white70,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            if (subtitle != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 3,
                ),
                child:
                    Text(
                  subtitle,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey,
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
margin:
const EdgeInsets.only(
top: 8,
),
padding:
const EdgeInsets.all(
14,
),
decoration:
BoxDecoration(
color:
const Color(0xFF241F18),
borderRadius:
BorderRadius.circular(
16,
),
border: Border.all(
color:
const Color(0xFF5A4930),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons
.warning_amber_rounded,
color:
Colors.amber,
),

      const SizedBox(
        width: 9,
      ),

      Expanded(
        child: Text(
          text,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                Colors.white70,
            height: 1.4,
          ),
        ),
      ),
    ],
  ),
);

}

Widget resultsWidget() {
final EvansResult? r =
result;

if (r == null) {
  return const SizedBox();
}

return Container(
  key: _resultKey,
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      sectionTitle(
        '🔥 Результат',
        'Классическая формула Эванса',
        Icons.analytics_outlined,
      ),

      if (r.pediatric)
        warning(
          'Пациент детского возраста. Классическая '
          'формула Эванса является исторической схемой '
          'и не должна рассматриваться как современный '
          'стандарт педиатрической ожоговой ресусцитации. '
          'Для ребёнка сверяйте расчёт с действующим '
          'педиатрическим протоколом.',
        ),

      // ==============================
      // ОБЩИЙ ОБЪЁМ
      // ==============================

      resultCard(
        title:
            'Общий объём за 24 часа',
        value:
            '${format(r.total24)} мл',
        subtitle:
            'Расчётный объём инфузии',
        icon:
            Icons.water_drop_outlined,
      ),

      resultCard(
        title:
            'Первые 8 часов',
        value:
            '${format(r.first8Total)} мл',
        subtitle:
            'Объём первой половины расчёта',
        icon:
            Icons.schedule_outlined,
      ),

      resultCard(
        title:
            'Последующие 16 часов',
        value:
            '${format(r.next16Total)} мл',
        subtitle:
            'Объём второй половины расчёта',
        icon:
            Icons.schedule_outlined,
      ),

      // ==============================
      // ПЕРВЫЕ 8 ЧАСОВ
      // ==============================

      resultCard(
        title:
            'Кристаллоиды — первые 8 часов',
        value:
            '${format(r.first8CrystalloidRate)} мл/ч',
        subtitle:
            'С учётом уже прошедшего времени',
        icon:
            Icons.speed_outlined,
      ),

      resultCard(
        title:
            'Глюкоза 5% — первые 8 часов',
        value:
            '${format(r.first8GlucoseRate)} мл/ч',
        icon:
            Icons.speed_outlined,
      ),

      // ==============================
      // СЛЕДУЮЩИЕ 16 ЧАСОВ
      // ==============================

      resultCard(
        title:
            'Кристаллоиды — последующие 16 часов',
        value:
            '${format(r.next16CrystalloidRate)} мл/ч',
        icon:
            Icons.speed_outlined,
      ),

      resultCard(
        title:
            'Глюкоза 5% — последующие 16 часов',
        value:
            '${format(r.next16GlucoseRate)} мл/ч',
        icon:
            Icons.speed_outlined,
      ),

      const SizedBox(
        height: 8,
      ),

      warning(
        'Скорость инфузии должна корректироваться '
        'по клиническому ответу, диурезу, гемодинамике '
        'и другим целевым показателям. Учитывайте '
        'жидкость, уже введённую до момента расчёта.',
      ),
    ],
  ),
);

}

@override
Widget build(
BuildContext context,
) {
return Scaffold(
appBar: AppBar(
title: const Row(
mainAxisSize:
MainAxisSize.min,
children: [
Text(
'🔥 ',
style:
TextStyle(
fontSize: 20,
),
),
Text(
'Эванс — ожоговая инфузия',
style:
TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),
],
),
actions: [
IconButton(
tooltip:
'Очистить',
onPressed:
clearAll,
icon:
const Icon(
Icons.refresh_rounded,
),
),
],
),

  body:
      SingleChildScrollView(
    controller:
        _scrollController,
    padding:
        const EdgeInsets.fromLTRB(
      16,
      16,
      16,
      130,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(
            16,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFF1C1C1C,
            ),
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child: const Row(
            children: [
              Text(
                '🔥',
                style:
                    TextStyle(
                  fontSize: 32,
                ),
              ),

              SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  'Расчёт инфузии '
                  'по формуле Эванса',
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==============================
        // ПАЦИЕНТ
        // ==============================

        sectionTitle(
          'Пациент',
          'Возраст указывается годами и месяцами.',
          Icons.person_outline,
        ),

        Row(
          children: [
            Expanded(
              child:
                  inputField(
                label:
                    'Лет',
                suffix:
                    'г',
                controller:
                    yearsController,
                hint:
                    '45',
                decimal:
                    false,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  inputField(
                label:
                    'Месяцев',
                suffix:
                    'мес',
                controller:
                    monthsController,
                hint:
                    '0',
                decimal:
                    false,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        inputField(
          label:
              'Масса тела',
          suffix:
              'кг',
          controller:
              weightController,
          hint:
              '80',
        ),

        // ==============================
        // ОЖОГ
        // ==============================

        sectionTitle(
          'Ожог',
          'Введите площадь ожога и время от момента травмы.',
          Icons.local_fire_department_outlined,
        ),

        inputField(
          label:
              'Площадь ожога',
          suffix:
              '%',
          controller:
              burnController,
          hint:
              '25',
        ),

        const SizedBox(
          height: 12,
        ),

        inputField(
          label:
              'Сколько часов прошло с момента ожога?',
          suffix:
              'ч',
          controller:
              hoursSinceBurnController,
          hint:
              '3',
        ),

        const SizedBox(
          height: 22,
        ),

        SizedBox(
          width:
              double.infinity,
          height:
              54,
          child:
              ElevatedButton.icon(
            onPressed:
                calculate,
            icon:
                const Icon(
              Icons
                  .calculate_outlined,
            ),
            label:
                const Text(
              'Рассчитать',
              style:
                  TextStyle(
                fontSize:
                    16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF7A5735,
              ),
              foregroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
            ),
          ),
        ),

        if (errorText != null) ...[
          const SizedBox(
            height: 12,
          ),
          warning(
            errorText!,
          ),
        ],

        resultsWidget(),

        const SizedBox(
          height: 70,
        ),

        const Center(
          child: Text(
            'Эванс • вспомогательный инструмент',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 10,
              color:
                  Colors.grey,
            ),
          ),
        ),

        const SizedBox(
          height: 30,
        ),
      ],
    ),
  ),
);

}
}

class EvansResult {
final double crystalloid24;
final double colloid24;
final double glucose24;
final double total24;

final double first8Total;
final double next16Total;

final double first8CrystalloidRate;
final double first8GlucoseRate;

final double next16CrystalloidRate;
final double next16GlucoseRate;

final double hoursSinceBurn;
final double remainingFirst8Hours;

final bool pediatric;

EvansResult({
required this.crystalloid24,
required this.colloid24,
required this.glucose24,
required this.total24,
required this.first8Total,
required this.next16Total,
required this.first8CrystalloidRate,
required this.first8GlucoseRate,
required this.next16CrystalloidRate,
required this.next16GlucoseRate,
required this.hoursSinceBurn,
required this.remainingFirst8Hours,
required this.pediatric,
});
}
