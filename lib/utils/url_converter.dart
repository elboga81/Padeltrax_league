class UrlConverter {
  static String getDirectGoogleDriveUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'assets/images/profile.png';
    }

    if (url.contains('drive.google.com')) {
      return url.replaceAll('https://drive.google.com/uc?id=',
          'https://drive.google.com/uc?export=view&id=');
    }
    return url;
  }
}
