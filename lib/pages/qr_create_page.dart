import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCreatePage extends StatefulWidget {
  const QRCreatePage({Key? key}) : super(key: key);

  @override
  _QRCreatePageState createState() => _QRCreatePageState();
}

class _QRCreatePageState extends State<QRCreatePage> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImage(
                data: controller.text,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(
                height: 40,
              ),
              buildTextField(context),
            ],
          ),
        ),
      );

  Widget buildTextField(BuildContext context) => TextField(
        controller: controller,
        style: const TextStyle(),
        decoration: InputDecoration(
          hintText: 'Enter the data',
          hintStyle: const TextStyle(color: Colors.white),
          suffixIcon: IconButton(
            icon: const Icon(Icons.done, size: 30),
            onPressed: () => setState(() => {}),
          ),
        ),
      );
}
