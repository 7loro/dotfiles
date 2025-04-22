local ls = require("luasnip")
local s = ls.snippet
-- t, i 노드들은 필요에 따라 주석을 해제하고 사용하세요.
-- local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- create provider
  s("prov", fmt([[
  final {}Provider = Provider(({}) => {});
  ]], {
    i(1, "name"), -- {}: provider 이름
    i(2, "ref"),  -- {}: ref 변수 이름
    i(3, "value"), -- {}: provider 값
  })),

  -- create stateprovider
  s("stprov", fmt([[
  final {}Provider = StateProvider(({}) => {});
  ]], {
    i(1, "name"), -- {}: provider 이름
    i(2, "ref"),  -- {}: ref 변수 이름
    i(3, "initialValue"), -- {}: 초깃값
  })),

  -- create StateNotifierProvider
  s("snprov", fmt([[
  class {} extends StateNotifier<{}> {{
    {}(super.{}); // Or super(initialState);

    // State 변경 메서드들을 여기에 추가하세요.
    {}
  }}

  final {} = StateNotifierProvider<{}, {}>(
    {}.new, // .new 생성자 Tear-off 사용 (Riverpod 2.0 이상)
  );
  ]], {
    i(1, "NotifierName"), -- {}: Notifier 클래스 이름 (첫 번째 등장)
    i(2, "State"),       -- {}: State 타입 (첫 번째 등장)
    rep(1),              -- {}: Notifier 생성자 이름 (클래스 이름 반복)
    i(3, "state"),       -- {}: super 생성자 인자 이름 (예: 'state')
    i(0),                -- {}: Notifier 클래스 본문 커서
    i(4, "providerName"),-- {}: Provider 변수 이름
    rep(1),              -- {}: StateNotifierProvider<> 첫 번째 타입 인자 (NotifierName 반복)
    rep(2),              -- {}: StateNotifierProvider<> 두 번째 타입 인자 (State 반복)
    rep(1),              -- {}: .new 생성자 Tear-off 부분 (NotifierName 반복)
  })),

  -- create FutureProvider
  s("fprov", fmt([[
  final {}Provider = FutureProvider(({}) async => {});
  ]], {
    i(1, "name"), -- {}: provider 이름
    i(2, "ref"),  -- {}: ref 변수 이름
    i(3, "value"), -- {}: Future 값
  })),

  -- create StreamProvider
  s("strprov", fmt([[
  final {}Provider = StreamProvider(({}) async* {{
    {}
  }});
  ]], {
    i(1, "name"), -- {}: provider 이름
    i(2, "ref"),  -- {}: ref 변수 이름
    i(0),         -- {}: async* 제너레이터 본문 커서
  })),

  -- ref.watch
  s("refw", fmt([[ref.watch({})]], {
    i(1, "provider"), -- {}: watch 할 provider
  })),

  -- ref.read
  s("refr", fmt([[ref.read({})]], {
    i(1, "provider"), -- {}: read 할 provider
  })),

  -- ref.listen
  s("refl", fmt([[
  ref.listen({}, ({}, {}) => {{
    {}
  }});
  ]], {
    i(1, "provider"), -- {}: listen 할 provider
    i(2, "previous"), -- {}: 이전 상태 변수
    i(3, "next"),     -- {}: 다음 상태 변수
    i(0),             -- {}: listener 본문 커서
  })),

  -- ref.onDispose
  s("refod", fmt([[
  ref.onDispose(() => {{
    {}
  }});
  ]], {
    i(0), -- {}: dispose 본문 커서
  })),

  -- create ConsumerWidget
  s("consumerw", fmt([[
  class {} extends ConsumerWidget {{
    const {}({{super.key}});

    @override
    Widget build(BuildContext context, WidgetRef ref) {{
      return {};
    }}
  }}
  ]], {
    i(1, "name"), -- {}: 위젯 이름 (첫 번째 등장)
    rep(1),       -- {}: const 생성자 이름 (이름 반복)
    i(0, "Container()"), -- {}: build 메서드 본문 (최종 커서)
  })),

  -- create ConsumerStatefulWidget
  s("consumersf", fmt([[
  class {} extends ConsumerStatefulWidget {{
    const {}({{super.key}});

    @override
    ConsumerState<{}> createState() => _{}State();
  }}

  class _{}State extends ConsumerState<{}> {{
    @override
    Widget build(BuildContext context) {{
      return {};
    }}
  }}
  ]], {
    i(1, "name"), -- {}: 위젯 이름 (첫 번째 등장)
    rep(1),       -- {}: const 생성자 이름 (반복)
    rep(1),       -- {}: createState 반환 타입 (반복)
    rep(1),       -- {}: _State 클래스 이름 in createState (반복)
    rep(1),       -- {}: _State 클래스 이름 (반복)
    rep(1),       -- {}: ConsumerState<> 타입 (반복)
    i(0, "Container()"), -- {}: build 메서드 본문 (최종 커서)
  })),

  -- create HookConsumerWidget
  s("hcw", fmt([[
  import 'package:flutter/material.dart';
  import 'package:hooks_riverpod/hooks_riverpod.dart';

  class {} extends HookConsumerWidget {{
    const {}({{super.key}});

    @override
    Widget build(BuildContext context, WidgetRef ref) {{
      return {};
    }}
  }}
  ]], {
    i(1, "name"),-- {}: 위젯 이름 (첫 번째 등장)
    rep(1),-- {}: const 생성자 이름 (이름 반복)
    i(0, "Container()"), -- {}: build 메서드 본문 (최종 커서)
  })),
}
