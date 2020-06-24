import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marqueer/marqueer.dart';

import 'style.dart';

class MyHomePage extends StatefulWidget {
  static const route = '/';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _textEditingController = new TextEditingController();

  Color _bgColor = Colors.black;
  Color _fontColor = Colors.white;
  var _numSettings = [
    200,
    50,
    0,
    0,
    1,
    5,
    5,
  ]; //fontSize,velocity,pauseAfterRound

  bool isAudioPlay = false;

  void changeBgColor(Color color) => setState(() => _bgColor = color);

  void changeFontColor(Color color) => setState(() => _fontColor = color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 10,
            minLines: 2,
            controller: _textEditingController,
            decoration: new InputDecoration(
              hintText: '输入需要滚动的文字',
              border: InputBorder.none,
            ),
          ),
          //background color
          _buildColorItem('背景色', _bgColor, changeBgColor),
          _buildColorItem('字体颜色', _fontColor, changeFontColor),
          _buildNumberItem('字体大小', 0, 10),
          _buildNumberItem('滚动速度', 1, 10),
          _buildNumberItem('间隔时间', 2, 1),
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Text('设置声音'),
                Switch(
                    value: isAudioPlay,
                    onChanged: (v) {
                      this.isAudioPlay = v;
                      this._numSettings[3] = 0;
                      setState(() {});
                    })
              ],
            ),
          ),
          if (this.isAudioPlay)
            _buildNumberItem('循环播放：0-1', 3, 1),
          if (this.isAudioPlay)
            _buildNumberItem('选择角色：1-10', 4, 1),
          if (this.isAudioPlay)
            _buildNumberItem('播放速度：1-10', 5, 1),
          if (this.isAudioPlay)
            _buildNumberItem('声音音色：1-10', 6, 1),
        ].map((widget) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: widget,
              ),
              divider,
            ],
          );
        }).toList(),
      ),
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            children: <Widget>[
              _buildDrawHead(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Marqueer(
                title: _textEditingController.text.isEmpty
                    ? '输入需要滚动的文字'
                    : _textEditingController.text,
                backgroundColor: _bgColor,
                fontColor: _fontColor,
                fontSize: _numSettings[0].toDouble(),
                velocity: _numSettings[1].toDouble(),
                pauseAfterRound: Duration(seconds: _numSettings[2]),
                isAudioPlay: isAudioPlay,
                isLoopAudioPlay: _numSettings[3] == 0 ? false : true,
                audioRole: _numSettings[4],
                audioSpeed: _numSettings[5],
                audioPit: _numSettings[6],
              ),
            ),
          );
        },
        tooltip: 'show',
        child: Icon(Icons.send),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('设置')),
          BottomNavigationBarItem(icon: Container(), title: Text('')),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            title: Text('请喝咖啡'),
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            showDialog(
              context: context,
              child: Center(
                child: Image.asset(
                  'wx_money.jpeg',
                  width: 200,
                ),
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDrawHead() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text('广告牌'),
            Text('这是一个设置并展示广告牌应用'),
          ],
        )
      ],
    );
  }

  Widget _buildColorItem(
      String title, Color color, ValueChanged<Color> onColorChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RaisedButton(
            elevation: 3.0,
            color: color,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: color,
                        onColorChanged: onColorChanged,
                        colorPickerWidth: 300.0,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: true,
                        displayThumbColor: true,
                        showLabel: true,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      ],
    );
  }

  Widget _buildNumberItem(String title, int index, int op) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  setState(() {
                    var num = _numSettings[index];
                    if (num <= 0) {
                      Fluttertoast.showToast(
                        msg: '不能再减少喽',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                      );
                      return;
                    }
                    _numSettings[index] = num - op;
                  });
                },
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _numSettings[index].toString(),
                  textAlign: TextAlign.center,
                ),
                constraints: BoxConstraints.expand(height: 50, width: 30),
              ),
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _numSettings[index] = _numSettings[index] + op;
                  });
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
