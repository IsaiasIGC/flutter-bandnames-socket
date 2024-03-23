import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload ) {

    bands = (payload as List)
        .map( (band) => Band.fromMap(band) )
        .toList();

        setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ( socketService.serverStatus == ServerStatus.Online )
            ? Icon(Icons.check_circle, color: Colors.blue[300])
            : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile(bands[i])
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.emit('delete-band', { 'id': band.id }),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),)
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0,2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if ( Platform.isIOS ) {
      // Android
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
          title: const Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => addBandToList( textController.text ),
              elevation: 5,
              textColor: Colors.blue,
              child: const Text('Add'),
            )
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: ( _ ) => CupertinoAlertDialog(
        title: const Text('New band name:'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => addBandToList( textController.text ),
            isDefaultAction: true,
            textStyle: const TextStyle(color: Colors.blue),
            child: const Text('Add'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

  }


  void addBandToList(String name) {

    if ( name.length > 1 ) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', { 'name': name });
    }


    Navigator.pop(context);

  }

  // Mostrar Gráfica
  Widget _showGraph() {
    Map<String, double> dataMap = {};
  
    bands.forEach((band) {
  
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble());
  
    });

    final List<Color> colorList = [
      Colors.blue[50] as Color,
      Colors.blue[200] as Color,
      Colors.pink[50] as Color,
      Colors.pink[200] as Color,
      Colors.yellow[50] as Color,
      Colors.yellow[200] as Color,
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 175,
      child: PieChart(
        dataMap: dataMap.isEmpty? {'No hay datos':0} : dataMap,
        animationDuration: const Duration(milliseconds: 800),
        colorList: colorList,
        chartType: ChartType.ring,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
      )
    );
  }


}