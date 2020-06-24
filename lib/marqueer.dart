import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:screen/screen.dart';

///
/// this is marquee widget
///
class Marqueer extends StatefulWidget {
  static const String route = '/marquee';

  Marqueer({
    Key key,
    this.title = '输入需要滚动的广告',
    this.backgroundColor = Colors.black,
    this.fontColor = Colors.white,
    this.fontSize,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.blankSpace = 0.0,
    this.velocity = 50.0,
    this.pauseAfterRound = Duration.zero,
    this.showFadingOnlyWhenScrolling = true,
    this.fadingEdgeStartFraction = 0.0,
    this.fadingEdgeEndFraction = 0.0,
    this.startPadding = 0.0,
    this.accelerationDuration = Duration.zero,
    this.accelerationCurve = Curves.decelerate,
    this.decelerationDuration = Duration.zero,
    this.decelerationCurve = Curves.decelerate,
    this.isAudioPlay = false,
    this.isLoopAudioPlay = false,
    this.audioRole = 1,
    this.audioSpeed = 10,
    this.audioPit = 5,
  })  : assert(title != null),
        super(key: key);

  final String title; //标题
  Color backgroundColor; //背景
  Color fontColor; //字体颜色
  double fontSize; //字体大小
  final Axis scrollAxis; //滚动方向
  final CrossAxisAlignment crossAxisAlignment; //纵轴对齐方向
  final double blankSpace; //空白大小
  final double velocity; //速度
  final Duration pauseAfterRound; //循环暂停时间
  final bool showFadingOnlyWhenScrolling; //是否显示效果
  final double fadingEdgeStartFraction; //边界渐变
  final double fadingEdgeEndFraction; //尾部边界渐变
  final double startPadding; //开始内间距
  final Duration accelerationDuration; //加速时间
  final Curve accelerationCurve; //加速算法
  final Duration decelerationDuration; //减速时间
  final Curve decelerationCurve; //减速算法
  final bool isAudioPlay; //是否播放音频
  final bool isLoopAudioPlay;
  final int audioRole;
  final int audioSpeed;
  final int audioPit; //频率

  @override
  State<StatefulWidget> createState() => _MarqueerState();
}

class _MarqueerState extends State<Marqueer> {
//  Timer _timer;
//  final RandomColor _randomColor = RandomColor();
  Dio _dio = new Dio();
  AudioPlayer _audioPlayer;

  @override
  void initState() {
    _initPlatformState();
    if (widget.isAudioPlay) _initAudioState();
    super.initState();
  }

  _initAudioState() async {
    Map<String, dynamic> headers = Map();
    headers['Cookie'] =
        'PSTM=1573710855; BAIDUID=682977CD4B88F4B67909B9F7D46928F4:FG=1; BIDUPSID=74D1287A761483002684B41C1B810403; H_WISE_SIDS=139913_143436_143879_144427_142357_140632_139057_141748_143161_143866_144420_142780_144483_131862_131246_137745_144741_138883_141941_127969_142874_140066_144284_140593_143060_141807_137911_140350_144608_143470_144726_143923_144485_131423_144277_128698_142208_144219_144006_128149_107314_143948_138596_139910_144112_143478_142427_142912_141911_144239_142115_143855_144098_140842_110085; BDUSS=1xaVlVbmowdzVjRFIzM35lc2lHZVJDS1p3ZWg2dW5ib1lmMVlYRXYyaHo3TTFlRVFBQUFBJCQAAAAAAAAAAAEAAABX92Fk0KHFvzG6xQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHNfpl5zX6ZeNC; MCITY=-%3A; Hm_lvt_3abe3fb0969d25e335f1fe7559defcc6=1591962570; Hm_lpvt_3abe3fb0969d25e335f1fe7559defcc6=1591962828';
    ;
    //get baidu audio generation
    FormData formData = FormData.fromMap({
      'title': widget.title,
      'content': widget.title,
      'sex': widget.audioRole,
      'speed': widget.audioSpeed,
      'volumn': 10,
      'pit': widget.audioPit,
      'method': 'TRADIONAL',
    });
    Response response = await _dio.post(
      'https://developer.baidu.com/vcast/getVcastInfo',
      data: formData,
      options: Options(headers: headers),
    );
    Map _data = json.decode(response.data);
    print("===========>$_data");
    AudioPlayer.setIosCategory(IosCategory.playback);
    _audioPlayer = AudioPlayer();
    String url = _data['bosUrl'];
    _audioPlayer.setUrl(url.replaceAll('http', 'https')).catchError((error) {
      // catch audio error ex: 404 url, wrong url ...
      print(error);
    });
    setState(() {});
  }

