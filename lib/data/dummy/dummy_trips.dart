import 'package:tubes_ppb_app/data/models/trip_model.dart';

/// Dummy trip data for initial development.
/// Will be replaced with API data later.
class DummyTrips {
  DummyTrips._();

  static final List<Trip> all = [
    Trip(
      id: '1',
      name: 'Sunrise Bromo',
      location: 'Jawa Timur',
      price: 850000,
      date: DateTime(2026, 6, 15),
      imageUrl: 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=800&q=80',
      description:
          'Nikmati keindahan matahari terbit dari puncak Gunung Bromo yang ikonik. '
          'Perjalanan dimulai dini hari dari Malang, melewati lautan pasir yang luas, '
          'dan mendaki menuju view point terbaik. Paket sudah termasuk jeep 4x4, '
          'penginapan satu malam, dan makan pagi. Cocok untuk solo traveler yang '
          'ingin pengalaman petualangan gunung berapi aktif.',
      duration: '2 Hari 1 Malam',
      rating: 4.8,
      maxParticipants: 15,
      category: 'Gunung',
    ),
    Trip(
      id: '2',
      name: 'Explore Nusa Penida',
      location: 'Bali',
      price: 1250000,
      date: DateTime(2026, 7, 3),
      imageUrl: 'https://images.unsplash.com/photo-1570789210967-2cac24f169ab?w=800&q=80',
      description:
          'Jelajahi keindahan Nusa Penida yang memukau dengan tebing-tebing '
          'dramatis dan pantai tersembunyi. Kunjungi Kelingking Beach, Angel\'s '
          'Billabong, dan Broken Beach dalam satu trip. Sudah termasuk fast boat, '
          'mobil keliling pulau, makan siang, dan snorkeling di Manta Point. '
          'Pengalaman tak terlupakan di surga tropis Bali.',
      duration: '3 Hari 2 Malam',
      rating: 4.9,
      maxParticipants: 12,
      category: 'Pantai',
    ),
    Trip(
      id: '3',
      name: 'Sailing Labuan Bajo',
      location: 'NTT',
      price: 3500000,
      date: DateTime(2026, 8, 10),
      imageUrl: 'https://images.unsplash.com/photo-1571366343168-631c5bcca7a4?w=800&q=80',
      description:
          'Berlayar mengelilingi kepulauan Komodo dengan kapal phinisi. Lihat langsung '
          'komodo di habitat aslinya, snorkeling di Pink Beach, dan menikmati sunset '
          'dari atas bukit Padar Island. Paket all-inclusive: kapal phinisi, 3x makan '
          'sehari, alat snorkeling, dan guide lokal berlisensi. Trip terbaik untuk '
          'pencinta laut dan fotografi.',
      duration: '4 Hari 3 Malam',
      rating: 4.9,
      maxParticipants: 10,
      category: 'Pulau',
    ),
    Trip(
      id: '4',
      name: 'Diving Raja Ampat',
      location: 'Papua Barat',
      price: 5200000,
      date: DateTime(2026, 9, 5),
      imageUrl: 'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?w=800&q=80',
      description:
          'Selami keajaiban bawah laut Raja Ampat — surga diving nomor satu dunia. '
          'Trip mencakup 6 dive spots terbaik, termasuk Cape Kri dan Manta Sandy. '
          'Cocok untuk diver bersertifikat maupun pemula (tersedia discover diving). '
          'Paket termasuk penerbangan domestik, homestay, perahu, peralatan diving, '
          'dan makan 3x sehari.',
      duration: '5 Hari 4 Malam',
      rating: 5.0,
      maxParticipants: 8,
      category: 'Pulau',
    ),
    Trip(
      id: '5',
      name: 'Pesona Dieng',
      location: 'Jawa Tengah',
      price: 650000,
      date: DateTime(2026, 6, 28),
      imageUrl: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80',
      description:
          'Jelajahi dataran tinggi Dieng yang mistis dan penuh pesona. Saksikan '
          'fenomena golden sunrise, kunjungi kawah Sikidang yang mendidih, dan nikmati '
          'hamparan ladang kentang yang hijau. Trip juga mengunjungi Candi Arjuna — '
          'candi Hindu tertua di Jawa. Paket termasuk transport, penginapan, makan, '
          'dan tiket masuk semua destinasi.',
      duration: '2 Hari 1 Malam',
      rating: 4.6,
      maxParticipants: 20,
      category: 'Gunung',
    ),
    Trip(
      id: '6',
      name: 'Toraja Heritage',
      location: 'Sulawesi Selatan',
      price: 2800000,
      date: DateTime(2026, 7, 20),
      imageUrl: 'https://images.unsplash.com/photo-1597435877467-2cfde77df30d?w=800&q=80',
      description:
          'Eksplorasi budaya unik Tana Toraja yang kaya akan tradisi dan keindahan alam. '
          'Kunjungi rumah adat Tongkonan, situs pemakaman batu Lemo, dan desa '
          'tradisional Kete Kesu. Nikmati kopi Toraja langsung di perkebunannya. '
          'Trip ini membawa kamu menyelami budaya yang tidak ditemukan di tempat lain. '
          'Termasuk flight, penginapan, dan guide budaya lokal.',
      duration: '4 Hari 3 Malam',
      rating: 4.7,
      maxParticipants: 12,
      category: 'Budaya',
    ),
  ];
}
