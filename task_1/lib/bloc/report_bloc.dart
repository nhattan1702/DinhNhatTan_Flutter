import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:excel/excel.dart';
import 'package:task_1/bloc/event.dart';
import 'package:task_1/bloc/state.dart';
import '../model/transaction.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  List<Transaction> transactions = [];

  ReportBloc() : super(ReportInitial()) {
    on<UploadFile>((event, emit) async {
      emit(ReportLoading());
      try {
        var file = File(event.filePath);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables.keys.first;
        var table = excel.tables[sheet]!.rows;

        transactions.clear();

        for (var row in table.skip(8)) {
          if (row.length > 8 && row[2] != null && row[8] != null) {
            String timeString = row[2]?.value.toString() ?? '00:00:00';

            double amount =
                double.tryParse(row[8]!.value.toString().replaceAll(',', '')) ??
                    0.0;

            transactions.add(Transaction(time: timeString, amount: amount));
          }
        }

        // for (var transaction in transactions) {
        //   print("Time: ${transaction.time}, Amount: ${transaction.amount}");
        // }

        emit(ReportSuccess(
            "Upload thành công: ${transactions.length} giao dịch"));
      } catch (e) {
        emit(ReportError("Lỗi khi tải file: $e"));
      }
    });

    on<CalculateTotal>((event, emit) {
      if (transactions.isEmpty) {
        emit(ReportError("Chưa có giao dịch nào để tính toán."));
        return;
      }

      DateTime? earliestTransactionTime;
      DateTime? latestTransactionTime;

      for (var transaction in transactions) {
        List<String> parts = transaction.time.split(':');
        DateTime transactionTime = DateTime(
          2024,
          03,
          21,
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        if (earliestTransactionTime == null ||
            transactionTime.isBefore(earliestTransactionTime)) {
          earliestTransactionTime = transactionTime;
        }

        if (latestTransactionTime == null ||
            transactionTime.isAfter(latestTransactionTime)) {
          latestTransactionTime = transactionTime;
        }
      }

      if (event.start.isBefore(earliestTransactionTime!) ||
          event.end.isAfter(latestTransactionTime!)) {
        emit(ReportError(
            "Thời gian bắt đầu và kết thúc phải nằm trong khoảng thời gian của các giao dịch. "
            "Giao dịch sớm nhất: ${earliestTransactionTime.toLocal()}, "
            "Giao dịch muộn nhất: ${latestTransactionTime?.toLocal()}"));
        return;
      }

      double total = transactions.where((transaction) {
        String timeString = transaction.time;
        List<String> parts = timeString.split(':');
        DateTime transactionTime = DateTime(
          2024,
          03,
          21,
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        return transactionTime.isAfter(event.start) &&
            transactionTime.isBefore(event.end);
      }).fold(0.0, (sum, transaction) => sum + transaction.amount);

      emit(TotalCalculated(total));
    });
  }
}
