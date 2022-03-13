class BoxSize {
  const BoxSize({
    this.minHeight = 0,
    this.minWidth = 0,
    this.maxHeight = 0,
    this.maxWidth = 0,
  });

  final double minHeight;
  final double minWidth;
  final double maxHeight;
  final double maxWidth;

  /// Returns the width that both satisfies the constraints and is as close as
  /// possible to the given width.
  double constrainWidth({required double width}) {
    return width.clamp(minWidth, maxWidth);
  }

  /// Returns the height that both satisfies the constraints and is as close as
  /// possible to the given height.
  double constrainHeight({required double height}) {
    return height.clamp(minHeight, maxHeight);
  }

  @override
  String toString() {
    return 'BoxSize{minHeight: $minHeight, minWidth: $minWidth, maxHeight: $maxHeight, maxWidth: $maxWidth}';
  }
}
