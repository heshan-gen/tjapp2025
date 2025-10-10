class RssCategory {
  final String catid;
  final String minititle;
  final String englisht;
  final String sinhalat;
  final String tamilt;
  final String icon;
  final String feedUrl;

  const RssCategory({
    required this.catid,
    required this.minititle,
    required this.englisht,
    required this.sinhalat,
    required this.tamilt,
    required this.icon,
    required this.feedUrl,
  });
}

class RssCategories {
  static const List<String> rssUrls = [
    'http://www.topjobs.lk/feeds/legasy/it_sware_db_qa_web_graphics_gis.rss',
    'http://www.topjobs.lk/feeds/legasy/it_hware_networks_systems.rss',
    'http://www.topjobs.lk/feeds/legasy/accounting_auditing_finance.rss',
    'http://www.topjobs.lk/feeds/legasy/banking_insurance.rss',
    'http://www.topjobs.lk/feeds/legasy/sales_marketing_merchandising.rss',
    'http://www.topjobs.lk/feeds/legasy/hr_training.rss',
    'http://www.topjobs.lk/feeds/legasy/corporate_management_analysts.rss',
    'http://www.topjobs.lk/feeds/legasy/office_admin_secretary_receptionist.rss',
    'http://www.topjobs.lk/feeds/legasy/civil_eng_interior_design_architecture.rss',
    'http://www.topjobs.lk/feeds/legasy/it_telecoms.rss',
    'http://www.topjobs.lk/feeds/legasy/customer_relations_public_relations.rss',
    'http://www.topjobs.lk/feeds/legasy/logistics_warehouse_transport.rss',
    'http://www.topjobs.lk/feeds/legasy/eng_mech_auto_elec.rss',
    'http://www.topjobs.lk/feeds/legasy/manufacturing_operations.rss',
    'http://www.topjobs.lk/feeds/legasy/media_advert_communication.rss',
    'http://www.topjobs.lk/feeds/legasy/HOTELS_RESTAURANTS_HOSPITALITY.rss',
    'http://www.topjobs.lk/feeds/legasy/TRAVEL_TOURISM.rss',
    'http://www.topjobs.lk/feeds/legasy/sports_fitness_recreation.rss',
    'http://www.topjobs.lk/feeds/legasy/hospital_nursing_healthcare.rss',
    'http://www.topjobs.lk/feeds/legasy/legal_law.rss',
    'http://www.topjobs.lk/feeds/legasy/supervision_quality_control.rss',
    'http://www.topjobs.lk/feeds/legasy/apparel_clothing.rss',
    'http://www.topjobs.lk/feeds/legasy/ticketing_airline_marine.rss',
    'http://www.topjobs.lk/feeds/legasy/EDUCATION.rss',
    'http://www.topjobs.lk/feeds/legasy/rnd_science_research.rss',
    'http://www.topjobs.lk/feeds/legasy/agriculture_dairy_environment.rss',
    'http://www.topjobs.lk/feeds/legasy/security.rss',
    'http://www.topjobs.lk/feeds/legasy/fashion_design_beauty.rss',
    'http://www.topjobs.lk/feeds/legasy/international_development.rss',
    'http://www.topjobs.lk/feeds/legasy/kpo_bpo.rss',
    'http://www.topjobs.lk/feeds/legasy/imports_exports.rss',
  ];

