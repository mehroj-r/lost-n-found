import 'package:flutter/material.dart';
import 'package:lost_n_found/widgets/textButton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          Text("This is home page"),
          OurButton(),
        ],
      ),
    ));
  }
}
