String publicIdFromUrl(String url) {
  final regex = RegExp(r'upload\/v\d+\/(.+)\.');
  final match = regex.firstMatch(url);
  if (match != null && match.groupCount > 0) {
    return match.group(1)!;
  }
  return '';
}
