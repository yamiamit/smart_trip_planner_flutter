import 'package:url_launcher/url_launcher.dart';

//not used because of parsing(not able to use as a fxn in different files) issues
Future<void> openInMaps(String latLng) async {
  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latLng');
  await launchUrl(url, mode: LaunchMode.externalApplication);
}