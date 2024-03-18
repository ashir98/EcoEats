import 'package:eco_eats/firebase_options.dart';
import 'package:eco_eats/home.dart';
import 'package:eco_eats/provider/app_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;







void main()async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the time zone data
  tz.initializeTimeZones();
  // Get the device's current time zone
  final String timeZone = await await FlutterTimezone.getLocalTimezone();
  // Set the local time zone
  tz.setLocalLocation(tz.getLocation(timeZone));





  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

runApp(EcoEats());



}


class EcoEats extends StatelessWidget {
  const EcoEats({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        child: ChangeNotifierProvider(
          create: (context) => AppNotifier(),
          child: MaterialApp(
            title: "EcoEats",
            debugShowCheckedModeBanner: false,
            home: HomePage(),
          ),
        ));
  }
}