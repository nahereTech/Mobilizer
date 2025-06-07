import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KHostPage extends StatelessWidget {
  final Color customBlue = const Color(0xFF005FDD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: customBlue,
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: customBlue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/25/25694.png',
                      width: 32,
                    ),
                    Icon(Icons.search, size: 28, color: Color(0xFF005FDD)),
                  ],
                ),
                SizedBox(height: 16),

                // Title
                Text('K-Host', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                SizedBox(height: 16),

                // Category buttons (scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      categoryButton('Music', isSelected: true, color: customBlue),
                      SizedBox(width: 8),
                      categoryButton('Food', color: customBlue),
                      SizedBox(width: 8),
                      categoryButton('Restaurant', color: customBlue),
                      SizedBox(width: 8),
                      categoryButton('Art', color: customBlue),
                      SizedBox(width: 8),
                      categoryButton('Nightlife', color: customBlue),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Most Popular
                Text('Most Popular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      mostPopularCard(
                        'https://picsum.photos/id/237/400/300',
                        'Tiesto DJ Party',
                        'DJ Club House Event in | Italy | 8th Jun',
                        customBlue,
                      ),
                      mostPopularCard(
                        'https://picsum.photos/id/238/400/300',
                        'Afro Night',
                        'Live performance | Lagos | 10th Jun',
                        customBlue,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // 28 June Section
                dateSection('28, Jun', [
                  verticalEventCard(
                    'https://picsum.photos/id/239/400/300',
                    'Outdoor Games',
                    'Marina, Santiago This is the place where you say hello and someone',
                    'Miami, United States',
                  ),
                ]),

                // 29 June Section
                dateSection('29, Jun', [
                  verticalEventCard(
                    'https://picsum.photos/id/240/400/300',
                    'Holy Church Service',
                    'Marina, Santiago This is the place where you say hello and someone',
                    'Miami, United States',
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget categoryButton(String label, {bool isSelected = false, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : color),
      ),
    );
  }

  Widget mostPopularCard(String imageUrl, String title, String subtitle, Color color) {
    return Container(
      width: 250,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dateSection(String date, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              date,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: customBlue),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...cards,
        SizedBox(height: 20),
      ],
    );
  }

  Widget verticalEventCard(String imageUrl, String title, String desc, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}