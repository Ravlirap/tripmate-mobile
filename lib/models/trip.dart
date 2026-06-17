class Trip {
  final String id;
  final String organizerId;
  final String title;
  final String destination;
  final String date;
  final int quota;
  final int price;
  final String description;
  final String imageUrl; // mock

  Trip({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.destination,
    required this.date,
    required this.quota,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizerId': organizerId,
      'title': title,
      'destination': destination,
      'date': date,
      'quota': quota,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      organizerId: map['organizerId'],
      title: map['title'],
      destination: map['destination'],
      date: map['date'],
      quota: map['quota'],
      price: map['price'],
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }
}
