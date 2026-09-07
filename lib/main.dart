import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/request_blood_screen.dart';

void main() {
  runApp(const GiveLifeApp());
}

class GiveLifeApp extends StatelessWidget {
  const GiveLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GiveLife',
      theme: ThemeData(
        primaryColor: const Color(0xFFA10725),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ColoredBox(
        color: Color(0xFFEFEFEF),
        child: Center(
          child: SizedBox(
            width: 430,
            child: GiveLifeScreen(),
          ),
        ),
      ),
    );
  }
}

class GiveLifeScreen extends StatefulWidget {
  const GiveLifeScreen({super.key});

  @override
  State<GiveLifeScreen> createState() {
    return _GiveLifeScreenState();
  }
}

class _GiveLifeScreenState extends State<GiveLifeScreen> {
  final Color redColor = const Color(0xFFA10725);

  int selectedPage = 2;
  bool donorAvailable = false;
  bool findingLocation = false;
  String donorBloodGroup = 'O+';
  String acceptedRequest = '';

  double? currentLatitude;
  double? currentLongitude;

  Map<String, Appointment> appointments = {};
  List<BloodRequest> nearbyRequests = [];

  final List<Hospital> hospitals = [
    Hospital(
      name: 'City Blood Bank',
      address: '12 Main Road, Dhaka',
      distance: '0.8 km',
      openingTime: 'Open until 8:00 PM',
    ),
    Hospital(
      name: 'Red Cross Blood Center',
      address: '45 Lake Road, Dhaka',
      distance: '1.5 km',
      openingTime: 'Open until 6:00 PM',
    ),
    Hospital(
      name: 'Memorial Clinic',
      address: '78 Park Street, Dhaka',
      distance: '2.3 km',
      openingTime: 'Open until 5:00 PM',
    ),
    Hospital(
      name: 'Dhaka Medical College Hospital',
      address: 'Secretariat Road, Dhaka',
      distance: '3.1 km',
      openingTime: 'Open 24 Hours',
    ),
    Hospital(
      name: 'Square Hospital',
      address: 'Panthapath, Dhaka',
      distance: '3.8 km',
      openingTime: 'Open 24 Hours',
    ),
    Hospital(
      name: 'Popular Medical Center',
      address: 'Dhanmondi, Dhaka',
      distance: '4.2 km',
      openingTime: 'Open until 10:00 PM',
    ),
    Hospital(
      name: 'United Hospital',
      address: 'Gulshan, Dhaka',
      distance: '5.4 km',
      openingTime: 'Open 24 Hours',
    ),
    Hospital(
      name: 'Evercare Hospital',
      address: 'Bashundhara, Dhaka',
      distance: '6.7 km',
      openingTime: 'Open 24 Hours',
    ),
  ];

  List<DonationRecord> donationHistory = [
    DonationRecord(
      hospitalName: 'City Blood Bank',
      bloodGroup: 'O+',
      units: 1,
      donationDate: DateTime.now().subtract(
        const Duration(days: 120),
      ),
    ),
    DonationRecord(
      hospitalName: 'Red Cross Blood Center',
      bloodGroup: 'O+',
      units: 1,
      donationDate: DateTime.now().subtract(
        const Duration(days: 260),
      ),
    ),
  ];

