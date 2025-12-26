import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class FrameController extends GetxController {
    final PersistentTabController persistentTabController =
      PersistentTabController(initialIndex: 0);
}
