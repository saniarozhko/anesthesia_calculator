import 'package:flutter/material.dart';
import 'dart:async';

// ===============================
// ЭКРАНЫ КАЛЬКУЛЯТОРОВ
// ===============================

import 'bmi_screen.dart';
import 'tidal_volume_screen.dart';
import 'apache_ii_screen.dart';
import 'renal_function_screen.dart';
import 'sofa_screen.dart';
import 'gcs_screen.dart';
import 'four_screen.dart';
import 'nihss_screen.dart';
import 'rass_screen.dart';
import 'pesi_screen.dart';
import 'geneva_screen.dart';
import 'wells_screen.dart';
import 'infusion_calculator_screen.dart';
import 'respiratory_index_screen.dart';
import 'harris_benedict_screen.dart';
import 'parkland_screen.dart';
import 'spinal_bupivacaine_screen.dart';
import 'hunt_hess_screen.dart';
import 'grace_screen.dart';
import 'killip_screen.dart';
import 'cpis_screen.dart';
import 'cha2ds2vasc_screen.dart';

// ===============================
// MAIN
// ===============================

void main() {
  runApp(const AnesthesiaCalculatorApp());
}

// ===============================
// APP
// ===============================

class AnesthesiaCalculatorApp extends StatelessWidget {
  const AnesthesiaCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Калькулятор реаниматолога",

      theme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF121212),

        colorScheme: ColorScheme.dark(primary: const Color(0xFF86BBD8)),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181818),

          centerTitle: true,
        ),
      ),

      home: const HomePage(),
    );
  }
}

// ===============================
// МОДЕЛЬ КАЛЬКУЛЯТОРА
// ===============================

class CalculatorItem {
  final String name;

  final String search;

  final Widget screen;

  CalculatorItem({
    required this.name,

    required this.search,

    required this.screen,
  });
}