  Future<void> changeAvailability(bool value) async {
    if (value == false) {
      setState(() {
        donorAvailable = false;
      });

      showMessage(
        'You will not receive nearby requests.',
        Colors.black87,
      );

      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Become an Available Donor'),
          content: Text(
            'Your blood group is $donorBloodGroup.\n\n'
            'Do you want to receive nearby blood requests?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        donorAvailable = true;
      });

      showMessage(
        'Nearby blood requests are now enabled.',
        Colors.green,
      );
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool locationEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (locationEnabled == false) {
      showMessage(
        'Please turn on your device location or GPS.',
        Colors.orange,
      );

      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      showMessage(
        'Location permission was denied.',
        const Color(0xFFA10725),
      );

      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      showMessage(
        'Please enable location permission from Settings.',
        const Color(0xFFA10725),
      );

      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return position;
  }

  Future<void> findNearbyRequests() async {
    setState(() {
      findingLocation = true;
    });

    try {
      Position? position = await getCurrentLocation();

      if (position == null) {
        setState(() {
          findingLocation = false;
        });

        return;
      }

      currentLatitude = position.latitude;
      currentLongitude = position.longitude;

      List<BloodRequest> requests = [
        BloodRequest(
          patientName: 'Rahim Ahmed',
          bloodGroup: 'O+',
          hospitalName: 'Nearby General Hospital',
          urgency: 'Critical',
          units: 2,
          latitude: position.latitude + 0.004,
          longitude: position.longitude + 0.003,
        ),
        BloodRequest(
          patientName: 'Nusrat Jahan',
          bloodGroup: 'A-',
          hospitalName: 'Community Medical Center',
          urgency: 'Urgent',
          units: 1,
          latitude: position.latitude - 0.008,
          longitude: position.longitude + 0.006,
        ),
        BloodRequest(
          patientName: 'Karim Hasan',
          bloodGroup: 'B+',
          hospitalName: 'Central Care Hospital',
          urgency: 'Needed',
          units: 3,
          latitude: position.latitude + 0.014,
          longitude: position.longitude - 0.009,
        ),
        BloodRequest(
          patientName: 'Fatema Akter',
          bloodGroup: 'AB+',
          hospitalName: 'City Emergency Hospital',
          urgency: 'Critical',
          units: 2,
          latitude: position.latitude - 0.020,
          longitude: position.longitude - 0.012,
        ),
        BloodRequest(
          patientName: 'Sakib Hossain',
          bloodGroup: 'O-',
          hospitalName: 'Life Care Clinic',
          urgency: 'Urgent',
          units: 1,
          latitude: position.latitude + 0.030,
          longitude: position.longitude + 0.018,
        ),
      ];

      for (int i = 0; i < requests.length; i++) {
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          requests[i].latitude,
          requests[i].longitude,
        );

        requests[i].distanceInKm = distanceInMeters / 1000;
      }

      requests.sort(
        (BloodRequest first, BloodRequest second) {
          return first.distanceInKm.compareTo(
            second.distanceInKm,
          );
        },
      );

      setState(() {
        nearbyRequests = requests;
        findingLocation = false;
      });

      if (!mounted) {
        return;
      }

      showNearbyRequests();
    } catch (error) {
      setState(() {
        findingLocation = false;
      });

      showMessage(
        'Could not get your location. Please try again.',
        const Color(0xFFA10725),
      );
    }
  }

  void showNearbyRequests() {
    if (nearbyRequests.isEmpty) {
      findNearbyRequests();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFFA10725),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Requests Near You',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${nearbyRequests.length} sample requests found near your GPS location',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: nearbyRequests.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return requestCard(
                        nearbyRequests[index],
                        bottomSheetContext,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void acceptRequest(
    BloodRequest request,
    BuildContext bottomSheetContext,
  ) {
    if (donorAvailable == false) {
      Navigator.pop(bottomSheetContext);

      showMessage(
        'Turn on Available to Donate first.',
        Colors.orange,
      );

      return;
    }

    setState(() {
      acceptedRequest =
          '${request.patientName}, ${request.bloodGroup}, '
          '${request.distanceInKm.toStringAsFixed(2)} km away';
    });

    Navigator.pop(bottomSheetContext);

    showMessage(
      'Blood request accepted successfully.',
      Colors.green,
    );
  }

  Future<void> bookAppointment(
    String hospitalName,
  ) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null || !mounted) {
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Text(
            'Hospital: $hospitalName\n\n'
            'Date: ${formatDate(selectedDate)}\n'
            'Time: ${selectedTime.format(context)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        appointments[hospitalName] = Appointment(
          date: selectedDate,
          time: selectedTime,
        );
      });

