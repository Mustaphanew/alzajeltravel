import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class AirportRepo {
  // يمكنك إضافة المزيد من المدن لاحقًا
  static const List<Map<String, dynamic>> _data = [
    {
      "code": "DXB",
      "name": {"en": "Dubai", "ar": "دبي"},
      "body": {"en": "Dubai, Emirates", "ar": "دبي، الامارات"},
    },
    {
      "code": "DWC",
      "name": {"en": "Al Maktoum", "ar": "آل مكتوم"},
      "body": {"en": "Dubai, Emirates", "ar": "دبي، الامارات"},
    },
    {
      "code": "AUH",
      "name": {"en": "Abu Dhabi", "ar": "أبوظبي"},
      "body": {"en": "Abu Dhabi, Emirates", "ar": "أبوظبي، الامارات"},
    },
    {
      "code": "SHJ",
      "name": {"en": "Sharjah", "ar": "الشارقة"},
      "body": {"en": "Sharjah, Emirates", "ar": "الشارقة، الامارات"},
    },
    {
      "code": "RUH",
      "name": {"en": "King Khalid", "ar": "الملك خالد"},
      "body": {"en": "Riyadh, Saudi", "ar": "الرياض، السعودية"},
    },
    {
      "code": "JED",
      "name": {"en": "King Abdulaziz", "ar": "الملك عبدالعزيز"},
      "body": {"en": "Jeddah, Saudi", "ar": "جدة، السعودية"},
    },
    {
      "code": "MED",
      "name": {"en": "Prince Mohammad bin Abdulaziz", "ar": "الأمير محمد بن عبدالعزيز"},
      "body": {"en": "Medina, Saudi", "ar": "المدينة، السعودية"},
    },
    {
      "code": "DMM",
      "name": {"en": "King Fahd", "ar": "الملك فهد"},
      "body": {"en": "Dammam, Saudi", "ar": "الدمام، السعودية"},
    },
    {
      "code": "DOH",
      "name": {"en": "Hamad", "ar": "حمد"},
      "body": {"en": "Doha, Qatar", "ar": "الدوحة، قطر"},
    },
    {
      "code": "BAH",
      "name": {"en": "Bahrain", "ar": "البحرين"},
      "body": {"en": "Manama, Bahrain", "ar": "المنامة، البحرين"},
    },
    {
      "code": "KWI",
      "name": {"en": "Kuwait", "ar": "الكويت"},
      "body": {"en": "Kuwait City, Kuwait", "ar": "مدينة الكويت، الكويت"},
    },
    {
      "code": "MCT",
      "name": {"en": "Muscat", "ar": "مسقط"},
      "body": {"en": "Muscat, Oman", "ar": "مسقط، عمان"},
    },
    {
      "code": "CAI",
      "name": {"en": "Cairo", "ar": "القاهرة"},
      "body": {"en": "Cairo, Egypt", "ar": "القاهرة، مصر"},
    },
    {
      "code": "HBE",
      "name": {"en": "Borg El Arab", "ar": "برج العرب"},
      "body": {"en": "Alexandria, Egypt", "ar": "الاسكندرية، مصر"},
    },
    {
      "code": "SSH",
      "name": {"en": "Sharm El Sheikh", "ar": "شرم الشيخ"},
      "body": {"en": "Sharm El Sheikh, Egypt", "ar": "شرم الشيخ، مصر"},
    },
    {
      "code": "AMM",
      "name": {"en": "Queen Alia", "ar": "الملكة علياء"},
      "body": {"en": "Amman, Jordan", "ar": "عمان، الاردن"},
    },
    {
      "code": "BEY",
      "name": {"en": "Rafic Hariri", "ar": "رفيق الحريري"},
      "body": {"en": "Beirut, Lebanon", "ar": "بيروت، لبنان"},
    },
    {
      "code": "IST",
      "name": {"en": "Istanbul", "ar": "إسطنبول"},
      "body": {"en": "Istanbul, Turkey", "ar": "إسطنبول، تركيا"},
    },
    {
      "code": "SAW",
      "name": {"en": "Sabiha Gökçen", "ar": "صبيحة كوكجن"},
      "body": {"en": "Istanbul, Turkey", "ar": "إسطنبول، تركيا"},
    },
    {
      "code": "LHR",
      "name": {"en": "Heathrow", "ar": "هيثرو"},
      "body": {"en": "London, UK", "ar": "لندن، بريطانيا"},
    },
    {
      "code": "LGW",
      "name": {"en": "Gatwick", "ar": "غاتويك"},
      "body": {"en": "London, UK", "ar": "لندن، بريطانيا"},
    },
    {
      "code": "STN",
      "name": {"en": "Stansted", "ar": "ستانستد"},
      "body": {"en": "London, UK", "ar": "لندن، بريطانيا"},
    },
    {
      "code": "LTN",
      "name": {"en": "Luton", "ar": "لوتن"},
      "body": {"en": "Luton, UK", "ar": "لوتن، بريطانيا"},
    },
    {
      "code": "LCY",
      "name": {"en": "London City", "ar": "لندن سيتي"},
      "body": {"en": "London, UK", "ar": "لندن، بريطانيا"},
    },
    {
      "code": "MAN",
      "name": {"en": "Manchester", "ar": "مانشستر"},
      "body": {"en": "Manchester, UK", "ar": "مانشستر، بريطانيا"},
    },
    {
      "code": "CDG",
      "name": {"en": "Charles de Gaulle", "ar": "شارل ديغول"},
      "body": {"en": "Paris, France", "ar": "باريس، فرنسا"},
    },
    {
      "code": "ORY",
      "name": {"en": "Orly", "ar": "أورلي"},
      "body": {"en": "Paris, France", "ar": "باريس، فرنسا"},
    },
    {
      "code": "AMS",
      "name": {"en": "Schiphol", "ar": "سخيبول"},
      "body": {"en": "Amsterdam, Netherlands", "ar": "أمستردام، هولندا"},
    },
    {
      "code": "FRA",
      "name": {"en": "Frankfurt", "ar": "فرانكفورت"},
      "body": {"en": "Frankfurt, Germany", "ar": "فرانكفورت، المانيا"},
    },
    {
      "code": "MUC",
      "name": {"en": "Munich", "ar": "ميونخ"},
      "body": {"en": "Munich, Germany", "ar": "ميونخ، المانيا"},
    },
    {
      "code": "BER",
      "name": {"en": "Berlin Brandenburg", "ar": "برلين براندنبورغ"},
      "body": {"en": "Berlin, Germany", "ar": "برلين، المانيا"},
    },
    {
      "code": "MAD",
      "name": {"en": "Madrid–Barajas", "ar": "مدريد باراخاس"},
      "body": {"en": "Madrid, Spain", "ar": "مدريد، اسبانيا"},
    },
    {
      "code": "BCN",
      "name": {"en": "Barcelona–El Prat", "ar": "برشلونة إل برات"},
      "body": {"en": "Barcelona, Spain", "ar": "برشلونة، اسبانيا"},
    },
    {
      "code": "FCO",
      "name": {"en": "Fiumicino", "ar": "فيوميتشينو"},
      "body": {"en": "Rome, Italy", "ar": "روما، ايطاليا"},
    },
    {
      "code": "MXP",
      "name": {"en": "Malpensa", "ar": "مالبينسا"},
      "body": {"en": "Milan, Italy", "ar": "ميلانو، ايطاليا"},
    },
    {
      "code": "ATH",
      "name": {"en": "Athens", "ar": "أثينا"},
      "body": {"en": "Athens, Greece", "ar": "أثينا، اليونان"},
    },
    {
      "code": "ZRH",
      "name": {"en": "Zurich", "ar": "زيورخ"},
      "body": {"en": "Zurich, Switzerland", "ar": "زيورخ، سويسرا"},
    },
    {
      "code": "VIE",
      "name": {"en": "Vienna", "ar": "فيينا"},
      "body": {"en": "Vienna, Austria", "ar": "فيينا، النمسا"},
    },
    {
      "code": "CPH",
      "name": {"en": "Copenhagen", "ar": "كوبنهاغن"},
      "body": {"en": "Copenhagen, Denmark", "ar": "كوبنهاغن، الدنمارك"},
    },
    {
      "code": "ARN",
      "name": {"en": "Arlanda", "ar": "آرلاندا"},
      "body": {"en": "Stockholm, Sweden", "ar": "ستوكهولم، السويد"},
    },
    {
      "code": "OSL",
      "name": {"en": "Oslo Gardermoen", "ar": "غاردرموين"},
      "body": {"en": "Oslo, Norway", "ar": "اوسلو، النرويج"},
    },
    {
      "code": "HEL",
      "name": {"en": "Helsinki-Vantaa", "ar": "هلسنكي فانتا"},
      "body": {"en": "Helsinki, Finland", "ar": "هلسنكي، فنلندا"},
    },
    {
      "code": "JFK",
      "name": {"en": "John F. Kennedy", "ar": "جون إف كينيدي"},
      "body": {"en": "New York, USA", "ar": "نيويورك، امريكا"},
    },
    {
      "code": "EWR",
      "name": {"en": "Newark Liberty", "ar": "نيوآرك ليبرتي"},
      "body": {"en": "Newark, USA", "ar": "نيوآرك، امريكا"},
    },
    {
      "code": "LGA",
      "name": {"en": "LaGuardia", "ar": "لاغوارديا"},
      "body": {"en": "New York, USA", "ar": "نيويورك، امريكا"},
    },
    {
      "code": "LAX",
      "name": {"en": "Los Angeles", "ar": "لوس أنجلوس"},
      "body": {"en": "Los Angeles, USA", "ar": "لوس أنجلوس، امريكا"},
    },
    {
      "code": "SFO",
      "name": {"en": "San Francisco", "ar": "سان فرانسيسكو"},
      "body": {"en": "San Francisco, USA", "ar": "سان فرانسيسكو، امريكا"},
    },
    {
      "code": "ORD",
      "name": {"en": "O'Hare", "ar": "أوهير"},
      "body": {"en": "Chicago, USA", "ar": "شيكاغو، امريكا"},
    },
    {
      "code": "ATL",
      "name": {"en": "Hartsfield–Jackson Atlanta", "ar": "هارتسفيلد جاكسون"},
      "body": {"en": "Atlanta, USA", "ar": "أتلانتا، امريكا"},
    },
    {
      "code": "DFW",
      "name": {"en": "Dallas/Fort Worth", "ar": "دالاس - فورت وورث"},
      "body": {"en": "Dallas–Fort Worth, USA", "ar": "دالاس - فورت وورث، امريكا"},
    },
    {
      "code": "MIA",
      "name": {"en": "Miami", "ar": "ميامي"},
      "body": {"en": "Miami, USA", "ar": "ميامي، امريكا"},
    },
    {
      "code": "SEA",
      "name": {"en": "Seattle–Tacoma", "ar": "سياتل تاكوما"},
      "body": {"en": "Seattle, USA", "ar": "سياتل، امريكا"},
    },
    {
      "code": "BOS",
      "name": {"en": "Logan", "ar": "لوغان"},
      "body": {"en": "Boston, USA", "ar": "بوسطن، امريكا"},
    },
    {
      "code": "YYZ",
      "name": {"en": "Toronto Pearson", "ar": "تورونتو بيرسون"},
      "body": {"en": "Toronto, Canada", "ar": "تورونتو، كندا"},
    },
    {
      "code": "YUL",
      "name": {"en": "Montréal–Trudeau", "ar": "مونتريال ترودو"},
      "body": {"en": "Montreal, Canada", "ar": "مونتريال، كندا"},
    },
    {
      "code": "YVR",
      "name": {"en": "Vancouver", "ar": "فانكوفر"},
      "body": {"en": "Vancouver, Canada", "ar": "فانكوفر، كندا"},
    },
    {
      "code": "GRU",
      "name": {"en": "São Paulo–Guarulhos", "ar": "ساو باولو غواروليوس"},
      "body": {"en": "São Paulo, Brazil", "ar": "ساو باولو، البرازيل"},
    },
    {
      "code": "GIG",
      "name": {"en": "Rio de Janeiro–Galeão", "ar": "ريو دي جانيرو غالياؤ"},
      "body": {"en": "Rio de Janeiro, Brazil", "ar": "ريو دي جانيرو، البرازيل"},
    },
    {
      "code": "HND",
      "name": {"en": "Haneda", "ar": "هانيدا"},
      "body": {"en": "Tokyo, Japan", "ar": "طوكيو، اليابان"},
    },
    {
      "code": "NRT",
      "name": {"en": "Narita", "ar": "ناريتا"},
      "body": {"en": "Tokyo, Japan", "ar": "طوكيو، اليابان"},
    },
    {
      "code": "ICN",
      "name": {"en": "Incheon", "ar": "إنتشون"},
      "body": {"en": "Seoul, Korea", "ar": "سيول، كوريا"},
    },
    {
      "code": "HKG",
      "name": {"en": "Hong Kong", "ar": "هونغ كونغ"},
      "body": {"en": "Hong Kong, China", "ar": "هونغ كونغ، الصين"},
    },
    {
      "code": "SIN",
      "name": {"en": "Changi", "ar": "تشانغي"},
      "body": {"en": "Singapore, Singapore", "ar": "سنغافورة، سنغافورة"},
    },
    {
      "code": "KUL",
      "name": {"en": "Kuala Lumpur", "ar": "كوالالمبور"},
      "body": {"en": "Kuala Lumpur, Malaysia", "ar": "كوالالمبور، ماليزيا"},
    },
    {
      "code": "BKK",
      "name": {"en": "Suvarnabhumi", "ar": "سوفارنابومي"},
      "body": {"en": "Bangkok, Thailand", "ar": "بانكوك، تايلاند"},
    },
    {
      "code": "HKT",
      "name": {"en": "Phuket", "ar": "بوكيت"},
      "body": {"en": "Phuket, Thailand", "ar": "بوكيت، تايلاند"},
    },
    {
      "code": "SYD",
      "name": {"en": "Sydney Kingsford Smith", "ar": "سيدني كنغسفورد سميث"},
      "body": {"en": "Sydney, Australia", "ar": "سيدني، استراليا"},
    },
    {
      "code": "MEL",
      "name": {"en": "Melbourne", "ar": "ملبورن"},
      "body": {"en": "Melbourne, Australia", "ar": "ملبورن، استراليا"},
    },
    {
      "code": "AKL",
      "name": {"en": "Auckland", "ar": "أوكلاند"},
      "body": {"en": "Auckland, New Zealand", "ar": "أوكلاند، نيوزيلندا"},
    },
    {
      "code": "DEL",
      "name": {"en": "Indira Gandhi (Delhi)", "ar": "إنديرا غاندي (دلهي)"},
      "body": {"en": "Delhi, India", "ar": "دلهي، الهند"},
    },
    {
      "code": "BOM",
      "name": {"en": "Chhatrapati Shivaji Maharaj (Mumbai)", "ar": "تشاتراباتي شيفاجي ماهاراج (مومباي)"},
      "body": {"en": "Mumbai, India", "ar": "مومباي، الهند"},
    },
    {
      "code": "DEN",
      "name": {"en": "Denver", "ar": "دنفر"},
      "body": {"en": "Denver, USA", "ar": "دنفر، امريكا"},
    },
    {
      "code": "CLT",
      "name": {"en": "Charlotte", "ar": "شارلوت"},
      "body": {"en": "Charlotte, USA", "ar": "شارلوت، امريكا"},
    },
    {
      "code": "MCO",
      "name": {"en": "Orlando", "ar": "أورلاندو"},
      "body": {"en": "Orlando, USA", "ar": "أورلاندو، امريكا"},
    },
    {
      "code": "IAH",
      "name": {"en": "Houston", "ar": "هيوستن"},
      "body": {"en": "Houston, USA", "ar": "هيوستن، امريكا"},
    },
    {
      "code": "LAS",
      "name": {"en": "Las Vegas", "ar": "لاس فيغاس"},
      "body": {"en": "Las Vegas, USA", "ar": "لاس فيغاس، امريكا"},
    },
    {
      "code": "PHX",
      "name": {"en": "Phoenix", "ar": "فينيكس"},
      "body": {"en": "Phoenix, USA", "ar": "فينيكس، امريكا"},
    },
    {
      "code": "DTW",
      "name": {"en": "Detroit", "ar": "ديترويت"},
      "body": {"en": "Detroit, USA", "ar": "ديترويت، امريكا"},
    },
    {
      "code": "PHL",
      "name": {"en": "Philadelphia", "ar": "فيلادلفيا"},
      "body": {"en": "Philadelphia, USA", "ar": "فيلادلفيا، امريكا"},
    },
    {
      "code": "MSP",
      "name": {"en": "Minneapolis–St Paul", "ar": "مينيابوليس - سانت بول"},
      "body": {"en": "Minneapolis, USA", "ar": "مينيابوليس، امريكا"},
    },
    {
      "code": "BWI",
      "name": {"en": "Baltimore/Washington", "ar": "بالتيمور - واشنطن"},
      "body": {"en": "Baltimore, USA", "ar": "بالتيمور، امريكا"},
    },
    {
      "code": "FLL",
      "name": {"en": "Fort Lauderdale", "ar": "فورت لودرديل"},
      "body": {"en": "Fort Lauderdale, USA", "ar": "فورت لودرديل، امريكا"},
    },
    {
      "code": "TPA",
      "name": {"en": "Tampa", "ar": "تامبا"},
      "body": {"en": "Tampa, USA", "ar": "تامبا، امريكا"},
    },
    {
      "code": "IAD",
      "name": {"en": "Washington Dulles", "ar": "واشنطن دالاس"},
      "body": {"en": "Washington, USA", "ar": "واشنطن، امريكا"},
    },
    {
      "code": "DCA",
      "name": {"en": "Washington Reagan", "ar": "واشنطن ريغان"},
      "body": {"en": "Washington, USA", "ar": "واشنطن، امريكا"},
    },
    {
      "code": "SAN",
      "name": {"en": "San Diego", "ar": "سان دييغو"},
      "body": {"en": "San Diego, USA", "ar": "سان دييغو، امريكا"},
    },
    {
      "code": "SJC",
      "name": {"en": "San Jose (CA)", "ar": "سان خوسيه (كاليفورنيا)"},
      "body": {"en": "San Jose, USA", "ar": "سان خوسيه، امريكا"},
    },
    {
      "code": "SLC",
      "name": {"en": "Salt Lake City", "ar": "سولت لايك سيتي"},
      "body": {"en": "Salt Lake City, USA", "ar": "سولت لايك سيتي، امريكا"},
    },
    {
      "code": "HNL",
      "name": {"en": "Honolulu", "ar": "هونولولو"},
      "body": {"en": "Honolulu, USA", "ar": "هونولولو، امريكا"},
    },
    {
      "code": "YYC",
      "name": {"en": "Calgary", "ar": "كالغاري"},
      "body": {"en": "Calgary, Canada", "ar": "كالغاري، كندا"},
    },
    {
      "code": "YEG",
      "name": {"en": "Edmonton", "ar": "إدمونتون"},
      "body": {"en": "Edmonton, Canada", "ar": "إدمونتون، كندا"},
    },
    {
      "code": "YOW",
      "name": {"en": "Ottawa", "ar": "أوتاوا"},
      "body": {"en": "Ottawa, Canada", "ar": "أوتاوا، كندا"},
    },
    {
      "code": "YHZ",
      "name": {"en": "Halifax", "ar": "هاليفاكس"},
      "body": {"en": "Halifax, Canada", "ar": "هاليفاكس، كندا"},
    },
    {
      "code": "YWG",
      "name": {"en": "Winnipeg", "ar": "وينيبيغ"},
      "body": {"en": "Winnipeg, Canada", "ar": "وينيبيغ، كندا"},
    },
    {
      "code": "AUS",
      "name": {"en": "Austin", "ar": "أوستن"},
      "body": {"en": "Austin, USA", "ar": "أوستن، امريكا"},
    },
    {
      "code": "BNA",
      "name": {"en": "Nashville", "ar": "ناشفيل"},
      "body": {"en": "Nashville, USA", "ar": "ناشفيل، امريكا"},
    },
    {
      "code": "MEX",
      "name": {"en": "Mexico City", "ar": "مكسيكو سيتي"},
      "body": {"en": "Mexico City, Mexico", "ar": "مكسيكو سيتي، المكسيك"},
    },
    {
      "code": "CUN",
      "name": {"en": "Cancun", "ar": "كانكون"},
      "body": {"en": "Cancun, Mexico", "ar": "كانكون، المكسيك"},
    },
    {
      "code": "GDL",
      "name": {"en": "Guadalajara", "ar": "غوادالاخارا"},
      "body": {"en": "Guadalajara, Mexico", "ar": "غوادالاخارا، المكسيك"},
    },
    {
      "code": "MTY",
      "name": {"en": "Monterrey", "ar": "مونتيري"},
      "body": {"en": "Monterrey, Mexico", "ar": "مونتيري، المكسيك"},
    },
    {
      "code": "SJU",
      "name": {"en": "San Juan", "ar": "سان خوان"},
      "body": {"en": "San Juan, Puerto Rico", "ar": "سان خوان، بورتوريكو"},
    },
    {
      "code": "PUJ",
      "name": {"en": "Punta Cana", "ar": "بونتا كانا"},
      "body": {"en": "Punta Cana, Dominican", "ar": "بونتا كانا، الدومينيكان"},
    },
    {
      "code": "BOG",
      "name": {"en": "Bogota", "ar": "بوغوتا"},
      "body": {"en": "Bogota, Colombia", "ar": "بوغوتا، كولومبيا"},
    },
    {
      "code": "LIM",
      "name": {"en": "Lima", "ar": "ليما"},
      "body": {"en": "Lima, Peru", "ar": "ليما، بيرو"},
    },
    {
      "code": "SCL",
      "name": {"en": "Santiago", "ar": "سانتياغو"},
      "body": {"en": "Santiago, Chile", "ar": "سانتياغو، تشيلي"},
    },
    {
      "code": "EZE",
      "name": {"en": "Buenos Aires (Ezeiza)", "ar": "بوينس آيرس (إيزيزا)"},
      "body": {"en": "Buenos Aires, Argentina", "ar": "بوينس آيرس، الارجنتين"},
    },
    {
      "code": "AEP",
      "name": {"en": "Buenos Aires (Aeroparque)", "ar": "بوينس آيرس (إيروبارك)"},
      "body": {"en": "Buenos Aires, Argentina", "ar": "بوينس آيرس، الارجنتين"},
    },
    {
      "code": "PTY",
      "name": {"en": "Panama City (Tocumen)", "ar": "بنما (توكومين)"},
      "body": {"en": "Panama City, Panama", "ar": "بنما، بنما"},
    },
    {
      "code": "UIO",
      "name": {"en": "Quito", "ar": "كيتو"},
      "body": {"en": "Quito, Ecuador", "ar": "كيتو، الاكوادور"},
    },
    {
      "code": "GYE",
      "name": {"en": "Guayaquil", "ar": "غواياكيل"},
      "body": {"en": "Guayaquil, Ecuador", "ar": "غواياكيل، الاكوادور"},
    },
    {
      "code": "MDE",
      "name": {"en": "Medellin", "ar": "ميديلين"},
      "body": {"en": "Medellin, Colombia", "ar": "ميديلين، كولومبيا"},
    },
    {
      "code": "DUB",
      "name": {"en": "Dublin", "ar": "دبلن"},
      "body": {"en": "Dublin, Ireland", "ar": "دبلن، ايرلندا"},
    },
    {
      "code": "LIS",
      "name": {"en": "Lisbon", "ar": "لشبونة"},
      "body": {"en": "Lisbon, Portugal", "ar": "لشبونة، البرتغال"},
    },
    {
      "code": "OPO",
      "name": {"en": "Porto", "ar": "بورتو"},
      "body": {"en": "Porto, Portugal", "ar": "بورتو، البرتغال"},
    },
    {
      "code": "BRU",
      "name": {"en": "Brussels", "ar": "بروكسل"},
      "body": {"en": "Brussels, Belgium", "ar": "بروكسل، بلجيكا"},
    },
    {
      "code": "PRG",
      "name": {"en": "Prague", "ar": "براغ"},
      "body": {"en": "Prague, Czechia", "ar": "براغ، التشيك"},
    },
    {
      "code": "WAW",
      "name": {"en": "Warsaw", "ar": "وارسو"},
      "body": {"en": "Warsaw, Poland", "ar": "وارسو، بولندا"},
    },
    {
      "code": "KRK",
      "name": {"en": "Krakow", "ar": "كراكوف"},
      "body": {"en": "Krakow, Poland", "ar": "كراكوف، بولندا"},
    },
    {
      "code": "BUD",
      "name": {"en": "Budapest", "ar": "بودابست"},
      "body": {"en": "Budapest, Hungary", "ar": "بودابست، المجر"},
    },
    {
      "code": "OTP",
      "name": {"en": "Bucharest", "ar": "بوخارست"},
      "body": {"en": "Bucharest, Romania", "ar": "بوخارست، رومانيا"},
    },
    {
      "code": "SOF",
      "name": {"en": "Sofia", "ar": "صوفيا"},
      "body": {"en": "Sofia, Bulgaria", "ar": "صوفيا، بلغاريا"},
    },
    {
      "code": "BEG",
      "name": {"en": "Belgrade", "ar": "بلغراد"},
      "body": {"en": "Belgrade, Serbia", "ar": "بلغراد، صربيا"},
    },
    {
      "code": "ZAG",
      "name": {"en": "Zagreb", "ar": "زغرب"},
      "body": {"en": "Zagreb, Croatia", "ar": "زغرب، كرواتيا"},
    },
    {
      "code": "KEF",
      "name": {"en": "Keflavik", "ar": "كيفلافيك"},
      "body": {"en": "Reykjavik, Iceland", "ar": "ريكيافيك، ايسلندا"},
    },
    {
      "code": "RIX",
      "name": {"en": "Riga", "ar": "ريغا"},
      "body": {"en": "Riga, Latvia", "ar": "ريغا، لاتفيا"},
    },
    {
      "code": "VNO",
      "name": {"en": "Vilnius", "ar": "فيلنيوس"},
      "body": {"en": "Vilnius, Lithuania", "ar": "فيلنيوس، ليتوانيا"},
    },
    {
      "code": "TLL",
      "name": {"en": "Tallinn", "ar": "تالين"},
      "body": {"en": "Tallinn, Estonia", "ar": "تالين، استونيا"},
    },
    {
      "code": "DUS",
      "name": {"en": "Dusseldorf", "ar": "دوسلدورف"},
      "body": {"en": "Dusseldorf, Germany", "ar": "دوسلدورف، المانيا"},
    },
    {
      "code": "HAM",
      "name": {"en": "Hamburg", "ar": "هامبورغ"},
      "body": {"en": "Hamburg, Germany", "ar": "هامبورغ، المانيا"},
    },
    {
      "code": "CGN",
      "name": {"en": "Cologne Bonn", "ar": "كولونيا بون"},
      "body": {"en": "Cologne, Germany", "ar": "كولونيا، المانيا"},
    },
    {
      "code": "STR",
      "name": {"en": "Stuttgart", "ar": "شتوتغارت"},
      "body": {"en": "Stuttgart, Germany", "ar": "شتوتغارت، المانيا"},
    },
    {
      "code": "NCE",
      "name": {"en": "Nice", "ar": "نيس"},
      "body": {"en": "Nice, France", "ar": "نيس، فرنسا"},
    },
    {
      "code": "MRS",
      "name": {"en": "Marseille", "ar": "مرسيليا"},
      "body": {"en": "Marseille, France", "ar": "مرسيليا، فرنسا"},
    },
    {
      "code": "LYS",
      "name": {"en": "Lyon", "ar": "ليون"},
      "body": {"en": "Lyon, France", "ar": "ليون، فرنسا"},
    },
    {
      "code": "TLS",
      "name": {"en": "Toulouse", "ar": "تولوز"},
      "body": {"en": "Toulouse, France", "ar": "تولوز، فرنسا"},
    },
    {
      "code": "VCE",
      "name": {"en": "Venice", "ar": "البندقية"},
      "body": {"en": "Venice, Italy", "ar": "البندقية، ايطاليا"},
    },
    {
      "code": "NAP",
      "name": {"en": "Naples", "ar": "نابولي"},
      "body": {"en": "Naples, Italy", "ar": "نابولي، ايطاليا"},
    },
    {
      "code": "FLR",
      "name": {"en": "Florence", "ar": "فلورنسا"},
      "body": {"en": "Florence, Italy", "ar": "فلورنسا، ايطاليا"},
    },
    {
      "code": "BLQ",
      "name": {"en": "Bologna", "ar": "بولونيا"},
      "body": {"en": "Bologna, Italy", "ar": "بولونيا، ايطاليا"},
    },
    {
      "code": "CTA",
      "name": {"en": "Catania", "ar": "كاتانيا"},
      "body": {"en": "Catania, Italy", "ar": "كاتانيا، ايطاليا"},
    },
    {
      "code": "PMO",
      "name": {"en": "Palermo", "ar": "باليرمو"},
      "body": {"en": "Palermo, Italy", "ar": "باليرمو، ايطاليا"},
    },
    {
      "code": "PEK",
      "name": {"en": "Beijing Capital", "ar": "بكين العاصمة"},
      "body": {"en": "Beijing, China", "ar": "بكين، الصين"},
    },
    {
      "code": "PKX",
      "name": {"en": "Beijing Daxing", "ar": "بكين داشينغ"},
      "body": {"en": "Beijing, China", "ar": "بكين، الصين"},
    },
    {
      "code": "PVG",
      "name": {"en": "Shanghai Pudong", "ar": "شنغهاي بودونغ"},
      "body": {"en": "Shanghai, China", "ar": "شنغهاي، الصين"},
    },
    {
      "code": "SHA",
      "name": {"en": "Shanghai Hongqiao", "ar": "شنغهاي هونغكياو"},
      "body": {"en": "Shanghai, China", "ar": "شنغهاي، الصين"},
    },
    {
      "code": "CAN",
      "name": {"en": "Guangzhou", "ar": "قوانغتشو"},
      "body": {"en": "Guangzhou, China", "ar": "قوانغتشو، الصين"},
    },
    {
      "code": "SZX",
      "name": {"en": "Shenzhen", "ar": "شنتشن"},
      "body": {"en": "Shenzhen, China", "ar": "شنتشن، الصين"},
    },
    {
      "code": "CTU",
      "name": {"en": "Chengdu", "ar": "تشنغدو"},
      "body": {"en": "Chengdu, China", "ar": "تشنغدو، الصين"},
    },
    {
      "code": "CKG",
      "name": {"en": "Chongqing", "ar": "تشونغتشينغ"},
      "body": {"en": "Chongqing, China", "ar": "تشونغتشينغ، الصين"},
    },
    {
      "code": "KMG",
      "name": {"en": "Kunming", "ar": "كونمينغ"},
      "body": {"en": "Kunming, China", "ar": "كونمينغ، الصين"},
    },
    {
      "code": "XIY",
      "name": {"en": "Xi'an", "ar": "شيآن"},
      "body": {"en": "Xi'an, China", "ar": "شيآن، الصين"},
    },
    {
      "code": "HGH",
      "name": {"en": "Hangzhou", "ar": "هانغتشو"},
      "body": {"en": "Hangzhou, China", "ar": "هانغتشو، الصين"},
    },
    {
      "code": "NKG",
      "name": {"en": "Nanjing", "ar": "نانجينغ"},
      "body": {"en": "Nanjing, China", "ar": "نانجينغ، الصين"},
    },
    {
      "code": "WUH",
      "name": {"en": "Wuhan", "ar": "ووهان"},
      "body": {"en": "Wuhan, China", "ar": "ووهان، الصين"},
    },
    {
      "code": "XMN",
      "name": {"en": "Xiamen", "ar": "شيامن"},
      "body": {"en": "Xiamen, China", "ar": "شيامن، الصين"},
    },
    {
      "code": "TAO",
      "name": {"en": "Qingdao", "ar": "تشينغداو"},
      "body": {"en": "Qingdao, China", "ar": "تشينغداو، الصين"},
    },
    {
      "code": "TPE",
      "name": {"en": "Taipei", "ar": "تايبيه"},
      "body": {"en": "Taipei, Taiwan", "ar": "تايبيه، تايوان"},
    },
    {
      "code": "MNL",
      "name": {"en": "Manila", "ar": "مانيلا"},
      "body": {"en": "Manila, Philippines", "ar": "مانيلا، الفلبين"},
    },
    {
      "code": "CGK",
      "name": {"en": "Jakarta", "ar": "جاكرتا"},
      "body": {"en": "Jakarta, Indonesia", "ar": "جاكرتا، اندونيسيا"},
    },
    {
      "code": "DPS",
      "name": {"en": "Bali", "ar": "بالي"},
      "body": {"en": "Bali, Indonesia", "ar": "بالي، اندونيسيا"},
    },
    {
      "code": "HAN",
      "name": {"en": "Hanoi", "ar": "هانوي"},
      "body": {"en": "Hanoi, Vietnam", "ar": "هانوي، فيتنام"},
    },
    {
      "code": "SGN",
      "name": {"en": "Ho Chi Minh City", "ar": "هو تشي منه"},
      "body": {"en": "Ho Chi Minh City, Vietnam", "ar": "هو تشي منه، فيتنام"},
    },
    {
      "code": "DMK",
      "name": {"en": "Bangkok Don Mueang", "ar": "بانكوك (دون موينغ)"},
      "body": {"en": "Bangkok, Thailand", "ar": "بانكوك، تايلاند"},
    },
    {
      "code": "KIX",
      "name": {"en": "Osaka Kansai", "ar": "أوساكا (كانساي)"},
      "body": {"en": "Osaka, Japan", "ar": "أوساكا، اليابان"},
    },
    {
      "code": "NGO",
      "name": {"en": "Nagoya", "ar": "ناغويا"},
      "body": {"en": "Nagoya, Japan", "ar": "ناغويا، اليابان"},
    },
    {
      "code": "BLR",
      "name": {"en": "Bengaluru", "ar": "بنغالورو"},
      "body": {"en": "Bengaluru, India", "ar": "بنغالورو، الهند"},
    },
    {
      "code": "TLV",
      "name": {"en": "Tel Aviv", "ar": "تل أبيب"},
      "body": {"en": "Tel Aviv, Israel", "ar": "تل أبيب، اسرائيل"},
    },
    {
      "code": "JNB",
      "name": {"en": "Johannesburg", "ar": "جوهانسبرغ"},
      "body": {"en": "Johannesburg, South Africa", "ar": "جوهانسبرغ، جنوب افريقيا"},
    },
    {
      "code": "CPT",
      "name": {"en": "Cape Town", "ar": "كيب تاون"},
      "body": {"en": "Cape Town, South Africa", "ar": "كيب تاون، جنوب افريقيا"},
    },
    {
      "code": "ADD",
      "name": {"en": "Addis Ababa", "ar": "أديس أبابا"},
      "body": {"en": "Addis Ababa, Ethiopia", "ar": "أديس أبابا، اثيوبيا"},
    },
    {
      "code": "BNE",
      "name": {"en": "Brisbane", "ar": "بريسبان"},
      "body": {"en": "Brisbane, Australia", "ar": "بريسبان، استراليا"},
    },
  ];

  Future<List<Map<String, dynamic>>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 0)); // تأخير بسيط
    final q = query.trim().toLowerCase();
    // if (q.isEmpty) return [];
    // البحث بالرمز أو الاسم أو الوصف
    final res = _data.where((element) {
      print("element: $element");
      final e = AirportModel.fromJson(element);
      return e.code.toLowerCase().contains(q) ||
          e.name[AppVars.lang].toString().toLowerCase().contains(q) ||
          e.body[AppVars.lang].toString().toLowerCase().contains(q);
    }).toList();
    // حد أقصى (لإنقاص الحمل)
    print("res.take(100).toList(): ${res.take(100).toList().length}");
    return res.take(100).toList();
  }

  /// ترجع AirportModel حسب كود المطار (مثل DXB) أو null إذا غير موجود
  static AirportModel? searchByCode(String code) {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return null;

    final json = _data.firstWhere(
      (e) => (e['code'] ?? '').toString().trim().toUpperCase() == c,
      orElse: () => <String, dynamic>{},
    );

    if (json.isEmpty) return null;
    return AirportModel.fromJson(json);
  }

  /// نسخة async إذا تحب نفس نمط search
  Future<AirportModel?> searchByCodeAsync(String code) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return searchByCode(code);
  }
}
