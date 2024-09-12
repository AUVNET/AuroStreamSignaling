import 'package:auro_stream_signaling/auro_stream_signaling.dart';

import 'signaling_service.dart';
import 'home_signaling_screen.dart';
import 'package:flutter/material.dart';

void main() {
  AuroStreamSignaling.initialize(
    projectId: 'f7675299b1b7ae6dab3dc0df61c3d88e',
    apiKey: '98dc785d2c5e50bc3b22b5f1.c3b883ebbdc5294c93217e77aa3a010abd9a69cd05141e68cdf5b3437a536199ae04c249793d5d5e6acc525afaec09223f9dfbf7931b8eac1f758664f82e9e894871a0106dc15ebdf5c7597b5b70189edbd8dd73930e323b22fd2f383f842266267fb949761ab0.0049bc47ee005b242b6a6bb2',
    port: '1024',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AuroStream Signaling',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuroStreamSignalingServices? auroStreamSignalingServices;
  final userController = TextEditingController();
  final roomIdController = TextEditingController();

  @override
  void initState() {
    auroStreamSignalingServices = AuroStreamSignalingServices();
    auroStreamSignalingServices!.connectServer();
    super.initState();
  }

  void connect(bool isCreate) {
    /// Should have unique String for user like username or id
    final username = userController.text.trim();
    final roomId = roomIdController.text.trim();
    if (username.isNotEmpty && roomId.isNotEmpty) {
      auroStreamSignalingServices!.initUsername(usernameId: username);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeSignalingScreen(
            auroStreamSignalingServices: auroStreamSignalingServices!,
            roomId: roomId,
            isCreate: isCreate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'UserName',
                  style: TextStyle(color: Color(0xff0445A2), fontSize: 16),
                ),

                const SizedBox(height: 8),
                TextFormField(
                  controller: userController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your username..',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: roomIdController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Room ID..',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: const Color(0xff0445A2),
                      onPressed: () {
                        connect(true);
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    MaterialButton(
                      color: const Color(0xff0445A2),
                      onPressed: () {
                        connect(false);
                      },
                      child: const Text(
                        'Join',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
