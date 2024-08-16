import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:taptune/taptune.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapTuneSDK 演示 APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.125,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String sdkInput = "";
  double fontSize = 18.0;
  bool isDarkMode = false;
  bool isLoading = false; // 用来管理加载状态
  late TapTuneSDK tapTuneSDK;
  final TextEditingController _controller = TextEditingController(); // 控制输入框

  @override
  void initState() {
    super.initState();
    initializeSDK(); // 在这里初始化您的 SDK
  }

  Future<void> initializeSDK() async {
    tapTuneSDK = TapTuneSDK();
    tapTuneSDK.init(
      appID: 'appid0001',
      knowledgeBase: [],
      callback: (id, param) {
        print(id);
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// 封装切换深色模式的函数
  void _toggleDarkMode(bool enable) {
    setState(() {
      isDarkMode = enable;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('深色模式已${enable ? '开启' : '关闭'}')),
    );
  }

  /// 封装切换字体大小的函数
  void _setFontSize(String newSize) {
    double size;
    switch (newSize) {
      case '小':
        size = 14.0;
        break;
      case '标准':
        size = 18.0;
        break;
      case '大':
        size = 22.0;
        break;
      default:
        size = fontSize; // 保持当前字体大小
    }

    setState(() {
      fontSize = size;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('字体大小已调整为: $newSize')),
    );
  }

  Future<void> _handleSDKCall() async {
    setState(() {
      isLoading = true; // 开始加载，显示加载状态
    });

    try {
      var result = await tapTuneSDK.callWorkflow(sdkInput);
      if (!mounted) return;

      // 根据 result 的 id 执行不同的操作
      switch (result['id']) {
        case 'c6c7aa5f-066e-aa87-f42a-b230ace2aa5b':
          _toggleDarkMode(result['param'] == 'true'? true : false);
          break;

        case '1c4a3b3e-4e50-4512-b449-78a28ea6d64c':
          _setFontSize(result['param'] as String);
          break;

        case 'appid0001':
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('暂时不支持相关设置')),
          );
          break;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $error')),
      );
    } finally {
      setState(() {
        isLoading = false; // 加载完成，隐藏加载状态
        _controller.clear(); // 清空输入框
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TapTuneSDK 接入演示 APP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 300.0,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    border: Border.all(width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '这里是应用内的效果\n'
                        'APP的所有设置内容都可以在这被体现\n'
                        '比如字体的大小\n'
                        '是否是深色模式\n'
                        '您可以假设这就是您常用的 APP\n'
                        '您可以有下方两种方法来调节设置内容',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '方法一：开发者轻松接入我们的SDK',
                      ),
                      InkWell(
                        onTap: () => _launchURL('https://pub.dev/packages/taptune'),
                        child: const Text(
                          'SDK 开源地址：https://pub.dev/packages/taptune',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        '您可以在下方通过自然语言调节设置\n'
                            '也可优化成语音、手势等方式来交互',
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _controller, // 绑定控制器
                        onSubmitted: (value) async {
                          setState(() {
                            sdkInput = value;
                          });
                          await _handleSDKCall(); // 调用函数并处理加载状态
                        },
                        decoration: const InputDecoration(
                          labelText: '试试：我觉得亮度有点高',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 16.0),
                        const Center(child: CircularProgressIndicator()), // 显示加载指示器
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '方法二：通过APP开发者自己写的设置页面\n'
                            '正常应该入口比较深，且需要自己找到相关设置\n'
                            '这里为了方便展示就放在这了\n',
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          const Text('深色模式：'),
                          const SizedBox(width: 8.0),
                          ChoiceChip(
                            label: const Text('开启'),
                            selected: isDarkMode,
                            onSelected: (selected) {
                              _toggleDarkMode(true); // 调用封装的切换深色模式函数
                            },
                          ),
                          const SizedBox(width: 8.0),
                          ChoiceChip(
                            label: const Text('关闭'),
                            selected: !isDarkMode,
                            onSelected: (selected) {
                              _toggleDarkMode(false); // 调用封装的切换深色模式函数
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          const Text('字体大小：'),
                          const SizedBox(width: 8.0),
                          ChoiceChip(
                            label: const Text('小'),
                            selected: fontSize == 14.0, // 增大后的字体大小
                            onSelected: (selected) {
                              _setFontSize('小'); // 调用封装的切换字体大小函数
                            },
                          ),
                          const SizedBox(width: 8.0),
                          ChoiceChip(
                            label: const Text('标准'),
                            selected: fontSize == 18.0, // 增大后的字体大小
                            onSelected: (selected) {
                              _setFontSize('标准'); // 调用封装的切换字体大小函数
                            },
                          ),
                          const SizedBox(width: 8.0),
                          ChoiceChip(
                            label: const Text('大'),
                            selected: fontSize == 22.0, // 增大后的字体大小
                            onSelected: (selected) {
                              _setFontSize('大'); // 调用封装的切换字体大小函数
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}