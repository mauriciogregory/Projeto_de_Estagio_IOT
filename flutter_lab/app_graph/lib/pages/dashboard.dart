import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  // token
  final token;
  const Dashboard({@required this.token, super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String email;

  List<dynamic> data = [];
  List<dynamic> datadht22 = [];
  double lastTemperature = 0;
  double lastHumidity = 0;
  int lastLDRValue = 0;
  List<dynamic> datadht22_last_data = [];
  List<dynamic> dataLDR_last = [];
  List<String> timeDHT22 = [];
  List<String> timeLDR = [];

  @override
  void initState() {
    if (mounted) {
      super.initState();

      Map<String, dynamic> jwt = JwtDecoder.decode(widget.token);

      email = jwt['sub'];

      fetchDataLDR(widget.token);
      fetchDataDht22(widget.token);
      Timer.periodic(const Duration(seconds: 5), (_) {
        fetchDataDht22(widget.token);
        fetchDataLDR(widget.token);
      });
    }
  }

// fetch data from DHT22 endpoint
  Future<void> fetchDataDht22(String jwt) async {
    if (mounted) {
      var url = Uri.parse("https://192.168.1.100:8443/dht22");

      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('sub') ?? "";

      var dht22 = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      });

      if (dht22.statusCode == 200 && mounted) {
        setState(() {
          datadht22 = json.decode(dht22.body);

          if (datadht22.isNotEmpty) {
            lastHumidity =
                double.parse(datadht22.last["humidityValue"].toString());
            lastTemperature =
                double.parse(datadht22.last["temperatureValue"].toString());

            datadht22_last_data = datadht22.reversed.take(100).toList();
            datadht22_last_data = datadht22_last_data.reversed.toList();
            timeDHT22 =
                datadht22_last_data.map((t) => t['time'].toString()).toList();
            timeDHT22 = timeDHT22.reversed.toList();
            // print(time);
          }
        });
      } else {
        throw Exception("Error to load API data DHT22");
      }
    }
  }

