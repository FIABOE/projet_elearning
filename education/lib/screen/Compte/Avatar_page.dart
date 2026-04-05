// ignore_for_file: file_names, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  List<Map<String, dynamic>> avatar = [
    {
      'title': 'Sport',
      'images': [
        'assets/images/arena.png',
        'assets/images/ball.png',
        'assets/images/barbell.png',
        'assets/images/badminton.png',
        'assets/images/basketball.png',
        'assets/images/casino-chips.png',
        'assets/images/coach.png',
        'assets/images/corner.png',
        'assets/images/foam.png',
        'assets/images/football.png',
        'assets/images/running.png',
        'assets/images/soccer.png',
        'assets/images/soccer-ball.png',
        'assets/images/soccer-player.png',
        'assets/images/sport-shoes.png',
        'assets/images/table-tennis.png',
        'assets/images/tennis.png',
        'assets/images/sport-shirt.png',
      ],
    },
    {
      'title': 'Paysage',
      'images': [
        'assets/images/beach.png',
        'assets/images/cocora-valley.png',
        'assets/images/forest.png',
        'assets/images/iguazu-falls.png',
        'assets/images/house.png',
        'assets/images/lotus.png',
        'assets/images/gold-coast.png',
        'assets/images/river.png',
        'assets/images/waterfall.png',
        'assets/images/sea.png',
        'assets/images/savannah.png',
        'assets/images/tag.png',
      ],
    },
    {
      'title': 'Lettres',
      'images': [
        'assets/images/a.png',
        'assets/images/b.png',
        'assets/images/c.png',
        'assets/images/d.png',
        'assets/images/e.png',
        'assets/images/f.png',
        'assets/images/g.png',
        'assets/images/h.png',
        'assets/images/i.png',
        'assets/images/j.png',
        'assets/images/k.png',
        'assets/images/l.png',
        'assets/images/m.png',
        'assets/images/n.png',
        'assets/images/o.png',
        'assets/images/p.png',
        'assets/images/q.png',
        'assets/images/r.png',
        'assets/images/s.png',
        'assets/images/t.png',
        'assets/images/u.png',
        'assets/images/v.png',
        'assets/images/w.png',
        'assets/images/y.png',
        //'assets/images/z.png',
      ],
    },
    {
      'title': 'Professionnels',
      'images': [
        'assets/images/businessman.png',
        'assets/images/woman3.png',
        'assets/images/doctor.png',
        'assets/images/woman2.png',
        'assets/images/mann.png',
        'assets/images/woman1.png',
        'assets/images/woman4.png',
        'assets/images/businessmann.png',
        'assets/images/ceo.png',
        'assets/images/woman5.png',
        'assets/images/woman.png',
        'assets/images/man.png',
      ],
    },
    {
      'title': 'ecole',
      'images': [
        'assets/images/open-book.png',
        'assets/images/books.png',
        'assets/images/book-stack.png',
        'assets/images/gift.png',
        'assets/images/arabic.png',
        'assets/images/building-block.png',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Choisir un avatar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF70A19F),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: avatar.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  avatar[index]['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: avatar[index]['images'].length,
                itemBuilder: (context, avatarIndex) {
                  final imagePath = avatar[index]['images'][avatarIndex];
                  return GestureDetector(
                    onTap: () {
                      //_selectAvatar(imagePath); // Call the _selectAvatar function with the selected image path
                    },
                    child: Image.asset(
                      imagePath ?? '',
                      width: 0,
                      height: 0,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}