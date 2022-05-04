

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProfilePlaceholder());
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color color = Colors.grey;
    return Column(
          children: [
            Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                        child: CircleAvatar(
                            radius: 40,
                          backgroundColor: color,
                        )
                    ),
                    const SizedBox(height: 10),

                    // NAME
                    Container(
                      width:200,
                      height:20,
                      color: color,
                    ),
                    const SizedBox(height: 20),

                    // Affiliation
                    Container(
                      width:300,
                      height:20,
                      color: color,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              width:60,
                              height:20,
                              color: color,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width:30,
                              height:20,
                              color: color,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width:60,
                              height:20,
                              color: color,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width:30,
                              height:20,
                              color: color,
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(height: 30,
                      thickness: 3,
                      indent: 20,
                      endIndent: 20,),
                    Container(
                      width:60,
                      height:20,
                      color: color,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              width:60,
                              height:20,
                              color: color,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width:30,
                              height:20,
                              color: color,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width:60,
                              height:20,
                              color: color,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width:30,
                              height:20,
                              color: color,
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(height: 30,
                      thickness: 3,
                      indent: 20,
                      endIndent: 20,),
                  ],
                )
            ),
            /*const SizedBox(height: 15),
                      const Text("Estatísticas", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                      const SizedBox(height: 15),

                      const Text("Número de Spots lidos"),
                      const Text("4", style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(height: 10),

                      const Text("Tempo médio de descoberta de Spots"),
                      const Text("20:35", style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(height: 10),

                      const Text("Estatística Random"),
                      const Text("Torradas Mistas", style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(height: 10),

                      const Text("Outra Estatística Random"),
                      const Text("Tostas Assadas", style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(height: 10),
                                                */
          ],
        );
  }
}

