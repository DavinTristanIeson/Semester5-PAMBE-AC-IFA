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

  TLeft leftOr(TLeft defaultValue) {
    return this._left == null ? defaultValue : this._left!;
  }

  TRight rightOr(TRight defaultValue) {
    return this._right == null ? defaultValue : this._right!;
  }

  bool get hasLeft {
    return this._left != null;
  }

  bool get hasRight {
    return this._right != null;
  }
}
