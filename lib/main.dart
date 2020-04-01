import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

import 'infinityComic.dart';
import 'infinityComicDetail.dart';

void main() => runApp(new MarvelApp());

const PUBLIC_KEY = "409bfd5e7c63c8b4f5dbd742ebeece56";
const PRIVATE_KEY = "299d2b414c032a94ac3176fd506dd8da15adc288";

var currentPagination = 0;
var pagination = 20;
var url = "";

String generateMd5(String input) {
  return crypto.md5.convert(utf8.encode(input)).toString();
}

class MarvelApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark, primaryColor: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text("Marvel Comics!"),
          ),
          body: InfinityDudes()),
    );
  }
}



class InfinityDudes extends StatefulWidget {
  @override
  ListInfinityDudesState createState() => new ListInfinityDudesState();
}

class ListInfinityDudesState extends State<InfinityDudes> {

  List<InfinityComic> items = List<InfinityComic>();

  Future<List<InfinityComic>> getDudes(bool newData) async {
    if (newData) {
      currentPagination += pagination;
    }
    var now = new DateTime.now();
    var md5D = generateMd5(now.toString() + PRIVATE_KEY + PUBLIC_KEY);
    url =
        "https://gateway.marvel.com:443/v1/public/characters?limit=$pagination&offset=$currentPagination&ts=" +
            now.toString() +
            "&apikey=" +
            PUBLIC_KEY +
            "&hash=" +
            md5D;
    print("Getting from url -> $url");

    var dudes = List<InfinityComic>();
    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    var dataMarvel = jsonData["data"];
    var marvelArray = dataMarvel["results"];
    for (var dude in marvelArray) {
      var thumb = dude["thumbnail"];
      var image = "${thumb["path"]}.jpg";
      InfinityComic infinityComic = InfinityComic(dude["name"], image);
      print("DUDE: " + infinityComic.title);
      dudes.add(infinityComic);
    }

    if(items.length == 0){
      items.addAll(dudes);
    }

    return dudes;
  }

  @override
  Widget build(BuildContext context) {
    var dataListView = new FutureBuilder(
        future: getDudes(false),
        builder: (context, AsyncSnapshot snapshot) {
          if (items.length == 0) {
            return Center(child: Text('Loading...'));
          } else {
            return createDudesListView(context);
          }
        }
    );

    return new Scaffold(
        body: dataListView
    );
  }

  Widget createDudesListView(BuildContext context) {
    print("Dudes length: ${items.length}");

    void _addMoreDudes() async{

      List<InfinityComic> newDudes = await getDudes(true);

      setState(() {
        items.addAll(newDudes);
      });
    }

    return ListView.builder(
      itemCount: items.length+1,
      itemBuilder: (BuildContext context, int index) {
        print("Current index: $index");
        if (index == currentPagination + pagination) {
          return Container(
            child: FlatButton(
              child: Text('Load more'),
              color: Colors.blueAccent,
              onPressed: _addMoreDudes,
            ),
          );
        } else {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(items[index].cover),
            ),
            title: Text(items[index].title),
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) => InfinityDetail(items[index])
              )
              );
            },
          );
        }
      },
    );


  }



}



