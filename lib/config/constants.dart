class FireStation {
  final String name;
  final double latitude;
  final double longitude;

  const FireStation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// Data pos damkar (matching web src/lib/fire-stations.ts)
const List<FireStation> fireStations = [
  FireStation(name: 'Pos Damkar Plaju', latitude: -2.9945, longitude: 104.7879),
  FireStation(name: 'Pos Damkar Seberang Ulu II', latitude: -3.0217, longitude: 104.7580),
  FireStation(name: 'Pos Damkar Kalidoni', latitude: -2.9483, longitude: 104.7847),
  FireStation(name: 'Pos Damkar IT I', latitude: -2.9770, longitude: 104.7327),
  FireStation(name: 'Pos Damkar IT II', latitude: -2.9636, longitude: 104.7724),
];

// Report status list
const List<String> reportStatuses = [
  'pending',
  'verified',
  'dispatched',
  'arrived',
  'completed',
  'false_report',
];
