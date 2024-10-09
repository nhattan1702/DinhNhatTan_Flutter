abstract class ReportEvent {}

class UploadFile extends ReportEvent {
  final String filePath;

  UploadFile(this.filePath);
}

class CalculateTotal extends ReportEvent {
  final DateTime start;
  final DateTime end;

  CalculateTotal(this.start, this.end);
}
