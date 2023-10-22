import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
part 'gen/container.g.dart';

/// A union of two values.
class Either<TLeft, TRight> {
  TLeft? _left;
  TRight? _right;
  Either.left(this._left);
  Either.right(this._right);
  TLeft? get left {
    return this._left;
  }

  TRight? get right {
    return this._right;
  }

  TLeft leftOr(TLeft Function(TRight right) defaultValue) {
    return _left == null ? defaultValue(_right as TRight) : _left!;
  }

  TRight rightOr(TRight Function(TLeft left) defaultValue) {
    return _right == null ? defaultValue(_left as TLeft) : _right!;
  }

  bool get hasLeft {
    return this._left != null;
  }

  bool get hasRight {
    return this._right != null;
  }
}

class Pair<T1, T2> {
  T1 first;
  T2 second;
  Pair(this.first, this.second);
  @override
  toString() {
    return "Pair($first, $second)";
  }
}

class SortBy<T> {
  T factor;
  late bool isAscending;
  SortBy.ascending(this.factor) {
    isAscending = true;
  }
  SortBy.descending(this.factor) {
    isAscending = false;
  }
  bool get isDescending => isAscending;
  String get apiParams => "${isAscending ? '' : '-'}${factor.toString()}";
}

@JsonSerializable()
class MinimalModel {
  String id;
  String name;
  MinimalModel({required this.id, required this.name});

  factory MinimalModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$MinimalModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$MinimalModelToJson(this);
}

@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class ApiResult<T> {
  String message;
  T data;
  ApiResult({required this.message, required this.data});

  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    try {
      return _$ApiResultFromJson(json, fromJsonT);
    } on ApiError catch (_) {
      rethrow;
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResultToJson(this, toJsonT);
}
