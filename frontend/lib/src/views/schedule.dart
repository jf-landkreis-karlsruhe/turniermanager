import 'package:flutter/material.dart';

class Schedule extends StatelessWidget {
  const Schedule(
    this.ageGroup,
    this.league, {
    super.key,
  });

  final String ageGroup;
  final String league;

  static const routeName = '/schedule';
  static const ageGroupQueryParam = 'ageGroup';
  static const leagueQueryParam = 'league';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
