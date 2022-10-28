import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translate_app/model.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Translate App',
      home: HomePage(),
    );
  }
}

class TranslateState {
  const TranslateState({required this.isLoading, required this.result});
  final bool isLoading;
  final String? result;
}

class TranslateStateNotifier extends StateNotifier<TranslateState> {
  TranslateStateNotifier()
      : super(const TranslateState(isLoading: false, result: null));

  Future<void> translate(String sentence) async {
    state = const TranslateState(isLoading: true, result: null);
    final url = Uri.parse('https://labs.goo.ne.jp/api/hiragana');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      // gooラボのWebサイトで取得したアプリケーションIDを<token>と置き換えてください
      // https://labs.goo.ne.jp/apiusage/
      'app_id':
          '693ee9f7531df88b7129ec233e2b10bdadb1d92b912d422f7e74d6ab61ed37c0',
      'sentence': sentence,
      'output_type': 'hiragana',
    });
    final request = Request(
      appId: '693ee9f7531df88b7129ec233e2b10bdadb1d92b912d422f7e74d6ab61ed37c0',
      sentence: sentence,
      outputType: 'hiragana',
    );
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request.toJson()),
    );
    final responseJson = json.decode(response.body) as Map<String, dynamic>;
    state = TranslateState(isLoading: false, result: responseJson['converted']);
  }

  void reset() {
    state = const TranslateState(isLoading: false, result: null);
  }
}

final translateStateProvider =
    StateNotifierProvider<TranslateStateNotifier, TranslateState>((ref) {
  return TranslateStateNotifier();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate App'),
      ),
      body: _body(ref),
    );
  }

  Widget _body(WidgetRef ref) {
    final TranslateState state = ref.watch(translateStateProvider);
    final TranslateStateNotifier stateNotifier =
        ref.watch(translateStateProvider.notifier);
    final String? result = state.result;

    if (result != null) {
      return _Result(
        sentence: result,
        onTapBack: stateNotifier.reset,
      );
    } else if (state.isLoading) {
      return const _Loading();
    } else {
      return _InputForm(onSubmit: stateNotifier.translate);
    }
  }
}

class _InputForm extends StatefulWidget {
  const _InputForm({super.key, required this.onSubmit});

  final Function(String) onSubmit;
  @override
  State<StatefulWidget> createState() => _InputFormState();
}

class _InputFormState extends State<_InputForm> {
  final _formKey = GlobalKey<FormState>();
  final _textEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _textEditController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '文章を入力してください',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '文章が入力されていません';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final formState = _formKey.currentState!;
              if (!formState.validate()) {
                return;
              }

              widget.onSubmit(_textEditController.text);
            },
            child: const Text(
              '変換',
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    super.key,
    required this.sentence,
    required this.onTapBack,
  });

  final String sentence;
  final void Function() onTapBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(sentence),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTapBack,
            child: const Text(
              '再入力',
            ),
          ),
        ],
      ),
    );
  }
}