  _initPlatformState() async {
    bool keptOn = await Screen.isKeptOn;
//    double brightness = await Screen.brightness;
    if (!keptOn) {
      Screen.keepOn(true);
    }
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
//    _timer.cancel();
//    _timer = null;
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    if (_audioPlayer != null) _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> isKeptOn() async {
    return await Screen.isKeptOn;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoopAudioPlay && widget.isAudioPlay && _audioPlayer != null) {
      _audioPlayer.fullPlaybackStateStream.listen(null);
      _audioPlayer.fullPlaybackStateStream.listen((fullState) {
        final state = fullState?.state;
        final buffering = fullState?.buffering;
        if (state == AudioPlaybackState.connecting || buffering == true) {
//          print("===> audio connecting");
        } else if (state == AudioPlaybackState.playing) {
//          print("===> audio playing");
        } else if (state == AudioPlaybackState.stopped ||
            state == AudioPlaybackState.completed) {
//          print("===> audio completed");
          _audioPlayer.seek(Duration(seconds: 0));
          _audioPlayer.play();
        } else {
//          print("===> audio else ${state}");
        }
      });
    }
    return MaterialApp(
      title: 'Marquee',
      home: WillPopScope(
        child: Scaffold(
          backgroundColor: widget.backgroundColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildComplexMarquee(),
              if (widget.isAudioPlay && !widget.isLoopAudioPlay) _buildAudio(),
            ],
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }

  Widget _buildAudio() {
    if (_audioPlayer != null) {
      return StreamBuilder<FullAudioPlaybackState>(
        stream: _audioPlayer.fullPlaybackStateStream,
        builder: (context, snapshot) {
          final fullState = snapshot.data;
          final state = fullState?.state;
          final buffering = fullState?.buffering;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state == AudioPlaybackState.connecting || buffering == true)
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  color: widget.fontColor,
                  child: CircularProgressIndicator(),
                )
              else if (state == AudioPlaybackState.playing)
                IconButton(
                  icon: Icon(Icons.pause),
                  iconSize: 64.0,
                  color: widget.fontColor,
                  onPressed: _audioPlayer.pause,
                )
              else
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  iconSize: 64.0,
                  color: widget.fontColor,
                  onPressed: () {
                    _audioPlayer.seek(Duration(seconds: 0));
                    _audioPlayer.play();
                  },
                ),
              IconButton(
                icon: Icon(Icons.stop),
                iconSize: 64.0,
                color: widget.fontColor,
                onPressed: state == AudioPlaybackState.stopped ||
                        state == AudioPlaybackState.none
                    ? null
                    : _audioPlayer.stop,
              ),
            ],
          );
        },
      );
    }
    return Container();
  }

  Widget _buildComplexMarquee() {
    var _h = _getTextHeight(context);
    return Container(
      height: _h,
      child: Marquee(
        text: widget.title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: widget.fontSize,
            color: widget.fontColor),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 0.0,
        velocity: widget.velocity,
        pauseAfterRound: widget.pauseAfterRound,
        showFadingOnlyWhenScrolling: false,
        fadingEdgeStartFraction: 0.1,
        fadingEdgeEndFraction: 0.1,
//      numberOfRounds: 3,
        startPadding: 10.0,
//        accelerationDuration: Duration(seconds: 1),
//        accelerationCurve: Curves.linear,
//        decelerationDuration: Duration(milliseconds: 500),
//        decelerationCurve: Curves.easeOut,
      ),
    );
  }

  /// Returns the width of the text.
  double _getTextHeight(BuildContext context) {
    final span = TextSpan(
      text: widget.title,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: widget.fontSize,
          color: widget.fontColor),
    );

    final constraints = BoxConstraints(maxWidth: double.infinity);

    final richTextWidget = Text.rich(span).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context);
    renderObject.layout(constraints);

    final boxes = renderObject.getBoxesForSelection(TextSelection(
      baseOffset: 0,
      extentOffset: 1,
    ));
    return boxes.last.bottom;
  }
}