// ===============================
// ГЛАВНЫЙ ЭКРАН
// ===============================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  Timer? searchTimer;

  // ===============================
  // ВСЕ КАЛЬКУЛЯТОРЫ
  // ===============================

  final List<CalculatorItem> allCalculators = [
    CalculatorItem(
      name: "ИМТ",

      search: "имт bmi индекс массы тела",

      screen: const BmiScreen(),
    ),

    CalculatorItem(
      name: "Расчёт скорости инфузии",

      search: "инфузия скорость мл час препарат дозировка",

      screen: const InfusionCalculatorScreen(),
    ),

    CalculatorItem(
      name: "СКФ",

      search: "скф egfr renal креатинин почки ckd epi",

      screen: const RenalFunctionScreen(),
    ),

    CalculatorItem(
      name: "Харрис-Бенедикт",

      search: "harris benedict питание калории",

      screen: const HarrisBenedictScreen(),
    ),
    CalculatorItem(
      name: "Паркланд",

      search: "паркланд parkland ожоги инфузия объем жидкости",

      screen: const ParklandScreen(),
    ),
    CalculatorItem(
      name: "Расчёт для СМА",

      search: "бупивакаин спинальная анестезия сма дозировка",

      screen: const SpinalBupivacaineScreen(),
    ),

    CalculatorItem(
      name: "Дыхательный объём ИВЛ",

      search: "дыхательный объем vt tidal volume вентиляция",

      screen: const TidalVolumeScreen(),
    ),

    CalculatorItem(
      name: "Респираторный индекс",

      search: "pf ratio respiratory index оксигенация",

      screen: const RespiratoryIndexScreen(),
    ),

    CalculatorItem(
      name: "CPIS",

      search: "cpis вентиляторная пневмония",

      screen: const CpisScreen(),
    ),

    CalculatorItem(
      name: "GCS — шкала комы Глазго",

      search: "gcs шкг глазго кома сознание",

      screen: const GcsScreen(),
    ),

    CalculatorItem(
      name: "FOUR",

      search: "four coma кома сознание",

      screen: const FourScreen(),
    ),

    CalculatorItem(
      name: "NIHSS",

      search: "nihss инсульт stroke неврология",

      screen: const NihssScreen(),
    ),

    CalculatorItem(
      name: "Hunt-Hess",

      search: "hunt hess субарахноидальное кровоизлияние",

      screen: const HuntHessScreen(),
    ),

    CalculatorItem(
      name: "RASS",

      search: "rass седация возбуждение",

      screen: const RassScreen(),
    ),
    CalculatorItem(
      name: "SOFA",

      search: "sofa сепсис органная недостаточность",

      screen: const SofaScreen(),
    ),

    CalculatorItem(
      name: "APACHE II",

      search: "apache apache2 тяжесть состояния прогноз",

      screen: const ApacheIIScreen(),
    ),

    CalculatorItem(
      name: "GRACE",

      search: "grace окс острый коронарный синдром",

      screen: const GraceScreen(),
    ),

    CalculatorItem(
      name: "Killip",

      search: "killip оим сердечная недостаточность",

      screen: const KillipScreen(),
    ),

    CalculatorItem(
      name: "CHA₂DS₂-VASc",

      search: "cha2ds2vasc cha vasc фибрилляция предсердий инсульт риск",

      screen: Cha2ds2VascScreen(),
    ),

    CalculatorItem(
      name: "PESI",

      search: "pesi тэлa эмболия риск",

      screen: const PesiScreen(),
    ),

    CalculatorItem(
      name: "Geneva",

      search: "geneva тэлa вероятность",

      screen: const GenevaScreen(),
    ),
    CalculatorItem(
      name: "Wells",

      search: "wells тэлa вероятность риск эмболия",

      screen: const WellsScreen(),
    ),
  ];

  // ===============================
  // РАСКРЫТЫЕ ГРУППЫ
  // ===============================

  final Map<String, bool> expandedGroups = {
    "Дыхание и вентиляция": false,

    "Неврология и сознание": false,

    "Тяжесть состояния пациента": false,

    "Кардиология": false,

    "ТЭЛА": false,
  };

  @override
  void dispose() {
    searchController.dispose();

    searchTimer?.cancel();

    super.dispose();
  }

  // ===============================
  // ПОИСК
  // ===============================

  bool matchesSearch(CalculatorItem item, String query) {
    if (query.trim().isEmpty) {
      return true;
    }

    final q = query.toLowerCase().replaceAll("ё", "е").trim();

    final text = "${item.name} ${item.search}".toLowerCase().replaceAll(
      "ё",
      "е",
    );

    return text.contains(q);
  }

  void openCalculator(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ===============================
  // ПОИСКАННЫЕ КАЛЬКУЛЯТОРЫ
  // ===============================

  List<CalculatorItem> get filtered {
    return allCalculators.where((e) => matchesSearch(e, searchText)).toList();
  }

  // ===============================
  // КНОПКА КАЛЬКУЛЯТОРА
  // ===============================

  Widget calculatorButton(CalculatorItem item) {
    return GestureDetector(
      onTap: () {
        openCalculator(item.screen);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

        decoration: BoxDecoration(
          color: const Color(0xFF202020),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: const Color(0xFF343434)),
        ),

        child: Row(
          children: [
            const Icon(Icons.calculate_outlined, color: Color(0xFF86BBD8)),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                item.name,

                style: const TextStyle(
                  fontSize: 16,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget smaButton(CalculatorItem item) {
    return GestureDetector(
      onTap: () {
        openCalculator(item.screen);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),

        decoration: BoxDecoration(
          color: const Color(0xFF202020),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: const Color(0xFF343434)),
        ),

        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 72, 117, 134),
                shape: BoxShape.circle,
              ),

              child: const Center(
                child: Text("💉", style: TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                item.name,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  // ===============================
  // ГРУППЫ
  // ===============================

  Widget groupHeader(String title, String emoji, Color color) {
    bool expanded = expandedGroups[title] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedGroups[title] = !expanded;
        });
      },

      child: Container(
        margin: const EdgeInsets.only(top: 14, bottom: 6),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),

          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Container(
              width: 42,

              height: 42,

              decoration: BoxDecoration(color: color, shape: BoxShape.circle),

              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 17,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,

              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget expandableGroup(
    String title,
    String emoji,
    Color color,
    List<CalculatorItem> items,
  ) {
    bool expanded = expandedGroups[title] ?? false;

    List<CalculatorItem> visible = items
        .where((e) => matchesSearch(e, searchText))
        .toList();

    if (searchText.isNotEmpty) {
      expanded = visible.isNotEmpty;
    }

    if (visible.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        groupHeader(title, emoji, color),

        AnimatedSize(
          duration: const Duration(milliseconds: 350),

          curve: Curves.easeInOut,

          child: expanded
              ? Column(
                  children: visible.map((e) => calculatorButton(e)).toList(),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  // ===============================
  // СПИСКИ ГРУПП
  // ===============================

  Widget groupsWidget() {
    return Column(
      children: [
        expandableGroup("Дыхание и вентиляция", "🫁", const Color(0xFF3F6F8F), [
          allCalculators[6],
          allCalculators[7],
          allCalculators[8],
        ]),

        expandableGroup(
          "Неврология и сознание",
          "🧠",
          const Color(0xFF7E6AA2),
          [
            allCalculators[9],
            allCalculators[10],
            allCalculators[11],
            allCalculators[12],
            allCalculators[13],
          ],
        ),

        expandableGroup(
          "Тяжесть состояния пациента",
          "🏥",
          const Color(0xFF81A878),
          [allCalculators[14], allCalculators[15]],
        ),

        expandableGroup("Кардиология", "❤️", const Color(0xFFB0B7B8), [
          allCalculators[16],
          allCalculators[17],
          allCalculators[18],
        ]),

        expandableGroup("ТЭЛА", "🫁", const Color.fromARGB(255, 145, 91, 182), [
          allCalculators[19],
          allCalculators[20],
          allCalculators[21],
        ]),
      ],
    );
  }

  // ===============================
  // BUILD
  // ===============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("🩺 ", style: TextStyle(fontSize: 20)),

            Text(
              "Калькулятор\nреаниматолога",
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),

        child: Column(
          children: [
            TextField(
              controller: searchController,

              onChanged: (value) {
                searchTimer?.cancel();

                searchTimer = Timer(const Duration(milliseconds: 250), () {
                  setState(() {
                    searchText = value;
                  });
                });
              },

              decoration: InputDecoration(
                hintText: "Поиск калькулятора...",

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: const Color(0xFF1E1E1E),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (searchText.isEmpty) ...[
              calculatorButton(allCalculators[0]),

              calculatorButton(allCalculators[1]),

              calculatorButton(allCalculators[2]),

              calculatorButton(allCalculators[3]),

              calculatorButton(allCalculators[4]),

              smaButton(allCalculators[5]),
            ],

            if (searchText.isNotEmpty)
              ...filtered.map((e) => calculatorButton(e)),

            if (searchText.isEmpty) groupsWidget(),

            const SizedBox(height: 30),

            // ===============================
            // ПОДПИСЬ АВТОРА
            // ВНИЗУ СПИСКА СПРАВА
            // ===============================
            Align(
              alignment: Alignment.centerRight,

              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(0xFF86BBD8).withOpacity(0.18),
                    ),
                  ),

                  child: const Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        "Автор: Рожко А.Ю.",

                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),

                      Text(
                        "Калькулятор реаниматолога v2.0",

                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF95C7F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "• Пр. созд. 25.07.2026\n"
                        "• Обновлено 28.07.2026",

                        textAlign: TextAlign.right,

                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // запас снизу после рамки
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
