import 'package:arch_sherpa/utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  group('FileUtils', () {
    final utils = FileUtils();

    test('resolves path inside root', () {
      final resolved = utils.resolveSafePath(
        projectRootPath: '/tmp/project',
        relativePath: 'lib/features',
      );
      expect(resolved, contains('/tmp/project'));
    });

    test('blocks path traversal', () {
      expect(
        () => utils.resolveSafePath(
          projectRootPath: '/tmp/project',
          relativePath: '../outside',
        ),
        throwsA(isA<FileUtilsException>()),
      );
    });
  });
}
