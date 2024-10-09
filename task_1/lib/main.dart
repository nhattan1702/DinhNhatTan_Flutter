import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/report_bloc.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tính Tổng Giao Dịch',
      home: BlocProvider(
        create: (context) => ReportBloc(),
        child: HomePage(),
      ),
    );
  }
}
