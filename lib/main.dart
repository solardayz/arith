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

// 이름 입력 및 게임 시작 화면
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

// _ArithmeticGameScreenState에 TickerProviderStateMixin을 추가하여 애니메이션 컨트롤러를 사용할 수 있습니다.
class ArithmeticGameScreen extends StatefulWidget {
  final String name;
  const ArithmeticGameScreen({Key? key, required this.name}) : super(key: key);

  @override
  _ArithmeticGameScreenState createState() => _ArithmeticGameScreenState();
}

class _ArithmeticGameScreenState extends State<ArithmeticGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _answerFocusNode = FocusNode();

  int score = 0;
  late int operand1;
  late int operand2;
  late String operator;
  late int correctAnswer;
  String resultMessage = '';

  final Random _random = Random();

  // 카운트다운 관련 변수
  int _timeLeft = 10;
  Timer? _countdownTimer;

  // 애니메이션 관련 변수 (남은 시간이 5초 미만일 때 작동)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _generateProblem();
    _startCountdown();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.red, end: Colors.blue), weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.blue, end: Colors.green), weight: 1),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.red), weight: 1),
    ]).animate(_animationController);

    _answerFocusNode.addListener(() {
      if (_answerFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    _answerFocusNode.dispose();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _timeLeft = 10;
    });
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        // 5초 미만이면 애니메이션 시작, 그렇지 않으면 중지
        if (_timeLeft < 5 && !_animationController.isAnimating) {
          _animationController.repeat(reverse: true);
        } else if (_timeLeft >= 5 && _animationController.isAnimating) {
          _animationController.stop();
        }
      } else {
        timer.cancel();
        _handleTimeOut();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
  }

  // 타임아웃 시 오답 처리
  void _handleTimeOut() {
    setState(() {
      score--;
      resultMessage = '시간 초과! 정답은 $correctAnswer 입니다. -1 점';
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _generateProblem();
        resultMessage = '';
        _startCountdown();
      });
    });
  }

  // 문제 생성: 사칙연산 중 무작위 선택, 최대 2자리 수
  void _generateProblem() {
    int opType = _random.nextInt(4); // 0: +, 1: -, 2: *, 3: /
    switch (opType) {
      case 0:
        operand1 = _random.nextInt(100);
        operand2 = _random.nextInt(100);
        operator = '+';
        correctAnswer = operand1 + operand2;
        break;
      case 1:
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
      case 2:
        operand1 = _random.nextInt(100);
        operand2 = _random.nextInt(100);
        operator = '×';
        correctAnswer = operand1 * operand2;
        break;
      case 3:
        operand2 = _random.nextInt(9) + 1;
        int quotient = _random.nextInt(10);
        operand1 = operand2 * quotient;
        operator = '÷';
        correctAnswer = quotient;
        break;
    }
    _answerController.clear();
  }

  // 답안 체크: 정답이면 +1, 틀리면 -1 (답 입력 시 타이머 취소)
  void _checkAnswer() {
    _cancelCountdown();
    String answerText = _answerController.text.trim();
    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('답을 입력해주세요!')),
      );
      _startCountdown();
      return;
    }

    int? userAnswer = int.tryParse(answerText);
    if (userAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('숫자만 입력해주세요!')),
      );
      _startCountdown();
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

    // 2초 후에 새 문제 생성 및 메시지 초기화
    Timer(Duration(seconds: 2), () {
      setState(() {
        _generateProblem();
        resultMessage = '';
        _startCountdown();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color resultColor = resultMessage.contains('정답')
        ? Colors.green
        : resultMessage.contains('오답')
        ? Colors.red
        : Colors.black;

    // 남은 시간을 표시하는 위젯 (5초 미만일 때는 애니메이션 적용)
    Widget countdownWidget;
    if (_timeLeft < 5) {
      countdownWidget = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              '남은 시간: $_timeLeft초',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _colorAnimation.value,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    } else {
      countdownWidget = Text(
        '남은 시간: $_timeLeft초',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text('사칙연산 게임'),
        backgroundColor: Colors.orange,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단: 앱 아이콘, 점수, 애니메이션 적용된 남은 시간
                    SvgPicture.asset(
                      'assets/app_icon.svg',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '안녕, ${widget.name}님! 점수: $score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    countdownWidget,
                    SizedBox(height: 20),
                    // 문제 컨테이너
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 문제 바로 아래에 정답/오답 메시지
                    SizedBox(height: 10),
                    Text(
                      resultMessage,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // 답 입력 필드
                    TextField(
                      focusNode: _answerFocusNode,
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
                    // 입력 버튼
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.orange,
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      child: Text('입력'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
