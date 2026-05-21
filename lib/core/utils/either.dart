/// dartz Either integration for type-safe error handling.
///
/// ## Why Either?
/// `Either<L, R>` explicitly encodes that an operation can return
/// one of two types: **Left** (typically a [Failure]) or **Right**
/// (the success value). This eliminates hidden exceptions and
/// forces callers to handle both paths at compile time.
///
/// ## Why Failure abstraction?
/// A base [Failure] class with subtypes ([ServerFailure], [CacheFailure],
/// [NetworkFailure]) provides a scalable way to categorize errors.
/// New failure types can be added without changing method signatures,
/// and each layer (repository → use case → bloc → UI) can handle
/// failures at the appropriate level of detail.
///
/// ## Why fold()?
/// `result.fold(handleLeft, handleRight)` is a single, predictable
/// call that exhaustively covers both outcomes:
/// - Left (failure) → emit error state, show user message, retry
/// - Right (success) → pass data to next layer, render UI
///
/// This prevents unhandled exceptions, reduces nesting, and makes
/// state transitions explicit in BLoC event handlers.
library;

import 'package:dartz/dartz.dart';
import 'package:dartz/dartz.dart' as dartz;

export 'package:dartz/dartz.dart';

/// Creates a [Left] (failure) [Either] value.
///
/// Convention: `Left` represents the error/failure case.
Either<L, R> left<L, R>(L value) => dartz.Left<L, R>(value);

/// Creates a [Right] (success) [Either] value.
///
/// Convention: `Right` represents the success/data case.
Either<L, R> right<L, R>(R value) => dartz.Right<L, R>(value);

/// Extension that provides convenience methods on dartz [Either].
///
/// dartz natively provides [fold], [map], [flatMap], [getOrElse],
/// [isLeft], and [isRight] (as methods). This extension adds
/// unwrapping methods used throughout the codebase.
extension EitherX<L, R> on dartz.Either<L, R> {
  /// Safely unwraps the [Right] value or throws [StateError].
  ///
  /// Only use when you are certain this is a [Right]; otherwise
  /// prefer [fold] or [getOrElse] for safe handling.
  R asRight() => fold((_) => throw StateError('asRight called on Left'), (r) => r);

  /// Safely unwraps the [Left] value or throws [StateError].
  ///
  /// Only use when you are certain this is a [Left]; otherwise
  /// prefer [fold] for safe handling.
  L asLeft() => fold((l) => l, (_) => throw StateError('asLeft called on Right'));
}
