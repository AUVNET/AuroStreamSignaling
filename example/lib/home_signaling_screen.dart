import 'signaling_service.dart';
import 'package:flutter/material.dart';

class HomeSignalingScreen extends StatefulWidget {
  final AuroStreamSignalingServices auroStreamSignalingServices;
  final String roomId;
  final bool isCreate;

  const HomeSignalingScreen({
    super.key,
    required this.auroStreamSignalingServices,
    required this.roomId,
    required this.isCreate,
  });

  @override
  State<HomeSignalingScreen> createState() => _HomeSignalingScreenState();
}

class _HomeSignalingScreenState extends State<HomeSignalingScreen> {
  AuroStreamSignalingServices? auroStreamSignalingServices;
  final messageController = TextEditingController();
  final roomIdController = TextEditingController();
  final userIdController = TextEditingController();

  @override
  void initState() {
    auroStreamSignalingServices = widget.auroStreamSignalingServices;
    auroStreamSignalingServices!.initRoomService(
      targetRoomId: widget.roomId,
      isCreateBoolean: widget.isCreate,
    );
    auroStreamSignalingServices!.initUpdateUI(
      update: () {
        setState(() {});
      },
      bContext: context,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(
                    color: Color(0xff0445A2),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Message..',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 50),
                MaterialButton(
                  color: const Color(0xff0445A2),
                  onPressed: () {
                    auroStreamSignalingServices?.sendObjectTOAll(
                      messageController.text.trim(),
                      true,
                    );
                  },
                  child: const Text(
                    'Send to ALL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: roomIdController,
                  decoration: const InputDecoration(
                    hintText: 'Room ID..',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                MaterialButton(
                  color: const Color(0xff0445A2),
                  onPressed: () {
                    auroStreamSignalingServices?.sendObjectTORoom(
                      messageController.text.trim(),
                      roomIdController.text.trim(),
                      true,
                    );
                  },
                  child: const Text(
                    'Send to Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    hintText: 'User ID..',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                MaterialButton(
                  color: const Color(0xff0445A2),
                  onPressed: () {
                    auroStreamSignalingServices?.sendObjectTOUser(
                      messageController.text.trim(),
                      userIdController.text.trim(),
                    );
                  },
                  child: const Text(
                    'Send to User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
