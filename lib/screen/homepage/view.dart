import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:meaning/component/message.dart';
import 'package:meaning/screen/homepage/controller.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final controller = HomePageController();
  @override
  void initState() {
    super.initState();
    controller.streamController = StreamController();
    controller.stream = controller.streamController!.stream.asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.longestSide * .165,
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))),
        title: Text(
          "Definitions",
          style: TextStyle(
              fontSize: size.shortestSide * .06, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
            child: Padding(
              padding: EdgeInsets.all(size.shortestSide * .02),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextField(
                        controller: controller.searchcontroller,
                        onChanged: (val) {
                          if (controller.timer?.isActive ?? false) {
                            controller.timer!.cancel();
                          }
                          controller.timer =
                              Timer(const Duration(milliseconds: 1000), () {
                            controller.search();
                          });
                        },
                        style: TextStyle(
                            fontSize: size.shortestSide * .05,
                            fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                            hintText: "Search for word",
                            filled: true,
                            fillColor: Colors.white)),
                  ),
                  Expanded(
                      flex: 2,
                      child: IconButton(
                          onPressed: () {
                            controller.search();
                          },
                          icon: Icon(Icons.search_rounded,
                              color: Colors.white,
                              size: size.shortestSide * .075)))
                ],
              ),
            ),
            preferredSize: const Size.fromHeight(0)),
      ),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          controller.connected = connectivity != ConnectivityResult.none;

          if (controller.connected == true) {
            return StreamBuilder(
                stream: controller.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return MessageItem(
                      img: "images/enterdata.png",
                      msg: "Enter Your Word",
                      size: size,
                    );
                  }
                  if (snapshot.data == "wait") {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  try {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.shortestSide * .015,
                          vertical: size.longestSide * .015),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (snapshot.data["definitions"].length == 0) {
                          return const Center(
                            child: Text("Enter Your Word"),
                          );
                        }
                        return Card(
                          elevation: 20,
                          margin:
                              EdgeInsets.only(bottom: size.longestSide * .02),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.shortestSide * .05,
                                vertical: size.longestSide * .02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                snapshot.data["definitions"][index]
                                            ["image_url"] ==
                                        null
                                    ? const SizedBox()
                                    : Center(
                                        child: CircleAvatar(
                                          radius: size.shortestSide * .18,
                                          backgroundImage: NetworkImage(
                                            snapshot.data["definitions"][index]
                                                ["image_url"],
                                          ),
                                        ),
                                      ),
                                SelectableText(
                                  controller.searchcontroller.text +
                                      " (" +
                                      snapshot.data["definitions"][index]
                                          ["type"] +
                                      ")",
                                  style: TextStyle(
                                      fontSize: size.shortestSide * .05,
                                      fontWeight: FontWeight.w600),
                                ),
                                SelectableText(
                                  snapshot.data["definitions"][index]
                                      ["definition"],
                                  style: TextStyle(
                                      fontSize: size.shortestSide * .045,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data["definitions"].length,
                    );
                    // ignore: empty_catches
                  } catch (e) {}
                  return MessageItem(
                    img: "images/wrong.png",
                    msg: "Enter The Word Correct..",
                    size: size,
                  );
                });
          } else {
            return MessageItem(
              img: "images/disconnected.png",
              msg: "Check your network..",
              size: size,
            );
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
