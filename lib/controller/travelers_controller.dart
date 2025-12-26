import 'package:get/get.dart';

class TravelersController extends GetxController {
  int adultsCounter = 1;
  int childrenCounter = 0;
  int infantsInSeatCounter = 0;
  int infantsInLapCounter = 0;

  int maxTravelersCounter = 9;

  int maxChildrenCounter() {
    return maxTravelersCounter - 1;
  }

  int maxInfantsInSeatCounter() {
    return maxTravelersCounter - 1;
  }

  int maxInfantsInLapCounter() {
    return adultsCounter;
  }

  int travelersCounter() {
    return adultsCounter +
        childrenCounter +
        infantsInSeatCounter +
        infantsInLapCounter;
  }

  changeAdultsCounter(int value) {
    print("changeAdultsCounter: $value");
    final newValue = adultsCounter + value;

    if (newValue >= 1) {
      adultsCounter = newValue;
    }
    if(infantsInLapCounter > adultsCounter) {
      infantsInLapCounter = adultsCounter;
    }
    update();
  }

  changeChildrenCounter(int value) {
    final newValue = childrenCounter + value;

    if (newValue >= 0) {
      childrenCounter = newValue;
      update();
    }
  }

  changeInfantsInSeatCounter(int value) {
    final newValue = infantsInSeatCounter + value;

    if (newValue >= 0) {
      infantsInSeatCounter = newValue;
      update();
    }
  }

  changeInfantsInLapCounter(int value) {
    final newValue = infantsInLapCounter + value;

    if (newValue >= 0) {
      infantsInLapCounter = newValue;
      update();
    }
  }
}
