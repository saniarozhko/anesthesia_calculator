import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final ScrollController _scrollController = ScrollController();

  bool isMale = true;

  final heightController = TextEditingController();

  final weightController = TextEditingController();

  String result = "";

  void calculateBMI() {
    double height = double.parse(heightController.text) / 100;

    double weight = double.parse(weightController.text);

    double bmi = weight / (height * height);

    String category;

    if (bmi < 18.5) {
      category = "Дефицит массы тела";
    } else if (bmi < 25) {
      category = "Норма";
    } else if (bmi < 30) {
      category = "Избыточная масса тела";
    } else if (bmi < 35) {
      category = "Ожирение I степени";
    } else if (bmi < 40) {
      category = "Ожирение II степени";
    } else {
      category = "Ожирение III степени";
    }

    setState(() {
      result =
          "ИМТ: ${bmi.toStringAsFixed(1)}\n\n"
          "$category";
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,

        duration: const Duration(milliseconds: 500),

        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📏 Расчет ИМТ")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          controller: _scrollController,

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMale ? Colors.blue : Colors.grey,

                      minimumSize: const Size(130, 50),
                    ),

                    onPressed: () {
                      setState(() {
                        isMale = true;
                      });
                    },

                    child: const Text(
                      "👨 Мужской",

                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isMale ? Colors.pink : Colors.grey,

                      minimumSize: const Size(130, 50),
                    ),

                    onPressed: () {
                      setState(() {
                        isMale = false;
                      });
                    },

                    child: const Text(
                      "👩 Женский",

                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              TextField(
                controller: heightController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: "Рост (см)"),
              ),

              TextField(
                controller: weightController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: "Вес (кг)"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: calculateBMI,

                child: const Text("РАССЧИТАТЬ", style: TextStyle(fontSize: 20)),
              ),

              const SizedBox(height: 30),

              Text(
                result,

                style: const TextStyle(fontSize: 22),

                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
