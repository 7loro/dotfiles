local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- fmt와 rep를 extras 모듈에서 가져옵니다.
-- 이 부분이 제대로 로드되지 않으면 rep 오류가 발생합니다.
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- StatelessWidget
  s("statelessW", fmt([[
import 'package:flutter/material.dart';

class {} extends StatelessWidget {{
  const {}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return {};
  }}
}}
]], {
    i(1, "MyWidget"), -- {}: class 이름
    rep(1),           -- {}: const 생성자 이름 (class 이름 반복)
    i(2, "Container()"), -- {}: build 메서드 내용
  })),

  -- StatefulWidget
  s("statefulW", fmt([[
import 'package:flutter/material.dart';

class {} extends StatefulWidget {{
  const {}({{super.key}});

  @override
  State<{}> createState() => _{}State();
}}

class _{}State extends State<{}> {{
  @override
  Widget build(BuildContext context) {{
    return {};
  }}
}}
]], {
    i(1, "MyWidget"),     -- {}: class 이름 (첫 번째 등장)
    rep(1),               -- {}: const 생성자 이름 (class 이름 반복)
    rep(1),               -- {}: createState의 State<> 이름 (class 이름 반복)
    rep(1),               -- {}: createState의 _State 이름 (class 이름 반복)
    rep(1),               -- {}: _State class 이름 (class 이름 반복)
    rep(1),               -- {}: State<> 이름 (class 이름 반복)
    i(2, "Container()"),   -- {}: build 메서드 내용
  })),

  -- Build Method
  s("build", fmt([[
@override
Widget build(BuildContext context) {{
  return {};
}}
]], {
    i(0), -- {}: 최종 커서 위치 (return 내용)
  })),

  -- Custom Painter
  s("customPainter", fmt([[
class {}Painter extends CustomPainter {{

  @override
  void paint(Canvas canvas, Size size) {{
  }}

  @override
  bool shouldRepaint({}Painter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics({}Painter oldDelegate) => false;
}}
]], {
    i(0, "name"), -- {}: 클래스 이름
    rep(0),       -- {}: shouldRepaint의 oldDelegate 타입 이름 (클래스 이름 반복)
    rep(0),       -- {}: shouldRebuildSemantics의 oldDelegate 타입 이름 (클래스 이름 반복)
  })),

  -- Custom Clipper
  s("customClipper", fmt([[
class {}Clipper extends CustomClipper<Path> {{

  @override
  Path getClip(Size size) {{
  }}

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}}
]], {
    i(0, "name"), -- {}: 클래스 이름
  })),

  -- InitState
  s("initS", fmt([[
@override
void initState() {{
  super.initState();
  {};
}}
]], {
    i(0), -- {}: 최종 커서 위치
  })),

  -- Dispose
  s("dis", fmt([[
@override
void dispose() {{
  {};
  super.dispose();
}}
]], {
    i(0), -- {}: 최종 커서 위치
  })),

  -- Reassemble
  s("reassemble", fmt([[
@override
void reassemble(){{
  super.reassemble();
  {};
}}
]], {
    i(0), -- {}: 최종 커서 위치
  })),

  -- didChangeDependencies
  s("didChangeD", fmt([[
@override
void didChangeDependencies() {{
  super.didChangeDependencies();
  {};
}}
]], {
    i(0), -- {}: 최종 커서 위치
  })),

  -- didUpdateWidget
  s("didUpdateW", fmt([[
@override
void didUpdateWidget ({} {}) {{
  super.didUpdateWidget({});
  {};
}}
]], {
    i(1, "Type"),       -- {}: Type
    i(2, "oldWidget"),  -- {}: oldWidget 변수 이름 (첫 번째 등장)
    rep(2),             -- {}: super.didUpdateWidget() 안의 oldWidget 변수 이름 (반복)
    i(0),               -- {}: 최종 커서 위치
  })),

  -- ListView.Builder
  s("listViewB", fmt([[
ListView.builder(
  itemCount: {},
  itemBuilder: (BuildContext context, int index) {{
    return {};
  }},
),
]], {
    i(1, "1"),    -- {}: itemCount
    i(2),         -- {}: itemBuilder 내용
  })),

  -- ListView.Separated
  s("listViewS", fmt([[
ListView.separated(
  itemCount: {},
  separatorBuilder: (BuildContext context, int index) {{
    return {};
  }},
  itemBuilder: (BuildContext context, int index) {{
    return {};
  }},
),
]], {
    i(1, "1"),    -- {}: itemCount
    i(2),         -- {}: separatorBuilder 내용
    i(3),         -- {}: itemBuilder 내용
  })),

  -- GridView.Builder
  s("gridViewB", fmt([[
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: {},
  ),
  itemCount: {},
  itemBuilder: (BuildContext context, int index) {{
    return {};
  }},
),
]], {
    i(1, "2"),    -- {}: crossAxisCount
    i(2, "2"),    -- {}: itemCount
    i(3),         -- {}: itemBuilder 내용
  })),

  -- GridView.Count
  s("gridViewC", fmt([[
GridView.count(
  crossAxisSpacing: {},
  mainAxisSpacing: {},
  crossAxisCount: {},
  children: <Widget> [
    {},
  ],
),
]], {
    i(1, "1"),    -- {}: crossAxisSpacing
    i(2, "2"),    -- {}: mainAxisSpacing
    i(3, "2"),    -- {}: crossAxisCount
    i(4),         -- {}: children 내용
  })),

  -- GridView.Extent
  s("gridViewE", fmt([[
GridView.extent(
  maxCrossAxisExtent: {},
  children: <Widget> [
    {},
  ],
),
]], {
    i(1, "2"),    -- {}: maxCrossAxisExtent
    i(2),         -- {}: children 내용
  })),

  -- Custom Scroll View
  s("customScrollV", fmt([[
CustomScrollView(
  slivers: <Widget>[
  {},
  ],
),
]], {
    i(0), -- {}: slivers 내용 (최종 커서)
  })),

  -- Stream Builder
  s("streamBldr", fmt([[
StreamBuilder(
  stream: {},
  initialData: {},
  builder: (BuildContext context, AsyncSnapshot snapshot) {{
    return Container(
      child: {},
    );
  }},
),
]], {
    i(1, "stream"),     -- {}: stream
    i(2, "initialData"),-- {}: initialData
    i(3, "child"),      -- {}: Container child
  })),

  -- Animated Builder
  s("animatedBldr", fmt([[
AnimatedBuilder(
  animation: {},
  child: {},
  builder: (BuildContext context, Widget child) {{
    return {};
  }},
),
]], {
    i(1, "animation"), -- {}: animation
    i(2, "child"),     -- {}: child 위젯
    i(3),              -- {}: builder 내용
  })),

  -- Stateful Builder
  s("statefulBldr", fmt([[
StatefulBuilder(
  builder: (BuildContext context, setState) {{
    return {};
  }},
),
]], {
    i(0), -- {}: builder 내용 (최종 커서)
  })),

  -- Orientation Builder
  s("orientationBldr", fmt([[
OrientationBuilder(
  builder: (BuildContext context, Orientation orientation) {{
    return Container(
      child: {},
    );
  }},
),
]], {
    i(3, "child"), -- {}: Container child (원본 JSON의 ${3}에 맞춰 번호 유지)
  })),

  -- Layout Builder
  s("layoutBldr", fmt([[
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {{
    return {};
  }},
),
]], {
    i(0), -- {}: builder 내용 (최종 커서)
  })),

  -- Single Child ScrollView
  s("singleChildSV", fmt([[
SingleChildScrollView(
  controller: {},
  child: Column(
    {},
  ),
),
]], {
    i(1, "controller,"), -- {}: controller (원본에 , 포함)
    i(0),                -- {}: Column children (최종 커서)
  })),

  -- Future Builder
  s("futureBldr", fmt([[
FutureBuilder(
  future: {},
  initialData: {},
  builder: (BuildContext context, AsyncSnapshot snapshot) {{
    return {};
  }},
),
]], {
    i(1, "Future"),      -- {}: future
    i(2, "InitialData"), -- {}: initialData
    i(3),                -- {}: builder 내용
  })),

  -- No Such Method
  s("nosm", fmt([[
@override
dynamic noSuchMethod(Invocation invocation) {{
  {};
}}
]], {
    i(1), -- {}: 최종 커서 위치
  })),

  -- Inherited Widget
  s("inheritedW", fmt([[
class {} extends InheritedWidget {{
  const {}({{super.key, required super.child}});

  static {}? maybeOf(BuildContext context) {{
    return context.dependOnInheritedWidgetOfExactType<{}>();
  }}

  @override
  bool updateShouldNotify({} oldWidget) {{
    return {};
  }}
}}
]], {
    i(1, "Name"),      -- {}: class 이름 (첫 번째 등장)
    rep(1),            -- {}: const 생성자 이름 (반복)
    rep(1),            -- {}: maybeOf 반환 타입 (반복)
    rep(1),            -- {}: dependOnInheritedWidgetOfExactType<> 타입 (반복)
    rep(1),            -- {}: updateShouldNotify 인자 타입 (반복)
    i(2, "true"),      -- {}: updateShouldNotify 반환 값
  })),

  -- Mounted
  s("mounted", fmt([[
@override
bool get mounted {{
  {};
}}
]], {
    i(0), -- {}: 최종 커서 위치
  })),

  -- Sink (Requires dart:async and potentially bloc/rxdart)
  s("snk", fmt([[
Sink<{}> get {} => _{}Controller.sink;
final _{}Controller = StreamController<{}>();
]], {
    i(1, "type"), -- {}: 타입 (첫 번째 등장)
    i(2, "name"), -- {}: 이름 (첫 번째 등장)
    rep(2),       -- {}: _이름Controller (반복)
    rep(2),       -- {}: _이름Controller 이름 (반복)
    rep(1),       -- {}: StreamController<> 타입 (타입 반복)
  })),

  -- Stream (Requires dart:async and potentially bloc/rxdart)
  s("strm", fmt([[
Stream<{}> get {} => _{}Controller.stream;
final _{}Controller = StreamController<{}>();
]], {
    i(1, "type"), -- {}: 타입 (첫 번째 등장)
    i(2, "name"), -- {}: 이름 (첫 번째 등장)
    rep(2),       -- {}: _이름Controller.stream (반복)
    rep(2),       -- {}: _이름Controller 이름 (반복)
    rep(1),       -- {}: StreamController<> 타입 (타입 반복)
  })),

  -- Subject (Requires rxdart)
  s("subj", fmt([[
Stream<{}> get {} => _{}Subject.stream;
final _{}Subject = BehaviorSubject<{}>();
]], {
    i(1, "type"), -- {}: 타입 (첫 번째 등장)
    i(2, "name"), -- {}: 이름 (첫 번째 등장)
    rep(2),       -- {}: _이름Subject.stream (반복)
    rep(2),       -- {}: _이름Subject 이름 (반복)
    rep(1),       -- {}: BehaviorSubject<> 타입 (타입 반복)
  })),

  -- toString
  s("toStr", fmt([[
@override
String toString() {{
  return {};
}}
]], {
    i(1, "toString"), -- {}: return 내용
  })),

  -- debugPrint (Requires flutter/foundation.dart)
  s("debugP", fmt([[
debugPrint({});
]], {
    i(1, "statement"), -- {}: print 내용
  })),

  -- Import Material Package
  s("importM", fmt([[import 'package:flutter/material.dart';]], {})),

  -- Import Cupertino Package
  s("importC", fmt([[import 'package:flutter/cupertino.dart';]], {})),

  -- Import flutter_test Package
  s("importFT", fmt([[import 'package:flutter_test/flutter_test.dart';]], {})),

  -- Material App
  s("mateapp", fmt([[
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {{
  @override
  Widget build(BuildContext context) {{
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: Container(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }}
}}
]], {})), -- 이 스니펫은 placeholder가 없습니다.

  -- Cupertino App
  s("cupeapp", fmt([[
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {{
  @override
  Widget build(BuildContext context) {{
    return CupertinoApp(
      title: 'Cupertino App',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino App Bar'),
        ),
        child: Center(
          child: Container(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }}
}}
]], {})), -- 이 스니펫은 placeholder가 없습니다.

  -- Tween Animation Builder
  s("tweenAnimationBuilder", fmt([[
TweenAnimationBuilder(
  duration: {},
  tween: {},
  builder: (BuildContext context, {} value, Widget? child) {{
    return {};
  }},
),
]], {
    i(1, "const Duration()"), -- {}: duration
    i(2, "Tween()"),          -- {}: tween
    i(3, "dynamic"),          -- {}: value 타입
    i(4, "Container()"),      -- {}: builder 내용
  })),

  -- Value Listenable Builder
  s("valueListenableBuilder", fmt([[
ValueListenableBuilder(
  valueListenable: {},
  builder: (BuildContext context, {} value, Widget? child) {{
    return {};
  }},
),
]], {
    i(1, "null"),    -- {}: valueListenable
    i(2, "dynamic"), -- {}: value 타입
    i(3, "Container()"), -- {}: builder 내용
  })),

  -- Test (Requires flutter_test/test.dart)
  s("f-test", fmt([[
test("{}", () {{
  {};
}});
]], {
    i(1, "test description"), -- {}: 테스트 설명
    i(0),                     -- {}: 테스트 본문 (최종 커서)
  })),

  -- Test Widgets (Requires flutter_test/test_widgets.dart)
  s("widgetTest", fmt([[
testWidgets("{}", (WidgetTester tester) async {{
  {};
}});
]], {
    i(1, "test description"), -- {}: 테스트 설명
    i(0),                     -- {}: 테스트 본문 (최종 커서)
  })),
}
