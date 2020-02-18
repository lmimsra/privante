
import 'package:flutter/material.dart';

class Event {
  Event({@required this.isMine ,this.id, this.title, this.description, this.start});
  final bool isMine;
  String id;
  String title;
  String description;
  DateTime start;
}