import '../models/business.dart';

final List<Business> mockBusinesses = [
  Business(
    id: '1',
    name: 'مطعم أبو علي',
    categoryId: '1',
    description: 'مشويات وبرياني على الطريقة العراقية.',
    city: 'بغداد',
    address: 'الكرادة',
    phone: '+9647700000000',
    rating: 4.7,
    images: const [
      'https://images.unsplash.com/photo-1421622548261-c45bfe178854',
    ],
    features: const ['توصيل سريع', 'عائلي'],
  ),
  Business(
    id: '2',
    name: 'ركن البصرة للمأكولات البحرية',
    categoryId: '1',
    description: 'أسماك طازجة مع جلسات عائلية.',
    city: 'البصرة',
    address: 'العشار',
    phone: '+9647711111111',
    rating: 4.5,
    images: const [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    ],
    features: const ['أسماك طازجة', 'جلسات عائلية'],
  ),
  Business(
    id: '3',
    name: 'قهوة المنصور',
    categoryId: '2',
    description: 'جلسات هادئة مع قهوة مختصة.',
    city: 'بغداد',
    address: 'المنصور',
    phone: '+9647722222222',
    rating: 4.3,
    images: const [
      'https://images.unsplash.com/photo-1432139509613-5c4255815697',
    ],
    features: const ['جلسات خارجية', 'واي فاي'],
  ),
];
