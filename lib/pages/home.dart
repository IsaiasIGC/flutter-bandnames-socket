import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Guns & Roses', votes: 5),
    Band(id: '2', name: 'Bon Jovi', votes: 4),
    Band(id: '3', name: 'ACDC', votes: 3),
    Band(id: '4', name: 'Queen', votes: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( context, i ) => _bandTile(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) {
        print('direction: $direction');
        print('id: ${band.id}');
        // todo
      },
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
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if ( Platform.isIOS ) {
      // Android
      return showDialog(
        context: context,
        builder: ( context ) {
          return AlertDialog(
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
          );
        }
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
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
        );
      }
    );

  }


  void addBandToList(String name) {
    print(name);

    if ( name.length > 1 ) {
      bands.add( Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }


    Navigator.pop(context);

  }


}