import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final response = await http
      .get(Uri.parse('https://test-share.shub.edu.vn/api/intern-test/input'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final String token = jsonResponse['token'];
    final List<int> data = List<int>.from(jsonResponse['data']);
    final List<dynamic> queries = jsonResponse['query'];

    List<int> prefixSum = List<int>.filled(data.length + 1, 0);
    List<int> prefixEvenOdd = List<int>.filled(data.length + 1, 0);

    for (int i = 0; i < data.length; i++) {
      prefixSum[i + 1] = prefixSum[i] + data[i];
      if (i % 2 == 0) {
        prefixEvenOdd[i + 1] = prefixEvenOdd[i] + data[i];
      } else {
        prefixEvenOdd[i + 1] = prefixEvenOdd[i] - data[i];
      }
    }

    List<int> results = [];

    for (var query in queries) {
      final String type = query['type'];
      final List<int> range = List<int>.from(query['range']);

      int l = range[0];
      int r = range[1];

      if (type == "1") {
        int sum = prefixSum[r + 1] - prefixSum[l];
        results.add(sum);
      } else if (type == "2") {
        int evenOddSum = prefixEvenOdd[r + 1] - prefixEvenOdd[l];
        results.add(evenOddSum);
      }
    }
    print('Mảng kết quả: $results');
    await sendResults(token, results);
  } else {
    print('Lỗi khi lấy dữ liệu: ${response.body}');
  }
}

Future<void> sendResults(String token, List<int> results) async {
  final response = await http.post(
    Uri.parse('https://test-share.shub.edu.vn/api/intern-test/output'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: jsonEncode(results),
  );

  if (response.statusCode == 200) {
    print('Kết quả đã được gửi thành công!');
  } else {
    print('Lỗi khi gửi kết quả: ${response.body}');
  }
}
