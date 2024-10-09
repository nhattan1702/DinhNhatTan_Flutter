import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:task_1/bloc/report_bloc.dart';
import 'package:task_1/bloc/event.dart';
import 'package:task_1/bloc/state.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _startTime;
  DateTime? _endTime;
  double _total = 0.0;

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _startTimeError;
  String? _endTimeError;

  bool _isValidTime(String time) {
    final RegExp timeRegExp = RegExp(r'^(?:[01]?\d|2[0-3]):[0-5]?\d:[0-5]?\d$');
    if (!timeRegExp.hasMatch(time)) {
      return false;
    }

    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    return hours < 24 && minutes < 60 && seconds < 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tính Tổng Giao Dịch")),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ReportError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is TotalCalculated) {
            setState(() {
              _total = state.total;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'xls'],
                    );

                    if (result != null && result.files.isNotEmpty) {
                      String filePath = result.files.single.path!;
                      context.read<ReportBloc>().add(UploadFile(filePath));
                    }
                  },
                  child: Text("Upload File"),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _startTimeController,
                  decoration: InputDecoration(
                    labelText: "Start Time (HH:mm:ss)",
                    errorText: _startTimeError,
                  ),
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    setState(() {
                      _startTimeError =
                          _isValidTime(value) ? null : "Định dạng không hợp lệ";
                    });
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _endTimeController,
                  decoration: InputDecoration(
                    labelText: "End Time (HH:mm:ss)",
                    errorText: _endTimeError,
                  ),
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    setState(() {
                      _endTimeError =
                          _isValidTime(value) ? null : "Định dạng không hợp lệ";
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String? startTimeString = _startTimeController.text;
                    String? endTimeString = _endTimeController.text;

                    if (startTimeString.isNotEmpty &&
                        endTimeString.isNotEmpty &&
                        _isValidTime(startTimeString) &&
                        _isValidTime(endTimeString)) {
                      try {
                        List<String> startParts = startTimeString.split(':');
                        List<String> endParts = endTimeString.split(':');

                        _startTime = DateTime(
                          2024,
                          03,
                          21,
                          int.parse(startParts[0]),
                          int.parse(startParts[1]),
                          int.parse(startParts[2]),
                        );

                        _endTime = DateTime(
                          2024,
                          03,
                          21,
                          int.parse(endParts[0]),
                          int.parse(endParts[1]),
                          int.parse(endParts[2]),
                        );
                        if (_endTime!.isBefore(_startTime!)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Thời gian kết thúc không được trước thời gian bắt đầu"),
                          ));
                          return;
                        }

                        context
                            .read<ReportBloc>()
                            .add(CalculateTotal(_startTime!, _endTime!));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Định dạng thời gian không hợp lệ"),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Vui lòng nhập cả thời gian bắt đầu và kết thúc")));
                    }
                  },
                  child: Text("Tính Tổng"),
                ),
                SizedBox(height: 20),
                Text(
                  "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_total)}",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
