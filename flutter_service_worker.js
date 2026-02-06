'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "4d5788db241fdf047b22faebdaf407d2",
"icons/Icon-maskable-512.png": "4d5788db241fdf047b22faebdaf407d2",
"icons/Icon-192.png": "4e411c5e7b0bf10608f695f2d9d71ef1",
"icons/Icon-maskable-192.png": "4e411c5e7b0bf10608f695f2d9d71ef1",
"manifest.json": "5b8324a11ebef662bc4b93b1bb5a7a00",
"index.html": "f471ba83a8b6f6e7c9ba30e680b68cfc",
"/": "f471ba83a8b6f6e7c9ba30e680b68cfc",
"splash/img/light-4x.png": "98a9ae5151cb99b01e22b3c5d4299ece",
"splash/img/branding-1x.png": "4e61d9497beddeb021495245246a7d1b",
"splash/img/dark-4x.png": "98a9ae5151cb99b01e22b3c5d4299ece",
"splash/img/branding-dark-1x.png": "4e61d9497beddeb021495245246a7d1b",
"splash/img/branding-4x.png": "65185cdbbcb3bc03b7a1d1afdf659267",
"splash/img/dark-3x.png": "53502e560c89385c4cdd6d6f6bf8df61",
"splash/img/branding-dark-2x.png": "20435486a0f58762b5d0a065ea09e5aa",
"splash/img/dark-1x.png": "30e1fd497222f2970a9849e2bed85862",
"splash/img/branding-dark-4x.png": "65185cdbbcb3bc03b7a1d1afdf659267",
"splash/img/dark-2x.png": "ba68ba5948d40e2422e19213a10233a7",
"splash/img/branding-3x.png": "7f062f3ec0ae7218f2a4f6525ff60cd9",
"splash/img/light-1x.png": "30e1fd497222f2970a9849e2bed85862",
"splash/img/branding-dark-3x.png": "7f062f3ec0ae7218f2a4f6525ff60cd9",
"splash/img/branding-2x.png": "20435486a0f58762b5d0a065ea09e5aa",
"splash/img/light-3x.png": "53502e560c89385c4cdd6d6f6bf8df61",
"splash/img/light-2x.png": "ba68ba5948d40e2422e19213a10233a7",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "fb5c2a44f2d574bc8ca8301a554fdf11",
"assets/assets/tmp/2.jpg": "6bfc41abda89ca4d77ea9427bdc96a46",
"assets/assets/tmp/1.jpg": "b4710b6a0602ddec5099851e0b30a74f",
"assets/assets/images/yellow_logo.png": "f95c95a02209052cef1f74359c55dd4b",
"assets/assets/images/icons/home.svg": "637f1caff5661650ef4c1959566a1fd0",
"assets/assets/images/icons/airplane_take_off_fill.svg": "f05d3f942c2d21a53829559505a23323",
"assets/assets/images/icons/earth_fill.svg": "df476771fc17a1a9974b4a42175d5fee",
"assets/assets/images/icons/collapse.svg": "f897f39d4f225f50cc99359cd77b2f12",
"assets/assets/images/icons/playlist_fill.svg": "9a2e7073ec37bb7353be56e6cd9433bc",
"assets/assets/images/icons/airplane_take_off.svg": "ddcc66d5e541ca17481955f925bb2667",
"assets/assets/images/icons/bell_fill.svg": "afaa2ad674e4f6c55fb502e7fe6d1606",
"assets/assets/images/icons/search_fill.svg": "752c538e670cc2425351eb1511a4ac6f",
"assets/assets/images/icons/logo_3.svg": "efb3179524d2c814990d613e44b4f0ff",
"assets/assets/images/icons/splash_ar.svg": "600732d01082cd39083225e5828ec08c",
"assets/assets/images/icons/airplane_landing.svg": "e5ac32cf91d6484f4d5e844639f9d1ca",
"assets/assets/images/icons/airport.svg": "eb142e8b20a41e857b584406cc96654a",
"assets/assets/images/icons/bell.svg": "a3348c2f96fc278d7c8a7e8ee39141f6",
"assets/assets/images/icons/facebook.svg": "243d1ec11cca436669cf2e0a0dad0584",
"assets/assets/images/icons/splash.svg": "7d723aa44a0f52be78c4fe49dcdcf2a5",
"assets/assets/images/icons/logo_black.svg": "283f4e4376aa0c790cefae3073d665dd",
"assets/assets/images/icons/logo.svg": "935d2eaed7a2a1863f9430acea8e62d5",
"assets/assets/images/icons/download_fill.svg": "8ca23178eee997c20c16b5aa52ab9424",
"assets/assets/images/icons/airport_fill.svg": "2dacb28109ca6f2d71d9ec1c9b296960",
"assets/assets/images/icons/earth.svg": "dbdad3fe39d18d16a3a9a563fbc00875",
"assets/assets/images/icons/card_id.svg": "e8d86bb9053d90921efd4591b1f29b88",
"assets/assets/images/icons/expand.svg": "7e1075a40cfa2c0cd02c2abcb8d5e69d",
"assets/assets/images/icons/settings.svg": "22b79a76b48c69998785b8cc305c7dd4",
"assets/assets/images/icons/logo_2.svg": "d926b16d052a9f1a838840a72bfd7b35",
"assets/assets/images/icons/telegram_fill.svg": "84b398663a25e209b5d4a0a8b4ac764c",
"assets/assets/images/icons/telegram.svg": "ae5446b9a5c334f1f41d0b70b50f3c9c",
"assets/assets/images/icons/search.svg": "2b41daada62c4815c716498687d4755f",
"assets/assets/images/icons/phone.svg": "dd86339100d47f19264a0e79a2de41c3",
"assets/assets/images/icons/home_fill.svg": "ecb1d64d6b19a1075f37a18b3c5b3a50",
"assets/assets/images/icons/airplane_landing_fill.svg": "0e484d7ea08ac50cfce62285f227db18",
"assets/assets/images/icons/gmail.svg": "93672286729bae70eab61d25aa014cab",
"assets/assets/images/icons/favorite_fill.svg": "54cebdf9d2190ec005f5876a6cb44fd5",
"assets/assets/images/icons/favorite.svg": "2bca8f9956481946afefe1b95c4f6a45",
"assets/assets/images/icons/google.svg": "5774a55ce9f8b85beb1d60720fdcd312",
"assets/assets/images/icons/brand.svg": "2e77c7c0efba685535298afa9c9d605d",
"assets/assets/images/icons/settings_fill.svg": "793192cc9b61580aee13652a61992c3f",
"assets/assets/images/icons/phone_fill.svg": "857273b03604e4c6b8a5b718cafae8e9",
"assets/assets/images/plane_around_earth.gif": "286778459223d9c64910e2f8842138b3",
"assets/assets/images/plane_around_earth.json": "a62867aeb4df99c332abe536b5965e07",
"assets/assets/images/splash.png": "daa4ea0c7c1e00d83ea9e405dc530052",
"assets/assets/images/flags/pk.svg": "85c810a1e00ecd4abd72535308d492af",
"assets/assets/images/flags/mn.svg": "e6640c18ac6f349b6400f596c42d6c6b",
"assets/assets/images/flags/lb.svg": "8ac6140b65128cd68fc10e8c9c072ded",
"assets/assets/images/flags/mq.svg": "1a77ee1805087d17c9b4bf21ad372a1b",
"assets/assets/images/flags/th.svg": "bcc03a3cd1a367274a2444aff71c0a68",
"assets/assets/images/flags/mg.svg": "7a54f12dc753217b1c0aaa7bf685f9fe",
"assets/assets/images/flags/mp.svg": "7dfee37acc6938a50e59d0419c4c17eb",
"assets/assets/images/flags/mu.svg": "46514c8008dc3564e49eaa790f28e255",
"assets/assets/images/flags/cp.svg": "8621f432232c7d0fe0a2660d04ed684c",
"assets/assets/images/flags/mc.svg": "acbf04f75fb877d1c2aef0f553c8d629",
"assets/assets/images/flags/je.svg": "002cf78b1f53c47a4c353292af6b4709",
"assets/assets/images/flags/eg.svg": "d7bb81afd5a3c3bb54dd3477f4777315",
"assets/assets/images/flags/sh.svg": "d264f1845336248617b786cb0e07d5aa",
"assets/assets/images/flags/st.svg": "7435c1629c29775dd2c9a81bb858a9e2",
"assets/assets/images/flags/ye.svg": "b45153c68c2d4ccaea6553357ca603c7",
"assets/assets/images/flags/dk.svg": "33bba71c12896b2df18901d98cf2b62c",
"assets/assets/images/flags/cl.svg": "e9b67a59841886e9b55fff67f1260909",
"assets/assets/images/flags/ml.svg": "1dd7a9ccbcd179a5a3fba550970ad75c",
"assets/assets/images/flags/arab.svg": "e793cfb17dafdb4d3e2c9dacc4a37142",
"assets/assets/images/flags/kg.svg": "4dcff8d78decbebe37a365bd423475be",
"assets/assets/images/flags/ar.svg": "1d7e00ff9865ea89b08d028b42baa503",
"assets/assets/images/flags/jo.svg": "8523785fa25192569f1fad7b5b4d2d57",
"assets/assets/images/flags/im.svg": "4843ed7a5eb0ba3f583bf434c8ef6ac9",
"assets/assets/images/flags/es.svg": "e3ee044c3d0dd611613075a24e7639ae",
"assets/assets/images/flags/cr.svg": "8f9e3dcc8f47407f57dd2eca6721d415",
"assets/assets/images/flags/asean.svg": "ee4bca89d7823f3752da067d45208b78",
"assets/assets/images/flags/tg.svg": "0d34bdaacc8417e527320642b4c1c691",
"assets/assets/images/flags/kr.svg": "2a183310b78d3d4fe57f88abcc491fcd",
"assets/assets/images/flags/la.svg": "038868d86f685b19f34bad6d7169c4df",
"assets/assets/images/flags/ve.svg": "5a76b2497118fb0435b2f5845717b9b0",
"assets/assets/images/flags/id.svg": "f5aa812145ee85fa05e5f2b62bdf030e",
"assets/assets/images/flags/wf.svg": "a3008b9d6f65356b95cf8f465b3eddc4",
"assets/assets/images/flags/cu.svg": "1f1e7f63d2df2bece82506bfe888e15d",
"assets/assets/images/flags/mh.svg": "b4e4c149e97d696789949136387f2840",
"assets/assets/images/flags/bo.svg": "710e9645532beaef5465fcf9d2c641d5",
"assets/assets/images/flags/tl.svg": "ed0c55931d9e4acaa3232a6fd90ecdd1",
"assets/assets/images/flags/jp.svg": "22e3b3a4abbb24945620817fd27ed7db",
"assets/assets/images/flags/gy.svg": "6cd4096e5ba2f34748e7938f6f1b075c",
"assets/assets/images/flags/mm.svg": "c22f7c51912ae5c86cc9b9a61def3be9",
"assets/assets/images/flags/gt.svg": "8e3df51f8ddc895d72a5450e7ac0e0a7",
"assets/assets/images/flags/fo.svg": "3f2be9ccbe5a3d0cef9da5c7044bba60",
"assets/assets/images/flags/ae.svg": "956b4f4b79831a21d5fe73b02fc746a2",
"assets/assets/images/flags/si.svg": "f6c5b9027d884d9d96ad22cc65a83a49",
"assets/assets/images/flags/cw.svg": "fa095496b50c4e4daca119cc11338051",
"assets/assets/images/flags/ao.svg": "a4970184e6f40587cf55192fc1f8c1a8",
"assets/assets/images/flags/ci.svg": "71b3f6b842edddfcbd0c964f6c45d7f1",
"assets/assets/images/flags/am.svg": "39c5d05ed3ce2660746bf8ea995af707",
"assets/assets/images/flags/gw.svg": "9e32ba13d46c36531bfc3511d54e521d",
"assets/assets/images/flags/vn.svg": "076d59568fc7a8ab59bc51ee7a39f956",
"assets/assets/images/flags/rw.svg": "32931738c195dc60323ab760f3b3b720",
"assets/assets/images/flags/tt.svg": "12c225a0602ef42490ab814b5ade9274",
"assets/assets/images/flags/sz.svg": "6b46b244d5da5de47b9710d86d2a1d11",
"assets/assets/images/flags/ag.svg": "2b9abaa53a66d1296f5a91ef98ad4ab9",
"assets/assets/images/flags/bs.svg": "9fc1437aae317caf48c9cf57506978ab",
"assets/assets/images/flags/ee.svg": "cb347ee463040a1f730374ff29beb730",
"assets/assets/images/flags/bf.svg": "4755cc0eeffc214e72703111d483703f",
"assets/assets/images/flags/to.svg": "cccdba4c3dfd080aeda7302c23588c7a",
"assets/assets/images/flags/fr.svg": "bf4cae9b80cd98ef576670139bdb167d",
"assets/assets/images/flags/sc.svg": "ab4767bc4088728a6841e7e578f6c7a8",
"assets/assets/images/flags/bq.svg": "63fa6eef889e055a5af0496cf8c8adfe",
"assets/assets/images/flags/do.svg": "297d8d321e21a475f703e2b050ef41b4",
"assets/assets/images/flags/rs.svg": "364865911c6e1ae8992ccd031eb5a7af",
"assets/assets/images/flags/so.svg": "3f60af6c70394d4b58d19f9873151a82",
"assets/assets/images/flags/bt.svg": "db2d8ae2c0817bd2c05689bdcd47fda2",
"assets/assets/images/flags/cc.svg": "4c518275a559ec514d2fdb4ac30e3f1f",
"assets/assets/images/flags/ru.svg": "8b2aa18f6e17aa2982e800c462781698",
"assets/assets/images/flags/py.svg": "7253dbde29c1216a996c9ea9853df2c0",
"assets/assets/images/flags/be.svg": "0d72048ba90512a794c881b1b26fb5e0",
"assets/assets/images/flags/gl.svg": "c6090a99ab0402116f4ab70719eb034a",
"assets/assets/images/flags/fm.svg": "97c5bb37d4fd9285c80c3809c9dedde6",
"assets/assets/images/flags/vu.svg": "14e6f23d4af642dadbed0ff480a8128b",
"assets/assets/images/flags/ma.svg": "a2e6a76e5f38058fd28b706beeb6a1b7",
"assets/assets/images/flags/sx.svg": "dc1d74ce5dbf399e5692d0e9bc7b3d18",
"assets/assets/images/flags/cx.svg": "fa24dc0815520db2d8ad8aafa8a98fe1",
"assets/assets/images/flags/sr.svg": "07e91c157e4b9e240d9b004da3529f08",
"assets/assets/images/flags/se.svg": "79da0f189e8fb82d6e148a77b5690e14",
"assets/assets/images/flags/fk.svg": "4a7ecaccb62942ddb363240698d44dbb",
"assets/assets/images/flags/by.svg": "eeab32ea4ba4bb9ed518ef5e26f0e409",
"assets/assets/images/flags/cg.svg": "9a9941443b3fb1958cee56c5a5c41915",
"assets/assets/images/flags/au.svg": "26b17d670b64aafb25fdaecf3b74e934",
"assets/assets/images/flags/mw.svg": "59ec0e8339665d309116b12d39b9baf1",
"assets/assets/images/flags/cf.svg": "99c6b22d8c18aaab72d05274aad88b9a",
"assets/assets/images/flags/pa.svg": "b6f6c58d78ffe67a54f46163232a8e1e",
"assets/assets/images/flags/bb.svg": "26b1f97e2fd0732b7073d7d3d0331aec",
"assets/assets/images/flags/ng.svg": "9eea84efdc0eb2553b9d3502feac044d",
"assets/assets/images/flags/hu.svg": "966f49336f7466efd6f8dbe19f9fc300",
"assets/assets/images/flags/dj.svg": "a77a7f76b479379c259d5e7f38462cd8",
"assets/assets/images/flags/bn.svg": "1c077085a0ab3916ed5f6e73cfc3724d",
"assets/assets/images/flags/hr.svg": "5314bd175ad41aa5c42b8e41e2af7173",
"assets/assets/images/flags/gh.svg": "a64592b4513a2648c11e6e00d1a1d158",
"assets/assets/images/flags/br.svg": "5fc02ad513bf2a2e04713f6a61daaa41",
"assets/assets/images/flags/tk.svg": "c868bd901f17042f63d97266d2f3055f",
"assets/assets/images/flags/gp.svg": "0973d50eb05aff4255d8e499c45c5ed3",
"assets/assets/images/flags/mf.svg": "308936fb3b99c9f642a531cb98876560",
"assets/assets/images/flags/eh.svg": "9429f8630905a34bf96fa1631dfeb847",
"assets/assets/images/flags/ec.svg": "670e1025534132cdcef6dae7930de81a",
"assets/assets/images/flags/pm.svg": "6999a852eb77bd0a5218ccc09be1c215",
"assets/assets/images/flags/vg.svg": "21d0dec21e188f57a9d0f8e1ec0e4029",
"assets/assets/images/flags/iq.svg": "6cd7b49b35b15d74cdcfce844064d132",
"assets/assets/images/flags/aw.svg": "76fe9474d96a84a4f984697f84812eb2",
"assets/assets/images/flags/pf.svg": "099cb9160e10e223f4aad5aea9ee83b4",
"assets/assets/images/flags/jm.svg": "4370e5279f135a52435cb1435fb51d25",
"assets/assets/images/flags/hk.svg": "406844d22310061e566f2e82f743e014",
"assets/assets/images/flags/ht.svg": "a236a3c5e1a7a5de7aec84e97442e609",
"assets/assets/images/flags/ch.svg": "269ddab4d19b9c60a6459c09ddfd48c9",
"assets/assets/images/flags/eu.svg": "2eba7797bc8552cb2b4cc1e200657bff",
"assets/assets/images/flags/nl.svg": "8c9bb5ae9234eb56f35372409f204c95",
"assets/assets/images/flags/bm.svg": "32ab7b906816f99ea0318484ce768230",
"assets/assets/images/flags/ax.svg": "62ea912b0e8803281b06875985d1c656",
"assets/assets/images/flags/es-ga.svg": "ef99a555b2717706ad773de500a9e244",
"assets/assets/images/flags/mx.svg": "281bf244efba667fefc3479788b0f01f",
"assets/assets/images/flags/xk.svg": "a8e4f500a18c4ec5e8dec2540dbe2c55",
"assets/assets/images/flags/eac.svg": "16f19f09d1dfc195df7b1ce7f986d44b",
"assets/assets/images/flags/kh.svg": "1732afe3e1a37bb2f1992690653b2337",
"assets/assets/images/flags/ga.svg": "f64e29ed68d2165d3620d53978933bb6",
"assets/assets/images/flags/gb-wls.svg": "a9f3880f26c469eb5031cce59fef8cc4",
"assets/assets/images/flags/gd.svg": "9c4ac524465c01439a799491819b6336",
"assets/assets/images/flags/fi.svg": "0e5ef3f583daa1a415330bed83ce8c4a",
"assets/assets/images/flags/ai.svg": "17bc6c4d31ff1956f00a5e27474f4a49",
"assets/assets/images/flags/gq.svg": "b6c53ed0903ff6ab665b7dd6dce6f627",
"assets/assets/images/flags/pn.svg": "a7dcc7fff87666cff39c724f73ec54e4",
"assets/assets/images/flags/tr.svg": "a00c7dfb9e8aad298b6bc1ce656dd9ef",
"assets/assets/images/flags/sn.svg": "091e42c6f8d95a1740ff343dcec62c7a",
"assets/assets/images/flags/pw.svg": "98481f768696b21b1cefe1c2a3c83fb7",
"assets/assets/images/flags/ie.svg": "1c12635a2932de4b8036779933a84d97",
"assets/assets/images/flags/vc.svg": "4bde18df266caa82f34338109dc9dd95",
"assets/assets/images/flags/kz.svg": "b048e9ddace203518e64f4999bf9df8e",
"assets/assets/images/flags/gf.svg": "333751e55034c41c3e59a55e47c2edb1",
"assets/assets/images/flags/gi.svg": "5a955a33f6273d071c177fc51a7a3ba3",
"assets/assets/images/flags/ba.svg": "010ce0adb7de5e927813a3e1ad0eb39c",
"assets/assets/images/flags/ic.svg": "bdc9877c5d42dfa5adcfb488fcbf153c",
"assets/assets/images/flags/gb-nir.svg": "d7bd7dfda1671592433372c74ac7adf3",
"assets/assets/images/flags/lv.svg": "0b4e6e1a21a939a1a474341da5aee4ca",
"assets/assets/images/flags/pt.svg": "f0f95b343296722c38dc0857f3a4c73d",
"assets/assets/images/flags/tm.svg": "04873ec1b2d0f87010981399f92e4cbe",
"assets/assets/images/flags/tv.svg": "c75afdde63ae0e1e205c5dfd653afffe",
"assets/assets/images/flags/ge.svg": "e7868570044eb45c42c248f5c6c0b9fb",
"assets/assets/images/flags/dm.svg": "bffb3422c8e72c85918baca34e21937c",
"assets/assets/images/flags/kw.svg": "2e0484c010807a0dca638bca095f76f5",
"assets/assets/images/flags/yt.svg": "38abb75fbdee89e313565bf814710692",
"assets/assets/images/flags/lt.svg": "7e7110b65bbe5cbfb8a84a0e5f68284e",
"assets/assets/images/flags/un.svg": "c3b2aac401d548c7cf39b27d8ec7d153",
"assets/assets/images/flags/bi.svg": "3f52178a68c68470929390c75a5b3d39",
"assets/assets/images/flags/vi.svg": "72221c5155f9cad3ab2239068ab34f93",
"assets/assets/images/flags/sv.svg": "e22d24982ee97b270ce1fc04c238dc2a",
"assets/assets/images/flags/ki.svg": "f5ac88c13d4fa16a406c5c7c3bd56da0",
"assets/assets/images/flags/ug.svg": "5090179bc7a21448ec49d70179c8d074",
"assets/assets/images/flags/mv.svg": "44a3b21f0ab17367c095a8798f7cc4da",
"assets/assets/images/flags/uz.svg": "c4be51bb2b634168ef4325784b53bf62",
"assets/assets/images/flags/at.svg": "a0e5865313bbfd0ee7411ad59832192b",
"assets/assets/images/flags/td.svg": "983e8a4ce97f1e3c1cf0e01ee2bc1a74",
"assets/assets/images/flags/cv.svg": "f0add59ff3bbb8991c713261ccab8cb2",
"assets/assets/images/flags/pr.svg": "3d6afa7282f19e68fe5ef48648bc6dce",
"assets/assets/images/flags/nu.svg": "bfd6de48e40574ec6d86c6e0589baa48",
"assets/assets/images/flags/me.svg": "80c3a3fe41ea4233fe8558ac3938bc07",
"assets/assets/images/flags/va.svg": "84dec055eb4e7f2bb4ca324051eb892f",
"assets/assets/images/flags/gr.svg": "71452bbd08d693543125cc15f5943637",
"assets/assets/images/flags/gs.svg": "136357c70b0710ea49cb4323b2cee08b",
"assets/assets/images/flags/lr.svg": "8483351ab6b981aae3b236c79ac62753",
"assets/assets/images/flags/ro.svg": "e9130a28a9ba2b93433f21a2cd5971f3",
"assets/assets/images/flags/mo.svg": "7df71c725bcb0587a7918896aad378c8",
"assets/assets/images/flags/my.svg": "6175b67f2c004626cbb214c9b52c5bc4",
"assets/assets/images/flags/tz.svg": "52d064016a82b03c1e59cdfc054ab303",
"assets/assets/images/flags/na.svg": "f770c272591ef4e6a20819cb32532799",
"assets/assets/images/flags/gb.svg": "6dcadf6916764560c2f1fec586e2c1de",
"assets/assets/images/flags/gu.svg": "9a7232b684321a8d4fdc07a6417b1fa3",
"assets/assets/images/flags/ps.svg": "5565202f90be94cb7a0e3dd6d6c7a771",
"assets/assets/images/flags/uy.svg": "7942bb43f1e2a75c4d81d7a2c569faef",
"assets/assets/images/flags/sh-ac.svg": "4f7d31d4de0ea70ab4472b4ec753c676",
"assets/assets/images/flags/nc.svg": "40f05fd024c99dbd3cf08dcca093c98f",
"assets/assets/images/flags/pc.svg": "008b14946b0305744becdc2bdaf18016",
"assets/assets/images/flags/bh.svg": "86725006a063c2db6d6b0ae08d2a2ae5",
"assets/assets/images/flags/io.svg": "8b90fd988d46280c2cf199d77ec24c6d",
"assets/assets/images/flags/sl.svg": "af0884d411f36ff8e0fb199a00b70691",
"assets/assets/images/flags/ck.svg": "ae3ea163a41e7acc6ec68d293ee62911",
"assets/assets/images/flags/sk.svg": "2c0bed77082c2e388a9b3d8bfed51be3",
"assets/assets/images/flags/cefta.svg": "e0e7f32f0b2bfa01a5ff612eaa23e8c7",
"assets/assets/images/flags/hm.svg": "d13f9cb35336040cbd9648c88f9d4ada",
"assets/assets/images/flags/ms.svg": "324434779ce1bbe0f611ae7c5c3a1755",
"assets/assets/images/flags/lc.svg": "dfc467ded9d00d68e775e15337fe5214",
"assets/assets/images/flags/al.svg": "6eef7622cecbab02f24192d8eba30bf7",
"assets/assets/images/flags/bj.svg": "7f6166b56e8697232afee3eec2516b3e",
"assets/assets/images/flags/om.svg": "1c751fd3d5fe291da7bde71c3d4e9a36",
"assets/assets/images/flags/za.svg": "da9e50f2ae3cc80343b9be4f2a5f599d",
"assets/assets/images/flags/il.svg": "c0a0925b76528c896afcf1b113bcc366",
"assets/assets/images/flags/dz.svg": "b37c4fcf5782f19c46c24f834a141bb1",
"assets/assets/images/flags/co.svg": "eefa6c2cd269ce7da90dc5ac0d78a48a",
"assets/assets/images/flags/tj.svg": "7321ab191e13ad2f8956ae31fc3d356a",
"assets/assets/images/flags/az.svg": "e22a754269058c7dc7ba83044de5ede0",
"assets/assets/images/flags/es-pv.svg": "b98fc13308678165cb8230b1e4bea60a",
"assets/assets/images/flags/xx.svg": "c15ffa45806fe02417d2bd22e6bd4fca",
"assets/assets/images/flags/cn.svg": "347824ed3b1806718c8881e7e2f13697",
"assets/assets/images/flags/nz.svg": "229d2fadba8d00df102927eae199d46f",
"assets/assets/images/flags/md.svg": "b8414a95271e7968e46f622b37737a08",
"assets/assets/images/flags/sm.svg": "253adf4b0d2ac68733caea280eacb1a1",
"assets/assets/images/flags/hn.svg": "57160f534d227ae78c5cb8381a75a37b",
"assets/assets/images/flags/sd.svg": "00f69acaade5d14c00e36d841b5e9b23",
"assets/assets/images/flags/bg.svg": "813f4105785ca18d96247198003fb0c2",
"assets/assets/images/flags/ky.svg": "4351dd3144851b98b81e45000597427b",
"assets/assets/images/flags/np.svg": "218bd7570bc9da97ffa7abec43ab5b63",
"assets/assets/images/flags/nf.svg": "8f7397ffa12755119ef349fddd280e8f",
"assets/assets/images/flags/pg.svg": "dbf16b180cf775e38aae810eb84357be",
"assets/assets/images/flags/tn.svg": "1e2cfb1bfd06ab00b1a5ac9263b7c444",
"assets/assets/images/flags/bl.svg": "9dc30a69d4ead9865c5237c7855dd278",
"assets/assets/images/flags/fj.svg": "5487b64cfff710d75493227f1085cf1f",
"assets/assets/images/flags/tf.svg": "3cdeba0c214a07003512752047e6ed9f",
"assets/assets/images/flags/in.svg": "230b82c4b877a6af4ea17b5e9d751b9a",
"assets/assets/images/flags/nr.svg": "b3fdadbc923b5a447ec89bca7c69d213",
"assets/assets/images/flags/ua.svg": "6d944bf795f95c09b2f78819af42db89",
"assets/assets/images/flags/ws.svg": "096fc50015e936e5ef310183baab82ca",
"assets/assets/images/flags/qa.svg": "6b0bfc63e28cf03deb8794d8c8ad8460",
"assets/assets/images/flags/ls.svg": "0ed298ed0de87d001d82365008bbcdd2",
"assets/assets/images/flags/bw.svg": "2f0ecfbb57512a7aa257a9695003e7d8",
"assets/assets/images/flags/de.svg": "e88d88604d655d0bd7059cf1fbd59ec2",
"assets/assets/images/flags/sj.svg": "5b6dddaf6a82ad8090d313f3088b7e2d",
"assets/assets/images/flags/et.svg": "4e95cb382ed9d13e3e6be16c2ad09a18",
"assets/assets/images/flags/tc.svg": "ffc069871ba7771c6439182ca40d1078",
"assets/assets/images/flags/re.svg": "93aac5219d4b4cce2df6460ee023daed",
"assets/assets/images/flags/es-ct.svg": "3eb3a35a978070fd4a68db545c527b54",
"assets/assets/images/flags/sh-ta.svg": "f4b69bfde175eb7418b6d5f8882ac6c2",
"assets/assets/images/flags/er.svg": "6d661bc292974a5050962bd98323e09a",
"assets/assets/images/flags/bd.svg": "e99cb11fdae12d94bce83d228b052dc3",
"assets/assets/images/flags/pl.svg": "f7adaa942c63ca98f1d2362bc67c45e3",
"assets/assets/images/flags/ir.svg": "1348920da6e96ada40978fd661eba1f9",
"assets/assets/images/flags/gm.svg": "21b07ec656b24882173b9760792b7691",
"assets/assets/images/flags/no.svg": "859a13561a1b24bfa65fb1a03835da49",
"assets/assets/images/flags/gg.svg": "6a608369d5207ef50ef840171aef8d40",
"assets/assets/images/flags/sh-hl.svg": "2a642f9a803833cd884c3f336d60652f",
"assets/assets/images/flags/pe.svg": "5156eee1494fa9ccb9ff78c95f6053d0",
"assets/assets/images/flags/dg.svg": "30a726a28a74b868170aecba714c3af4",
"assets/assets/images/flags/us.svg": "1d23b9509d0a0a828e3071096b0d2edf",
"assets/assets/images/flags/zm.svg": "14fe4bb777477c582f360befb3034ec6",
"assets/assets/images/flags/ne.svg": "5c109026a107f910512b09e208a90538",
"assets/assets/images/flags/ke.svg": "6e6a47cb574c6895a0e7086cb52390a1",
"assets/assets/images/flags/cm.svg": "e97d922e36f1702627e033b6d936f143",
"assets/assets/images/flags/it.svg": "1d72a5dec3acd073763570e3e5fdf784",
"assets/assets/images/flags/cd.svg": "b0b418db3a598e6fc240fe6dbda56de0",
"assets/assets/images/flags/ss.svg": "0678d330e69d1c83ed22e43b987a8554",
"assets/assets/images/flags/bz.svg": "dde2970543218e1a1d5448d1080f25ff",
"assets/assets/images/flags/km.svg": "a68238693856a7f909ce0bad9ab9e8fd",
"assets/assets/images/flags/gb-eng.svg": "7caecb785400d1cca7b319887a9d81bf",
"assets/assets/images/flags/lk.svg": "b36959d910d1aed36bf660fe2cb0f60d",
"assets/assets/images/flags/ad.svg": "ecd056d068548937c4eefbce56fb332d",
"assets/assets/images/flags/ly.svg": "b180a3a13fbcd16816afecf0cf994609",
"assets/assets/images/flags/sg.svg": "b8d345820ac52f8187155ff5c79ef5b0",
"assets/assets/images/flags/ca.svg": "8ce7bacf57b7f970b82fff0c1ee2e38f",
"assets/assets/images/flags/gn.svg": "f1d6c153def70087cff4f84c49ee2fb2",
"assets/assets/images/flags/as.svg": "f4e9b503f714fc513af5f1ea63f6b9ad",
"assets/assets/images/flags/af.svg": "645254d672bdd95806931d704441f47a",
"assets/assets/images/flags/cz.svg": "859f18a5acfd4e8d702a9b3d539dfd2d",
"assets/assets/images/flags/li.svg": "e2d8b339351d627308fc46ce3d4a61b4",
"assets/assets/images/flags/mk.svg": "b96b8a63c2939ef1e4cebb9585908591",
"assets/assets/images/flags/sb.svg": "54215c8c6e4973b16535240f796b55a6",
"assets/assets/images/flags/tw.svg": "a4b47fff88d0596123054bb88aaa2ca2",
"assets/assets/images/flags/mz.svg": "966fd28d247169146755072b86b90668",
"assets/assets/images/flags/sy.svg": "3eb9d0f06233d918805e757d70d66840",
"assets/assets/images/flags/lu.svg": "e2fc15cc49d1afe3ef9fc92004464f19",
"assets/assets/images/flags/kn.svg": "170a2ee40bdc3edacff21c6dacd1964b",
"assets/assets/images/flags/mt.svg": "222b42d001de2a0f071a27621cb038e5",
"assets/assets/images/flags/kp.svg": "de1ff54929a738623cb053e25d98c806",
"assets/assets/images/flags/sa.svg": "242c5a79405f4d1e5bd9ef1b82caa9cc",
"assets/assets/images/flags/gb-sct.svg": "ade55ed456211d6577b2f80c06e40c51",
"assets/assets/images/flags/bv.svg": "4a3cbeed34e0e6032a444b5069a94ff3",
"assets/assets/images/flags/um.svg": "f2ba7f8f8ad272e4335c51579b0b1025",
"assets/assets/images/flags/mr.svg": "e06ac425a27488d82d93de2e9ac05293",
"assets/assets/images/flags/aq.svg": "5c7ea30ed8bb10bfb23c642051fa6b7e",
"assets/assets/images/flags/is.svg": "dd9622551b169bddb9e9f99d9b97cb54",
"assets/assets/images/flags/ni.svg": "616b5049f9d7f851e9b961c848214537",
"assets/assets/images/flags/ph.svg": "d8046bd209c4750f7a67beb68f780dd1",
"assets/assets/images/flags/zw.svg": "bcaa4841520ad37f49b24fbac83307c7",
"assets/assets/images/flags/cy.svg": "11f5dd5f329227cfa7ea462821ad92d6",
"assets/assets/images/icon.png": "9cb81f3a49c986011d179700707dda24",
"assets/assets/images/splash_text_yellow.png": "6c50321b758d33260d93df687b3604fa",
"assets/assets/images/white_logo.png": "fc68bd3960d853daf21d18a67092d257",
"assets/assets/images/blue_logo.png": "854643db1925c3303569b5eea840175a",
"assets/assets/images/pln.gif": "7b360d0c72c4ff9285ebca64868aa13e",
"assets/assets/images/ic_notify.png": "76838177eb9ac905bf0d58d30de3b75d",
"assets/assets/images/splash_text_white.png": "4be22963389eef6ed8a73d9360c7d894",
"assets/assets/images/splash_text_blue.png": "1a0a0a1f574b03a29841569ee8f5348e",
"assets/assets/images/icon_foreground.png": "61e303dd1ac4009a28eb79dee739923b",
"assets/assets/images/logo.png": "6ff7902e655b27ab57c4eca5844f04e6",
"assets/assets/images/logo_2.png": "ac5ecfc6c705ca10227422729f6a7bfc",
"assets/assets/images/splash_text_white_2.png": "06c29f3dee29f462653a3c5e10f87a6d",
"assets/assets/images/splash_text_black.png": "9f197d4d27c79cadfa907a549723cda5",
"assets/assets/images/black_logo.png": "182add7f6698ba461a6106a0ca71b2df",
"assets/assets/images/logo_2_12.png": "8e7f7fe16648ed8773e94862e1da83bf",
"assets/assets/images/plane.png": "dfdf319cdba46b196e30090a96cc5db8",
"assets/assets/images/splash_text.png": "24b0b56b26616b8efa2ed6c71ba902c4",
"assets/assets/images/gifs/flight_loader_dark.gif": "15cab307d7e4f476cf2df77cc3c1e814",
"assets/assets/images/gifs/flight_loader_light.gif": "425c3e33ee87d6e123d53ba1e6ec5303",
"assets/assets/fonts/Almaria/Almarai-ExtraBold.ttf": "5270f5e7ab01259e282604276871946f",
"assets/assets/fonts/Almaria/Almarai-Regular.ttf": "4fcf563640cefe40b7474aec4f966c0a",
"assets/assets/fonts/Almaria/Almarai-Bold.ttf": "1c7b8f3e50a7ca693dc27d3f1314167f",
"assets/assets/fonts/Almaria/Almarai-Light.ttf": "5b0dec05feae02fef51afd517af94d4c",
"assets/fonts/MaterialIcons-Regular.otf": "744ea8bb4acadd3a78e563bfc5aa6ee7",
"assets/NOTICES": "1fe8db22d28052819fe8227de559d08c",
"assets/packages/awesome_dialog/assets/flare/succes.flr": "ebae20460b624d738bb48269fb492edf",
"assets/packages/awesome_dialog/assets/flare/error.flr": "e3b124665e57682dab45f4ee8a16b3c9",
"assets/packages/awesome_dialog/assets/flare/succes_without_loop.flr": "3d8b3b3552370677bf3fb55d0d56a152",
"assets/packages/awesome_dialog/assets/flare/warning.flr": "68898234dacef62093ae95ff4772509b",
"assets/packages/awesome_dialog/assets/flare/info_without_loop.flr": "cf106e19d7dee9846bbc1ac29296a43f",
"assets/packages/awesome_dialog/assets/flare/info.flr": "bc654ba9a96055d7309f0922746fe7a7",
"assets/packages/awesome_dialog/assets/flare/question.flr": "1c31ec57688a19de5899338f898290f0",
"assets/packages/awesome_dialog/assets/flare/warning_without_loop.flr": "c84f528c7e7afe91a929898988012291",
"assets/packages/awesome_dialog/assets/flare/info2.flr": "21af33cb65751b76639d98e106835cfb",
"assets/packages/awesome_dialog/assets/rive/info.riv": "2a425920b11404228f613bc51b30b2fb",
"assets/packages/awesome_dialog/assets/rive/warning.riv": "0becf971559a68f9a74c8f0c6e0f8335",
"assets/packages/awesome_dialog/assets/rive/error.riv": "e74e21f8b53de4b541dd037c667027c1",
"assets/packages/awesome_dialog/assets/rive/question.riv": "00f02da4d08c2960079d4cd8211c930c",
"assets/packages/awesome_dialog/assets/rive/success.riv": "73618ab4166b406e130c2042dc595f42",
"assets/packages/awesome_dialog/assets/rive/info_reverse.riv": "c6e814d66c0e469f1574a2f171a13a76",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "7f3240515d6a1c8a3a5a2f605783f58a",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "98838445dacd8e39028974b25ac4f434",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "da8d5883bd4ac272efb3c99f46ce484d",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "b2703f18eee8303425a5342dba6958db",
"assets/packages/country_flags/res/si/sa.si": "cf93fcbb04c97fac13136e80fd27ade9",
"assets/packages/country_flags/res/si/ph.si": "c8899c0eb2232931f49fa35de57f5d09",
"assets/packages/country_flags/res/si/ls.si": "f469f1632ad300b4fb00db8328f9b844",
"assets/packages/country_flags/res/si/tv.si": "7e462e7d6fa8bdd967bf9e37b86d0906",
"assets/packages/country_flags/res/si/cd.si": "092862ef3f988f301bf81d937d0b2251",
"assets/packages/country_flags/res/si/az.si": "203fdb6be0df02e0b86e1ab468a84588",
"assets/packages/country_flags/res/si/lk.si": "c8f0c394d54b1618603d89307e6cd127",
"assets/packages/country_flags/res/si/uy.si": "8163529e4c65d4f7f97dad78c51918c7",
"assets/packages/country_flags/res/si/ki.si": "80c4adc8b03b18055be571a612fa3f79",
"assets/packages/country_flags/res/si/kz.si": "f5aad35a9ce49a2a17f165d4761d8ace",
"assets/packages/country_flags/res/si/ky.si": "498424ad28f6c9e005ae14e8d66c3e2f",
"assets/packages/country_flags/res/si/aq.si": "e15ec1a740dfd94250faaf3a04c3e009",
"assets/packages/country_flags/res/si/il.si": "5926479ae8ffa09647b9c20feceb9415",
"assets/packages/country_flags/res/si/sj.si": "04dcac0249ab5999520c35c8e7f3ce38",
"assets/packages/country_flags/res/si/gq.si": "e8e087ae91048f042fa212b5f79a496c",
"assets/packages/country_flags/res/si/ai.si": "98108de6fc34688b9281b6040f855730",
"assets/packages/country_flags/res/si/ae.si": "600a0ce358d82ca58155a6298524084f",
"assets/packages/country_flags/res/si/pn.si": "4df57b8f366ab9d559a134e25fa92201",
"assets/packages/country_flags/res/si/mo.si": "4a369319962984183cfed7f0bf4d60a5",
"assets/packages/country_flags/res/si/ci.si": "2dd6886cd9b611e8301f347233f275db",
"assets/packages/country_flags/res/si/ge.si": "6f700846562325e1e647946a9b7e26f6",
"assets/packages/country_flags/res/si/sk.si": "009a8dbaf2bc675683650d84bde81643",
"assets/packages/country_flags/res/si/ck.si": "30d75fc50470f00d7fc590c058b7a4c1",
"assets/packages/country_flags/res/si/kh.si": "711d8494963708be2a01a1dfc5a002db",
"assets/packages/country_flags/res/si/dm.si": "114b039b7de692af992aa75bdfd324d9",
"assets/packages/country_flags/res/si/vn.si": "5e53b20018d53d957714d0211c237211",
"assets/packages/country_flags/res/si/tk.si": "9fc0141c9928734e4229f05d2f2f68d4",
"assets/packages/country_flags/res/si/im.si": "3bca9cb89673cd2c1837c69f72038bde",
"assets/packages/country_flags/res/si/ax.si": "a456e36511e13498fa3d610a026d79b8",
"assets/packages/country_flags/res/si/pa.si": "3231c2af8957eddd456819783df37ef5",
"assets/packages/country_flags/res/si/mr.si": "73d5e7f3158beeb1e09e294cc2cc3b79",
"assets/packages/country_flags/res/si/cm.si": "d89b50b2a1e7c5814a53894ddf6842f6",
"assets/packages/country_flags/res/si/jm.si": "db4e387e95c824cefb80b16ae8f8af9f",
"assets/packages/country_flags/res/si/fi.si": "6ed37987c4dee7606f35b1f3ef2f4352",
"assets/packages/country_flags/res/si/mx.si": "add64001e4e654f95a36c24e5b212b80",
"assets/packages/country_flags/res/si/nf.si": "1473b829023248dbbd77f49b9e6e5ede",
"assets/packages/country_flags/res/si/bg.si": "75bcf4b187601813fcf6008da5ef3625",
"assets/packages/country_flags/res/si/cf.si": "00cce9e9924e59417fd640f22ff3c068",
"assets/packages/country_flags/res/si/mq.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/id.si": "9cf3c91fee39a1ff1d93cbbe385d7bbf",
"assets/packages/country_flags/res/si/ws.si": "1644f5c199bfc4a5ee49d0907eb26efa",
"assets/packages/country_flags/res/si/lc.si": "981c9cb18294152ac0423aa64039f6e0",
"assets/packages/country_flags/res/si/ht.si": "2f82778ff6d4910a677170a08545bfd6",
"assets/packages/country_flags/res/si/me.si": "d87206186e9601dcfabdd0d38b655899",
"assets/packages/country_flags/res/si/ch.si": "25b5af40c1ed5254d8a5c9286a235a78",
"assets/packages/country_flags/res/si/is.si": "6a75ef472e3b3674cb992a6c1a2d8656",
"assets/packages/country_flags/res/si/tt.si": "6550348a507c01feaf93fd191503ce72",
"assets/packages/country_flags/res/si/gb-sct.si": "c1e2452023ede8ca68306f9360bec03f",
"assets/packages/country_flags/res/si/as.si": "f12705f23ac102cc4fa8e85c3a780040",
"assets/packages/country_flags/res/si/bj.si": "e356b737969b4d0413d0d17781f5476f",
"assets/packages/country_flags/res/si/ug.si": "b5368d2d0a873dd2ff8adc689c6c6b09",
"assets/packages/country_flags/res/si/kr.si": "0fc0217454ce0fac5d5b0ed0e19051ce",
"assets/packages/country_flags/res/si/cg.si": "a9df20410076c50e9abbd11b324712c3",
"assets/packages/country_flags/res/si/li.si": "08d65db7ba158c62f8b70240985fbbe9",
"assets/packages/country_flags/res/si/td.si": "7fe532f134f64c198cc8b4feb90efcaf",
"assets/packages/country_flags/res/si/nu.si": "dac0a569e83a73006b8600fa1f1f8ac5",
"assets/packages/country_flags/res/si/bm.si": "2c1effe65d4c9c6ea846536f9ebcac93",
"assets/packages/country_flags/res/si/vu.si": "54ccd51f720f6bb242f2256626a172b8",
"assets/packages/country_flags/res/si/et.si": "6020d43892ed1096172d0d01a00afe89",
"assets/packages/country_flags/res/si/bv.si": "d2e12ff6011d4fc76d0044e61abbd8a1",
"assets/packages/country_flags/res/si/sn.si": "e283672331f67926294d3609b6317d82",
"assets/packages/country_flags/res/si/uz.si": "9141032bde5150e86cd2d159c4f31b72",
"assets/packages/country_flags/res/si/cp.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/ea.si": "c59363bf0d9a595df07cfe238f9cc16a",
"assets/packages/country_flags/res/si/gb-eng.si": "c23da032fa2a18ca5390c2cab903ac80",
"assets/packages/country_flags/res/si/vi.si": "acbfd08b5cd096eac556c46efecb7926",
"assets/packages/country_flags/res/si/xx.si": "95362a356a59ae95c73b1a7a415abff6",
"assets/packages/country_flags/res/si/kw.si": "fae7c5f1138fcb68b76b6bf1ecb5f422",
"assets/packages/country_flags/res/si/tg.si": "2a23d4dbc913968f6eb97dbb5454941e",
"assets/packages/country_flags/res/si/bo.si": "1491a562f1ee0f5fdf512a72821dc3b1",
"assets/packages/country_flags/res/si/cc.si": "831df80000b0c6d12f0c37f696a11e31",
"assets/packages/country_flags/res/si/mw.si": "529e2edb7b4f71261a4d8c52de450f5d",
"assets/packages/country_flags/res/si/bw.si": "50b6724787e9b206d8998f747748f133",
"assets/packages/country_flags/res/si/ml.si": "e583b41ed5e4f9508970265999bf47bf",
"assets/packages/country_flags/res/si/sh.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/kg.si": "1f1f0daac400da3f36e873982f002844",
"assets/packages/country_flags/res/si/ec.si": "87d4beb1830c8746d02bd3eb81daa1cf",
"assets/packages/country_flags/res/si/sm.si": "e29d9a0493a72947dfc5e5668bcdcc30",
"assets/packages/country_flags/res/si/al.si": "3a10d259f602c6832ed5316403f6fe91",
"assets/packages/country_flags/res/si/bb.si": "a0f7ccd01c2e5eee48607b53d0791941",
"assets/packages/country_flags/res/si/au.si": "93810e1a767ca77d78fa8d70ef89878a",
"assets/packages/country_flags/res/si/bt.si": "9b9f54fdaeb57d27628dd7318c23d632",
"assets/packages/country_flags/res/si/cr.si": "7385af5d3c967dad1c62027ece383dd6",
"assets/packages/country_flags/res/si/cy.si": "f4f95412e75e3e82b62b140f1fb4d327",
"assets/packages/country_flags/res/si/cl.si": "1765b8d051900505b51ca7149756b62e",
"assets/packages/country_flags/res/si/vc.si": "a6d41b2c67d49f3f202dc920ad2f8c49",
"assets/packages/country_flags/res/si/sc.si": "65a3e456a8f0cfb400f7a4b354fd1839",
"assets/packages/country_flags/res/si/do.si": "0c12349ea290f3e7d6bd3c7eba8ec556",
"assets/packages/country_flags/res/si/sz.si": "780a7eb9794bd6cf85d59d42766e62b3",
"assets/packages/country_flags/res/si/ba.si": "6719180c7b4f5d76a1c41fd76668cc69",
"assets/packages/country_flags/res/si/yt.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/at.si": "da9709351758847fbf187e9947fd44a5",
"assets/packages/country_flags/res/si/sy.si": "e510652843b486afcb5f160188b4514a",
"assets/packages/country_flags/res/si/gi.si": "1d4b7516dbef91dd53a3223786433468",
"assets/packages/country_flags/res/si/jp.si": "ee22ac07312690001d82c27ed0fab0a8",
"assets/packages/country_flags/res/si/ye.si": "cc3bd4c5b25155d249015f88380a3023",
"assets/packages/country_flags/res/si/nz.si": "95a431faf2077c36c314e060d3565e11",
"assets/packages/country_flags/res/si/pk.si": "afa64ff88820436b4ec66b1043a1ca7d",
"assets/packages/country_flags/res/si/np.si": "aac703fec2d68d1f05f0b368bcd05b5c",
"assets/packages/country_flags/res/si/cn.si": "a629d6ea2863bc2e2783ed86427fccdf",
"assets/packages/country_flags/res/si/bf.si": "36c828d75ffb1b1ee0c074f08dbd162e",
"assets/packages/country_flags/res/si/tn.si": "d15a30567010db55d9a398ffde25694c",
"assets/packages/country_flags/res/si/gm.si": "b764f5bed08b62f0c908d224b61c62ce",
"assets/packages/country_flags/res/si/ca.si": "a911aefa8694f795f4066047492134be",
"assets/packages/country_flags/res/si/va.si": "c23d81f5e4e3acd336ce01d9ed561ee8",
"assets/packages/country_flags/res/si/fr.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/cz.si": "722387eee039fb858312120170af2ba7",
"assets/packages/country_flags/res/si/mf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/gb-nir.si": "70756040e8747ea10547485c1b5493dd",
"assets/packages/country_flags/res/si/fm.si": "d195abb2e8d6961f6ffa0da23d8b2813",
"assets/packages/country_flags/res/si/gd.si": "2bd89cc35d9a35aa6b5c7dfa8888e769",
"assets/packages/country_flags/res/si/gu.si": "f47c5abf0b2dd4b8b717e87c82e1f328",
"assets/packages/country_flags/res/si/sg.si": "3e20b9387970793f6b3db62609820d4a",
"assets/packages/country_flags/res/si/om.si": "8d23e422f6191c117e764aa17c80e195",
"assets/packages/country_flags/res/si/nc.si": "8760c0e60c7ab868ea1577de40a8dd04",
"assets/packages/country_flags/res/si/af.si": "9fb0d66778b5afe46c5750f6b2de0a06",
"assets/packages/country_flags/res/si/cu.si": "b561ce782460b38c99795d3891be4bd8",
"assets/packages/country_flags/res/si/bq.si": "130b5b1f64baa8e002dc668b0d3d589f",
"assets/packages/country_flags/res/si/be.si": "6d9dd724fd5dd06b3cff71955bf03728",
"assets/packages/country_flags/res/si/ag.si": "f2607a0fcfd1aeecb45e1ea7d17979a0",
"assets/packages/country_flags/res/si/eh.si": "99373a71bd21ee4d5ce37dd840fa8bc5",
"assets/packages/country_flags/res/si/rs.si": "f231dce72ce3243a624eb723d200a63e",
"assets/packages/country_flags/res/si/bl.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/hu.si": "379f70d867e53920ef1105ae9d3dc5e1",
"assets/packages/country_flags/res/si/tz.si": "643850342b81b7015ad57cddc9589a69",
"assets/packages/country_flags/res/si/pe.si": "978e662d337e34163ef3dbc28cf35f11",
"assets/packages/country_flags/res/si/io.si": "3469f709b852fa25f3d735d4e7ee88a2",
"assets/packages/country_flags/res/si/se.si": "64f75927796e3bcf418a7f1bce12cf39",
"assets/packages/country_flags/res/si/rw.si": "8b075359fc5a06224acf83d24b058752",
"assets/packages/country_flags/res/si/am.si": "f1c0decc96d76ecce7dda29e1b0a3048",
"assets/packages/country_flags/res/si/ie.si": "58082f0739794c2562fbd21b9700a0a9",
"assets/packages/country_flags/res/si/hn.si": "bf1d541bc8c0b4826c3cf7f2d36e1b87",
"assets/packages/country_flags/res/si/er.si": "1f32851695ad06a33b607cbfe96cbe5c",
"assets/packages/country_flags/res/si/ao.si": "042c2a03c013acf928449dbaf2a4affe",
"assets/packages/country_flags/res/si/ga.si": "863042bec1c7781b8245d2fec2961835",
"assets/packages/country_flags/res/si/es-ga.si": "c128cec2feffaff7aab7940dadcd9ccd",
"assets/packages/country_flags/res/si/ps.si": "e91b4cc92cc8629f42c9d8fb11d028ba",
"assets/packages/country_flags/res/si/eu.si": "0c7acf5338eb131940e6a2d53022fda7",
"assets/packages/country_flags/res/si/jo.si": "3c4f0683e2fe5e5d9b1424a5865c1e59",
"assets/packages/country_flags/res/si/ro.si": "ec81c7e1014f2b8584ddd07d0fad9c43",
"assets/packages/country_flags/res/si/sv.si": "912cc0a01ad6e839db6392ece5736b68",
"assets/packages/country_flags/res/si/ma.si": "9ced8447a0a9b2e720d870bc5aef87cf",
"assets/packages/country_flags/res/si/lr.si": "8ea704b8b395abcb8dbd13a7fb738b3e",
"assets/packages/country_flags/res/si/dj.si": "c39ebb82ae2414d5b42b0c78d7db1626",
"assets/packages/country_flags/res/si/mu.si": "9f4070ad133e7380edb48cb11cffaef1",
"assets/packages/country_flags/res/si/pt.si": "04c1755d12a50d7524a66124c8d725cc",
"assets/packages/country_flags/res/si/je.si": "5fb5c37d3e7469ad537882debd8c4f33",
"assets/packages/country_flags/res/si/ng.si": "d2764e808010a6d2389cfc1e83e3b710",
"assets/packages/country_flags/res/si/km.si": "6cc50d7456a351984bae778298741591",
"assets/packages/country_flags/res/si/no.si": "6b6efedb50f0a7b05a9afe882924fe99",
"assets/packages/country_flags/res/si/so.si": "ee4702222805ec60fe47cca5500fced8",
"assets/packages/country_flags/res/si/vg.si": "de1ed29316c1d0f81af9946e35d254d7",
"assets/packages/country_flags/res/si/kn.si": "cd16cb0ce86ecb131422414a132352bb",
"assets/packages/country_flags/res/si/gl.si": "f447d0f9f9e95027def4b4a333f59393",
"assets/packages/country_flags/res/si/si.si": "11367d866b110a2971aae42dbc72b47f",
"assets/packages/country_flags/res/si/dk.si": "23b9112d01b91326804b173427d0a991",
"assets/packages/country_flags/res/si/br.si": "dc32cd1c578da0b7106bd15a74434692",
"assets/packages/country_flags/res/si/mz.si": "65389bae62f6de08c93ff93fe61e7b24",
"assets/packages/country_flags/res/si/tm.si": "61cac086e156158fe52394aadb734bd1",
"assets/packages/country_flags/res/si/pl.si": "034643869bc1b14ad2af44cc9aa24b9f",
"assets/packages/country_flags/res/si/mt.si": "2c7e94cc8b51a7ce1c1958a00f880398",
"assets/packages/country_flags/res/si/ms.si": "e04ef3545afb3927de3aff13640ff6b9",
"assets/packages/country_flags/res/si/gy.si": "6373d2b94878202fd94563aeea4fd8ca",
"assets/packages/country_flags/res/si/fj.si": "5315abdde8d2a5274a621a7d1fdb92a6",
"assets/packages/country_flags/res/si/cefta.si": "4a619e7166e3a91fd3333a0aa9a7f212",
"assets/packages/country_flags/res/si/ke.si": "87ce4c55414a8c5d29f23ca16310a01c",
"assets/packages/country_flags/res/si/ne.si": "5323700b3b0dc68916ffe048c4afc2b1",
"assets/packages/country_flags/res/si/wf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/pg.si": "51e824f62d970ad02c7afa9cc70330d8",
"assets/packages/country_flags/res/si/md.si": "074b41437a23811d27d4db98bedd56d8",
"assets/packages/country_flags/res/si/ic.si": "5459bbd72389b2300c7da170cd528f23",
"assets/packages/country_flags/res/si/mk.si": "0aee6cc90fb321101c9d4afd923c2d85",
"assets/packages/country_flags/res/si/bd.si": "18bcbe7c5cd7ef99faf8e581dcf6f2db",
"assets/packages/country_flags/res/si/ir.si": "84eb55b574dd390d8fc86b185d182578",
"assets/packages/country_flags/res/si/tr.si": "3bd279bd1f4c26e0ad0abed7fb744df3",
"assets/packages/country_flags/res/si/in.si": "335a5837f0d2b45527db4e60087b4221",
"assets/packages/country_flags/res/si/my.si": "6487d3c60a6fb74711c8bf732ef9aaea",
"assets/packages/country_flags/res/si/fo.si": "c074164f5875cc2ac648caa3461a4ffa",
"assets/packages/country_flags/res/si/ac.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/aw.si": "bac854c7bbf50dd71fc643f9197f4587",
"assets/packages/country_flags/res/si/la.si": "161dccf57b198768b6c95fd585966156",
"assets/packages/country_flags/res/si/tj.si": "ff5523df78dbb97dbc212adec3b67a5e",
"assets/packages/country_flags/res/si/to.si": "999f5edc1d7bd74937dab96f8d035368",
"assets/packages/country_flags/res/si/nr.si": "7762af79a081de69557b7611eaf93bf9",
"assets/packages/country_flags/res/si/st.si": "201fdb14910faacd6ce8c30c0a2c1bec",
"assets/packages/country_flags/res/si/gb.si": "b875cc97c8e2a1a41fd3ccbbdb63d291",
"assets/packages/country_flags/res/si/sr.si": "c996e0d2b46e4afc13b18a5abe492fe7",
"assets/packages/country_flags/res/si/ad.si": "c3ccb8e3cf8b3ce384280c687c94ed53",
"assets/packages/country_flags/res/si/bz.si": "3fad74bf2e5948e1556c8048e65e084e",
"assets/packages/country_flags/res/si/ni.si": "8af49cf35b72204052de6fab8322afc8",
"assets/packages/country_flags/res/si/gg.si": "57b684be8b0e0fa86e1dae5100f3c0ee",
"assets/packages/country_flags/res/si/ly.si": "b99bf6af3ded37ca4b35c612bfe98721",
"assets/packages/country_flags/res/si/es.si": "c59363bf0d9a595df07cfe238f9cc16a",
"assets/packages/country_flags/res/si/th.si": "1654e97b82bcdcdaade71e1bc3a5590d",
"assets/packages/country_flags/res/si/iq.si": "a0be6279c1905893dcbcbe0c7ce44302",
"assets/packages/country_flags/res/si/tw.si": "7bba519f0f26cca5417d8edb57bdef83",
"assets/packages/country_flags/res/si/gp.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/zw.si": "b32c711b08bfe7425d509407c48ee5ed",
"assets/packages/country_flags/res/si/kp.si": "863f41ba80f1b3f9c794aaeafafb02d6",
"assets/packages/country_flags/res/si/gf.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/gn.si": "ebb9409ab8449de9d040549ffcef1321",
"assets/packages/country_flags/res/si/bs.si": "5818730530c519e134452e41830a7d4b",
"assets/packages/country_flags/res/si/de.si": "aaabd585b21d0960b60d05acf4c54cd3",
"assets/packages/country_flags/res/si/ua.si": "aeb59a31627c7e9cb89c2c31c8b95d15",
"assets/packages/country_flags/res/si/mc.si": "0cb03fed360c4c1401b0e9cff5dea505",
"assets/packages/country_flags/res/si/ee.si": "d1d0e6c483ec14291ccafc69c4390f07",
"assets/packages/country_flags/res/si/gr.si": "a7ffe39d3dbd0f7e2d7cf03b38ebce8b",
"assets/packages/country_flags/res/si/bn.si": "1334a282f886a35989ab2d1fee8b3acc",
"assets/packages/country_flags/res/si/mg.si": "f6406a9d332acb29115b31235c49c920",
"assets/packages/country_flags/res/si/gw.si": "9c6f62e2963f012b571dad989416a1f3",
"assets/packages/country_flags/res/si/un.si": "d3a2546a132b2e216aa17ffafaca8f57",
"assets/packages/country_flags/res/si/bi.si": "4e22a5fa7d3657998c6424ee89ba328f",
"assets/packages/country_flags/res/si/zm.si": "ef4d9e8828b6609e41642a3fbb6541ec",
"assets/packages/country_flags/res/si/lv.si": "d61111f2dcbc8b2c84e644f7288b1fd7",
"assets/packages/country_flags/res/si/py.si": "a05eb3d105fde5507180087464bc282b",
"assets/packages/country_flags/res/si/cv.si": "1d61ed1ebf59c2a571f54da09340b52b",
"assets/packages/country_flags/res/si/pr.si": "ccb19936defb882dea166d865f8ee5ff",
"assets/packages/country_flags/res/si/tl.si": "307e25e1507c3e76df867108079cb487",
"assets/packages/country_flags/res/si/us.si": "a524142e2a2f7df4ee1b26a98f09a927",
"assets/packages/country_flags/res/si/za.si": "a66971379a3a65b274a702c82b3375d7",
"assets/packages/country_flags/res/si/es-ct.si": "9d497fc098e8ac8eb94576ca2b72a65a",
"assets/packages/country_flags/res/si/re.si": "b319560213233391af1170881595344f",
"assets/packages/country_flags/res/si/tf.si": "2fdcf8c49f0b17d65aa2601d4b505cfa",
"assets/packages/country_flags/res/si/lt.si": "8ef10e2712fa997ca06742fc1d79c095",
"assets/packages/country_flags/res/si/pw.si": "e658e7c8cdf0e27c4d9ccb084768f383",
"assets/packages/country_flags/res/si/by.si": "045e4e447111a76bb834bd9e969756b4",
"assets/packages/country_flags/res/si/nl.si": "130b5b1f64baa8e002dc668b0d3d589f",
"assets/packages/country_flags/res/si/gt.si": "2841eca17a032575b20e97e3c4c0977e",
"assets/packages/country_flags/res/si/ve.si": "e846876f7ec7ad396e58fb20e969a486",
"assets/packages/country_flags/res/si/ar.si": "4ce98d701be0d5607ec3f0d62e5c7ff8",
"assets/packages/country_flags/res/si/pm.si": "5ac3d76ce03f06c4463d135d4129c494",
"assets/packages/country_flags/res/si/lu.si": "0ac3af11df6af8b90ca8f8078902fc9a",
"assets/packages/country_flags/res/si/gs.si": "d6e2a1be23c5e70fced629d467e0a1f7",
"assets/packages/country_flags/res/si/gh.si": "21e46cb3743f96b4e47de0c0b277c604",
"assets/packages/country_flags/res/si/ss.si": "cd22425520f63dac39be3dbfdb49465b",
"assets/packages/country_flags/res/si/dz.si": "74f32a3036da03823454cf8c2fbcc22f",
"assets/packages/country_flags/res/si/sb.si": "b6160f674954161619f0f57d4039e010",
"assets/packages/country_flags/res/si/mv.si": "47d6de70a92bb16bc0284187d12dfb47",
"assets/packages/country_flags/res/si/um.si": "bec8665843b879da2d8ed65532da7e01",
"assets/packages/country_flags/res/si/cx.si": "8d7a59ff653f34ab3323c39c5c5b2f75",
"assets/packages/country_flags/res/si/dg.si": "3469f709b852fa25f3d735d4e7ee88a2",
"assets/packages/country_flags/res/si/ru.si": "677089233d82298520fd2b176f8003a8",
"assets/packages/country_flags/res/si/hm.si": "93810e1a767ca77d78fa8d70ef89878a",
"assets/packages/country_flags/res/si/pf.si": "29e59d85bfa9cc1ed50424098c4577b5",
"assets/packages/country_flags/res/si/hr.si": "dc0efaf40fb58a21f52fd9a86c7ddfdc",
"assets/packages/country_flags/res/si/mh.si": "88c8196c37481de5021237e01ccb95a1",
"assets/packages/country_flags/res/si/tc.si": "78d2718e865371288caf216fb083c8bd",
"assets/packages/country_flags/res/si/gb-wls.si": "bb7216967d97426e1d684b2745118f89",
"assets/packages/country_flags/res/si/qa.si": "534abea02d79321b510b2a3fb040ffbc",
"assets/packages/country_flags/res/si/it.si": "c472c6bc7844cc6633d4e41d139b282c",
"assets/packages/country_flags/res/si/lb.si": "d2268cc1967d63699bb1ff2a87264c75",
"assets/packages/country_flags/res/si/eg.si": "eb6351aaa487d5e422ecd8f1160ada0d",
"assets/packages/country_flags/res/si/mp.si": "48f591d6c4a1e7aab511bcc750536836",
"assets/packages/country_flags/res/si/cw.si": "8c2327f9686e6183f85b4141294f7944",
"assets/packages/country_flags/res/si/sd.si": "c6e5b30fafc73d2d84b45a10c6053568",
"assets/packages/country_flags/res/si/hk.si": "cdc28623f40113eb4227c9ed796b6201",
"assets/packages/country_flags/res/si/na.si": "d49f748db27e5d6f63293f41c2e8361e",
"assets/packages/country_flags/res/si/sx.si": "424c70f52c10927bd40135e75d958e8b",
"assets/packages/country_flags/res/si/fk.si": "bcdc2242f7af2a72255f8d89d2642fe8",
"assets/packages/country_flags/res/si/xk.si": "967bec40d36ab8264262777667c5da33",
"assets/packages/country_flags/res/si/mm.si": "3ab23c7fcc44e249de75e6019af32611",
"assets/packages/country_flags/res/si/ta.si": "084b17449dd0ba76474f133039ee68d3",
"assets/packages/country_flags/res/si/bh.si": "637d8c9177fdc8bf98d2afb4de3a3cbe",
"assets/packages/country_flags/res/si/co.si": "471a020ee0695a4be6867c76e3e4fcdf",
"assets/packages/country_flags/res/si/sl.si": "a0d669d7821909f6b73d73ebd29e77e7",
"assets/packages/country_flags/res/si/mn.si": "d7d59010e2822958f8390d72bfbf0072",
"assets/packages/awesome_notifications/test/assets/images/test_image.png": "c27a71ab4008c83eba9b554775aa12ca",
"assets/FontManifest.json": "532dfe4c3fe55e1bee28510a8c816a5a",
"assets/AssetManifest.bin": "dffa0ce2a715b57fa1e1a2267500f6ea",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "90823f84f6800400a987c3d7886d1b9a",
"sqlite3.wasm": "a4fe605c530a5e5dfd4819303dc75829",
"flutter_bootstrap.js": "c41bc26aa06221f572a1cd786419cbda",
"version.json": "1bbfd7fc654161fa5a0f58627b0a3481",
"main.dart.js": "d4299eb5a123ec576484737bd94efbb2"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
