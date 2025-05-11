import 'package:timeago/timeago.dart' as timeago;

class UtilityHelper {
  static String formatTimeAgo(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      return timeago.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
