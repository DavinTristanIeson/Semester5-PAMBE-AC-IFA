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
