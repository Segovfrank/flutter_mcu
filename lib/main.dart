import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

void main() => runApp(new MarvelApp());

const PUBLIC_KEY = "409bfd5e7c63c8b4f5dbd742ebeece56";
const PRIVATE_KEY = "299d2b414c032a94ac3176fd506dd8da15adc288";

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
  Future<List<InfinityComic>> getDudes() async {
    var now = new DateTime.now();
    var md5D = generateMd5(now.toString() + PRIVATE_KEY + PUBLIC_KEY);
    var url = "https://gateway.marvel.com:443/v1/public/characters?&ts=" +
        now.toString() +
        "&apikey=" +
        PUBLIC_KEY +
        "&hash=" +
        md5D;
    print("------------------------------->" + url);

    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    List<InfinityComic> dudes = [];
    var dataMarvel = jsonData["data"];
    var marvelArray = dataMarvel["results"];
    for (var dude in marvelArray) {
      var thumb = dude["thumbnail"];
      var image = "${thumb["path"]}.jpg";
      InfinityComic infinityComic = InfinityComic(dude["name"], image);
      print("DUDE: " + infinityComic.title);
      dudes.add(infinityComic);
    }

    return dudes;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: FutureBuilder(
          future: getDudes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data[index].cover),
                    ),
                    title: Text(snapshot.data[index].title),
                    onTap: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => InfinityDetail(snapshot.data[index])
                        )
                      );
                    },
                  );
                },
              );
            } else {
              return Container(
                child: Center(
                  child: Text('Loading...'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class InfinityComic {
  final String title;
  final String cover;

  InfinityComic(this.title, this.cover);
}

class InfinityDetail extends StatelessWidget {
  final InfinityComic infinityComic;

  InfinityDetail(this.infinityComic);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(infinityComic.title),
        ),
        body: Image.network(
          infinityComic.cover,
        ));
  }
}
