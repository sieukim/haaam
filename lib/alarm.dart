class Alarm {
  late String title;
  late String timeList;
  late bool activated;

  Alarm(this.title, this.timeList, this.activated);

  @override
  String toString() {
    return '{"title": "$title", "timeList": "$timeList", "activated": "$activated"}';
  }
}
