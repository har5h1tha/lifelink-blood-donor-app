const bool useDummyData = true; // set to false when Firebase is connected

const String usersCollection = 'users';
const String requestsCollection = 'requests';

const List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
const List<String> urgencyLevels = ['Critical', 'High', 'Normal'];
const List<String> cities = [
  'Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi', 'Chennai',
  'Hyderabad', 'Mumbai', 'Pune', 'Delhi', 'Kochi',
];

const String statusOpen = 'open';
const String statusFulfilled = 'fulfilled';
