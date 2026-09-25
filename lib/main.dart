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
import 'padua_screen.dart';
import 'infusion_calculator_screen.dart';
import 'pediatric_infusion_screen.dart';
import 'electrolyte_calculator_screen.dart';
import 'respiratory_index_screen.dart';
import 'harris_benedict_screen.dart';
import 'parkland_screen.dart';
import 'evans_burn_screen.dart';
import 'spinal_bupivacaine_screen.dart';
import 'hunt_hess_screen.dart';
import 'grace_screen.dart';
import 'killip_screen.dart';
import 'cpis_screen.dart';
import 'cha2ds2vasc_screen.dart';
import 'child_pugh_screen.dart';
import 'nutritional_support_screen.dart';

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
      title: 'Калькулятор реаниматолога',
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
  final String? emoji;

  CalculatorItem({
    required this.name,
    required this.search,
    required this.screen,
    this.emoji,
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

  String searchText = '';

  Timer? searchTimer;

  // ===============================
  // ВСЕ КАЛЬКУЛЯТОРЫ
  // ===============================
  //
  // ВАЖНО:
  // Группы ниже НЕ используют индексы этого списка.
  // Поэтому добавление нового калькулятора больше
  // не будет ломать остальные группы.
  // ===============================

  final List<CalculatorItem> allCalculators = [
    // ===============================
    // БЫСТРЫЙ ДОСТУП
    // ===============================
    CalculatorItem(
      name: 'ИМТ',
      search: 'имт bmi индекс массы тела',
      screen: const BmiScreen(),
      emoji: '📏',
    ),

    CalculatorItem(
      name: 'Расчёт скорости инфузии',
      search: 'инфузия скорость мл час препарат дозировка',
      screen: const InfusionCalculatorScreen(),
    ),

    CalculatorItem(
      name: 'СКФ',
      search: 'скф egfr renal креатинин почки ckd epi кокрофта голта',
      screen: const RenalFunctionScreen(),
      emoji: '💧',
    ),

    CalculatorItem(
      name: 'Харрис-Бенедикт',
      search: 'harris benedict питание калории',
      screen: const HarrisBenedictScreen(),
    ),

    CalculatorItem(
      name: 'Расчёт для СМА',
      search: 'бупивакаин спинальная анестезия сма дозировка',
      screen: const SpinalBupivacaineScreen(),
    ),

    CalculatorItem(
      name: 'Паркланд',
      search: 'паркланд parkland ожоги ожог инфузия объем жидкости',
      screen: const ParklandScreen(),
      emoji: '🔥',
    ),

    // ===============================
    // НУТРИТИВНАЯ ПОДДЕРЖКА
    // ===============================
    CalculatorItem(
      name: 'Нутритивная поддержка',
      search:
          'нутритивная поддержка питание энтеральное парентеральное '
          'калории ккал белок аминокислоты глюкоза липиды '
          'энергетические субстраты пептамен peptamen '
          'интралипид intralipid альбумин вамин аминостерил гепавил',
      screen: const NutritionalSupportScreen(),
      emoji: '🥗',
    ),

    // ===============================
    // ДЫХАНИЕ
    // ===============================
    CalculatorItem(
      name: 'Дыхательный объём ИВЛ',
      search: 'дыхательный объем vt tidal volume вентиляция',
      screen: const TidalVolumeScreen(),
    ),

    CalculatorItem(
      name: 'Респираторный индекс',
      search: 'pf ratio respiratory index оксигенация',
      screen: const RespiratoryIndexScreen(),
    ),

    CalculatorItem(
      name: 'CPIS',
      search: 'cpis вентиляторная пневмония',
      screen: const CpisScreen(),
    ),

    // ===============================
    // НЕВРОЛОГИЯ
    // ===============================
    CalculatorItem(
      name: 'GCS — шкала комы Глазго',
      search: 'gcs шкг глазго кома сознание',
      screen: const GcsScreen(),
    ),

    CalculatorItem(
      name: 'FOUR',
      search: 'four coma кома сознание',
      screen: const FourScreen(),
    ),

    CalculatorItem(
      name: 'NIHSS',
      search: 'nihss инсульт stroke неврология',
      screen: const NihssScreen(),
    ),

    CalculatorItem(
      name: 'Hunt-Hess',
      search: 'hunt hess субарахноидальное кровоизлияние',
      screen: const HuntHessScreen(),
    ),

    CalculatorItem(
      name: 'RASS',
      search: 'rass седация возбуждение',
      screen: const RassScreen(),
    ),

    // ===============================
    // ТЯЖЕСТЬ СОСТОЯНИЯ
    // ===============================
    CalculatorItem(
      name: 'SOFA',
      search: 'sofa сепсис органная недостаточность',
      screen: const SofaScreen(),
    ),

    CalculatorItem(
      name: 'APACHE II',
      search: 'apache apache2 тяжесть состояния прогноз',
      screen: const ApacheIIScreen(),
    ),

    // ===============================
    // КАРДИОЛОГИЯ
    // ===============================
    CalculatorItem(
      name: 'GRACE',
      search: 'grace окс острый коронарный синдром',
      screen: const GraceScreen(),
    ),

    CalculatorItem(
      name: 'Killip',
      search: 'killip оим сердечная недостаточность',
      screen: const KillipScreen(),
    ),

    CalculatorItem(
      name: 'CHA₂DS₂-VASc',
      search: 'cha2ds2vasc cha vasc фибрилляция предсердий инсульт риск',
      screen: const Cha2ds2VascScreen(),
    ),

    // ===============================
    // ГЕПАТОЛОГИЯ
    // ===============================
    CalculatorItem(
      name: 'Child–Pugh (Чайлд–Пью)',
      search:
          'child pugh чайлд пью цирроз печени гепатология '
          'билирубин альбумин мно асцит энцефалопатия',
      screen: const ChildPughScreen(),
      emoji: '🧬',
    ),

    // ===============================
    // ТЭЛА
    // ===============================
    CalculatorItem(
      name: 'PESI',
      search: 'pesi тэла эмболия риск',
      screen: const PesiScreen(),
    ),

    CalculatorItem(
      name: 'Geneva',
      search: 'geneva тэла вероятность',
      screen: const GenevaScreen(),
    ),

    CalculatorItem(
      name: 'Wells',
      search: 'wells тэла вероятность риск эмболия',
      screen: const WellsScreen(),
    ),

    CalculatorItem(
      name: 'Padua',
      search: 'padua падуа вте венозная тромбоэмболия риск',
      screen: const PaduaScreen(),
    ),

    // ===============================
    // ПЕДИАТРИЯ
    // ===============================
    CalculatorItem(
      name: 'Инфузия у детей',
      search:
          'инфузия дети ребенок педиатрия жидкость '
          'жп жво жтпп обезвоживание эксикоз регидратация',
      screen: const PediatricInfusionScreen(),
      emoji: '👶',
    ),

    // ===============================
    // ЭЛЕКТРОЛИТЫ
    // ===============================
    CalculatorItem(
      name: 'Электролитный расчёт',
      search:
          'электролиты натрий Na гипонатриемия '
          'калий K гипокалиемия хлор Cl гипохлоремия '
          'кальций Ca гипокальциемия '
          'магний Mg магний сульфат MgSO4 '
          'дефицит электролитов',
      screen: const ElectrolyteCalculatorScreen(),
      emoji: '⚡',
    ),

    // ===============================
    // ОЖОГИ
    // ===============================
    CalculatorItem(
      name: 'Эванс — ожоговая инфузия',
      search:
          'эванс evans ожоги ожог инфузия '
          'кристаллоид коллоид глюкоза burn',
      screen: const EvansBurnScreen(),
      emoji: '🔥',
    ),
  ];

  // ===============================
  // РАСКРЫТЫЕ ГРУППЫ
  // ===============================

  final Map<String, bool> expandedGroups = {
    'Дыхание и вентиляция': false,
    'Неврология и сознание': false,
    'Тяжесть состояния пациента': false,
    'Кардиология': false,
    'Гепатология': false,
    'ТЭЛА': false,
    'Педиатрия': false,
    'Электролиты': false,
    'Ожоги': false,
    'Питание и нутритивная поддержка': false,
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

    final String q = query.toLowerCase().replaceAll('ё', 'е').trim();

    final String text = '${item.name} ${item.search}'.toLowerCase().replaceAll(
      'ё',
      'е',
    );

    return text.contains(q);
  }

  void openCalculator(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ===============================
  // БЕЗОПАСНЫЙ ПОИСК КАЛЬКУЛЯТОРА
  // ===============================
  //
  // Именно это защищает группы от
  // сдвига индексов.
  // ===============================

  CalculatorItem calculatorByName(String name) {
    return allCalculators.firstWhere((item) => item.name == name);
  }

  // ===============================
  // ПОИСКАННЫЕ КАЛЬКУЛЯТОРЫ
  // ===============================

  List<CalculatorItem> get filtered {
    return allCalculators
        .where((item) => matchesSearch(item, searchText))
        .toList();
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
            item.emoji != null
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: Text(
                        item.emoji!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.calculate_outlined,
                    color: Color(0xFF86BBD8),
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
  // КНОПКА СМА
  // ===============================

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
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 72, 117, 134),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💉', style: TextStyle(fontSize: 22)),
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
  // ЗАГОЛОВОК ГРУППЫ
  // ===============================

  Widget groupHeader(String title, String emoji, Color color) {
    final bool expanded = expandedGroups[title] ?? false;

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

  // ===============================
  // РАСКРЫВАЕМАЯ ГРУППА
  // ===============================

  Widget expandableGroup(
    String title,
    String emoji,
    Color color,
    List<CalculatorItem> items,
  ) {
    bool expanded = expandedGroups[title] ?? false;

    final List<CalculatorItem> visible = items
        .where((item) => matchesSearch(item, searchText))
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
                  children: visible
                      .map((item) => calculatorButton(item))
                      .toList(),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  // ===============================
  // СПИСКИ ГРУПП
  // ===============================
  //
  // НИКАКИХ allCalculators[23],
  // allCalculators[24] и т.п.
  //
  // Поэтому Child-Pugh, Mg,
  // новый калькулятор и любые
  // будущие изменения не ломают
  // существующие группы.
  // ===============================

  Widget groupsWidget() {
    return Column(
      children: [
        // ===============================
        // ДЫХАНИЕ И ВЕНТИЛЯЦИЯ
        // ===============================
        expandableGroup('Дыхание и вентиляция', '🫁', const Color(0xFF3F6F8F), [
          calculatorByName('Дыхательный объём ИВЛ'),
          calculatorByName('Респираторный индекс'),
          calculatorByName('CPIS'),
        ]),

        // ===============================
        // НЕВРОЛОГИЯ
        // ===============================
        expandableGroup(
          'Неврология и сознание',
          '🧠',
          const Color(0xFF7E6AA2),
          [
            calculatorByName('GCS — шкала комы Глазго'),
            calculatorByName('FOUR'),
            calculatorByName('NIHSS'),
            calculatorByName('Hunt-Hess'),
            calculatorByName('RASS'),
          ],
        ),

        // ===============================
        // ТЯЖЕСТЬ СОСТОЯНИЯ
        // ===============================
        expandableGroup(
          'Тяжесть состояния пациента',
          '🏥',
          const Color(0xFF81A878),
          [calculatorByName('SOFA'), calculatorByName('APACHE II')],
        ),

        // ===============================
        // КАРДИОЛОГИЯ
        // ===============================
        expandableGroup('Кардиология', '❤️', const Color(0xFFB0B7B8), [
          calculatorByName('GRACE'),
          calculatorByName('Killip'),
          calculatorByName('CHA₂DS₂-VASc'),
        ]),

        // ===============================
        // ГЕПАТОЛОГИЯ
        // ===============================
        expandableGroup(
          'Гепатология',
          '🔬',
          const Color.fromARGB(255, 168, 87, 54),
          [calculatorByName('Child–Pugh (Чайлд–Пью)')],
        ),

        // ===============================
        // ТЭЛА
        // ===============================
        expandableGroup('ТЭЛА', '🫁', const Color.fromARGB(255, 145, 91, 182), [
          calculatorByName('PESI'),
          calculatorByName('Geneva'),
          calculatorByName('Wells'),
          calculatorByName('Padua'),
        ]),

        // ===============================
        // ПЕДИАТРИЯ
        // ===============================
        expandableGroup('Педиатрия', '👶', const Color(0xFF4F8A70), [
          calculatorByName('Инфузия у детей'),
        ]),

        // ===============================
        // ЭЛЕКТРОЛИТЫ
        // ===============================
        expandableGroup('Электролиты', '⚡', const Color(0xFFB08A45), [
          calculatorByName('Электролитный расчёт'),
        ]),

        // ===============================
        // ОЖОГИ
        // ===============================
        expandableGroup('Ожоги', '🔥', const Color(0xFF9A6139), [
          calculatorByName('Паркланд'),
          calculatorByName('Эванс — ожоговая инфузия'),
        ]),

        // ===============================
        // ПИТАНИЕ И НУТРИТИВНАЯ ПОДДЕРЖКА
        // ===============================
        expandableGroup(
          'Питание и нутритивная поддержка',
          '🥗',
          const Color(0xFF4F8A70),
          [calculatorByName('Нутритивная поддержка')],
        ),
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
            Text('🩺 ', style: TextStyle(fontSize: 20)),
            Text(
              'Калькулятор\nреаниматолога',
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
            // ===============================
            // ПОИСК
            // ===============================
            TextField(
              controller: searchController,
              onChanged: (value) {
                searchTimer?.cancel();

                searchTimer = Timer(const Duration(milliseconds: 250), () {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    searchText = value;
                  });
                });
              },
              decoration: InputDecoration(
                hintText: 'Поиск калькулятора...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===============================
            // БЫСТРЫЙ ДОСТУП
            // ===============================
            if (searchText.isEmpty) ...[
              calculatorButton(calculatorByName('ИМТ')),

              calculatorButton(calculatorByName('Расчёт скорости инфузии')),

              calculatorButton(calculatorByName('СКФ')),

              calculatorButton(calculatorByName('Харрис-Бенедикт')),

              smaButton(calculatorByName('Расчёт для СМА')),
            ],

            // ===============================
            // ПОИСК
            // ===============================
            if (searchText.isNotEmpty)
              ...filtered.map((item) => calculatorButton(item)),

            // ===============================
            // ГРУППЫ
            // ===============================
            if (searchText.isEmpty) groupsWidget(),

            const SizedBox(height: 30),

            // ===============================
            // ПОДПИСЬ АВТОРА
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
                        'Автор: Рожко А.Ю.',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),

                      Text(
                        'Калькулятор реаниматолога v2.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF95C7F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '• Пр. созд. 25.07.2026\n'
                        '• Обновлено 25.09.2026',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