  static const List<RssCategory> categories = [
    RssCategory(
      catid: 'SDQ',
      minititle: 'Software',
      englisht: 'IT-SW/DB/QA/Web/Graphics/GIS',
      sinhalat: 'තොරතුරු තාක්ෂණ මෘදුකාංග',
      tamilt: 'IT (மென்பொருள்)',
      icon: 'design-services',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/it_sware_db_qa_web_graphics_gis.rss',
    ),
    RssCategory(
      catid: 'HNS',
      minititle: 'Hardware',
      englisht: 'IT-HW/Networks/Systems',
      sinhalat: 'තොරතුරු තාක්ෂණ දෘඪාංග',
      tamilt: 'IT (வன்பொருள்)',
      icon: 'lan',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/it_hware_networks_systems.rss',
    ),
    RssCategory(
      catid: 'ACA',
      minititle: 'Accounting',
      englisht: 'Accounting/Auditing/Finance',
      sinhalat: 'ගිණුම්කරණය',
      tamilt: 'கணக்கியல்',
      icon: 'attach-money',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/accounting_auditing_finance.rss',
    ),
    RssCategory(
      catid: 'BAF',
      minititle: 'Banking',
      englisht: 'Banking & Finance/Insurance',
      sinhalat: 'බැංකු/රක්ෂණ',
      tamilt: 'வங்கி/காப்பீடு',
      icon: 'home-work',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/banking_insurance.rss',
    ),
    RssCategory(
      catid: 'SMM',
      minititle: 'Sales',
      englisht: 'Sales/Marketing/Merchandising',
      sinhalat: 'විකුණුම්/අලෙවිකරණය/වෙළඳාම',
      tamilt: 'விற்பனை/சந்தைப்படுத்தல்',
      icon: 'people-alt',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/sales_marketing_merchandising.rss',
    ),
    RssCategory(
      catid: 'HAT',
      minititle: 'HR',
      englisht: 'HR/Training',
      sinhalat: 'මානව සම්පත්/පුහුණුව',
      tamilt: 'மனித வளம்',
      icon: 'diversity-3',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/hr_training.rss',
    ),
    RssCategory(
      catid: 'COM',
      minititle: 'Management',
      englisht: 'Corporate Management/Analysts',
      sinhalat: 'ආයතනික කළමනාකරණය',
      tamilt: 'நிறுவன முகாமைத்துவம் / ஆய்வாளர்',
      icon: 'settings-accessibility',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/corporate_management_analysts.rss',
    ),
    RssCategory(
      catid: 'OAS',
      minititle: 'Admin',
      englisht: 'Admin/Secretary/Receptionist',
      sinhalat: 'පරිපාලක/ලේකම්',
      tamilt: 'நிர்வாகி / செயலாளர் / வரவேற்பாளர்',
      icon: 'shield',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/office_admin_secretary_receptionist.rss',
    ),
    RssCategory(
      catid: 'CCE',
      minititle: 'Civil Engineering',
      englisht: 'Civil Eng/Interior/Architecture',
      sinhalat: 'ඉංජිනේරු/අභ්‍යන්තර/ගෘහ නිර්මාණ',
      tamilt: 'கட்டிட பொறியியல்',
      icon: 'roofing',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/civil_eng_interior_design_architecture.rss',
    ),
    RssCategory(
      catid: 'ITT',
      minititle: 'IT-Telecoms',
      englisht: 'IT-Telecoms',
      sinhalat: 'තොරතුරු තාක්ෂණ - ටෙලිකොම්',
      tamilt: 'டெலிகாம்',
      icon: 'router',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/it_telecoms.rss',
    ),
    RssCategory(
      catid: 'CUR',
      minititle: 'Customer Relations',
      englisht: 'Customer/Public Relations',
      sinhalat: 'පාරිභෝගික/මහජන සම්බන්ධතා',
      tamilt: 'வாடிக்கையாளர் சேவை',
      icon: 'connect-without-contact',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/customer_relations_public_relations.rss',
    ),
    RssCategory(
      catid: 'LWT',
      minititle: 'Logistics',
      englisht: 'Logistics/Warehouse/Transport',
      sinhalat: 'සැපයුම්/ගබඩා/ප්‍රවාහනය',
      tamilt: 'தளவாடம் / கிடங்கு / போக்குவரத்து',
      icon: 'directions-bus',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/logistics_warehouse_transport.rss',
    ),
    RssCategory(
      catid: 'MAE',
      minititle: 'Mechanical Engineering',
      englisht: 'Eng-Mech/Auto/Elec',
      sinhalat: 'යාන්ත්‍රික/මෝටර් රථ/විදුලි',
      tamilt: 'பொறியியல் (Mech/Auto/Elec)',
      icon: 'car-repair',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/eng_mech_auto_elec.rss',
    ),
    RssCategory(
      catid: 'POS',
      minititle: 'Manufacturing',
      englisht: 'Manufacturing/Operations',
      sinhalat: 'නිෂ්පාදන/මෙහෙයුම්',
      tamilt: 'உற்பத்தி / செயல்பாடுகள்',
      icon: 'handyman',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/manufacturing_operations.rss',
    ),
    RssCategory(
      catid: 'MAC',
      minititle: 'Media',
      englisht: 'Media/Advert/Communication',
      sinhalat: 'මාධ්‍ය/දැන්වීම්/සන්නිවේදනය',
      tamilt: 'ஊடகம் / விளம்பரம் / தொடர்பாடல்',
      icon: 'linked-camera',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/media_advert_communication.rss',
    ),
    RssCategory(
      catid: 'HRF',
      minititle: 'Hotel',
      englisht: 'Hotel/Restaurant/Hospitality',
      sinhalat: 'හෝටල්/ආගන්තුක සත්කාරය',
      tamilt: 'ஹோட்டல்கள் / உணவகம்',
      icon: 'liquor',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/HOTELS_RESTAURANTS_HOSPITALITY.rss',
    ),
    RssCategory(
      catid: 'HOT',
      minititle: 'Tourism',
      englisht: 'Travel/Tourism',
      sinhalat: 'සංචාරක කර්මාන්තය',
      tamilt: 'சுற்றுலாத் துறை',
      icon: 'luggage',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/TRAVEL_TOURISM.rss',
    ),
    RssCategory(
      catid: 'SRF',
      minititle: 'Sports',
      englisht: 'Sports/Fitness/Recreation',
      sinhalat: 'ක්‍රීඩා/යෝග්‍යතාව/විනෝදාස්වාදය',
      tamilt: 'விளையாட்டு / உடற்பயிற்சி / பொழுதுபோக்கு',
      icon: 'directions-bike',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/sports_fitness_recreation.rss',
    ),
    RssCategory(
      catid: 'MHN',
      minititle: 'Healthcare',
      englisht: 'Hospital/Nursing/Healthcare',
      sinhalat: 'රෝහල/හෙද/සෞඛ්‍ය සේවා',
      tamilt: 'மருத்துவ துறை',
      icon: 'local-hospital',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/hospital_nursing_healthcare.rss',
    ),
    RssCategory(
      catid: 'LEL',
      minititle: 'Law',
      englisht: 'Legal/Law',
      sinhalat: 'නීති',
      tamilt: 'சட்டம்',
      icon: 'local-police',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/legal_law.rss',
    ),
    RssCategory(
      catid: 'SQC',
      minititle: 'Quality Control',
      englisht: 'Supervision/Quality Control',
      sinhalat: 'අධීක්ෂණය/තත්ත්ව පාලන',
      tamilt: 'மேற்பார்வை / தர கட்டுப்பாடு',
      icon: 'checklist',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/supervision_quality_control.rss',
    ),
    RssCategory(
      catid: 'APC',
      minititle: 'Apparel',
      englisht: 'Apparel/Clothing',
      sinhalat: 'ඇඟලුම්/ඇඳුම් පැළඳුම්',
      tamilt: 'ஆடை தொழில் துறை',
      icon: 'dry-cleaning',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/apparel_clothing.rss',
    ),
    RssCategory(
      catid: 'AIM',
      minititle: 'Ticketing',
      englisht: 'Ticketing/Airline/Marine',
      sinhalat: 'ටිකට්පත්/ගුවන් සේවය/මැරීන්',
      tamilt: 'விமானம் / கடல்சார் துறை',
      icon: 'airplanemode-active',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/ticketing_airline_marine.rss',
    ),
    RssCategory(
      catid: 'TAL',
      minititle: 'Education',
      englisht: 'Education',
      sinhalat: 'අධ්‍යාපන',
      tamilt: 'கல்வி துறை',
      icon: 'menu-book',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/EDUCATION.rss',
    ),
    RssCategory(
      catid: 'RLT',
      minititle: 'Research',
      englisht: 'R&D/Science/Research',
      sinhalat: 'පර්යේෂණ සහ සංවර්ධන/විද්‍යාව',
      tamilt: 'அறிவியல் / ஆராய்ச்சி',
      icon: 'science',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/rnd_science_research.rss',
    ),
    RssCategory(
      catid: 'AGD',
      minititle: 'Agriculture',
      englisht: 'Agriculture/Dairy/Environment',
      sinhalat: 'කෘෂිකර්මය/පරිසරය',
      tamilt: 'விவசாயம் / சுற்றுச்சூழல்',
      icon: 'forest',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/agriculture_dairy_environment.rss',
    ),
    RssCategory(
      catid: 'SEC',
      minititle: 'Security',
      englisht: 'Security',
      sinhalat: 'ආරක්ෂක',
      tamilt: 'பாதுகாப்பு / காவல்',
      icon: 'local-police',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/security.rss',
    ),
    RssCategory(
      catid: 'BEC',
      minititle: 'Fashion',
      englisht: 'Fashion/Design/Beauty',
      sinhalat: 'විලාසිතා/නිර්මාණය/අලංකාරය',
      tamilt: 'அழகு கலை / வடிவமைப்பு',
      icon: 'palette',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/fashion_design_beauty.rss',
    ),
    RssCategory(
      catid: 'IDV',
      minititle: 'International Development',
      englisht: 'International Development',
      sinhalat: 'ජාත්‍යන්තර සංවර්ධනය',
      tamilt: 'சர்வதேச வளர்ச்சி',
      icon: 'people-alt',
      feedUrl:
          'http://www.topjobs.lk/feeds/legasy/international_development.rss',
    ),
    RssCategory(
      catid: 'KPO',
      minititle: 'KPO/BPO',
      englisht: 'KPO/BPO',
      sinhalat: 'ව්‍යාපාර ක්‍රියාවලි බාහිරකරණය',
      tamilt: 'அறிவு செயல்முறை அவுட்சோர்சிங்',
      icon: 'supervised-user-circle',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/kpo_bpo.rss',
    ),
    RssCategory(
      catid: 'IME',
      minititle: 'Imports/Exports',
      englisht: 'Imports/Exports',
      sinhalat: 'ආනයන/අපනයන',
      tamilt: 'ஏற்றுமதி/இறக்குமதி',
      icon: 'import-export',
      feedUrl: 'http://www.topjobs.lk/feeds/legasy/imports_exports.rss',
    ),
  ];

  static RssCategory? getCategoryByFeedUrl(final String feedUrl) {
    try {
      return categories.firstWhere((final category) => category.feedUrl == feedUrl);
    } catch (e) {
      return null;
    }
  }

  static RssCategory? getCategoryById(final String catid) {
    try {
      return categories.firstWhere((final category) => category.catid == catid);
    } catch (e) {
      return null;
    }
  }
}
