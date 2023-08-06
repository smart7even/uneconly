import 'package:flutter/material.dart';

MaterialColor getColorFromString(String color) {
  switch (color) {
    case 'blue':
      return Colors.blue;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'pink':
      return Colors.pink;
    case 'purple':
      return Colors.purple;
    case 'indigo':
      return Colors.indigo;
    case 'teal':
      return Colors.teal;
    case 'cyan':
      return Colors.cyan;
    case 'brown':
      return Colors.brown;
    case 'grey':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}

String getStringFromColor(MaterialColor color) {
  if (color == Colors.blue) {
    return 'blue';
  } else if (color == Colors.red) {
    return 'red';
  } else if (color == Colors.green) {
    return 'green';
  } else if (color == Colors.yellow) {
    return 'yellow';
  } else if (color == Colors.orange) {
    return 'orange';
  } else if (color == Colors.pink) {
    return 'pink';
  } else if (color == Colors.purple) {
    return 'purple';
  } else if (color == Colors.indigo) {
    return 'indigo';
  } else if (color == Colors.teal) {
    return 'teal';
  } else if (color == Colors.cyan) {
    return 'cyan';
  } else if (color == Colors.brown) {
    return 'brown';
  } else if (color == Colors.grey) {
    return 'grey';
  } else {
    return 'blue';
  }
}
