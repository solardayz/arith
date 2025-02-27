import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arithmetic Game',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: SplashScreen(), // 시작 화면을 스플래시 화면으로 지정
    );
  }
}

// 스플래시 화면: 앱 아이콘을 보여주고 2초 후 이름 입력 화면으로 전환
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => NameInputScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: SvgPicture.asset(
          'assets/app_icon.svg',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

class NameInputScreen extends StatefulWidget {
  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _showStartGameDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name님, 사칙연산 게임을 시작해 볼까요?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ArithmeticGameScreen(name: name),
                ),
              );
            },
            child: Text('네'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('아쉽네요 다음에 봐요')),
              );
              _nameController.clear(); // 텍스트 필드 초기화
            },
            child: Text('아니오'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사칙연산 게임 시작하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  _showStartGameDialog(name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이름을 입력해주세요')),
                  );
                }
              },
              child: Text('확인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.yellow[100],
    );
  }
}

class ArithmeticGameScreen extends StatefulWidget {
  final String name;
  const ArithmeticGameScreen({Key? key, required this.name}) : super(key: key);

  @override
  _ArithmeticGameScreenState createState() => _ArithmeticGameScreenState();
}

class _ArithmeticGameScreenState extends State<ArithmeticGameScreen> {
  final TextEditingController _answerController = TextEditingController();
  int score = 0;
  late int operand1;
  late int operand2;
  late String operator;
  late int correctAnswer;
  String resultMessage = '';

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  // 문제 생성: 사칙연산 중 무작위 선택, 최대 2자리 수
  void _generateProblem() {
    int opType = _random.nextInt(4); // 0: +, 1: -, 2: *, 3: /
    switch (opType) {
      case 0: // 덧셈
        operand1 = _random.nextInt(100);
        operand2 = _random.nextInt(100);
        operator = '+';
        correctAnswer = operand1 + operand2;
        break;
      case 1: // 뺄셈 (음수 방지)
        operand1 = _random.nextInt(100);
        operand2 = _random.nextInt(100);
        if (operand1 < operand2) {
          int temp = operand1;
          operand1 = operand2;
          operand2 = temp;
        }
        operator = '-';
        correctAnswer = operand1 - operand2;
        break;
      case 2: // 곱셈
        operand1 = _random.nextInt(100);
        operand2 = _random.nextInt(100);
        operator = '×';
        correctAnswer = operand1 * operand2;
        break;
      case 3: // 나눗셈: 1~9 범위의 divisor와 quotient (정수 몫)
        operand2 = _random.nextInt(9) + 1; // 1~9
        int quotient = _random.nextInt(10); // 0~9
        operand1 = operand2 * quotient;
        operator = '÷';
        correctAnswer = quotient;
        break;
    }
    _answerController.clear();
  }

  // 답안 체크: 정답이면 +1, 틀리면 -1
  void _checkAnswer() {
    String answerText = _answerController.text.trim();
    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('답을 입력해주세요!')),
      );
      return;
    }

    int? userAnswer = int.tryParse(answerText);
    if (userAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('숫자만 입력해주세요!')),
      );
      return;
    }

    if (userAnswer == correctAnswer) {
      setState(() {
        score++;
        resultMessage = '정답입니다! +1 점';
      });
    } else {
      setState(() {
        score--;
        resultMessage = '오답입니다! 정답은 $correctAnswer 입니다. -1 점';
      });
    }

    // 1초 후에 새 문제 생성 및 메시지 초기화
    Timer(Duration(seconds: 1), () {
      setState(() {
        _generateProblem();
        resultMessage = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 결과 메시지 색상: 정답은 녹색, 오답은 빨간색
    final Color resultColor = resultMessage.contains('정답')
        ? Colors.green
        : resultMessage.contains('오답')
        ? Colors.red
        : Colors.black;

    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text('사칙연산 게임'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '안녕, ${widget.name}님! 점수: $score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 30),
            // 문제를 감싸는 카드 형태의 컨테이너
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                '$operand1 $operator $operand2 = ?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '답을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orange,
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('입력'),
            ),
            SizedBox(height: 20),
            Text(
              resultMessage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
