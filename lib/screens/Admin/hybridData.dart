import 'package:flutter/material.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/services/googleSheetServices.dart';
import 'package:psyscale/shared/widgets.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'dart:convert';

class HybridData extends StatefulWidget {
  final Questionnaire questionnaire;
  const HybridData({Key key, this.questionnaire}) : super(key: key);

  @override
  _HybridDataState createState() => _HybridDataState();
}

class _HybridDataState extends State<HybridData> {
  final GoogleSheetApi _googleSheetApi = GoogleSheetApi();
  List<List<String>> dataToExcel = [];
  List<List<String>> allRows = [];
  List<DataColumn> _columns = [];

  getData(List<Map<String, Object>> data) {
    _columns.addAll(data.first.keys.map((e) => DataColumn(
            label: Text(
          e,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.bold),
        ))));

    data.forEach((element) {
      List<String> row = [];
      element.values.forEach((element) {
        row.add(element.toString());
      });
      allRows.add(row);
    });

    dataToExcel.add(data.first.keys.toList());
    dataToExcel.addAll(allRows);
  }

  Future<void> createExcel(List<List<String>> data) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    int i = 1, j = 1;

    data.forEach((row) {
      row.forEach((element) {
        sheet.getRangeByIndex(i, j).setText(element);
        j++;
      });
      j = 1;
      i++;
    });

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', '${widget.questionnaire.nameEn}.xlsx')
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.questionnaire.nameEn,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: deleteButton(context, () {
                createExcel(dataToExcel);
              }, text: 'Download', color: Colors.green, icon: Icons.download),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: FutureBuilder(
            future: _googleSheetApi.getHybridData(
                widget.questionnaire.stockageUrl, widget.questionnaire.nameEn),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (allRows.isEmpty) {
                  getData(snapshot.data);
                }
                return Scrollbar(
                  isAlwaysShown: true,
                  child: ListView(
                    children: [
                      PaginatedDataTable(
                        source: DataSource(
                            context: context,
                            allRows: allRows,
                            questionnaire: widget.questionnaire),
                        columns: _columns,
                        showFirstLastButtons: true,
                      ),
                    ],
                  ),
                );
              }
              return loading(context);
            },
          ),
        ));
  }
}

class DataSource extends DataTableSource {
  List<List<String>> allRows;
  BuildContext context;
  int _selectedCount = 0;
  Questionnaire questionnaire;
  DataSource({this.questionnaire, this.allRows, this.context});
  @override
  DataRow getRow(int index) {
    final List<String> row = allRows[index];
    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.all(Colors.transparent),
      cells: row.map((e) {
        return DataCell(
          Text(
            e,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => allRows.length;

  @override
  int get selectedRowCount => _selectedCount;
}
