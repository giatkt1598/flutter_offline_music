import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/home_page.dart';
import 'package:flutter_offline_music/pages/player_page.dart';
import 'package:flutter_offline_music/pages/song_list_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final double _sliderVal = 0;
  List<String> musicFormats = ['.mp3', '.m4a'];
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<List<String>> getMusicFolders({
    String folderPath = '/storage/emulated/0',
  }) async {
    List<String> result = [];
    List<String> blacklist = ['/storage/emulated/0/Android'];
    if (blacklist.contains(folderPath)) return result;
    Directory directory = Directory(folderPath);
    if (await directory.exists()) {
      for (var element in directory.listSync()) {
        var type = await FileSystemEntity.type(element.path);
        bool isMusicFile =
            type == FileSystemEntityType.file &&
            musicFormats.any((x) => element.path.endsWith(x));
        if (isMusicFile) {
          result.add(element.parent.path);
        } else if (type == FileSystemEntityType.directory) {
          result.addAll(await getMusicFolders(folderPath: element.path));
        }
      }
      return result.toSet().toList(); // Lists all files and folders
    } else {
      throw Exception("Folder does not exist");
    }
  }

  final player = AudioPlayer();
  void scanMusic() async {
    if (await requestStoragePermission()) {
      List<String> files = await getMusicFolders();

      for (var file in files) {
        print("File: $file");
        for (var element in getMusicFiles(file)) {
          print('Music $element');
          return;
        }
      }
    } else {
      print("Permission Denied");
    }
  }

  void play() async {
    String musicPath = getMusicFiles((await getMusicFolders()).first).first;
    await player.setFilePath(musicPath);
    player.durationStream.listen(
      (d) => setState(() {
        _duration = d ?? Duration.zero;
      }),
    );

    player.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
    player.play();
  }

  void _seek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  List<String> getMusicFiles(String filePath) {
    var dir = Directory(filePath);
    var files = dir.listSync();

    return files
        .where((x) => musicFormats.any((f) => x.path.endsWith(f)))
        .map((x) => x.path)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                scanMusic();
              },
              child: Text('Quét nhạc'),
            ),
            TextButton(
              onPressed: () async {
                if (!await requestStoragePermission()) {
                  return;
                }
                if (player.duration == null) {
                  play();
                } else {
                  if (player.playing) {
                    player.pause();
                  } else {
                    player.play();
                  }
                }

                setState(() {});
              },
              child: Text(player.playing ? 'Pause' : 'Play'),
            ),
            Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: _seek,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: player.play,
                ),
                IconButton(icon: Icon(Icons.pause), onPressed: player.pause),
                IconButton(icon: Icon(Icons.stop), onPressed: player.stop),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
