import 'package:slang/builder/model/i18n_locale.dart';
import 'package:slang/builder/model/raw_config.dart';
import 'package:slang_gpt/model/gpt_config.dart';
import 'package:slang_gpt/model/gpt_model.dart';
import 'package:slang_gpt/prompt/prompt.dart';
import 'package:test/test.dart';

const _expectedSystemPrompt =
    r'''The user wants to internationalize the app. The user will provide you with a JSON file containing the English strings.
You will translate it to German.
Parameters are interpolated with ${parameter} or $parameter.
Linked translations are denoted with the "@:path0.path1" syntax.

Here is the app description. Respect this context when translating:
A simple calculator''';

void main() {
  group('prompt', () {
    test('should return a prompt', () {
      final prompts = getPrompts(
        rawConfig: RawConfig.defaultConfig,
        targetLocale: I18nLocale.fromString('de'),
        config: GptConfig(
          model: GptModel.gpt3_5_4k,
          description: 'A simple calculator',
          maxInputLength: 1000,
          temperature: null,
        ),
        namespace: null,
        translations: {
          'calculate': 'Calculate',
          'add': 'Add',
          'subtract': 'Subtract',
          'multiply': 'Multiply',
          'divide': 'Divide',
        },
      );

      expect(prompts.length, 1);
      expect(prompts.first.system, _expectedSystemPrompt);
      expect(
        prompts.first.user,
        '{"calculate":"Calculate","add":"Add","subtract":"Subtract","multiply":"Multiply","divide":"Divide"}',
      );
    });

    test('Should divide into smaller prompts', () {
      final prompts = getPrompts(
        rawConfig: RawConfig.defaultConfig,
        targetLocale: I18nLocale.fromString('de'),
        config: GptConfig(
          model: GptModel.gpt3_5_4k,
          description: 'A simple calculator',
          maxInputLength: 1,
          temperature: null,
        ),
        namespace: null,
        translations: {
          'a': 'a',
          'b': 'b',
          'c': 'c',
          'd': 'd',
          'e': 'e',
        },
      );

      expect(prompts.length, 5);
      expect(prompts.first.system, _expectedSystemPrompt);
      expect(prompts.first.user, '{"a":"a"}');

      expect(prompts[1].system, _expectedSystemPrompt);
      expect(prompts[1].user, '{"b":"b"}');

      expect(prompts[2].system, _expectedSystemPrompt);
      expect(prompts[2].user, '{"c":"c"}');

      expect(prompts[3].system, _expectedSystemPrompt);
      expect(prompts[3].user, '{"d":"d"}');

      expect(prompts[4].system, _expectedSystemPrompt);
      expect(prompts[4].user, '{"e":"e"}');
    });

    test('Should add namespace hint', () {
      final prompts = getPrompts(
        rawConfig: RawConfig.defaultConfig,
        targetLocale: I18nLocale.fromString('de'),
        config: GptConfig(
          model: GptModel.gpt3_5_4k,
          description: 'A simple calculator',
          maxInputLength: 1000,
          temperature: null,
        ),
        namespace: 'settings',
        translations: {
          'a': 'a',
        },
      );

      expect(prompts.length, 1);
      expect(
        prompts.first.system,
        r'''The user wants to internationalize the "settings" part of the app. The user will provide you with a JSON file containing the English strings.
You will translate it to German.
Parameters are interpolated with ${parameter} or $parameter.
Linked translations are denoted with the "@:path0.path1" syntax.

Here is the app description. Respect this context when translating:
A simple calculator''',
      );
    });
  });
}
