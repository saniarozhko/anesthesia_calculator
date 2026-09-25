import 'package:flutter/material.dart';

/// Калькулятор нутритивной поддержки.
///
/// Вводятся только: пол, возраст, рост, масса.
/// Далее можно выбрать день энтерального питания и вручную указать
/// фактические объёмы растворов/смесей.
///
/// ВАЖНО:
/// - Peptamen AF: 1.5 ккал/мл, 94 г белка/л, 66 г жира/л.
///   Углеводы рассчитаны из 36% энергии: 0.135 г/мл.
/// - Для растворов аминокислот, где известен общий азот,
///   белковый эквивалент = азот × 6.25.
/// - Альбумин выводится отдельно и НЕ включается в основной
///   нутритивный калораж.
/// - Для Гепавила используется масса указанных в инструкции
///   BCAA (9.6 г/400 мл) как белковый эквивалент, поскольку
///   в используемой инструкции общий азот отдельно не указан.
///
/// Значения препаратов необходимо сверять с локальной инструкцией
/// и фактической концентрацией препарата в учреждении перед клиническим
/// использованием.

class NutritionalSupportScreen extends StatefulWidget {
  const NutritionalSupportScreen({super.key});

  @override
  State<NutritionalSupportScreen> createState() =>
      _NutritionalSupportScreenState();
}

