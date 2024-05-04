import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State
{
  int maleCount = 0;
  int femaleCount = 0;
  int kidsCount = 0;

  void _incrementCount(String gender) {
    setState(() {
      if (gender == 'male')
        maleCount++;
      else if (gender == 'female')
        femaleCount++;
      else if (gender == 'kids') kidsCount++;
    });
  }

  void _decrementCount(String gender) {
    setState(() {
      if (gender == 'male' && maleCount > 0)
        maleCount--;
      else if (gender == 'female' && femaleCount > 0)
        femaleCount--;
      else if (gender == 'kids' && kidsCount > 0) kidsCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Booking'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Map section (dummy container for illustration)
          Container(
            height: 149.0,
            width: 500,
            // decoration: BoxDecoration(
            //   color: Colors.blue[200],
            //   border: Border.all(
            //     color: Colors.blueAccent,
            //   ),
            // ),
            child: Center(
              child: SizedBox(
                width: 500, // Set width
                height: 300, // Set height
                child: Image.asset(
                  'assets/images/map.jpg', // Dummy map image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Form section
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Trip Type'),
                  trailing: Text('Daily'),
                ),
                ListTile(
                  title: Text('Departure Time'),
                  trailing: Text('6:00 PM'),
                ),
                ListTile(
                  title: Text('Seating Capacity'),
                  trailing: Text('4'),
                ),
                ListTile(
                  title: Text('Available Seats'),
                  trailing: Text('4'),
                ),

                Divider(),
                ListTile(
                  title: Text('Contact No'),
                  trailing: Text('03157099944'),
                ),
                ListTile(
                  title: Text('Vehicle No'),
                  trailing: Text('RI-252'),
                ),
                Divider(),
                CounterWidget(
                  label: 'Male',
                  count: maleCount,
                  onIncrement: () => _incrementCount('male'),
                  onDecrement: () => _decrementCount('male'),
                ),
                CounterWidget(
                  label: 'Female',
                  count: femaleCount,
                  onIncrement: () => _incrementCount('female'),
                  onDecrement: () => _decrementCount('female'),
                ),
                CounterWidget(
                  label: 'Kids',
                  count: kidsCount,
                  onIncrement: () => _incrementCount('kids'),
                  onDecrement: () => _decrementCount('kids'),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement booking logic
                    },
                    child: Text('Request Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CounterWidget extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  CounterWidget({
    required this.label,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: onDecrement,
          ),
          Text('$count'),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
