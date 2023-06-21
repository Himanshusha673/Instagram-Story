import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:insta_story/screens/story_screen_view.dart';
import '../data.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Stories'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      log(users[index].name);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StoryScreen(
                                stories: stories,
                                user: users[currentUserIndex++])),
                      );
                    },
                    child: Container(
                      // padding: const EdgeInsets.all(4.0),
                      width: 70.0,
                      height: 70.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 3.0,
                        ),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            users[index].profileImageUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    users[index].name,
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
