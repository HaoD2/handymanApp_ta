class FilterMenu {
  bool filterByDistance;
  bool checkbox1;
  bool checkbox2;
  bool checkbox3;
  bool checkbox4;
  bool checkbox5;

  double distance;

  FilterMenu({
    this.distance = 100.0,
    this.checkbox1 = false,
    this.checkbox2 = false,
    this.checkbox3 = false,
    this.checkbox4 = false,
    this.checkbox5 = false,
    this.filterByDistance = false,
  });
}