// fetch data from LDR endpoint
  Future<void> fetchDataLDR(String jwt) async {
    if (mounted) {
      var urlDht22 = Uri.parse('https://192.168.1.100:8443/ldr');
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('sub') ?? "";

      var ldr = await http.get(urlDht22, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      });

      if (ldr.statusCode == 200 && mounted) {
        setState(() {
          data = json.decode(ldr.body);

          if (data.isNotEmpty) {
            lastLDRValue = int.parse(data.last['value'].toString());
            dataLDR_last = data.reversed.take(100).toList();
            dataLDR_last = dataLDR_last.reversed.toList();
            timeLDR = dataLDR_last.map((t) => t['time'].toString()).toList();
            // print(dataLDR_last.sublist(0));
          }
        });
      } else {
        throw Exception("Error to load data from api");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  getDate(int index) {
    String date = timeLDR[index];
    return date;
  }

  getDateDHT22(int index) {
    String dateDHT = timeDHT22[index];
    return dateDHT;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lab IoT",
      theme: ThemeData(useMaterial3: false),
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.home),
          title: const Text(
            "Dashboard",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: ListView(
          addAutomaticKeepAlives: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Luminosidade do Sistema",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      (datadht22.isEmpty)
                          ? const Text("Error to Load Data from API")
                          : Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.lightBlue, width: 1)),
                                  width: 400,
                                  height: 300,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: LineChart(
                                      LineChartData(
                                        lineTouchData: LineTouchData(
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((e) {
                                                final date =
                                                    getDate(e.spotIndex);
                                                return LineTooltipItem(
                                                    e.y.toString(),
                                                    const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      TextSpan(
                                                          text: '\n $date',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          12,
                                                                          12,
                                                                          10)))
                                                    ]);
                                              }).toList();
                                            },
                                            // tooltipBgColor:
                                            //     const Color.fromARGB(
                                            //         255, 164, 207, 254),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                              spots: dataLDR_last.map((e) {
                                                return FlSpot(
                                                    dataLDR_last
                                                        .indexOf(e)
                                                        .toDouble(),
                                                    double.parse(
                                                        e['value'].toString()));
                                              }).toList(),
                                              isCurved: false,
                                              barWidth: 3,
                                              belowBarData:
                                                  BarAreaData(show: true),
                                              color: Colors.blue),
                                        ],
                                        titlesData: const FlTitlesData(
                                          bottomTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                reservedSize: 30,
                                                // interval: 10,
                                                showTitles: true,
                                              )),
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                                padding: EdgeInsets.all(8)),
                                            // axisNameSize: 5,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(16)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                          rightTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                        ),
                                        maxY: 4500,
                                        minY: 0,
                                        borderData: FlBorderData(
                                          border: const Border(
                                            bottom: BorderSide(),
                                            left: BorderSide(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // LDR Show in Dashboard
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.sunny),
                                        Text(
                                          "$lastLDRValue",
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),

//////////////////////////////////////////////////////////////////
                // Grafico da temperatura
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Umidade do Sistema",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    (datadht22.isEmpty)
                        ? const Text("Error to Load Data from API")
                        : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.lightBlue, width: 1)),
                                  width: 400,
                                  height: 300,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: LineChart(
                                      LineChartData(
                                        lineTouchData: LineTouchData(
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((e) {
                                                final date =
                                                    getDateDHT22(e.spotIndex);
                                                return LineTooltipItem(
                                                    e.y.toString(),
                                                    const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      TextSpan(
                                                          text: '\n $date',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          12,
                                                                          12,
                                                                          10)))
                                                    ]);
                                              }).toList();
                                            },
                                            // tooltipBgColor:
                                            //     const Color.fromARGB(
                                            //         255, 164, 207, 254),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                              spots: datadht22_last_data
                                                  .reversed
                                                  .map((e) {
                                                return FlSpot(
                                                    datadht22_last_data
                                                        .indexOf(e)
                                                        .toDouble(),
                                                    double.parse(
                                                        e['humidityValue']
                                                            .toString()));
                                              }).toList(),
                                              isCurved: true,
                                              barWidth: 4,
                                              belowBarData:
                                                  BarAreaData(show: true),
                                              color: Colors.blue),
                                        ],
                                        titlesData: const FlTitlesData(
                                          bottomTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                reservedSize: 30,
                                                interval: 10,
                                                showTitles: true,
                                              )),
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                                padding: EdgeInsets.all(8)),
                                            // axisNameSize: 5,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                          rightTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                        ),
                                        maxY: 100,
                                        minY: 0,
                                        maxX: 100,
                                        minX: 0,
                                        borderData: FlBorderData(
                                            border: const Border(
                                                bottom: BorderSide(),
                                                left: BorderSide())),
                                      ),
                                    ),
                                  ),
                                ),

                                // LDR Show in Dashboard
                                Center(
                                  child: SizedBox(
                                    height: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.cloudy_snowing),
                                            Text(
                                              maxLines: 1,
                                              "$lastHumidity",
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Temperatura do Sistema",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    (datadht22.isEmpty)
                        ? const Text("Error to Load Data from API")
                        : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.lightBlue, width: 1)),
                                  width: 400,
                                  height: 300,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: LineChart(
                                      LineChartData(
                                        lineTouchData: LineTouchData(
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((e) {
                                                final date =
                                                    getDateDHT22(e.spotIndex);
                                                return LineTooltipItem(
                                                    e.y.toString(),
                                                    const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      TextSpan(
                                                          text: '\n $date',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          12,
                                                                          12,
                                                                          10)))
                                                    ]);
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                              spots: datadht22_last_data
                                                  .reversed
                                                  .map((e) {
                                                return FlSpot(
                                                    datadht22_last_data
                                                        .indexOf(e)
                                                        .toDouble(),
                                                    double.parse(
                                                        e['temperatureValue']
                                                            .toString()));
                                              }).toList(),
                                              isCurved: true,
                                              barWidth: 4,
                                              belowBarData:
                                                  BarAreaData(show: true),
                                              color: Colors.blue),
                                        ],
                                        titlesData: const FlTitlesData(
                                          bottomTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                reservedSize: 30,
                                                interval: 10,
                                                showTitles: true,
                                              )),
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                                padding: EdgeInsets.all(8)),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                          rightTitles: AxisTitles(
                                              axisNameWidget: Padding(
                                                  padding: EdgeInsets.all(8)),
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                                reservedSize: 60,
                                              )),
                                        ),
                                        maxY: 100,
                                        minY: 0,
                                        maxX: 100,
                                        minX: 0,
                                        borderData: FlBorderData(
                                            border: const Border(
                                                bottom: BorderSide(),
                                                left: BorderSide())),
                                      ),
                                    ),
                                  ),
                                ),

                                // LDR Show in Dashboard
                                Center(
                                  child: SizedBox(
                                    height: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.thermostat),
                                            Text(
                                              maxLines: 1,
                                              "$lastTemperature",
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
