import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class BusSchedule {
  final String route;
  final String firstDepartureTime;
  final String lastDepartureTime;
  final int ticketPrice;

  BusSchedule({
    required this.route,
    required this.firstDepartureTime,
    required this.lastDepartureTime,
    required this.ticketPrice,
  });
}

class BusSchedulePage extends StatefulWidget {
  @override
  _BusSchedulePageState createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  List<BusSchedule> allSchedules = [
    BusSchedule(
        route: 'Lahore to Faisalabad',
        firstDepartureTime: '05:00 AM',
        lastDepartureTime: '11:00 PM',
        ticketPrice: 1000),
    BusSchedule(
        route: 'Lahore to Multan',
        firstDepartureTime: '05:00 AM',
        lastDepartureTime: '02:30 AM',
        ticketPrice: 1800),
    BusSchedule(
        route: 'Lahore to Islamabad',
        firstDepartureTime: '05:00 AM',
        lastDepartureTime: '02:30 AM',
        ticketPrice: 2000),
    // Add more dummy data...
  ];
  List<BusSchedule> displayedSchedules = [];
  String selectedCompany = 'All';
  final List<String> companies = [
    'All',
    'Daewoo',
    'Niazi Express',
    'Faisal Movers'
  ];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    displayedSchedules = allSchedules;
  }

  void filterSchedules() {
    setState(() {
      displayedSchedules = allSchedules.where((schedule) {
        final searchMatch =
            schedule.route.toLowerCase().contains(searchText.toLowerCase());
        final companyMatch = selectedCompany == 'All' ||
            schedule.route
                .toLowerCase()
                .contains(selectedCompany.toLowerCase());
        return searchMatch && companyMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Bus Schedule", showicon: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchText = value;
                filterSchedules();
              },
              decoration: const InputDecoration(
                labelText: 'Search for routes',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          DropdownButton<String>(
            value: selectedCompany,
            onChanged: (newValue) {
              setState(() {
                selectedCompany = newValue!;
                filterSchedules();
              });
            },
            items: companies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Routes')),
                    DataColumn(label: Text('First Departure Time')),
                    DataColumn(label: Text('Last Departure Time')),
                    DataColumn(label: Text('Ticket Price')),
                  ],
                  rows: displayedSchedules.map((schedule) {
                    return DataRow(cells: [
                      DataCell(Text(schedule.route)),
                      DataCell(Text(schedule.firstDepartureTime)),
                      DataCell(Text(schedule.lastDepartureTime)),
                      DataCell(Text('Rs. ${schedule.ticketPrice}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Bus Schedule App',
    home: BusSchedulePage(),
  ));
}
