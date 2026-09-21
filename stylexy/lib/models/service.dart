class BarberService {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;
  final int durationMinutes;

  const BarberService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.durationMinutes,
  });

  static const List<BarberService> allServices = [
    BarberService(
      id: 'haircut',
      name: 'Haircut',
      description: 'Professional haircut tailored to your style',
      price: 100,
      icon: '✂️',
      durationMinutes: 30,
    ),
    BarberService(
      id: 'beard_trim',
      name: 'Beard Trimming',
      description: 'Expert beard grooming and shaping',
      price: 70,
      icon: '🪒',
      durationMinutes: 20,
    ),
    BarberService(
      id: 'massage_facial',
      name: 'Head Massage + Facial',
      description: 'Relaxing combo of head massage and rejuvenating facial',
      price: 199,
      icon: '💆',
      durationMinutes: 45,
    ),
  ];

  String get priceDisplay => '₹${price.toInt()}';
}
