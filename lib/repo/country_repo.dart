import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class CountryRepo {
  static const List<Map<String, dynamic>> _data = [
    {
      "name": {"en": "Afghanistan", "ar": "أفغانستان"},
      "alpha2": "AF",
      "alpha3": "AFG",
      "dialcode": "93",
    },
    {
      "name": {"en": "Aland Islands", "ar": "جزر آلاند"},
      "alpha2": "AX",
      "alpha3": "ALA",
      "dialcode": "358",
    },
    {
      "name": {"en": "Albania", "ar": "ألبانيا"},
      "alpha2": "AL",
      "alpha3": "ALB",
      "dialcode": "355",
    },
    {
      "name": {"en": "Algeria", "ar": "الجزائر"},
      "alpha2": "DZ",
      "alpha3": "DZA",
      "dialcode": "213",
    },
    {
      "name": {"en": "American Samoa", "ar": "ساموا الأمريكية"},
      "alpha2": "AS",
      "alpha3": "ASM",
      "dialcode": "1",
    },
    {
      "name": {"en": "Andorra", "ar": "أندورا"},
      "alpha2": "AD",
      "alpha3": "AND",
      "dialcode": "376",
    },
    {
      "name": {"en": "Angola", "ar": "أنغولا"},
      "alpha2": "AO",
      "alpha3": "AGO",
      "dialcode": "244",
    },
    {
      "name": {"en": "Anguilla", "ar": "أنغويلا"},
      "alpha2": "AI",
      "alpha3": "AIA",
      "dialcode": "1",
    },
    {
      "name": {"en": "Antarctica", "ar": "أنتاركتيكا"},
      "alpha2": "AQ",
      "alpha3": "ATA",
      "dialcode": "672",
    },
    {
      "name": {"en": "Antigua and Barbuda", "ar": "أنتيغوا وبربودا"},
      "alpha2": "AG",
      "alpha3": "ATG",
      "dialcode": "1",
    },
    {
      "name": {"en": "Argentina", "ar": "الأرجنتين"},
      "alpha2": "AR",
      "alpha3": "ARG",
      "dialcode": "54",
    },
    {
      "name": {"en": "Armenia", "ar": "أرمينيا"},
      "alpha2": "AM",
      "alpha3": "ARM",
      "dialcode": "374",
    },
    {
      "name": {"en": "Aruba", "ar": "أروبا"},
      "alpha2": "AW",
      "alpha3": "ABW",
      "dialcode": "297",
    },
    {
      "name": {"en": "Australia", "ar": "أستراليا"},
      "alpha2": "AU",
      "alpha3": "AUS",
      "dialcode": "61",
    },
    {
      "name": {"en": "Austria", "ar": "النمسا"},
      "alpha2": "AT",
      "alpha3": "AUT",
      "dialcode": "43",
    },
    {
      "name": {"en": "Azerbaijan", "ar": "أذربيجان"},
      "alpha2": "AZ",
      "alpha3": "AZE",
      "dialcode": "994",
    },

    {
      "name": {"en": "Bahamas", "ar": "جزر البهاما"},
      "alpha2": "BS",
      "alpha3": "BHS",
      "dialcode": "1",
    },
    {
      "name": {"en": "Bahrain", "ar": "البحرين"},
      "alpha2": "BH",
      "alpha3": "BHR",
      "dialcode": "973",
    },
    {
      "name": {"en": "Bangladesh", "ar": "بنغلاديش"},
      "alpha2": "BD",
      "alpha3": "BGD",
      "dialcode": "880",
    },
    {
      "name": {"en": "Barbados", "ar": "بربادوس"},
      "alpha2": "BB",
      "alpha3": "BRB",
      "dialcode": "1",
    },
    {
      "name": {"en": "Belarus", "ar": "بيلاروس"},
      "alpha2": "BY",
      "alpha3": "BLR",
      "dialcode": "375",
    },
    {
      "name": {"en": "Belgium", "ar": "بلجيكا"},
      "alpha2": "BE",
      "alpha3": "BEL",
      "dialcode": "32",
    },
    {
      "name": {"en": "Belize", "ar": "بليز"},
      "alpha2": "BZ",
      "alpha3": "BLZ",
      "dialcode": "501",
    },
    {
      "name": {"en": "Benin", "ar": "بنين"},
      "alpha2": "BJ",
      "alpha3": "BEN",
      "dialcode": "229",
    },
    {
      "name": {"en": "Bermuda", "ar": "برمودا"},
      "alpha2": "BM",
      "alpha3": "BMU",
      "dialcode": "1",
    },
    {
      "name": {"en": "Bhutan", "ar": "بوتان"},
      "alpha2": "BT",
      "alpha3": "BTN",
      "dialcode": "975",
    },
    {
      "name": {"en": "Bolivia", "ar": "بوليفيا"},
      "alpha2": "BO",
      "alpha3": "BOL",
      "dialcode": "591",
    },
    {
      "name": {"en": "Bonaire, Sint Eustatius and Saba", "ar": "بونير وسانت أوستاتيوس وسابا"},
      "alpha2": "BQ",
      "alpha3": "BES",
      "dialcode": "599",
    },
    {
      "name": {"en": "Bosnia and Herzegovina", "ar": "البوسنة والهرسك"},
      "alpha2": "BA",
      "alpha3": "BIH",
      "dialcode": "387",
    },
    {
      "name": {"en": "Botswana", "ar": "بوتسوانا"},
      "alpha2": "BW",
      "alpha3": "BWA",
      "dialcode": "267",
    },
    {
      "name": {"en": "Bouvet Island", "ar": "جزيرة بوفيه"},
      "alpha2": "BV",
      "alpha3": "BVT",
      "dialcode": "47",
    },
    {
      "name": {"en": "Brazil", "ar": "البرازيل"},
      "alpha2": "BR",
      "alpha3": "BRA",
      "dialcode": "55",
    },
    {
      "name": {"en": "British Indian Ocean Territory", "ar": "إقليم المحيط الهندي البريطاني"},
      "alpha2": "IO",
      "alpha3": "IOT",
      "dialcode": "246",
    },
    {
      "name": {"en": "Brunei Darussalam", "ar": "بروناي دار السلام"},
      "alpha2": "BN",
      "alpha3": "BRN",
      "dialcode": "673",
    },
    {
      "name": {"en": "Bulgaria", "ar": "بلغاريا"},
      "alpha2": "BG",
      "alpha3": "BGR",
      "dialcode": "359",
    },
    {
      "name": {"en": "Burkina Faso", "ar": "بوركينا فاسو"},
      "alpha2": "BF",
      "alpha3": "BFA",
      "dialcode": "226",
    },
    {
      "name": {"en": "Burundi", "ar": "بوروندي"},
      "alpha2": "BI",
      "alpha3": "BDI",
      "dialcode": "257",
    },

    {
      "name": {"en": "Cabo Verde", "ar": "الرأس الأخضر"},
      "alpha2": "CV",
      "alpha3": "CPV",
      "dialcode": "238",
    },
    {
      "name": {"en": "Cambodia", "ar": "كمبوديا"},
      "alpha2": "KH",
      "alpha3": "KHM",
      "dialcode": "855",
    },
    {
      "name": {"en": "Cameroon", "ar": "الكاميرون"},
      "alpha2": "CM",
      "alpha3": "CMR",
      "dialcode": "237",
    },
    {
      "name": {"en": "Canada", "ar": "كندا"},
      "alpha2": "CA",
      "alpha3": "CAN",
      "dialcode": "1",
    },
    {
      "name": {"en": "Cayman Islands", "ar": "جزر كايمان"},
      "alpha2": "KY",
      "alpha3": "CYM",
      "dialcode": "1",
    },
    {
      "name": {"en": "Central African Republic", "ar": "جمهورية أفريقيا الوسطى"},
      "alpha2": "CF",
      "alpha3": "CAF",
      "dialcode": "236",
    },
    {
      "name": {"en": "Chad", "ar": "تشاد"},
      "alpha2": "TD",
      "alpha3": "TCD",
      "dialcode": "235",
    },
    {
      "name": {"en": "Chile", "ar": "تشيلي"},
      "alpha2": "CL",
      "alpha3": "CHL",
      "dialcode": "56",
    },
    {
      "name": {"en": "China", "ar": "الصين"},
      "alpha2": "CN",
      "alpha3": "CHN",
      "dialcode": "86",
    },
    {
      "name": {"en": "Christmas Island", "ar": "جزيرة كريسماس"},
      "alpha2": "CX",
      "alpha3": "CXR",
      "dialcode": "61",
    },
    {
      "name": {"en": "Cocos (Keeling) Islands", "ar": "جزر كوكوس (كيلينغ)"},
      "alpha2": "CC",
      "alpha3": "CCK",
      "dialcode": "61",
    },
    {
      "name": {"en": "Colombia", "ar": "كولومبيا"},
      "alpha2": "CO",
      "alpha3": "COL",
      "dialcode": "57",
    },
    {
      "name": {"en": "Comoros", "ar": "جزر القمر"},
      "alpha2": "KM",
      "alpha3": "COM",
      "dialcode": "269",
    },
    {
      "name": {"en": "Congo", "ar": "الكونغو"},
      "alpha2": "CG",
      "alpha3": "COG",
      "dialcode": "242",
    },
    {
      "name": {"en": "Congo, Democratic Republic of the", "ar": "جمهورية الكونغو الديمقراطية"},
      "alpha2": "CD",
      "alpha3": "COD",
      "dialcode": "243",
    },
    {
      "name": {"en": "Cook Islands", "ar": "جزر كوك"},
      "alpha2": "CK",
      "alpha3": "COK",
      "dialcode": "682",
    },
    {
      "name": {"en": "Costa Rica", "ar": "كوستاريكا"},
      "alpha2": "CR",
      "alpha3": "CRI",
      "dialcode": "506",
    },
    {
      "name": {"en": "Cote d'Ivoire", "ar": "ساحل العاج"},
      "alpha2": "CI",
      "alpha3": "CIV",
      "dialcode": "225",
    },
    {
      "name": {"en": "Croatia", "ar": "كرواتيا"},
      "alpha2": "HR",
      "alpha3": "HRV",
      "dialcode": "385",
    },
    {
      "name": {"en": "Cuba", "ar": "كوبا"},
      "alpha2": "CU",
      "alpha3": "CUB",
      "dialcode": "53",
    },
    {
      "name": {"en": "Curacao", "ar": "كوراساو"},
      "alpha2": "CW",
      "alpha3": "CUW",
      "dialcode": "599",
    },
    {
      "name": {"en": "Cyprus", "ar": "قبرص"},
      "alpha2": "CY",
      "alpha3": "CYP",
      "dialcode": "357",
    },
    {
      "name": {"en": "Czechia", "ar": "التشيك"},
      "alpha2": "CZ",
      "alpha3": "CZE",
      "dialcode": "420",
    },

    {
      "name": {"en": "Denmark", "ar": "الدنمارك"},
      "alpha2": "DK",
      "alpha3": "DNK",
      "dialcode": "45",
    },
    {
      "name": {"en": "Djibouti", "ar": "جيبوتي"},
      "alpha2": "DJ",
      "alpha3": "DJI",
      "dialcode": "253",
    },
    {
      "name": {"en": "Dominica", "ar": "دومينيكا"},
      "alpha2": "DM",
      "alpha3": "DMA",
      "dialcode": "1",
    },
    {
      "name": {"en": "Dominican Republic", "ar": "جمهورية الدومينيكان"},
      "alpha2": "DO",
      "alpha3": "DOM",
      "dialcode": "1",
    },

    {
      "name": {"en": "Ecuador", "ar": "الإكوادور"},
      "alpha2": "EC",
      "alpha3": "ECU",
      "dialcode": "593",
    },
    {
      "name": {"en": "Egypt", "ar": "مصر"},
      "alpha2": "EG",
      "alpha3": "EGY",
      "dialcode": "20",
    },
    {
      "name": {"en": "El Salvador", "ar": "السلفادور"},
      "alpha2": "SV",
      "alpha3": "SLV",
      "dialcode": "503",
    },
    {
      "name": {"en": "Equatorial Guinea", "ar": "غينيا الاستوائية"},
      "alpha2": "GQ",
      "alpha3": "GNQ",
      "dialcode": "240",
    },
    {
      "name": {"en": "Eritrea", "ar": "إريتريا"},
      "alpha2": "ER",
      "alpha3": "ERI",
      "dialcode": "291",
    },
    {
      "name": {"en": "Estonia", "ar": "إستونيا"},
      "alpha2": "EE",
      "alpha3": "EST",
      "dialcode": "372",
    },
    {
      "name": {"en": "Eswatini", "ar": "إسواتيني"},
      "alpha2": "SZ",
      "alpha3": "SWZ",
      "dialcode": "268",
    },
    {
      "name": {"en": "Ethiopia", "ar": "إثيوبيا"},
      "alpha2": "ET",
      "alpha3": "ETH",
      "dialcode": "251",
    },

    {
      "name": {"en": "Falkland Islands", "ar": "جزر فوكلاند"},
      "alpha2": "FK",
      "alpha3": "FLK",
      "dialcode": "500",
    },
    {
      "name": {"en": "Faroe Islands", "ar": "جزر فارو"},
      "alpha2": "FO",
      "alpha3": "FRO",
      "dialcode": "298",
    },
    {
      "name": {"en": "Fiji", "ar": "فيجي"},
      "alpha2": "FJ",
      "alpha3": "FJI",
      "dialcode": "679",
    },
    {
      "name": {"en": "Finland", "ar": "فنلندا"},
      "alpha2": "FI",
      "alpha3": "FIN",
      "dialcode": "358",
    },
    {
      "name": {"en": "France", "ar": "فرنسا"},
      "alpha2": "FR",
      "alpha3": "FRA",
      "dialcode": "33",
    },
    {
      "name": {"en": "French Guiana", "ar": "غويانا الفرنسية"},
      "alpha2": "GF",
      "alpha3": "GUF",
      "dialcode": "594",
    },
    {
      "name": {"en": "French Polynesia", "ar": "بولينيزيا الفرنسية"},
      "alpha2": "PF",
      "alpha3": "PYF",
      "dialcode": "689",
    },
    {
      "name": {"en": "French Southern Territories", "ar": "الأقاليم الجنوبية الفرنسية"},
      "alpha2": "TF",
      "alpha3": "ATF",
      "dialcode": "262",
    },

    {
      "name": {"en": "Gabon", "ar": "الغابون"},
      "alpha2": "GA",
      "alpha3": "GAB",
      "dialcode": "241",
    },
    {
      "name": {"en": "Gambia", "ar": "غامبيا"},
      "alpha2": "GM",
      "alpha3": "GMB",
      "dialcode": "220",
    },
    {
      "name": {"en": "Georgia", "ar": "جورجيا"},
      "alpha2": "GE",
      "alpha3": "GEO",
      "dialcode": "995",
    },
    {
      "name": {"en": "Germany", "ar": "ألمانيا"},
      "alpha2": "DE",
      "alpha3": "DEU",
      "dialcode": "49",
    },
    {
      "name": {"en": "Ghana", "ar": "غانا"},
      "alpha2": "GH",
      "alpha3": "GHA",
      "dialcode": "233",
    },
    {
      "name": {"en": "Gibraltar", "ar": "جبل طارق"},
      "alpha2": "GI",
      "alpha3": "GIB",
      "dialcode": "350",
    },
    {
      "name": {"en": "Greece", "ar": "اليونان"},
      "alpha2": "GR",
      "alpha3": "GRC",
      "dialcode": "30",
    },
    {
      "name": {"en": "Greenland", "ar": "غرينلاند"},
      "alpha2": "GL",
      "alpha3": "GRL",
      "dialcode": "299",
    },
    {
      "name": {"en": "Grenada", "ar": "غرينادا"},
      "alpha2": "GD",
      "alpha3": "GRD",
      "dialcode": "1",
    },
    {
      "name": {"en": "Guadeloupe", "ar": "غوادلوب"},
      "alpha2": "GP",
      "alpha3": "GLP",
      "dialcode": "590",
    },
    {
      "name": {"en": "Guam", "ar": "غوام"},
      "alpha2": "GU",
      "alpha3": "GUM",
      "dialcode": "1",
    },
    {
      "name": {"en": "Guatemala", "ar": "غواتيمالا"},
      "alpha2": "GT",
      "alpha3": "GTM",
      "dialcode": "502",
    },
    {
      "name": {"en": "Guernsey", "ar": "غيرنزي"},
      "alpha2": "GG",
      "alpha3": "GGY",
      "dialcode": "44",
    },
    {
      "name": {"en": "Guinea", "ar": "غينيا"},
      "alpha2": "GN",
      "alpha3": "GIN",
      "dialcode": "224",
    },
    {
      "name": {"en": "Guinea-Bissau", "ar": "غينيا بيساو"},
      "alpha2": "GW",
      "alpha3": "GNB",
      "dialcode": "245",
    },
    {
      "name": {"en": "Guyana", "ar": "غيانا"},
      "alpha2": "GY",
      "alpha3": "GUY",
      "dialcode": "592",
    },

    {
      "name": {"en": "Haiti", "ar": "هايتي"},
      "alpha2": "HT",
      "alpha3": "HTI",
      "dialcode": "509",
    },
    {
      "name": {"en": "Heard Island and McDonald Islands", "ar": "جزيرة هيرد وجزر ماكدونالد"},
      "alpha2": "HM",
      "alpha3": "HMD",
      "dialcode": "61",
    },
    {
      "name": {"en": "Holy See", "ar": "الكرسي الرسولي"},
      "alpha2": "VA",
      "alpha3": "VAT",
      "dialcode": "39",
    },
    {
      "name": {"en": "Honduras", "ar": "هندوراس"},
      "alpha2": "HN",
      "alpha3": "HND",
      "dialcode": "504",
    },
    {
      "name": {"en": "Hong Kong", "ar": "هونغ كونغ"},
      "alpha2": "HK",
      "alpha3": "HKG",
      "dialcode": "852",
    },
    {
      "name": {"en": "Hungary", "ar": "هنغاريا"},
      "alpha2": "HU",
      "alpha3": "HUN",
      "dialcode": "36",
    },

    {
      "name": {"en": "Iceland", "ar": "آيسلندا"},
      "alpha2": "IS",
      "alpha3": "ISL",
      "dialcode": "354",
    },
    {
      "name": {"en": "India", "ar": "الهند"},
      "alpha2": "IN",
      "alpha3": "IND",
      "dialcode": "91",
    },
    {
      "name": {"en": "Indonesia", "ar": "إندونيسيا"},
      "alpha2": "ID",
      "alpha3": "IDN",
      "dialcode": "62",
    },
    {
      "name": {"en": "Iran", "ar": "إيران"},
      "alpha2": "IR",
      "alpha3": "IRN",
      "dialcode": "98",
    },
    {
      "name": {"en": "Iraq", "ar": "العراق"},
      "alpha2": "IQ",
      "alpha3": "IRQ",
      "dialcode": "964",
    },
    {
      "name": {"en": "Ireland", "ar": "أيرلندا"},
      "alpha2": "IE",
      "alpha3": "IRL",
      "dialcode": "353",
    },
    {
      "name": {"en": "Isle of Man", "ar": "جزيرة مان"},
      "alpha2": "IM",
      "alpha3": "IMN",
      "dialcode": "44",
    },
    {
      "name": {"en": "Israel", "ar": "إسرائيل"},
      "alpha2": "IL",
      "alpha3": "ISR",
      "dialcode": "972",
    },
    {
      "name": {"en": "Italy", "ar": "إيطاليا"},
      "alpha2": "IT",
      "alpha3": "ITA",
      "dialcode": "39",
    },

    {
      "name": {"en": "Jamaica", "ar": "جامايكا"},
      "alpha2": "JM",
      "alpha3": "JAM",
      "dialcode": "1",
    },
    {
      "name": {"en": "Japan", "ar": "اليابان"},
      "alpha2": "JP",
      "alpha3": "JPN",
      "dialcode": "81",
    },
    {
      "name": {"en": "Jersey", "ar": "جيرسي"},
      "alpha2": "JE",
      "alpha3": "JEY",
      "dialcode": "44",
    },
    {
      "name": {"en": "Jordan", "ar": "الأردن"},
      "alpha2": "JO",
      "alpha3": "JOR",
      "dialcode": "962",
    },

    {
      "name": {"en": "Kazakhstan", "ar": "كازاخستان"},
      "alpha2": "KZ",
      "alpha3": "KAZ",
      "dialcode": "7",
    },
    {
      "name": {"en": "Kenya", "ar": "كينيا"},
      "alpha2": "KE",
      "alpha3": "KEN",
      "dialcode": "254",
    },
    {
      "name": {"en": "Kiribati", "ar": "كيريباتي"},
      "alpha2": "KI",
      "alpha3": "KIR",
      "dialcode": "686",
    },
    {
      "name": {"en": "Korea, Democratic People's Republic of", "ar": "كوريا الشمالية"},
      "alpha2": "KP",
      "alpha3": "PRK",
      "dialcode": "850",
    },
    {
      "name": {"en": "Korea, Republic of", "ar": "كوريا الجنوبية"},
      "alpha2": "KR",
      "alpha3": "KOR",
      "dialcode": "82",
    },
    {
      "name": {"en": "Kuwait", "ar": "الكويت"},
      "alpha2": "KW",
      "alpha3": "KWT",
      "dialcode": "965",
    },
    {
      "name": {"en": "Kyrgyzstan", "ar": "قيرغيزستان"},
      "alpha2": "KG",
      "alpha3": "KGZ",
      "dialcode": "996",
    },

    {
      "name": {"en": "Lao People's Democratic Republic", "ar": "لاوس"},
      "alpha2": "LA",
      "alpha3": "LAO",
      "dialcode": "856",
    },
    {
      "name": {"en": "Latvia", "ar": "لاتفيا"},
      "alpha2": "LV",
      "alpha3": "LVA",
      "dialcode": "371",
    },
    {
      "name": {"en": "Lebanon", "ar": "لبنان"},
      "alpha2": "LB",
      "alpha3": "LBN",
      "dialcode": "961",
    },
    {
      "name": {"en": "Lesotho", "ar": "ليسوتو"},
      "alpha2": "LS",
      "alpha3": "LSO",
      "dialcode": "266",
    },
    {
      "name": {"en": "Liberia", "ar": "ليبيريا"},
      "alpha2": "LR",
      "alpha3": "LBR",
      "dialcode": "231",
    },
    {
      "name": {"en": "Libya", "ar": "ليبيا"},
      "alpha2": "LY",
      "alpha3": "LBY",
      "dialcode": "218",
    },
    {
      "name": {"en": "Liechtenstein", "ar": "ليختنشتاين"},
      "alpha2": "LI",
      "alpha3": "LIE",
      "dialcode": "423",
    },
    {
      "name": {"en": "Lithuania", "ar": "ليتوانيا"},
      "alpha2": "LT",
      "alpha3": "LTU",
      "dialcode": "370",
    },
    {
      "name": {"en": "Luxembourg", "ar": "لوكسمبورغ"},
      "alpha2": "LU",
      "alpha3": "LUX",
      "dialcode": "352",
    },

    {
      "name": {"en": "Macao", "ar": "ماكاو"},
      "alpha2": "MO",
      "alpha3": "MAC",
      "dialcode": "853",
    },
    {
      "name": {"en": "Madagascar", "ar": "مدغشقر"},
      "alpha2": "MG",
      "alpha3": "MDG",
      "dialcode": "261",
    },
    {
      "name": {"en": "Malawi", "ar": "مالاوي"},
      "alpha2": "MW",
      "alpha3": "MWI",
      "dialcode": "265",
    },
    {
      "name": {"en": "Malaysia", "ar": "ماليزيا"},
      "alpha2": "MY",
      "alpha3": "MYS",
      "dialcode": "60",
    },
    {
      "name": {"en": "Maldives", "ar": "المالديف"},
      "alpha2": "MV",
      "alpha3": "MDV",
      "dialcode": "960",
    },
    {
      "name": {"en": "Mali", "ar": "مالي"},
      "alpha2": "ML",
      "alpha3": "MLI",
      "dialcode": "223",
    },
    {
      "name": {"en": "Malta", "ar": "مالطا"},
      "alpha2": "MT",
      "alpha3": "MLT",
      "dialcode": "356",
    },
    {
      "name": {"en": "Marshall Islands", "ar": "جزر مارشال"},
      "alpha2": "MH",
      "alpha3": "MHL",
      "dialcode": "692",
    },
    {
      "name": {"en": "Martinique", "ar": "مارتينيك"},
      "alpha2": "MQ",
      "alpha3": "MTQ",
      "dialcode": "596",
    },
    {
      "name": {"en": "Mauritania", "ar": "موريتانيا"},
      "alpha2": "MR",
      "alpha3": "MRT",
      "dialcode": "222",
    },
    {
      "name": {"en": "Mauritius", "ar": "موريشيوس"},
      "alpha2": "MU",
      "alpha3": "MUS",
      "dialcode": "230",
    },
    {
      "name": {"en": "Mayotte", "ar": "مايوت"},
      "alpha2": "YT",
      "alpha3": "MYT",
      "dialcode": "262",
    },
    {
      "name": {"en": "Mexico", "ar": "المكسيك"},
      "alpha2": "MX",
      "alpha3": "MEX",
      "dialcode": "52",
    },
    {
      "name": {"en": "Micronesia, Federated States of", "ar": "ولايات ميكرونيزيا المتحدة"},
      "alpha2": "FM",
      "alpha3": "FSM",
      "dialcode": "691",
    },
    {
      "name": {"en": "Moldova", "ar": "مولدوفا"},
      "alpha2": "MD",
      "alpha3": "MDA",
      "dialcode": "373",
    },
    {
      "name": {"en": "Monaco", "ar": "موناكو"},
      "alpha2": "MC",
      "alpha3": "MCO",
      "dialcode": "377",
    },
    {
      "name": {"en": "Mongolia", "ar": "منغوليا"},
      "alpha2": "MN",
      "alpha3": "MNG",
      "dialcode": "976",
    },
    {
      "name": {"en": "Montenegro", "ar": "مونتينيغرو"},
      "alpha2": "ME",
      "alpha3": "MNE",
      "dialcode": "382",
    },
    {
      "name": {"en": "Montserrat", "ar": "مونتسرات"},
      "alpha2": "MS",
      "alpha3": "MSR",
      "dialcode": "1",
    },
    {
      "name": {"en": "Morocco", "ar": "المغرب"},
      "alpha2": "MA",
      "alpha3": "MAR",
      "dialcode": "212",
    },
    {
      "name": {"en": "Mozambique", "ar": "موزمبيق"},
      "alpha2": "MZ",
      "alpha3": "MOZ",
      "dialcode": "258",
    },
    {
      "name": {"en": "Myanmar", "ar": "ميانمار"},
      "alpha2": "MM",
      "alpha3": "MMR",
      "dialcode": "95",
    },

    {
      "name": {"en": "Namibia", "ar": "ناميبيا"},
      "alpha2": "NA",
      "alpha3": "NAM",
      "dialcode": "264",
    },
    {
      "name": {"en": "Nauru", "ar": "ناورو"},
      "alpha2": "NR",
      "alpha3": "NRU",
      "dialcode": "674",
    },
    {
      "name": {"en": "Nepal", "ar": "نيبال"},
      "alpha2": "NP",
      "alpha3": "NPL",
      "dialcode": "977",
    },
    {
      "name": {"en": "Netherlands", "ar": "هولندا"},
      "alpha2": "NL",
      "alpha3": "NLD",
      "dialcode": "31",
    },
    {
      "name": {"en": "New Caledonia", "ar": "كاليدونيا الجديدة"},
      "alpha2": "NC",
      "alpha3": "NCL",
      "dialcode": "687",
    },
    {
      "name": {"en": "New Zealand", "ar": "نيوزيلندا"},
      "alpha2": "NZ",
      "alpha3": "NZL",
      "dialcode": "64",
    },
    {
      "name": {"en": "Nicaragua", "ar": "نيكاراغوا"},
      "alpha2": "NI",
      "alpha3": "NIC",
      "dialcode": "505",
    },
    {
      "name": {"en": "Niger", "ar": "النيجر"},
      "alpha2": "NE",
      "alpha3": "NER",
      "dialcode": "227",
    },
    {
      "name": {"en": "Nigeria", "ar": "نيجيريا"},
      "alpha2": "NG",
      "alpha3": "NGA",
      "dialcode": "234",
    },
    {
      "name": {"en": "Niue", "ar": "نيوي"},
      "alpha2": "NU",
      "alpha3": "NIU",
      "dialcode": "683",
    },
    {
      "name": {"en": "Norfolk Island", "ar": "جزيرة نورفولك"},
      "alpha2": "NF",
      "alpha3": "NFK",
      "dialcode": "672",
    },
    {
      "name": {"en": "North Macedonia", "ar": "مقدونيا الشمالية"},
      "alpha2": "MK",
      "alpha3": "MKD",
      "dialcode": "389",
    },
    {
      "name": {"en": "Northern Mariana Islands", "ar": "جزر ماريانا الشمالية"},
      "alpha2": "MP",
      "alpha3": "MNP",
      "dialcode": "1",
    },
    {
      "name": {"en": "Norway", "ar": "النرويج"},
      "alpha2": "NO",
      "alpha3": "NOR",
      "dialcode": "47",
    },

    {
      "name": {"en": "Oman", "ar": "عُمان"},
      "alpha2": "OM",
      "alpha3": "OMN",
      "dialcode": "968",
    },

    {
      "name": {"en": "Pakistan", "ar": "باكستان"},
      "alpha2": "PK",
      "alpha3": "PAK",
      "dialcode": "92",
    },
    {
      "name": {"en": "Palau", "ar": "بالاو"},
      "alpha2": "PW",
      "alpha3": "PLW",
      "dialcode": "680",
    },
    {
      "name": {"en": "Palestine, State of", "ar": "فلسطين"},
      "alpha2": "PS",
      "alpha3": "PSE",
      "dialcode": "970",
    },
    {
      "name": {"en": "Panama", "ar": "بنما"},
      "alpha2": "PA",
      "alpha3": "PAN",
      "dialcode": "507",
    },
    {
      "name": {"en": "Papua New Guinea", "ar": "بابوا غينيا الجديدة"},
      "alpha2": "PG",
      "alpha3": "PNG",
      "dialcode": "675",
    },
    {
      "name": {"en": "Paraguay", "ar": "باراغواي"},
      "alpha2": "PY",
      "alpha3": "PRY",
      "dialcode": "595",
    },
    {
      "name": {"en": "Peru", "ar": "بيرو"},
      "alpha2": "PE",
      "alpha3": "PER",
      "dialcode": "51",
    },
    {
      "name": {"en": "Philippines", "ar": "الفلبين"},
      "alpha2": "PH",
      "alpha3": "PHL",
      "dialcode": "63",
    },
    {
      "name": {"en": "Pitcairn", "ar": "بيتكيرن"},
      "alpha2": "PN",
      "alpha3": "PCN",
      "dialcode": "64",
    },
    {
      "name": {"en": "Poland", "ar": "بولندا"},
      "alpha2": "PL",
      "alpha3": "POL",
      "dialcode": "48",
    },
    {
      "name": {"en": "Portugal", "ar": "البرتغال"},
      "alpha2": "PT",
      "alpha3": "PRT",
      "dialcode": "351",
    },
    {
      "name": {"en": "Puerto Rico", "ar": "بورتو ريكو"},
      "alpha2": "PR",
      "alpha3": "PRI",
      "dialcode": "1",
    },

    {
      "name": {"en": "Qatar", "ar": "قطر"},
      "alpha2": "QA",
      "alpha3": "QAT",
      "dialcode": "974",
    },

    {
      "name": {"en": "Reunion", "ar": "ريونيون"},
      "alpha2": "RE",
      "alpha3": "REU",
      "dialcode": "262",
    },
    {
      "name": {"en": "Romania", "ar": "رومانيا"},
      "alpha2": "RO",
      "alpha3": "ROU",
      "dialcode": "40",
    },
    {
      "name": {"en": "Russian Federation", "ar": "روسيا"},
      "alpha2": "RU",
      "alpha3": "RUS",
      "dialcode": "7",
    },
    {
      "name": {"en": "Rwanda", "ar": "رواندا"},
      "alpha2": "RW",
      "alpha3": "RWA",
      "dialcode": "250",
    },

    {
      "name": {"en": "Saint Barthelemy", "ar": "سانت بارتيليمي"},
      "alpha2": "BL",
      "alpha3": "BLM",
      "dialcode": "590",
    },
    {
      "name": {"en": "Saint Helena, Ascension and Tristan da Cunha", "ar": "سانت هيلينا وأسنسيون وتريستان دا كونها"},
      "alpha2": "SH",
      "alpha3": "SHN",
      "dialcode": "290",
    },
    {
      "name": {"en": "Saint Kitts and Nevis", "ar": "سانت كيتس ونيفيس"},
      "alpha2": "KN",
      "alpha3": "KNA",
      "dialcode": "1",
    },
    {
      "name": {"en": "Saint Lucia", "ar": "سانت لوسيا"},
      "alpha2": "LC",
      "alpha3": "LCA",
      "dialcode": "1",
    },
    {
      "name": {"en": "Saint Martin (French part)", "ar": "سانت مارتن (الجزء الفرنسي)"},
      "alpha2": "MF",
      "alpha3": "MAF",
      "dialcode": "590",
    },
    {
      "name": {"en": "Saint Pierre and Miquelon", "ar": "سان بيار وميكلون"},
      "alpha2": "PM",
      "alpha3": "SPM",
      "dialcode": "508",
    },
    {
      "name": {"en": "Saint Vincent and the Grenadines", "ar": "سانت فينسنت والغرينادين"},
      "alpha2": "VC",
      "alpha3": "VCT",
      "dialcode": "1",
    },
    {
      "name": {"en": "Samoa", "ar": "ساموا"},
      "alpha2": "WS",
      "alpha3": "WSM",
      "dialcode": "685",
    },
    {
      "name": {"en": "San Marino", "ar": "سان مارينو"},
      "alpha2": "SM",
      "alpha3": "SMR",
      "dialcode": "378",
    },
    {
      "name": {"en": "Sao Tome and Principe", "ar": "ساو تومي وبرينسيب"},
      "alpha2": "ST",
      "alpha3": "STP",
      "dialcode": "239",
    },
    {
      "name": {"en": "Saudi Arabia", "ar": "المملكة العربية السعودية"},
      "alpha2": "SA",
      "alpha3": "SAU",
      "dialcode": "966",
    },
    {
      "name": {"en": "Senegal", "ar": "السنغال"},
      "alpha2": "SN",
      "alpha3": "SEN",
      "dialcode": "221",
    },
    {
      "name": {"en": "Serbia", "ar": "صربيا"},
      "alpha2": "RS",
      "alpha3": "SRB",
      "dialcode": "381",
    },
    {
      "name": {"en": "Seychelles", "ar": "سيشل"},
      "alpha2": "SC",
      "alpha3": "SYC",
      "dialcode": "248",
    },
    {
      "name": {"en": "Sierra Leone", "ar": "سيراليون"},
      "alpha2": "SL",
      "alpha3": "SLE",
      "dialcode": "232",
    },
    {
      "name": {"en": "Singapore", "ar": "سنغافورة"},
      "alpha2": "SG",
      "alpha3": "SGP",
      "dialcode": "65",
    },
    {
      "name": {"en": "Sint Maarten (Dutch part)", "ar": "سانت مارتن (الجزء الهولندي)"},
      "alpha2": "SX",
      "alpha3": "SXM",
      "dialcode": "1",
    },
    {
      "name": {"en": "Slovakia", "ar": "سلوفاكيا"},
      "alpha2": "SK",
      "alpha3": "SVK",
      "dialcode": "421",
    },
    {
      "name": {"en": "Slovenia", "ar": "سلوفينيا"},
      "alpha2": "SI",
      "alpha3": "SVN",
      "dialcode": "386",
    },
    {
      "name": {"en": "Solomon Islands", "ar": "جزر سليمان"},
      "alpha2": "SB",
      "alpha3": "SLB",
      "dialcode": "677",
    },
    {
      "name": {"en": "Somalia", "ar": "الصومال"},
      "alpha2": "SO",
      "alpha3": "SOM",
      "dialcode": "252",
    },
    {
      "name": {"en": "South Africa", "ar": "جنوب أفريقيا"},
      "alpha2": "ZA",
      "alpha3": "ZAF",
      "dialcode": "27",
    },
    {
      "name": {"en": "South Georgia and the South Sandwich Islands", "ar": "جورجيا الجنوبية وجزر ساندويتش الجنوبية"},
      "alpha2": "GS",
      "alpha3": "SGS",
      "dialcode": "500",
    },
    {
      "name": {"en": "South Sudan", "ar": "جنوب السودان"},
      "alpha2": "SS",
      "alpha3": "SSD",
      "dialcode": "211",
    },
    {
      "name": {"en": "Spain", "ar": "إسبانيا"},
      "alpha2": "ES",
      "alpha3": "ESP",
      "dialcode": "34",
    },
    {
      "name": {"en": "Sri Lanka", "ar": "سريلانكا"},
      "alpha2": "LK",
      "alpha3": "LKA",
      "dialcode": "94",
    },
    {
      "name": {"en": "Sudan", "ar": "السودان"},
      "alpha2": "SD",
      "alpha3": "SDN",
      "dialcode": "249",
    },
    {
      "name": {"en": "Suriname", "ar": "سورينام"},
      "alpha2": "SR",
      "alpha3": "SUR",
      "dialcode": "597",
    },
    {
      "name": {"en": "Svalbard and Jan Mayen", "ar": "سفالبارد وجان ماين"},
      "alpha2": "SJ",
      "alpha3": "SJM",
      "dialcode": "47",
    },
    {
      "name": {"en": "Sweden", "ar": "السويد"},
      "alpha2": "SE",
      "alpha3": "SWE",
      "dialcode": "46",
    },
    {
      "name": {"en": "Switzerland", "ar": "سويسرا"},
      "alpha2": "CH",
      "alpha3": "CHE",
      "dialcode": "41",
    },
    {
      "name": {"en": "Syrian Arab Republic", "ar": "سوريا"},
      "alpha2": "SY",
      "alpha3": "SYR",
      "dialcode": "963",
    },

    {
      "name": {"en": "Taiwan", "ar": "تايوان"},
      "alpha2": "TW",
      "alpha3": "TWN",
      "dialcode": "886",
    },
    {
      "name": {"en": "Tajikistan", "ar": "طاجيكستان"},
      "alpha2": "TJ",
      "alpha3": "TJK",
      "dialcode": "992",
    },
    {
      "name": {"en": "Tanzania, United Republic of", "ar": "تنزانيا"},
      "alpha2": "TZ",
      "alpha3": "TZA",
      "dialcode": "255",
    },
    {
      "name": {"en": "Thailand", "ar": "تايلاند"},
      "alpha2": "TH",
      "alpha3": "THA",
      "dialcode": "66",
    },
    {
      "name": {"en": "Timor-Leste", "ar": "تيمور الشرقية"},
      "alpha2": "TL",
      "alpha3": "TLS",
      "dialcode": "670",
    },
    {
      "name": {"en": "Togo", "ar": "توغو"},
      "alpha2": "TG",
      "alpha3": "TGO",
      "dialcode": "228",
    },
    {
      "name": {"en": "Tokelau", "ar": "توكيلو"},
      "alpha2": "TK",
      "alpha3": "TKL",
      "dialcode": "690",
    },
    {
      "name": {"en": "Tonga", "ar": "تونغا"},
      "alpha2": "TO",
      "alpha3": "TON",
      "dialcode": "676",
    },
    {
      "name": {"en": "Trinidad and Tobago", "ar": "ترينيداد وتوباغو"},
      "alpha2": "TT",
      "alpha3": "TTO",
      "dialcode": "1",
    },
    {
      "name": {"en": "Tunisia", "ar": "تونس"},
      "alpha2": "TN",
      "alpha3": "TUN",
      "dialcode": "216",
    },
    {
      "name": {"en": "Turkey", "ar": "تركيا"},
      "alpha2": "TR",
      "alpha3": "TUR",
      "dialcode": "90",
    },
    {
      "name": {"en": "Turkmenistan", "ar": "تركمانستان"},
      "alpha2": "TM",
      "alpha3": "TKM",
      "dialcode": "993",
    },
    {
      "name": {"en": "Turks and Caicos Islands", "ar": "جزر تركس وكايكوس"},
      "alpha2": "TC",
      "alpha3": "TCA",
      "dialcode": "1",
    },
    {
      "name": {"en": "Tuvalu", "ar": "توفالو"},
      "alpha2": "TV",
      "alpha3": "TUV",
      "dialcode": "688",
    },

    {
      "name": {"en": "Uganda", "ar": "أوغندا"},
      "alpha2": "UG",
      "alpha3": "UGA",
      "dialcode": "256",
    },
    {
      "name": {"en": "Ukraine", "ar": "أوكرانيا"},
      "alpha2": "UA",
      "alpha3": "UKR",
      "dialcode": "380",
    },
    {
      "name": {"en": "United Arab Emirates", "ar": "الإمارات العربية المتحدة"},
      "alpha2": "AE",
      "alpha3": "ARE",
      "dialcode": "971",
    },
    {
      "name": {"en": "United Kingdom", "ar": "المملكة المتحدة"},
      "alpha2": "GB",
      "alpha3": "GBR",
      "dialcode": "44",
    },
    {
      "name": {"en": "United States of America", "ar": "الولايات المتحدة الأمريكية"},
      "alpha2": "US",
      "alpha3": "USA",
      "dialcode": "1",
    },
    {
      "name": {"en": "United States Minor Outlying Islands", "ar": "الجزر النائية الصغيرة للولايات المتحدة"},
      "alpha2": "UM",
      "alpha3": "UMI",
      "dialcode": "1",
    },
    {
      "name": {"en": "Uruguay", "ar": "أوروغواي"},
      "alpha2": "UY",
      "alpha3": "URY",
      "dialcode": "598",
    },
    {
      "name": {"en": "Uzbekistan", "ar": "أوزبكستان"},
      "alpha2": "UZ",
      "alpha3": "UZB",
      "dialcode": "998",
    },

    {
      "name": {"en": "Vanuatu", "ar": "فانواتو"},
      "alpha2": "VU",
      "alpha3": "VUT",
      "dialcode": "678",
    },
    {
      "name": {"en": "Venezuela, Bolivarian Republic of", "ar": "فنزويلا"},
      "alpha2": "VE",
      "alpha3": "VEN",
      "dialcode": "58",
    },
    {
      "name": {"en": "Viet Nam", "ar": "فيتنام"},
      "alpha2": "VN",
      "alpha3": "VNM",
      "dialcode": "84",
    },
    {
      "name": {"en": "Virgin Islands, British", "ar": "جزر العذراء البريطانية"},
      "alpha2": "VG",
      "alpha3": "VGB",
      "dialcode": "1",
    },
    {
      "name": {"en": "Virgin Islands, U.S.", "ar": "جزر العذراء الأمريكية"},
      "alpha2": "VI",
      "alpha3": "VIR",
      "dialcode": "1",
    },

    {
      "name": {"en": "Wallis and Futuna", "ar": "واليس وفوتونا"},
      "alpha2": "WF",
      "alpha3": "WLF",
      "dialcode": "681",
    },
    {
      "name": {"en": "Western Sahara", "ar": "الصحراء الغربية"},
      "alpha2": "EH",
      "alpha3": "ESH",
      "dialcode": "212",
    },

    {
      "name": {"en": "Yemen", "ar": "اليمن"},
      "alpha2": "YE",
      "alpha3": "YEM",
      "dialcode": "967",
    },

    {
      "name": {"en": "Zambia", "ar": "زامبيا"},
      "alpha2": "ZM",
      "alpha3": "ZMB",
      "dialcode": "260",
    },
    {
      "name": {"en": "Zimbabwe", "ar": "زيمبابوي"},
      "alpha2": "ZW",
      "alpha3": "ZWE",
      "dialcode": "263",
    },
  ];

  // search fun
  Future<List<Map<String, dynamic>>> search(String query) async {
    // await Future.delayed(const Duration(milliseconds: 2000)); // تأخير بسيط
    final q = query.trim().toLowerCase();
    // if (q.isEmpty) return []; // البحث بالرمز او الاسم او الوصف
    final res = _data.where((element) {
      final e = CountryModel.fromJson(element);
      return e.name['en'].toLowerCase().contains(q) || e.name['ar'].toLowerCase().contains(q) || e.dialcode.toLowerCase().contains(q);
    }).toList();
    // حد اقصى (لانقاص الحمل)

    if (AppVars.lang == 'ar') {
      // sort by ar
      res.sort((a, b) {
        final aName = a['name']['ar'] ?? "";
        final bName = b['name']['ar'] ?? "";
        return aName.compareTo(bName);
      });
    }

    return res;
  }

  // =========================
  //  البحث بالـ alpha3 / alpha2
  // =========================
  static CountryModel? searchByAlpha(String code) {
    final upper = code.toUpperCase();

    // نحاول نطابق أولاً مع alpha3، ولو حاب نوسعها ممكن نطابق alpha2 أيضًا
    try {
      final Map<String, dynamic> json = _data.firstWhere(
        (e) => (e['alpha3'] as String).toUpperCase() == upper || (e['alpha2'] as String).toUpperCase() == upper,
      );

      return CountryModel.fromJson(json);
    } catch (_) {
      // لو ما لقينا شيء نرجع null
      return null;
    }
  }

  // =========================
  //  البحث بالـ dialcode
  // =========================
  static CountryModel? searchByDialcode(String dialcode) {
    final upper = dialcode.replaceAll("+", "").toUpperCase();

    try {
      final Map<String, dynamic> json = _data.firstWhere(
        (e) => (e['dialcode'] as String).toUpperCase() == upper,
      );

      return CountryModel.fromJson(json);
    } catch (_) {
      return null;
    }
  } 


}
