import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui; // Added for ui.TextDirection

class ProductDetailsPage extends StatefulWidget {
  final dynamic item;

  const ProductDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentImageIndex = 0;
  List<dynamic> _images = [];
  late String formattedCost;
  late String currency;

  @override
  void initState() {
    super.initState();
    _images = widget.item['images'] ?? [];
    formattedCost =
        NumberFormat("#,##0").format(int.parse(widget.item['cost']));
    currency = widget.item['currency'] == "1" ? "₦" : "\$";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('Product Details',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(),
            _buildProductInfo(),
            _buildReviewsSection(),
            _buildSellerContact(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.4,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: _images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _images.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Colors.blueGrey
                      : Colors.blueGrey.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item['name'] ?? 'Unknown Product',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            '$currency$formattedCost',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00AFEF)),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                widget.item['item_location'] ?? 'Location not specified',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final textSpan = TextSpan(
                text: widget.item['description'] ?? 'No description available',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              );

              final textDirection =
                  Directionality.of(context) ?? ui.TextDirection.ltr;

              final textPainter = TextPainter(
                text: textSpan,
                textDirection: textDirection,
                maxLines: 3,
                ellipsis: '...',
              )..layout(maxWidth: constraints.maxWidth);

              if (textPainter.didExceedMaxLines) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (textPainter.text as TextSpan).text ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: () {
                        // Handle tap to show full description
                        print('See More clicked');
                      },
                      child: Text(
                        'See More',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Text(
                  widget.item['description'] ?? 'No description available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    List<dynamic> reviews = widget.item['reviews'] ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews (${reviews.length})',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          if (reviews.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey[100],
                              child: Text(
                                (review['username'] ?? 'A')[0].toUpperCase(),
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              review['username'] ?? 'Anonymous',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          review['comment'] ?? 'No comment provided',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Rating: ${review['rating'] ?? 'N/A'}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSellerContact() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Seller',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, color: Colors.blueGrey, size: 20),
              SizedBox(width: 8),
              Text(
                widget.item['seller_name'] ?? 'Seller Name Not Available',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.blueGrey, size: 20),
              SizedBox(width: 8),
              Text(
                widget.item['seller_phone'] ?? 'Phone Not Available',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email, color: Colors.blueGrey, size: 20),
              SizedBox(width: 8),
              Text(
                widget.item['seller_email'] ?? 'Email Not Available',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