      showMessage(
        'Appointment booked successfully.',
        Colors.green,
      );
    }
  }

  void completeDonation(String hospitalName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Complete Donation'),
          content: Text(
            'Did you complete your blood donation at $hospitalName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('NO'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  donationHistory.insert(
                    0,
                    DonationRecord(
                      hospitalName: hospitalName,
                      bloodGroup: donorBloodGroup,
                      units: 1,
                      donationDate: DateTime.now(),
                    ),
                  );

                  appointments.remove(hospitalName);
                });

                Navigator.pop(dialogContext);

                showMessage(
                  'Donation added to your history.',
                  Colors.green,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('YES, COMPLETED'),
            ),
          ],
        );
      },
    );
  }

  void cancelAppointment(String hospitalName) {
    setState(() {
      appointments.remove(hospitalName);
    });

    showMessage(
      'Appointment cancelled.',
      const Color(0xFFA10725),
    );
  }

  void showMapView() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Nearby Hospitals'),
          content: const Text(
            'City Blood Bank - 0.8 km\n\n'
            'Red Cross Blood Center - 1.5 km\n\n'
            'Memorial Clinic - 2.3 km\n\n'
            'Dhaka Medical College - 3.1 km\n\n'
            'Square Hospital - 3.8 km\n\n'
            'Popular Medical Center - 4.2 km\n\n'
            'United Hospital - 5.4 km\n\n'
            'Evercare Hospital - 6.7 km',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message, Color color) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void changePage(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const RequestBloodScreen();
          },
        ),
      );

      return;
    }

    if (index == 2 || index == 3) {
      setState(() {
        selectedPage = index;
      });

      return;
    }

    String pageName = '';

    if (index == 0) {
      pageName = 'Home';
    } else {
      pageName = 'More';
    }

    showMessage(
      '$pageName page will be connected by your team.',
      Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool historyPage = selectedPage == 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          historyPage ? 'Donation History' : 'Donate Blood',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: historyPage
            ? null
            : [
                Stack(
                  children: [
                    IconButton(
                      onPressed:
                          findingLocation ? null : showNearbyRequests,
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black,
                        size: 27,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 5,
                      child: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: redColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          nearbyRequests.isEmpty
                              ? '5'
                              : '${nearbyRequests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 5),
              ],
      ),
      body: historyPage ? buildHistoryPage() : buildDonatePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        onTap: changePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: redColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'REQUEST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'DONATE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'HISTORY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'MORE',
          ),
        ],
      ),
    );
  }

  Widget buildDonatePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find a donation center near you',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: donorAvailable
                    ? const Color(0xFFEAF8EE)
                    : const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: donorAvailable
                      ? Colors.green.shade200
                      : const Color(0xFFA10725),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            donorAvailable ? Colors.green : redColor,
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available to Donate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Receive nearby blood requests',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: donorAvailable,
                        activeColor: Colors.green,
                        onChanged: changeAvailability,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Your blood group:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: donorBloodGroup,
                        items: const [
                          DropdownMenuItem(
                            value: 'A+',
                            child: Text('A+'),
                          ),
                          DropdownMenuItem(
                            value: 'A-',
                            child: Text('A-'),
                          ),
                          DropdownMenuItem(
                            value: 'B+',
                            child: Text('B+'),
                          ),
                          DropdownMenuItem(
                            value: 'B-',
                            child: Text('B-'),
                          ),
                          DropdownMenuItem(
                            value: 'AB+',
                            child: Text('AB+'),
                          ),
                          DropdownMenuItem(
                            value: 'AB-',
                            child: Text('AB-'),
                          ),
                          DropdownMenuItem(
                            value: 'O+',
                            child: Text('O+'),
                          ),
                          DropdownMenuItem(
                            value: 'O-',
                            child: Text('O-'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              donorBloodGroup = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (acceptedRequest.isNotEmpty) ...[
              const SizedBox(height: 11),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Accepted: $acceptedRequest',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              height: 145,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 35,
                    left: 70,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFA10725),
                      size: 29,
                    ),
                  ),
                  const Positioned(
                    top: 65,
                    left: 175,
                    child: Icon(
                      Icons.water_drop,
                      color: Color(0xFFA10725),
                      size: 27,
                    ),
                  ),
                  const Positioned(
                    top: 18,
                    right: 100,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFA10725),
                      size: 29,
                    ),
                  ),
                  Positioned(
                    right: 9,
                    bottom: 8,
                    child: ElevatedButton(
                      onPressed: showMapView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: redColor,
                      ),
                      child: const Text(
                        'MAP VIEW',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed:
                    findingLocation ? null : findNearbyRequests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  foregroundColor: Colors.white,
                ),
                icon: findingLocation
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  findingLocation
                      ? 'FINDING YOUR LOCATION...'
                      : 'FIND NEARBY BLOOD REQUESTS',
                ),
              ),
            ),
            if (currentLatitude != null) ...[
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'GPS location found successfully',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              '${hospitals.length} DONATION CENTERS',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < hospitals.length; i++) ...[
              hospitalCard(hospitals[i]),
              const SizedBox(height: 11),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildHistoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: historySummary(
                  icon: Icons.water_drop,
                  number: '${donationHistory.length}',
                  label: 'Total Donations',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: historySummary(
                  icon: Icons.favorite,
                  number: '${donationHistory.length * 3}',
                  label: 'Lives Impacted',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DONATION RECORDS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${donationHistory.length} records',
                style: TextStyle(
                  color: redColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (donationHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text('No donation history found'),
                ],
              ),
            ),
          for (int i = 0; i < donationHistory.length; i++) ...[
            historyCard(donationHistory[i]),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget historySummary({
    required IconData icon,
    required String number,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: redColor,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            number,
            style: TextStyle(
              color: redColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget historyCard(DonationRecord record) {
    int daysAgo =
        DateTime.now().difference(record.donationDate).inDays;

    String timeInformation;

    if (daysAgo == 0) {
      timeInformation = 'Today';
    } else if (daysAgo == 1) {
      timeInformation = 'Yesterday';
    } else {
      timeInformation = '$daysAgo days ago';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: redColor,
            child: Text(
              record.bloodGroup,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.hospitalName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Date: ${formatDate(record.donationDate)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${record.units} unit donated • $timeInformation',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              Text(
                'Completed',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hospitalCard(Hospital hospital) {
    Appointment? appointment = appointments[hospital.name];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                hospital.distance,
                style: TextStyle(
                  color: redColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hospital.address,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          Text(
            hospital.openingTime,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          if (appointment != null) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.event_available,
                  color: Colors.green,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${formatDate(appointment.date)} at '
                    '${appointment.time.format(context)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          if (appointment == null)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  bookAppointment(hospital.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'BOOK APPOINTMENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (appointment != null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      completeDonation(hospital.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'MARK AS DONATED',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      cancelAppointment(hospital.name);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: redColor,
                      side: BorderSide(
                        color: redColor,
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget requestCard(
    BloodRequest request,
    BuildContext bottomSheetContext,
  ) {
    Color urgencyColor = Colors.blue;

    if (request.urgency == 'Critical') {
      urgencyColor = const Color(0xFFA10725);
    } else if (request.urgency == 'Urgent') {
      urgencyColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFA10725),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: redColor,
            child: Text(
              request.bloodGroup,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  request.hospitalName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${request.units} unit needed',
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${request.distanceInKm.toStringAsFixed(2)} km away',
                  style: TextStyle(
                    color: redColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  request.urgency,
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              acceptRequest(
                request,
                bottomSheetContext,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
              ),
            ),
            child: const Text(
              'ACCEPT',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class Hospital {
  String name;
  String address;
  String distance;
  String openingTime;

  Hospital({
    required this.name,
    required this.address,
    required this.distance,
    required this.openingTime,
  });
}

class Appointment {
  DateTime date;
  TimeOfDay time;

  Appointment({
    required this.date,
    required this.time,
  });
}

class DonationRecord {
  String hospitalName;
  String bloodGroup;
  int units;
  DateTime donationDate;

  DonationRecord({
    required this.hospitalName,
    required this.bloodGroup,
    required this.units,
    required this.donationDate,
  });
}

class BloodRequest {
  String patientName;
  String bloodGroup;
  String hospitalName;
  String urgency;
  int units;
  double latitude;
  double longitude;
  double distanceInKm;

  BloodRequest({
    required this.patientName,
    required this.bloodGroup,
    required this.hospitalName,
    required this.urgency,
    required this.units,
    required this.latitude,
    required this.longitude,
    this.distanceInKm = 0,
  });
}