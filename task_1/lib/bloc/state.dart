abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final String message;

  ReportSuccess(this.message);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}

class TotalCalculated extends ReportState {
  final double total;

  TotalCalculated(this.total);
}
