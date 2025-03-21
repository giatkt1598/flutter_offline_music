extension StringExtension on String {
  String? toNullIfEmpty() {
    return isEmpty ? null : this;
  }
}
