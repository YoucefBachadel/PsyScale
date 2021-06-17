import 'package:gsheets/gsheets.dart';

class GoogleSheetApi {
  static const _credential = r'''
  {
  "type": "service_account",
  "project_id": "psyscale-316309",
  "private_key_id": "b95b4e6466d6dd4ed60e48903f1db2bf8efa6f2c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClFJc8BIYzdU7s\nCzFlFx+4ATZC+BOTot3ozRn3btaw4ArfIVCoQrSZtPWcM80gYe01POcY/4WMxVN4\nqup6E50Je9SfMzkjKq7uCHWaNZc4YK3wIcwVhjplmpfYzNDA9YopHQCywtkGckY/\n40ZWmltpVmYKSSn1BtAJbTxB/6RlRWp1OZYjqO6UUjzx/2W1Lx/IbAPg8qtNF9Vv\n6bh4HHVgKdAGilSixO7yNDQVS3/YVqG+i2yjtYh0IRhvWD9APTvGYR4J9eBffhpU\nGMxKA05pSQ/es7U00XeDalCXmwNl23i5WQrRPutd6Ic0reTOPRPXMOWFFIej9kNM\ntUo1f9axAgMBAAECggEACT6BoEtU0EiAOZbAHqwEg0Finm4Nyxd8h50GKGlnGXcn\nVrLC9XQsULvt4dATC15eehvpqUhETFNvut7v09OZuHJsL/jOaRwqmPLlcoPwHpin\n3t3Go9ktF5vYR1xDT53kXWxlyczgWjR/n3PgwEhjKG89ljN+B24I6/E3dc7s79yD\n5veVlzzb/CyxP5HbhMnEugtC1OhPPsDM/3WLYF72CNHgR1WX12dRuOz3Ab3CCccK\nCgvya3GNRXstJfPTKg52k+fbERcjuuqMzrNawS48rF8t70ptpLe+PG6keVteaEr7\nxYRFQr55QYKvEaPhwfQqVTCoCAZKxu/tKzbPK+/WIQKBgQDXRlaPvisD7RypBn/T\nFxXKFqgClcxm8Ekpsjh8A/jHFHBZesty2nv5wB8DvdIiz9mT3B9siJt9MYhSF/rM\nafk980OaJ9iw7knfxCxnOAM+efI/GbTtxrxy/TDiRJlyNPfAL1muoYB7MkjYr7p5\nRTccwtnjzmLV5LDbpPQjWj7kUQKBgQDET10PGinMFIsyD2gThDQuV+PrGXJ9rhvp\nlVOrhQ/qfjdxtZYbJwqnD4OshOJZMs65nzr8cmu1d3vxhjia3QXlHTJHOJwuCfD5\nB+I2q+MHHcSC8zoRRQMxoq4fLE6QS29XdMjN/ya4DhYYe3D6rEBGM5ZBazITmUiU\ngvtHkEUUYQKBgAwAqfbdvXw8jiqGaD4WvWpFFRz/ySO8JfgjLa8McaR36UOz6v/+\nWoc0RQZqYPr757+suDvO6gxy5IzfNWaMSg9ALva7XgOPZaMKRweCQfwLxIvsHQBc\n4kjvAPi8pmmNtnqKqU9pRcaYqSMbuSPlzgrWeluPOEeAtrOoYMxPzc3hAoGAdoKi\n31cgHH/aeGIspnuNNN0CTw+RuqW9XAo19LnjneCMgCzrbYDoQWpwR1oBe2/ctNqX\ntYct1uNHA8vPqE3+HQ6/J5fZUUHXI7/KpM6nw8gItjU3vO04vGJFU7RfyWSA1v89\nqn56VWrLlAQRdINAWiESeHPKS2KiGmXoZI+H5IECgYEAkFrl3Y8crs83c55xYVT5\n1trukCzc9/DNvdPQcMrr86VrAQp7xPX9OSLkfpeRTvvclXz6WvpBrtjvt/k/9dWQ\nwJKjDftSggFK/57IwWuiKMc4UiRVqJN/xDu+G3OprmMhQqiH+Me9OWETztr5vmQZ\na2Kgc1Yjhq93151rxApIT38=\n-----END PRIVATE KEY-----\n",
  "client_email": "psyscale@psyscale-316309.iam.gserviceaccount.com",
  "client_id": "106286386253444482970",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/psyscale%40psyscale-316309.iam.gserviceaccount.com"
  }
  ''';

  final gsheet = GSheets(_credential);

  Worksheet userSheet;

  Future init(String spreadsheetId, String workSheetTitle, List<String> items,
      String insertType) async {
    final spreadsheet = await gsheet.spreadsheet(spreadsheetId);
    userSheet =
        await _getWorkSheet(spreadsheet: spreadsheet, title: workSheetTitle);
    insertType == 'first' ? addRow(items) : insertRow(items);
  }

  Future<Worksheet> _getWorkSheet(
      {Spreadsheet spreadsheet, String title}) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title);
    }
  }

  Future fillStudentsSheets() async {
    final spreadsheet = await gsheet
        .spreadsheet('1ToixrUhL3HeP0XOR5F-9AoStsOFAlDx4u88B8DMs8pk');
    userSheet =
        await _getWorkSheet(spreadsheet: spreadsheet, title: 'Origin Students');

    final json = await userSheet.values.map.allRows();
    print(json.length);
    userSheet = await _getWorkSheet(
        spreadsheet: spreadsheet,
        title: 'Anxiety disorder in college students');

    List<List<String>> allRows = [];
    json.forEach((element) async {
      List<String> row = [];
      element.values.forEach((element) {
        row.add(transferToInt(element));
      });
      allRows.add(row);
    });

    userSheet.values.appendRows(allRows);
  }

  addRow(List<String> items) {
    try {
      userSheet.values.insertRow(1, items);
    } catch (e) {
      print('Init Error: $e');
    }
  }

  insertRow(List<String> items) {
    try {
      userSheet.values.appendRow(items);
    } catch (e) {
      print('Init Error: $e');
    }
  }

  String transferToInt(String value) {
    switch (value.toLowerCase()) {
      case 'false':
      case 'no':
        return '0';
      case 'not at all':
      case 'true':
      case 'a little of the time':
      case 'yes':
      case 'first':
      case 'less than 3 hours':
        return '1';
      case 'several days':
      case 'some of the time':
      case 'middle':
      case '3 to 4 hours':
        return '2';
        break;
      case 'over half the days':
      case 'good part of the time':
      case 'last one':
      case '4 to 5 hours':
        return '3';
      case 'nearly everyday':
      case 'most of the time':
      case '5 to 6 hours':
        return '4';
      case 'more than 6 hours':
        return '5';
      default:
        return '1';
    }
  }
}
