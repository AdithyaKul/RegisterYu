class Event {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String date;
  final String location;
  final String price;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.location,
    required this.price,
  });
}

final List<Event> mockEvents = [
  const Event(
    id: '1',
    title: 'HackHorizon 2024',
    category: 'Hackathon',
    imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
    date: 'Oct 14 • 24 Hours',
    location: 'Main Block Auditorium',
    price: 'Free',
  ),
  const Event(
    id: '2',
    title: 'AI & The Future',
    category: 'Seminar',
    imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80',
    date: 'Oct 18 • 10:00 AM',
    location: 'Seminar Hall 2',
    price: '₹150',
  ),
  const Event(
    id: '3',
    title: 'Cloud Native Summit',
    category: 'Workshop',
    imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
    date: 'Oct 22 • 2 Days',
    location: 'CS Department Lab',
    price: '₹300',
  ),
  const Event(
    id: '4',
    title: 'Design Thinking Lab',
    category: 'Workshop',
    imageUrl: 'https://images.unsplash.com/photo-1558655146-9f40138edfeb?w=800&q=80',
    date: 'Oct 25 • 9:00 AM',
    location: 'Innovation Hub',
    price: '₹200',
  ),
];
