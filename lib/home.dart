import 'package:eco_eats/admin/auth_screen.dart';
import 'package:eco_eats/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'add_item.dart';
import 'edit_item.dart';
import 'utils/helper_functions.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notificationService.initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Items'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () => gotoPage(AdminLoginPage(), context),
              child: CircleAvatar(
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('foodItems').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Lottie.asset("assets/lottie/empty.json"),

                    Text('No items found', style: TextStyle(color: Colors.purple.shade400, fontSize: 20),),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var foodItem = snapshot.data!.docs[index];

                notificationService.scheduleNotifications(snapshot.data!.docs);

                // Convert the 'expiryDate' Timestamp to a DateTime object
                DateTime expiryDate =(foodItem['expiryDate'] as Timestamp).toDate();

                // Format the DateTime to display only the date
                String formattedDate = DateFormat('yyyy-MM-dd').format(expiryDate);

                // Calculate difference in days between today and the expiry date
                int daysDifference = expiryDate.difference(DateTime.now()).inDays;

                // Determine if the expiry date is today or just a day away
                bool isExpiringSoon = daysDifference == 0 || daysDifference == 1;

                return SizedBox(
                  height: 100.h,
                  child: GestureDetector(
                    onTap: () {
                      gotoPage(EditFoodItemPage(foodItem: foodItem), context);
                    },
                    child: Card(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Card(
                                elevation: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage.memoryNetwork(
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outlined),
                                            Text(
                                              "Error loading",
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    placeholder: kTransparentImage,
                                    image: foodItem['imageUrl'],
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: isExpiringSoon
                                              ? Colors.red
                                              : Colors.grey
                                                  .shade600, // Change color based on expiry date
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Show dialog to confirm deletion
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Deletion'),
                                                content: Text('Are you sure you want to delete this item?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context); // Close dialog
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      // Delete food item from Firestore
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'foodItems')
                                                          .doc(foodItem.id)
                                                          .delete();
                                                      Navigator.pop(
                                                          context); // Close dialog
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          size: 18,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    foodItem['name'],
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    foodItem['category'],
                                    style:TextStyle(color: Colors.grey.shade600),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          gotoPage(AddFoodItemPage(), context);
        },
        label: Row(
          children: [
            Icon(Icons.add),
            Text("Add item"),
          ],
        ),
      ),
    );
  }
}
