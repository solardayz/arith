import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '더하기 게임',
      home: NameInputScreen(),
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
        title: Text('$name님, 더하기 게임을 시작해 볼까요?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdditionGameScreen(name: name),
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
        title: Text('더하기 게임 시작하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름을 입력하세요'),
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
            ),
          ],
        ),
      ),
    );
  }
}

class AdditionGameScreen extends StatelessWidget {
  final String name;
  const AdditionGameScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 실제 더하기 게임 로직은 여기서 추가하면 됩니다.
    return Scaffold(
      appBar: AppBar(
        title: Text('더하기 게임'),
      ),
      body: Center(
        child: Text(
          '$name님의 더하기 게임 시작!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
