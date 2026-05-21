import 'package:flutter_test/flutter_test.dart';
import 'package:spend_arc/core/utils/either.dart';

void main() {
  group('Either', () {
    test('should create Right value', () {
      final Either<String, int> result = right(42);

      expect(result.isRight(), true);
      expect(result.isLeft(), false);
      expect(result.asRight(), 42);
    });

    test('should create Left value', () {
      final Either<String, int> result = left('error');

      expect(result.isLeft(), true);
      expect(result.isRight(), false);
      expect(result.asLeft(), 'error');
    });

    test('fold should apply right function for Right', () {
      final Either<String, int> result = right(42);

      final output = result.fold(
        (l) => 'left: $l',
        (r) => 'right: $r',
      );

      expect(output, 'right: 42');
    });

    test('fold should apply left function for Left', () {
      final Either<String, int> result = left('fail');

      final output = result.fold(
        (l) => 'left: $l',
        (r) => 'right: $r',
      );

      expect(output, 'left: fail');
    });

    test('map should transform Right value', () {
      final Either<String, int> result = right(42);

      final mapped = result.map((r) => r * 2);

      expect(mapped.isRight(), true);
      expect(mapped.asRight(), 84);
    });

    test('map should pass through Left value unchanged', () {
      final Either<String, int> result = left('error');

      final mapped = result.map((r) => r * 2);

      expect(mapped.isLeft(), true);
      expect(mapped.asLeft(), 'error');
    });

    test('getOrElse should return value for Right', () {
      final Either<String, int> result = right(42);

      final value = result.getOrElse(() => 0);

      expect(value, 42);
    });

    test('getOrElse should return default for Left', () {
      final Either<String, int> result = left('error');

      final value = result.getOrElse(() => 0);

      expect(value, 0);
    });

    test('flatMap should chain Right values', () {
      final Either<String, int> result = right(10);

      final chained = result.flatMap((r) => right<String, int>(r + 5));

      expect(chained.isRight(), true);
      expect(chained.asRight(), 15);
    });

    test('flatMap should short-circuit on Left', () {
      final Either<String, int> result = left('error');

      final chained = result.flatMap((r) => right<String, int>(r + 5));

      expect(chained.isLeft(), true);
      expect(chained.asLeft(), 'error');
    });
  });
}
