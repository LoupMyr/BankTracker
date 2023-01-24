import 'package:bank_tracker/depensePerMonth.dart';
import 'package:bank_tracker/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bank_tracker/tools.dart';
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

class GraphePage extends StatefulWidget {
  const GraphePage({super.key, required this.title});
  final String title;

  @override
  State<GraphePage> createState() => GraphePageState();
}

class GraphePageState extends State<GraphePage> {
  Tools _tools = Tools();
  var _depenses;
  List<TotalPerMonth> _listTotal = List.empty(growable: true);
  List<String> months = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre'
  ];
  Future<String> recupDepenses() async {
    var response = await _tools.getDepenses();
    if (response.statusCode == 200) {
      _depenses = convert.jsonDecode(response.body);
      createTab();
    }
    return '';
  }

  void createTab() {
    for (int i = 1; i <= 12; i++) {
      double total = 0;
      for (var elt in _depenses['hydra:member']) {
        int mois = int.parse(
            DateFormat('MM').format(DateTime.parse(elt['datePaiement'])));
        double montant = double.parse(elt['montant'].toString());
        if (mois == i) {
          total = total + montant;
        }
      }
      _listTotal.add(new TotalPerMonth(months[i - 1], total));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: recupDepenses(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1.5,
                  child: SfCartesianChart(
                    title: ChartTitle(
                        text: 'Vos dépenses de 2023',
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    primaryXAxis: CategoryAxis(
                        interval: 1,
                        labelRotation: 75,
                        labelAlignment: LabelAlignment.end),
                    primaryYAxis: NumericAxis(minimum: 0),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<TotalPerMonth, String>>[
                      ColumnSeries<TotalPerMonth, String>(
                          onPointTap: (pointInteractionDetails) =>
                              Navigator.pushNamed(context, '/routeDetailsMois',
                                  arguments:
                                      pointInteractionDetails.pointIndex! + 1),
                          width: 0.5,
                          dataSource: _listTotal,
                          xValueMapper: (TotalPerMonth data, index) =>
                              data.getMois(),
                          yValueMapper: (TotalPerMonth data, index) =>
                              data.getTotal(),
                          name: 'Total:',
                          color: const Color.fromRGBO(8, 142, 255, 1))
                    ],
                  ),
                ),
              ),
            ];
          } else if (snapshot.hasError) {
            children = [
              const Icon(Icons.error_outline,
                  color: Color.fromARGB(255, 255, 17, 0)),
            ];
          } else {
            children = [
              SpinKitChasingDots(size: 150, color: Colors.red.shade400),
            ];
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget.title),
            ),
            drawer: Widgets.createDrawer(context),
            body: Center(
              child: Column(children: children),
            ),
          );
        });
  }
}
