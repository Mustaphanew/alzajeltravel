// all pages as enum

enum Routes {
  root('/'),
  intro('/intro'),
  login('/login'),
  frame('/frame'),
  searchFlight('/search-flight'),
  flightOfferList('/flight-offer-list'),
  flightOfferDetails('/flight-offer-details'),
  moreFlightDetail('/more-flight-detail'),
  passportForms('/passport-forms'),
  travelersReview('/travelers-review'),
  prebookingAndIssueing('/prebooking-and-issueing');
  
  final String route;
  const Routes(this.route);

  String get path => route.startsWith('/') ? route : '/$route';

  // try parse
  static Routes? tryParse(String v) {
    for (final e in Routes.values) {
      if (e.route == v || e.path == v) return e; // نقبل route أو path
    }
    return null;
  }

  // from raw
  static Routes fromRaw(String v) {
    return Routes.values.firstWhere((e) {
      return e.route == v || e.path == v;
    });
  } 
}