class _NutritionalSupportScreenState extends State<NutritionalSupportScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final Map<String, TextEditingController> _volumeControllers = {
    'peptamen': TextEditingController(),
    'glucose5': TextEditingController(),
    'glucose10': TextEditingController(),
    'intralipid': TextEditingController(),
    'vamin': TextEditingController(),
    'aminosteril': TextEditingController(),
    'hepavil': TextEditingController(),
    'albumin10': TextEditingController(),
    'albumin20': TextEditingController(),
  };

  bool _isMale = true;
  bool _enteral = true;
  int _dayIndex = 0;

  // Пн–Вс: ккал и белок из больничного энтерального рациона.
  final List<_DailyEnteral> _days = const [
    _DailyEnteral('Понедельник', 2419, 95.0),
    _DailyEnteral('Вторник', 2462, 85.76),
    _DailyEnteral('Среда', 2043, 87.9),
    _DailyEnteral('Четверг', 2232, 85.44),
    _DailyEnteral('Пятница', 2438, 109.0),
    _DailyEnteral('Суббота', 2130, 86.4),
    _DailyEnteral('Воскресенье', 2216, 88.3),
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    for (final controller in _volumeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _number(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  double get _age => _number(_ageController.text);
  double get _height => _number(_heightController.text);
  double get _weight => _number(_weightController.text);

  double get _bmi {
    if (_height <= 0 || _weight <= 0) return 0;
    final h = _height / 100;
    return _weight / (h * h);
  }

  /// Harris–Benedict, как на представленном листе.
  double get _basalEnergy {
    if (_weight <= 0 || _height <= 0 || _age <= 0) return 0;

    if (_isMale) {
      return 66.47 + (13.75 * _weight) + (5.0 * _height) - (6.76 * _age);
    }

    return 655.1 + (9.56 * _weight) + (1.85 * _height) - (4.68 * _age);
  }

  // Расчётная энергетическая потребность по диапазону 25–30 ккал/кг/сут.
  double get _energyLow => _weight * 25;
  double get _energyHigh => _weight * 30;

  // Средняя точка диапазона используется только как контрольная цифра
  // для процента покрытия, а не как отдельная медицинская рекомендация.
  double get _energyReference => _weight * 27.5;

  double get _proteinTarget => _weight * 1.3;
  double get _glucoseLow => _weight * 4;
  double get _glucoseHigh => _weight * 6;
  double get _fatLow => _weight * 1;
  double get _fatHigh => _weight * 2;
  double get _fluidLow => _weight * 20;
  double get _fluidHigh => _weight * 40;

  double _volume(String key) => _number(_volumeControllers[key]!.text);

  _DailyEnteral get _selectedDay => _days[_dayIndex];

  _NutritionTotals get _totals {
    double kcal = 0;
    double protein = 0;
    double aminoAcids = 0;
    double nitrogen = 0;
    double glucose = 0;
    double fat = 0;
    double fluid = 0;

    // Энтеральный рацион по выбранному дню.
    if (_enteral) {
      kcal += _selectedDay.kcal;
      protein += _selectedDay.protein;
      fluid += 0; // Объём больничного рациона не задан пользователем.
    }

    // Peptamen AF:
    // 1.5 kcal/ml; 94 g protein/L; 66 g fat/L;
    // 36% энергии из углеводов -> 0.135 g carbohydrate/ml.
    final peptamen = _volume('peptamen');
    kcal += peptamen * 1.5;
    protein += peptamen * 0.094;
    fat += peptamen * 0.066;
    glucose += peptamen * 0.135;
    fluid += peptamen;

    // Глюкоза 5%.
    final glucose5 = _volume('glucose5');
    kcal += glucose5 * 0.17;
    glucose += glucose5 * 0.05;
    fluid += glucose5;

    // Глюкоза 10%.
    final glucose10 = _volume('glucose10');
    kcal += glucose10 * 0.34;
    glucose += glucose10 * 0.10;
    fluid += glucose10;

    // Intralipid 20%: 200 g fat/L, 2000 kcal/L.
    final intralipid = _volume('intralipid');
    kcal += intralipid * 2.0;
    fat += intralipid * 0.20;
    fluid += intralipid;

    // Vamin 18: 114 g AA/L, 18 g N/L, 460 kcal/L.
    final vamin = _volume('vamin');
    final vaminAa = vamin * 0.114;
    final vaminN = vamin * 0.018;
    aminoAcids += vaminAa;
    nitrogen += vaminN;
    protein += vaminN * 6.25;
    kcal += vamin * 0.46;
    fluid += vamin;

    // Aminosteril N-Hepa 8%:
    // 80 g AA/L, 12.9 g N/L, 320 kcal/L.
    final aminosteril = _volume('aminosteril');
    final aminosterilAa = aminosteril * 0.080;
    final aminosterilN = aminosteril * 0.0129;
    aminoAcids += aminosterilAa;
    nitrogen += aminosterilN;
    protein += aminosterilN * 6.25;
    kcal += aminosteril * 0.32;
    fluid += aminosteril;

    // Гепавил 400 мл:
    // 9.6 г BCAA + 40 г безводной глюкозы на 400 мл.
    // Энергия глюкозы считается как 4 kcal/g.
    final hepavil = _volume('hepavil');
    final hepavilAa = hepavil * (9.6 / 400);
    final hepavilGlucose = hepavil * (40 / 400);
    aminoAcids += hepavilAa;
    protein += hepavilAa;
    glucose += hepavilGlucose;
    kcal += hepavilGlucose * 4;
    fluid += hepavil;

    // Альбумин учитываем в отдельном поле белка,
    // но не добавляем его в основной нутритивный калораж.
    final albumin10 = _volume('albumin10');
    final albumin20 = _volume('albumin20');
    final albuminProtein = albumin10 * 0.10 + albumin20 * 0.20;
    final albuminFluid = albumin10 + albumin20;

    fluid += albuminFluid;

    return _NutritionTotals(
      kcal: kcal,
      protein: protein,
      aminoAcids: aminoAcids,
      nitrogen: nitrogen,
      glucose: glucose,
      fat: fat,
      fluid: fluid,
      albuminProtein: albuminProtein,
      albuminFluid: albuminFluid,
    );
  }

  void _recalculate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;
    final hasPatient = _weight > 0 && _height > 0 && _age > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101114),
        elevation: 0,
        title: const Text(
          '🥗 Нутритивная поддержка',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
          children: [
            _section(
              icon: '👤',
              title: 'Пациент',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _ageController,
                          label: 'Возраст',
                          suffix: 'лет',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _numberField(
                          controller: _heightController,
                          label: 'Рост',
                          suffix: 'см',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _numberField(
                          controller: _weightController,
                          label: 'Масса',
                          suffix: 'кг',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _choiceButton(
                          title: '♂ Мужчина',
                          selected: _isMale,
                          onTap: () {
                            setState(() => _isMale = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _choiceButton(
                          title: '♀ Женщина',
                          selected: !_isMale,
                          onTap: () {
                            setState(() => _isMale = false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (hasPatient) ...[
              _section(
                icon: '🔥',
                title: 'Расчёт потребности',
                child: Column(
                  children: [
                    _resultTile('ИМТ', '${_fmt(_bmi)} кг/м²', icon: '⚖️'),
                    _resultTile(
                      'Основной обмен (Harris–Benedict)',
                      '${_fmt0(_basalEnergy)} ккал/сут',
                      icon: '🔥',
                    ),
                    _resultTile(
                      'Энергия 25–30 ккал/кг',
                      '${_fmt0(_energyLow)}–${_fmt0(_energyHigh)} ккал/сут',
                      icon: '⚡',
                    ),
                    _resultTile(
                      'Контрольная точка',
                      '${_fmt0(_energyReference)} ккал/сут '
                          '(${_fmt(_energyReference / _weight)} ккал/кг)',
                      icon: '🎯',
                    ),
                    _resultTile(
                      'Белок',
                      '${_fmt(_proteinTarget)} г/сут '
                          '(${_fmt(_proteinTarget / _weight)} г/кг)',
                      icon: '🥩',
                    ),
                  ],
                ),
              ),
            ],

            _section(
              icon: '🍽️',
              title: 'Энтеральное питание',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _choiceButton(
                          title: 'Нет',
                          selected: !_enteral,
                          onTap: () {
                            setState(() => _enteral = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _choiceButton(
                          title: 'Да',
                          selected: _enteral,
                          onTap: () {
                            setState(() => _enteral = true);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_enteral) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'День недели',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _dayIndex,
                      dropdownColor: const Color(0xFF202228),
                      decoration: _inputDecoration('Выберите день'),
                      items: List.generate(
                        _days.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            '${_days[index].name} — '
                            '${_fmt0(_days[index].kcal)} ккал / '
                            '${_fmt(_days[index].protein)} г белка',
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _dayIndex = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _infoCard(
                      'За выбранный день',
                      '${_fmt0(_selectedDay.kcal)} ккал • '
                          '${_fmt(_selectedDay.protein)} г белка',
                      '📅',
                    ),
                  ],
                ],
              ),
            ),

            _section(
              icon: '🥤',
              title: 'Энтеральная смесь',
              child: Column(
                children: [
                  _volumeField(
                    keyName: 'peptamen',
                    title: 'Peptamen AF',
                    subtitle: '1,5 ккал/мл • 94 г белка/л • 66 г жира/л',
                  ),
                ],
              ),
            ),

            _section(
              icon: '💉',
              title: 'Парентеральное питание',
              child: Column(
                children: [
                  _volumeField(
                    keyName: 'glucose5',
                    title: 'Глюкоза 5%',
                    subtitle: '50 г глюкозы/л',
                  ),
                  _volumeField(
                    keyName: 'glucose10',
                    title: 'Глюкоза 10%',
                    subtitle: '100 г глюкозы/л',
                  ),
                  _volumeField(
                    keyName: 'intralipid',
                    title: 'Интралипид 20%',
                    subtitle: '200 г жира/л • 2000 ккал/л',
                  ),
                  _volumeField(
                    keyName: 'vamin',
                    title: 'Вамин 18',
                    subtitle: '114 г аминокислот/л • 18 г азота/л',
                  ),
                  _volumeField(
                    keyName: 'aminosteril',
                    title: 'Аминостерил Н-Гепа 8%',
                    subtitle: '80 г аминокислот/л • 12,9 г азота/л',
                  ),
                  _volumeField(
                    keyName: 'hepavil',
                    title: 'Гепавил',
                    subtitle: '9,6 г BCAA + 40 г глюкозы/400 мл',
                  ),
                  _volumeField(
                    keyName: 'albumin10',
                    title: 'Альбумин 10%',
                    subtitle:
                        '10 г белка/100 мл • отдельно от нутритивных ккал',
                  ),
                  _volumeField(
                    keyName: 'albumin20',
                    title: 'Альбумин 20%',
                    subtitle:
                        '20 г белка/100 мл • отдельно от нутритивных ккал',
                  ),
                ],
              ),
            ),

            _section(
              icon: '📊',
              title: 'Итоговое поступление',
              child: Column(
                children: [
                  _bigResult(
                    '🔥',
                    'Энергия',
                    '${_fmt0(totals.kcal)} ккал/сут',
                    hasPatient && _weight > 0
                        ? '${_fmt(totals.kcal / _weight)} ккал/кг'
                        : '',
                  ),
                  _bigResult(
                    '🥩',
                    'Белковый эквивалент',
                    '${_fmt(totals.protein)} г/сут',
                    hasPatient && _weight > 0
                        ? '${_fmt(totals.protein / _weight)} г/кг'
                        : '',
                  ),
                  _bigResult(
                    '🍬',
                    'Глюкоза',
                    '${_fmt(totals.glucose)} г/сут',
                    hasPatient && _weight > 0
                        ? '${_fmt(totals.glucose / _weight)} г/кг'
                        : '',
                  ),
                  _bigResult(
                    '🫒',
                    'Жиры',
                    '${_fmt(totals.fat)} г/сут',
                    hasPatient && _weight > 0
                        ? '${_fmt(totals.fat / _weight)} г/кг'
                        : '',
                  ),
                  _bigResult(
                    '💧',
                    'Жидкость',
                    '${_fmt0(totals.fluid)} мл/сут',
                    hasPatient && _weight > 0
                        ? '${_fmt(totals.fluid / _weight)} мл/кг'
                        : '',
                  ),
                  const SizedBox(height: 6),
                  _infoCard(
                    'Аминокислоты → белок',
                    'Аминокислоты: ${_fmt(totals.aminoAcids)} г • '
                        'азот: ${_fmt(totals.nitrogen)} г • '
                        'белковый эквивалент: ${_fmt(totals.protein - (_enteral ? _selectedDay.protein : 0) - totals.albuminProtein)} г',
                    '🧪',
                  ),
                  if (totals.albuminProtein > 0)
                    _infoCard(
                      'Альбумин отдельно',
                      '${_fmt(totals.albuminProtein)} г белка '
                          '(${_fmt0(totals.albuminFluid)} мл)',
                      '🩸',
                    ),
                ],
              ),
            ),

            _section(
              icon: '📋',
              title: 'Энергетически-субстратное обеспечение пациента',
              child: _substrateTable(totals),
            ),

            _section(
              icon: '🔎',
              title: 'Проверка покрытия потребности',
              child: _coverage(totals),
            ),

            const SizedBox(height: 10),
            const Text(
              'Расчёт является вспомогательным. Перед назначением необходимо '
              'сверять состав и концентрацию конкретного препарата по '
              'локальной инструкции/упаковке и оценивать клиническое состояние пациента.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _substrateTable(_NutritionTotals totals) {
    final patientReady = _weight > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Норма и фактическое поступление рассчитываются автоматически.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF292D35)),
            dataRowMinHeight: 58,
            dataRowMaxHeight: 76,
            columns: const [
              DataColumn(label: Text('Субстрат')),
              DataColumn(label: Text('Норма')),
              DataColumn(label: Text('Расчёт\nпациента')),
              DataColumn(label: Text('Фактически')),
              DataColumn(label: Text('На кг')),
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(Text('Энергия')),
                  DataCell(Text('25–30\nккал/кг')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt0(_energyLow)}–${_fmt0(_energyHigh)} ккал'
                          : '—',
                    ),
                  ),
                  DataCell(Text('${_fmt0(totals.kcal)} ккал')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(totals.kcal / _weight)} ккал/кг'
                          : '—',
                    ),
                  ),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('Белок')),
                  const DataCell(Text('1,3\nг/кг')),
                  DataCell(
                    Text(patientReady ? '${_fmt(_proteinTarget)} г' : '—'),
                  ),
                  DataCell(Text('${_fmt(totals.protein)} г')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(totals.protein / _weight)} г/кг'
                          : '—',
                    ),
                  ),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('Глюкоза')),
                  const DataCell(Text('4–6\nг/кг')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(_glucoseLow)}–${_fmt(_glucoseHigh)} г'
                          : '—',
                    ),
                  ),
                  DataCell(Text('${_fmt(totals.glucose)} г')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(totals.glucose / _weight)} г/кг'
                          : '—',
                    ),
                  ),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('Жиры')),
                  const DataCell(Text('1–2\nг/кг')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(_fatLow)}–${_fmt(_fatHigh)} г'
                          : '—',
                    ),
                  ),
                  DataCell(Text('${_fmt(totals.fat)} г')),
                  DataCell(
                    Text(
                      patientReady ? '${_fmt(totals.fat / _weight)} г/кг' : '—',
                    ),
                  ),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('Жидкость')),
                  const DataCell(Text('20–40\nмл/кг')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt0(_fluidLow)}–${_fmt0(_fluidHigh)} мл'
                          : '—',
                    ),
                  ),
                  DataCell(Text('${_fmt0(totals.fluid)} мл')),
                  DataCell(
                    Text(
                      patientReady
                          ? '${_fmt(totals.fluid / _weight)} мл/кг'
                          : '—',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Для больничного энтерального рациона по дням известны '
          'ккал и белок. Его углеводы, жиры и объём жидкости здесь '
          'не распределяются искусственно без данных состава рациона.',
          style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Widget _coverage(_NutritionTotals totals) {
    if (_weight <= 0) {
      return const Text(
        'Введите возраст, рост и массу пациента.',
        style: TextStyle(color: Colors.white60),
      );
    }

    final energyPercent = _energyReference > 0
        ? totals.kcal / _energyReference * 100
        : 0.0;
    final proteinPercent = _proteinTarget > 0
        ? totals.protein / _proteinTarget * 100
        : 0.0;

    return Column(
      children: [
        _coverageRow(
          'Энергия',
          '${_fmt0(_energyLow)}–${_fmt0(_energyHigh)} ккал',
          '${_fmt0(totals.kcal)} ккал',
          _between(totals.kcal, _energyLow, _energyHigh),
          '${_fmt(energyPercent)}% от контрольной точки 27,5 ккал/кг',
        ),
        _coverageRow(
          'Белок',
          '${_fmt(_proteinTarget)} г',
          '${_fmt(totals.protein)} г',
          totals.protein >= _proteinTarget,
          '${_fmt(proteinPercent)}% от 1,3 г/кг',
        ),
        _coverageRow(
          'Глюкоза',
          '${_fmt(_glucoseLow)}–${_fmt(_glucoseHigh)} г',
          '${_fmt(totals.glucose)} г',
          _between(totals.glucose, _glucoseLow, _glucoseHigh),
          '${_fmt(totals.glucose / _weight)} г/кг',
        ),
        _coverageRow(
          'Жиры',
          '${_fmt(_fatLow)}–${_fmt(_fatHigh)} г',
          '${_fmt(totals.fat)} г',
          _between(totals.fat, _fatLow, _fatHigh),
          '${_fmt(totals.fat / _weight)} г/кг',
        ),
        _coverageRow(
          'Жидкость',
          '${_fmt0(_fluidLow)}–${_fmt0(_fluidHigh)} мл',
          '${_fmt0(totals.fluid)} мл',
          _between(totals.fluid, _fluidLow, _fluidHigh),
          '${_fmt(totals.fluid / _weight)} мл/кг',
        ),
      ],
    );
  }

  bool _between(double value, double low, double high) {
    if (value == 0) return false;
    return value >= low && value <= high;
  }

  Widget _coverageRow(
    String title,
    String target,
    String actual,
    bool ok,
    String detail,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C21),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            ok ? '✓' : '!',
            style: TextStyle(
              color: ok ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Цель: $target • Получено: $actual',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _volumeField({
    required String keyName,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191B20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: TextField(
              controller: _volumeControllers[keyName],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              onChanged: (_) => _recalculate(),
              decoration: _inputDecoration('мл'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _recalculate(),
      decoration: _inputDecoration(label).copyWith(suffixText: suffix),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF1A1C21),
      labelStyle: const TextStyle(color: Colors.white60),
      suffixStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E9CFF), width: 1.2),
      ),
    );
  }

  Widget _choiceButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFF2A6EF5) : const Color(0xFF1B1D22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15171C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF242831),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  Widget _resultTile(String title, String value, {required String icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C21),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _bigResult(String icon, String title, String value, String perKg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C21),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 25)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (perKg.isNotEmpty)
            Text(
              perKg,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, String icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF20242C),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double value) {
    if (value.abs() < 0.005) return '0';
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }

  String _fmt0(double value) {
    return value.round().toString();
  }
}

class _DailyEnteral {
  final String name;
  final double kcal;
  final double protein;

  const _DailyEnteral(this.name, this.kcal, this.protein);
}

class _NutritionTotals {
  final double kcal;
  final double protein;
  final double aminoAcids;
  final double nitrogen;
  final double glucose;
  final double fat;
  final double fluid;
  final double albuminProtein;
  final double albuminFluid;

  const _NutritionTotals({
    required this.kcal,
    required this.protein,
    required this.aminoAcids,
    required this.nitrogen,
    required this.glucose,
    required this.fat,
    required this.fluid,
    required this.albuminProtein,
    required this.albuminFluid,
  });
}
