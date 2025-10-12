class Banner {
  final String image;
  final String link;
  final String location;

  Banner({
    required this.image,
    required this.link,
    required this.location,
  });

  factory Banner.fromJson(final Map<String, dynamic> json) {
    return Banner(
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'link': link,
      'location': location,
    };
  }
}

class BannerResponse {
  final Map<String, List<Banner>> banners;

  BannerResponse({
    required this.banners,
  });

  factory BannerResponse.fromJson(final Map<String, dynamic> json) {
    final banners = <String, List<Banner>>{};

    if (json['banners'] != null) {
      final bannersData = json['banners'] as Map<String, dynamic>;
      bannersData.forEach((final key, final value) {
        if (value is List) {
          banners[key] = value
              .map((final bannerJson) => Banner.fromJson(bannerJson))
              .toList();
        }
      });
    }

    return BannerResponse(banners: banners);
  }

  List<Banner> getPLPBanners() {
    return banners['ACA'] ?? [];
  }
}
