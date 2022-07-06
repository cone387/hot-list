bool isLocalMedia(String? media) {
  return media != null && media.startsWith('/');
}

bool isRemoteMedia(String? media) {
  return media != null && media.startsWith('http');
}
