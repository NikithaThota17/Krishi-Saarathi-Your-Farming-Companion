class MarketPriceRecord {
  const MarketPriceRecord({
    required this.commodity,
    required this.state,
    required this.district,
    required this.market,
    required this.variety,
    required this.grade,
    required this.arrivalDate,
    required this.minPrice,
    required this.modalPrice,
    required this.maxPrice,
    required this.priceUnit,
    required this.arrivalQty,
    required this.arrivalUnit,
  });

  final String commodity;
  final String state;
  final String district;
  final String market;
  final String variety;
  final String grade;
  final String arrivalDate;
  final double minPrice;
  final double modalPrice;
  final double maxPrice;
  final String priceUnit;
  final double arrivalQty;
  final String arrivalUnit;
}

class MarketFilterData {
  const MarketFilterData({
    required this.states,
    required this.markets,
    required this.commodities,
  });

  final List<String> states;
  final List<String> markets;
  final List<String> commodities;
}
