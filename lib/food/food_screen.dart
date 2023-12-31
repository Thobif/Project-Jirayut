import 'package:abc/cameara/camera.dart';
import 'package:abc/food/foodmap.dart';
import 'package:abc/food/listffod.dart';
import 'package:flutter/material.dart';
import 'package:abc/food/restaurantmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc/menu/menudetail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../menu/formfood.dart';

class FoodScreen extends StatefulWidget {
  final String userKey;

  FoodScreen({required this.userKey});

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late Future<List<Restaurant>> _restaurantListFuture;

  @override
  void initState() {
    super.initState();
    _restaurantListFuture = _fetchRestaurants();
  }

  void _navigateToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Classify(userKey: widget.userKey),
      ),
    );
  }

  void _navigateToFormfood(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormFood(userKey: widget.userKey),
      ),
    );
  }

  void _navigateToFoodMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(userKey: widget.userKey),
      ),
    );
  }

  Future<List<Restaurant>> _fetchRestaurants() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('shop').get();
    return querySnapshot.docs.map((doc) {
      final restaurant =
          Restaurant(name: doc['shop_name'], menu: [], key: doc.id);
      return restaurant;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ร้านอาหาร'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () => _navigateToFoodMap(context),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => _navigateToCamera(context),
          ),
          IconButton(
            icon: Icon(Icons.food_bank_outlined),
            onPressed: () => _navigateToFormfood(context),
          ),
        ],
      ),
      body: Container(
         decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
             
            ];
          },
          body: FutureBuilder<List<Restaurant>>(
            future: _restaurantListFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final restaurantList = snapshot.data!;
                return ListView.builder(
                  itemCount: restaurantList.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurantList[index];
                    return ListTile(
                      title: Text(restaurant.name),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MenuDetail(
                              userKey: widget.userKey,
                              restaurant: restaurant,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Failed to fetch restaurants'),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListFood(
                userKey: widget.userKey,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        
      ),
      
    );
  }
}
