// data.js 
const existingContributions = [{
        id: 'ex1',
        lat: 17.3850,
        lon: 78.4867,
        name: "Charminar Photo",
        user: "Pranjali",
        category: "Architecture"
    }, // Hyderabad, Charminar

    {
        id: 'ex2',
        lat: 17.445740,
        lon: 78.350472,
        category: "Text",
        file_url: "https://hel1.your-objectstorage.com/corpus-data/text/20250617_033952_bebfc99c.txt",
    },

    {
        id: 'ex2',
        lat: 17.445742,
        lon: 78.350482,
        category: "Image",
        name: "Viswam AI Location",
        file_url: "https://hel1.your-objectstorage.com/corpus-data/image/20250617_034034_c05752a2.jpg",
    },
    {
        id : 'ex4',
        lat: 17.4457368,
        lon: 78.3504583,
        category: "Audio",
        file_url: "https://hel1.your-objectstorage.com/corpus-data/audio/20250617_034112_d0e2dbbf.m4a",
    },
    {
        id: 'ex5',
        lat: 16.378378,
        lon: 80.510315,
        category: "Image",
        file_url: "https://hel1.your-objectstorage.com/corpus-data/image/20250617_065642_d2463cbf.jpg",
    },
    {
        id: 'ex6',
        lat: 12.9205729,
        lon: 77.6511682,
        category: "Audio"
    },
    {
        id: 'ex7',
        lat: 12.9207133,
        lon: 77.6512776,
        category: "Video",
    },
    {
        id: 'ex8',
        lat: 15.7675653,
        lon: 79.2810686,
        category: "Image",
    },
    {
        id: 'ex9',
        lat: 18.4499477,
        lon: 79.1162416,
        caregory: "Text",
        file_url: "https://hel1.your-objectstorage.com/corpus-data/text/20250619_113222_74a965a1.txt"

    },
]
const potentialcontributionareas = [{
        id: 'pot1',
        lat: 17.8333,
        lon: 79.0833
    }, {
        id: 'pot2',
        lat: 21.14631,
        lon: 79.08491
    }, {
        id: 'pot3',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot4',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot5',
        lat: 26.7033695,
        lon: 88.3637613
    }, {
        id: 'pot6',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot7',
        lat: 22.4949,
        lon: 88.4366
    }, {
        id: 'pot8',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot9',
        lat: 26.83928,
        lon: 80.92313
    }, {
        id: 'pot10',
        lat: 15.8309251,
        lon: 78.0425373
    }, {
        id: 'pot11',
        lat: 26.58333,
        lon: 87.91667
    }, {
        id: 'pot12',
        lat: 16.81259312,
        lon: 79.32299115
    }, {
        id: 'pot13',
        lat: 31.09823,
        lon: -97.34278
    }, {
        id: 'pot14',
        lat: 17.2717124,
        lon: 80.1412212
    }, {
        id: 'pot15',
        lat: 25.52792079,
        lon: 82.0580056
    }, {
        id: 'pot16',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot17',
        lat: 17.4627975,
        lon: 78.3607601
    },

    {
        id: 'pot18',
        lat: 16.795,
        lon: 79.543
    }, {
        id: 'pot19',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot20',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot21',
        lat: 17.5179,
        lon: 78.3828
    }, {
        id: 'pot22',
        lat: 17.4747737,
        lon: 78.3963608
    }, {
        id: 'pot23',
        lat: 13.5543846,
        lon: 78.5054843
    }, {
        id: 'pot24',
        lat: 17.4568104,
        lon: 78.4329534
    }, {
        id: 'pot25',
        lat: 18.01009,
        lon: 79.56936
    }, {
        id: 'pot26',
        lat: 17.4556078,
        lon: 78.4292796
    }, {
        id: 'pot27',
        lat: 13.03841429,
        lon: 77.61564816
    }, {
        id: 'pot28',
        lat: 13.6316368,
        lon: 79.4231711
    }, {
        id: 'pot29',
        lat: 17.47510993,
        lon: 78.34658903
    }, {
        id: 'pot30',
        lat: 18.0439402,
        lon: 78.2637489
    }, {
        id: 'pot31',
        lat: 38.07086,
        lon: -95.36554
    }, {
        id: 'pot32',
        lat: 17.5960476,
        lon: 78.5762193
    }, {
        id: 'pot33',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot34',
        lat: 17.4251,
        lon: 78.4248
    },

    {
        id: 'pot35',
        lat: 27.42397,
        lon: 77.09922
    }, {
        id: 'pot36',
        lat: 45.57034,
        lon: 3.30319
    }, {
        id: 'pot37',
        lat: 17.3475631,
        lon: 78.426629
    }, {
        id: 'pot38',
        lat: 17.51990968,
        lon: 78.39795305
    }, {
        id: 'pot39',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot40',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot41',
        lat: 19.0222,
        lon: 79.1276
    }, {
        id: 'pot42',
        lat: 17.4762579,
        lon: 78.3150218
    }, {
        id: 'pot43',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot44',
        lat: 45.7281332,
        lon: 24.9042134
    }, {
        id: 'pot45',
        lat: 17.5675684,
        lon: 78.1999798
    }, {
        id: 'pot46',
        lat: 17.2414312,
        lon: 80.1407979
    }, {
        id: 'pot47',
        lat: 15.805935,
        lon: 78.0434885
    }, {
        id: 'pot48',
        lat: 17.43891067,
        lon: 78.48250853
    }, {
        id: 'pot49',
        lat: 12.99667,
        lon: 80.25306
    }, {
        id: 'pot50',
        lat: 17.496673,
        lon: 78.3671766
    }, {
        id: 'pot51',
        lat: 18.01349895,
        lon: 79.53628464
    },

    {
        id: 'pot52',
        lat: 17.8333,
        lon: 79.0833
    }, {
        id: 'pot53',
        lat: 17.1912302,
        lon: 81.6781217
    }, {
        id: 'pot54',
        lat: 25.18254,
        lon: 75.83907
    }, {
        id: 'pot55',
        lat: 26.4609135,
        lon: 80.3217588
    }, {
        id: 'pot56',
        lat: 18.5916,
        lon: 77.7972398
    }, {
        id: 'pot57',
        lat: 17.4992724,
        lon: 78.3568843
    }, {
        id: 'pot58',
        lat: 16.96036,
        lon: 82.23809
    }, {
        id: 'pot59',
        lat: 17.46728574,
        lon: 78.26344627
    }, {
        id: 'pot60',
        lat: 17.8333,
        lon: 79.0833
    }, {
        id: 'pot61',
        lat: 17.18051651,
        lon: 78.48672367
    }, {
        id: 'pot62',
        lat: 16.72496186,
        lon: 81.11420267
    },

    {
        id: 'pot63',
        lat: 18.41102,
        lon: 83.37677
    }, {
        id: 'pot64',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot65',
        lat: 17.4190342,
        lon: 78.442798
    }, {
        id: 'pot66',
        lat: 17.6994351,
        lon: 83.4697024
    }, {
        id: 'pot67',
        lat: 25.6166342,
        lon: 85.1728204
    }, {
        id: 'pot68',
        lat: 26.83928,
        lon: 80.92313
    }, {
        id: 'pot69',
        lat: 17.5589,
        lon: 78.0133
    }, {
        id: 'pot70',
        lat: 13.5503,
        lon: 78.50288
    }, {
        id: 'pot71',
        lat: 17.37047538,
        lon: 78.42508484
    }, {
        id: 'pot72',
        lat: 17.53615228,
        lon: 78.32386617
    }, {
        id: 'pot73',
        lat: 15.7758859,
        lon: 77.4786813
    }, {
        id: 'pot74',
        lat: 19.16023,
        lon: 77.31497
    }, {
        id: 'pot75',
        lat: 16.96036,
        lon: 82.23809
    }, {
        id: 'pot76',
        lat: 17.51442746,
        lon: 78.28774509
    }, {
        id: 'pot77',
        lat: 17.38405,
        lon: 78.45636
    }, {
        id: 'pot78',
        lat: 16.57868,
        lon: 82.00609
    }, {
        id: 'pot79',
        lat: 17.8333,
        lon: 79.0833
    },

    {
        id: 'pot80',
        lat: 16.17813323,
        lon: 80.00610507
    }, {
        id: 'pot81',
        lat: 14.72477128,
        lon: 78.95949294
    }, {
        id: 'pot82',
        lat: 17.21357345,
        lon: 82.31908831
    }, {
        id: 'pot83',
        lat: 17.08995342,
        lon: 81.86662784
    }, {
        id: 'pot84',
        lat: 14.65301676,
        lon: 79.60013284
    }, {
        id: 'pot85',
        lat: 15.74056592,
        lon: 78.00847991
    }, {
        id: 'pot86',
        lat: 18.16677152,
        lon: 83.3883013
    }, {
        id: 'pot87',
        lat: 16.42575892,
        lon: 81.97269353
    }, {
        id: 'pot88',
        lat: 15.89046618,
        lon: 80.44203027
    }, {
        id: 'pot89',
        lat: 17.75263728,
        lon: 83.18152252
    }, {
        id: 'pot90',
        lat: 17.06043603,
        lon: 81.84188962
    }, {
        id: 'pot91',
        lat: 15.57944324,
        lon: 79.87949772
    }, {
        id: 'pot92',
        lat: 18.07631008,
        lon: 83.2847593
    }, {
        id: 'pot93',
        lat: 15.78910732,
        lon: 80.37171352
    }, {
        id: 'pot94',
        lat: 14.37271197,
        lon: 77.28269882
    }, {
        id: 'pot95',
        lat: 18.7697275,
        lon: 83.88344265
    }, {
        id: 'pot96',
        lat: 16.21238553,
        lon: 81.17107216
    }, {
        id: 'pot97',
        lat: 17.68300331,
        lon: 83.02561791
    },

    {
        id: 'pot98',
        lat: 17.73199357,
        lon: 83.31435297
    }, {
        id: 'pot99',
        lat: 17.68796,
        lon: 80.91290117
    }, {
        id: 'pot100',
        lat: 14.52083428,
        lon: 78.78505027
    }, {
        id: 'pot101',
        lat: 15.91428889,
        lon: 80.48884574
    }, {
        id: 'pot102',
        lat: 16.19904086,
        lon: 80.0862617
    }, {
        id: 'pot103',
        lat: 15.77444405,
        lon: 78.05683465
    }, {
        id: 'pot104',
        lat: 17.82246165,
        lon: 83.34255249
    }, {
        id: 'pot105',
        lat: 17.06957186,
        lon: 81.86723341
    }, {
        id: 'pot106',
        lat: 13.72020284,
        lon: 79.99122445
    }, {
        id: 'pot107',
        lat: 16.31934552,
        lon: 80.43842718
    }, {
        id: 'pot108',
        lat: 13.6516624,
        lon: 78.78459144
    }, {
        id: 'pot109',
        lat: 16.14781318,
        lon: 80.00204044
    }, {
        id: 'pot110',
        lat: 18.15119133,
        lon: 83.37568013
    }, {
        id: 'pot111',
        lat: 14.47716881,
        lon: 78.76512483
    }, {
        id: 'pot112',
        lat: 12.72201781,
        lon: 78.36042911
    }, {
        id: 'pot113',
        lat: 16.74921532,
        lon: 80.6348689
    }, {
        id: 'pot114',
        lat: 17.43385541,
        lon: 81.77823989
    }, {
        id: 'pot115',
        lat: 16.20875999,
        lon: 80.0848391
    }, {
        id: 'pot116',
        lat: 16.64162609,
        lon: 80.42463294
    }, {
        id: 'pot117',
        lat: 14.15795733,
        lon: 79.85642465
    },

    {
        id: 'pot118',
        lat: 16.19997205,
        lon: 80.05565178
    }, {
        id: 'pot119',
        lat: 16.48308431,
        lon: 79.36822469
    }, {
        id: 'pot120',
        lat: 17.08368716,
        lon: 82.0536532
    }, {
        id: 'pot121',
        lat: 15.22778553,
        lon: 79.87466968
    }, {
        id: 'pot122',
        lat: 16.83910077,
        lon: 82.2251154
    }, {
        id: 'pot123',
        lat: 16.25511078,
        lon: 80.32588557
    }, {
        id: 'pot124',
        lat: 16.62394763,
        lon: 80.46377924
    }, {
        id: 'pot125',
        lat: 17.99439226,
        lon: 83.41419145
    }, {
        id: 'pot126',
        lat: 16.68674258,
        lon: 81.02575742
    }, {
        id: 'pot127',
        lat: 16.54329606,
        lon: 81.4963218
    }, {
        id: 'pot128',
        lat: 14.4596535,
        lon: 78.8184
    }, {
        id: 'pot129',
        lat: 17.79918726,
        lon: 83.34720731
    }, {
        id: 'pot130',
        lat: 17.79906467,
        lon: 83.34714294
    }, {
        id: 'pot131',
        lat: 14.13419474,
        lon: 77.7862601
    }, {
        id: 'pot132',
        lat: 15.5060574,
        lon: 78.3756317
    }, {
        id: 'pot133',
        lat: 16.8373202,
        lon: 81.51860518
    }, {
        id: 'pot134',
        lat: 16.35108823,
        lon: 81.04261891
    }, {
        id: 'pot135',
        lat: 16.69527328,
        lon: 81.05064837
    }, {
        id: 'pot136',
        lat: 13.65908227,
        lon: 79.48998269
    }, {
        id: 'pot137',
        lat: 16.19778996,
        lon: 80.27213507
    },

    {
        id: 'pot138',
        lat: 18.2707225,
        lon: 83.80797988
    }, {
        id: 'pot139',
        lat: 16.85900951,
        lon: 81.4943739
    }, {
        id: 'pot140',
        lat: 16.28370955,
        lon: 81.19940364
    }, {
        id: 'pot141',
        lat: 16.25493368,
        lon: 80.48050264
    }, {
        id: 'pot142',
        lat: 15.44309602,
        lon: 78.51455122
    }, {
        id: 'pot143',
        lat: 16.2441486,
        lon: 80.09693589
    }, {
        id: 'pot144',
        lat: 16.84118199,
        lon: 82.01898385
    }, {
        id: 'pot145',
        lat: 16.05312845,
        lon: 80.53634911
    }, {
        id: 'pot146',
        lat: 17.71671342,
        lon: 83.17690906
    }, {
        id: 'pot147',
        lat: 16.62803439,
        lon: 80.67407987
    }, {
        id: 'pot148',
        lat: 13.6116004,
        lon: 78.48682973
    }, {
        id: 'pot149',
        lat: 16.45308415,
        lon: 80.98361497
    }, {
        id: 'pot150',
        lat: 16.912219,
        lon: 81.43721938
    }, {
        id: 'pot151',
        lat: 14.75940531,
        lon: 78.55725438
    },

    {
        id: 'pot152',
        lat: 26.14344961,
        lon: 91.6596164
    }, {
        id: 'pot153',
        lat: 24.79811435,
        lon: 92.48373122
    }, {
        id: 'pot154',
        lat: 26.43262857,
        lon: 90.23763102
    }, {
        id: 'pot155',
        lat: 26.47928006,
        lon: 90.30285301
    }, {
        id: 'pot156',
        lat: 27.51822267,
        lon: 94.48525792
    }, {
        id: 'pot157',
        lat: 27.47018904,
        lon: 94.98800311
    }, {
        id: 'pot158',
        lat: 26.13408421,
        lon: 91.62148563
    }, {
        id: 'pot159',
        lat: 26.55729039,
        lon: 93.96647145
    }, {
        id: 'pot160',
        lat: 26.75477443,
        lon: 94.2171597
    }, {
        id: 'pot161',
        lat: 26.75458283,
        lon: 94.21724553
    }, {
        id: 'pot162',
        lat: 26.08142966,
        lon: 91.56151866
    }, {
        id: 'pot163',
        lat: 26.74650826,
        lon: 94.24815769
    }, {
        id: 'pot164',
        lat: 26.786569,
        lon: 94.29096645
    }, {
        id: 'pot165',
        lat: 24.75868832,
        lon: 92.79246449
    }, {
        id: 'pot166',
        lat: 26.09617952,
        lon: 91.54100779
    }, {
        id: 'pot167',
        lat: 26.70083248,
        lon: 92.83110335
    }, {
        id: 'pot168',
        lat: 25.24878,
        lon: 84.66629,
        name: "Government Engineering College"
    }, {
        id: 'pot169',
        lat: 24.75389,
        lon: 84.37407,
        name: "Government Engineering College"
    }, {
        id: 'pot170',
        lat: 25.45931,
        lon: 85.53301,
        name: "Bakhtiyarpur College of Engineering"
    }, {
        id: 'pot171',
        lat: 25.24446,
        lon: 86.97183,
        name: "Bhagalpur College of Engineering"
    }, {
        id: 'pot172',
        lat: 25.80000,
        lon: 87.00000,
        name: "BP Mandal College of Engineering"
    }, {
        id: 'pot173',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot174',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot175',
        lat: 25.57473,
        lon: 83.97867,
        name: "M.I.T. Muzaffarpur"
    }, {
        id: 'pot176',
        lat: 25.69003,
        lon: 85.20954,
        name: "Nalanda College of Engineering, Chandi"
    }, {
        id: 'pot177',
        lat: 26.1795785,
        lon: 85.8642484,
        name: "Government Engineering College, Vaishali"
    }, {
        id: 'pot178',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot179',
        lat: 26.46734,
        lon: 84.44041,
        name: "Motihari College of Engineering"
    }, {
        id: 'pot180',
        lat: 24.88091,
        lon: 86.92257,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot181',
        lat: 25.30886,
        lon: 84.44504,
        name: "Rohtas College of Engineering and Technology"
    }, {
        id: 'pot182',
        lat: 25.1765,
        lon: 86.0947,
        name: "S.P. College of Engineering"
    }, {
        id: 'pot183',
        lat: 26.35367,
        lon: 86.07169,
        name: "Saharsa College of Engineering"
    }, {
        id: 'pot184',
        lat: 24.8867,
        lon: 85.54364,
        name: "Vaishali College of Engineering"
    }, {
        id: 'pot185',
        lat: 25.86077,
        lon: 85.78971,
        name: "Siwan College of Engineering"
    }, {
        id: 'pot186',
        lat: 25.13073,
        lon: 85.78176,
        name: "Sonepur College of Engineering"
    }, {
        id: 'pot187',
        lat: 26.51393,
        lon: 85.29341,
        name: "Bettiah College of Engineering"
    }, {
        id: 'pot188',
        lat: 25.75,
        lon: 85.41667,
        name: "Kishanganj College of Engineering"
    }, {
        id: 'pot189',
        lat: 25.75,
        lon: 85.75,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot190',
        lat: 25.24446,
        lon: 86.97183,
        name: "Bhagalpur College of Engineering"
    }, {
        id: 'pot191',
        lat: 25.5424381,
        lon: 84.8516072,
        name: "Gaya College of Engineering"
    }, {
        id: 'pot192',
        lat: 24.92589,
        lon: 86.22574,
        name: "Jamui College of Engineering"
    }, {
        id: 'pot193',
        lat: 25.20701,
        lon: 84.99573,
        name: "Jehanabad College of Engineering"
    }, {
        id: 'pot194',
        lat: 25.05077,
        lon: 83.58261,
        name: "Kaimur College of Engineering"
    }, {
        id: 'pot195',
        lat: 25.53852,
        lon: 87.57044,
        name: "Katihar College of Engineering"
    }, {
        id: 'pot196',
        lat: 25.51049,
        lon: 86.47627,
        name: "Khagaria College of Engineering"
    }, {
        id: 'pot197',
        lat: 26.3,
        lon: 88.0,
        name: "Madhepura College of Engineering"
    }, {
        id: 'pot198',
        lat: 25.781,
        lon: 84.73089,
        name: "Muzaffarpur Institute of Technology"
    }, {
        id: 'pot199',
        lat: 25.5861484,
        lon: 85.0958548,
        name: "Nalanda College of Engineering"
    }, {
        id: 'pot200',
        lat: 25.7989309,
        lon: 87.5048042,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot201',
        lat: 25.55972,
        lon: 84.87118,
        name: "Saran College of Engineering"
    }, {
        id: 'pot202',
        lat: 26.29857,
        lon: 87.2671,
        name: "Seemanchal Institute of Technology"
    }, {
        id: 'pot203',
        lat: 26.65738,
        lon: 84.91922,
        name: "Sitamarhi Institute of Technology"
    }, {
        id: 'pot204',
        lat: 25.37556,
        lon: 86.47352,
        name: "Supual College of Engineering"
    }, {
        id: 'pot205',
        lat: 26.12259,
        lon: 85.39055,
        name: "Vaishali Institute of Technology"
    }, {
        id: 'pot206',
        lat: 25.3203775,
        lon: 85.4110417,
        name: "MIT, Muzaffarpur"
    }, {
        id: 'pot207',
        lat: 25.60222,
        lon: 85.11936,
        name: "College of Agricultural Engineering, Pusa"
    }, {
        id: 'pot208',
        lat: 25.55972,
        lon: 84.87118,
        name: "MIT, Muzaffarpur"
    }, {
        id: 'pot209',
        lat: 25.75,
        lon: 85.41667,
        name: "Kishanganj College of Engineering"
    }, {
        id: 'pot210',
        lat: 25.7612593,
        lon: 87.4673783,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot211',
        lat: 25.60222,
        lon: 85.11936,
        name: "College of Agricultural Engineering, Pusa"
    }, {
        id: 'pot212',
        lat: 25.41853,
        lon: 86.13389,
        name: "B.P. Mandal College of Engineering"
    }, {
        id: 'pot213',
        lat: 25.8818916,
        lon: 86.6094658,
        name: "Motihari College of Engineering"
    }, {
        id: 'pot214',
        lat: 24.94872,
        lon: 84.01693,
        name: "Bakhtiyarpur College of Engineering"
    }, {
        id: 'pot215',
        lat: 26.14845,
        lon: 87.51404,
        name: "Katihar College of Engineering"
    }, {
        id: 'pot216',
        lat: 26.59357,
        lon: 85.4906,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot217',
        lat: 26.22152,
        lon: 84.35879,
        name: "Muzaffarpur Institute of Technology"
    }, {
        id: 'pot218',
        lat: 26.11503,
        lon: 86.59527,
        name: "S.P. College of Engineering"
    }, {
        id: 'pot219',
        lat: 25.7420371,
        lon: 87.461033,
        name: "Saharsa College of Engineering"
    }, {
        id: 'pot220',
        lat: 25.57473,
        lon: 83.97867,
        name: "M.I.T. Muzaffarpur"
    }, {
        id: 'pot221',
        lat: 26.15216,
        lon: 85.89707,
        name: "Vaishali College of Engineering"
    }, {
        id: 'pot222',
        lat: 21.19441556,
        lon: 81.29909449
    }, {
        id: 'pot223',
        lat: 21.16348601,
        lon: 81.65909307
    }, {
        id: 'pot224',
        lat: 22.13693135,
        lon: 82.13010107
    }, {
        id: 'pot225',
        lat: 19.10102282,
        lon: 81.98175074
    }, {
        id: 'pot226',
        lat: 22.13179957,
        lon: 82.12806014
    }, {
        id: 'pot227',
        lat: 23.12797808,
        lon: 83.18352785
    }, {
        id: 'pot228',
        lat: 22.40936873,
        lon: 82.7217424
    }, {
        id: 'pot229',
        lat: 21.24769993,
        lon: 81.31881849
    }, {
        id: 'pot230',
        lat: 22.13184209,
        lon: 82.1421549
    }, {
        id: 'pot231',
        lat: 21.12866453,
        lon: 81.76614394
    }, {
        id: 'pot232',
        lat: 21.89342884,
        lon: 83.40418721
    }, {
        id: 'pot233',
        lat: 21.85752855,
        lon: 83.41060214
    }, {
        id: 'pot234',
        lat: 21.15659855,
        lon: 81.66334035
    }, {
        id: 'pot235',
        lat: 21.23536238,
        lon: 81.80071863
    }, {
        id: 'pot236',
        lat: 21.2649141,
        lon: 81.34847661
    }, {
        id: 'pot237',
        lat: 21.23990528,
        lon: 81.30340345
    }, {
        id: 'pot238',
        lat: 21.13486197,
        lon: 81.66853497
    }, {
        id: 'pot239',
        lat: 28.5806,
        lon: 77.0672,
        name: "Dwarka, Delhi"
    }, {
        id: 'pot240',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot241',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot242',
        lat: 28.70113,
        lon: 77.10154,
        name: "Netaji Subhas University of Technology, Dwarka"
    }, {
        id: 'pot243',
        lat: 28.64857,
        lon: 77.21895,
        name: "India Gate, New Delhi"
    }, {
        id: 'pot244',
        lat: 28.64857,
        lon: 77.21895,
        name: "India Gate, New Delhi"
    }, {
        id: 'pot245',
        lat: 28.70113,
        lon: 77.10154,
        name: "Netaji Subhas University of Technology, Dwarka"
    }, {
        id: 'pot246',
        lat: 28.6109477,
        lon: 77.0384563,
        name: "Indira Gandhi International Airport, Delhi"
    }, {
        id: 'pot247',
        lat: 28.65381,
        lon: 77.22897,
        name: "Red Fort, Delhi"
    }, {
        id: 'pot248',
        lat: 28.6644604,
        lon: 77.2326063,
        name: "Feroz Shah Kotla Ground, Delhi"
    }, {
        id: 'pot249',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot250',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot251',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot252',
        lat: 28.6869,
        lon: 77.30195,
        name: "Dilshad Garden, Delhi"
    }, {
        id: 'pot253',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot254',
        lat: 28.65381,
        lon: 77.22897,
        name: "Red Fort, Delhi"
    }, {
        id: 'pot255',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot256',
        lat: 28.53009,
        lon: 77.25174,
        name: "Okhla Industrial Area, Delhi"
    }, {
        id: 'pot257',
        lat: 28.64857,
        lon: 77.21895,
        name: "India Gate, New Delhi"
    }, {
        id: 'pot258',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot259',
        lat: 28.65381,
        lon: 77.22897,
        name: "Red Fort, Delhi"
    }, {
        id: 'pot260',
        lat: 28.53009,
        lon: 77.25174,
        name: "Okhla Industrial Area, Delhi"
    }, {
        id: 'pot261',
        lat: 28.53009,
        lon: 77.25174,
        name: "Okhla Industrial Area, Delhi"
    }, {
        id: 'pot262',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot263',
        lat: 28.65655,
        lon: 77.10068,
        name: "Janakpuri, Delhi"
    }, {
        id: 'pot264',
        lat: 28.6316975,
        lon: 77.1165416,
        name: "Kirby Place, Delhi Cantt"
    }, {
        id: 'pot265',
        lat: 28.7196184,
        lon: 77.0661762,
        name: "Rohini, Delhi"
    }, {
        id: 'pot266',
        lat: 28.6216,
        lon: 77.09458,
        name: "Rajouri Garden, Delhi"
    }, {
        id: 'pot267',
        lat: 28.6869,
        lon: 77.30195,
        name: "Dilshad Garden, Delhi"
    }, {
        id: 'pot268',
        lat: 28.70113,
        lon: 77.10154,
        name: "Netaji Subhas University of Technology, Dwarka"
    }, {
        id: 'pot269',
        lat: 28.7374225,
        lon: 77.1121051,
        name: "Narela, Delhi"
    }, {
        id: 'pot270',
        lat: 28.66242,
        lon: 77.29122,
        name: "Yamuna Sports Complex, Delhi"
    }, {
        id: 'pot271',
        lat: 28.5806,
        lon: 77.0672,
        name: "Dwarka, Delhi"
    }, {
        id: 'pot272',
        lat: 25.24878,
        lon: 84.66629,
        name: "Government Engineering College"
    }, {
        id: 'pot273',
        lat: 24.75389,
        lon: 84.37407,
        name: "Government Engineering College"
    }, {
        id: 'pot274',
        lat: 25.45931,
        lon: 85.53301,
        name: "Bakhtiyarpur College of Engineering"
    }, {
        id: 'pot275',
        lat: 25.24446,
        lon: 86.97183,
        name: "Bhagalpur College of Engineering"
    }, {
        id: 'pot276',
        lat: 25.80000,
        lon: 87.00000,
        name: "BP Mandal College of Engineering"
    }, {
        id: 'pot277',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot278',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot279',
        lat: 25.57473,
        lon: 83.97867,
        name: "M.I.T. Muzaffarpur"
    }, {
        id: 'pot280',
        lat: 25.69003,
        lon: 85.20954,
        name: "Nalanda College of Engineering, Chandi"
    }, {
        id: 'pot281',
        lat: 26.1795785,
        lon: 85.8642484,
        name: "Government Engineering College, Vaishali"
    }, {
        id: 'pot282',
        lat: 24.79686,
        lon: 85.00385,
        name: "K.K. College of Engineering and Management"
    }, {
        id: 'pot283',
        lat: 26.46734,
        lon: 84.44041,
        name: "Motihari College of Engineering"
    }, {
        id: 'pot284',
        lat: 24.88091,
        lon: 86.92257,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot285',
        lat: 25.30886,
        lon: 84.44504,
        name: "Rohtas College of Engineering and Technology"
    }, {
        id: 'pot286',
        lat: 25.1765,
        lon: 86.0947,
        name: "S.P. College of Engineering"
    }, {
        id: 'pot287',
        lat: 26.35367,
        lon: 86.07169,
        name: "Saharsa College of Engineering"
    }, {
        id: 'pot288',
        lat: 24.8867,
        lon: 85.54364,
        name: "Vaishali College of Engineering"
    }, {
        id: 'pot289',
        lat: 25.86077,
        lon: 85.78971,
        name: "Siwan College of Engineering"
    }, {
        id: 'pot290',
        lat: 25.13073,
        lon: 85.78176,
        name: "Sonepur College of Engineering"
    }, {
        id: 'pot291',
        lat: 26.51393,
        lon: 85.29341,
        name: "Bettiah College of Engineering"
    }, {
        id: 'pot292',
        lat: 25.75,
        lon: 85.41667,
        name: "Kishanganj College of Engineering"
    }, {
        id: 'pot293',
        lat: 25.75,
        lon: 85.75,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot294',
        lat: 25.24446,
        lon: 86.97183,
        name: "Bhagalpur College of Engineering"
    }, {
        id: 'pot295',
        lat: 25.5424381,
        lon: 84.8516072,
        name: "Gaya College of Engineering"
    }, {
        id: 'pot296',
        lat: 24.92589,
        lon: 86.22574,
        name: "Jamui College of Engineering"
    }, {
        id: 'pot297',
        lat: 25.20701,
        lon: 84.99573,
        name: "Jehanabad College of Engineering"
    }, {
        id: 'pot298',
        lat: 25.05077,
        lon: 83.58261,
        name: "Kaimur College of Engineering"
    }, {
        id: 'pot299',
        lat: 25.53852,
        lon: 87.57044,
        name: "Katihar College of Engineering"
    }, {
        id: 'pot300',
        lat: 25.51049,
        lon: 86.47627,
        name: "Khagaria College of Engineering"
    }, {
        id: 'pot301',
        lat: 26.3,
        lon: 88.0,
        name: "Madhepura College of Engineering"
    }, {
        id: 'pot302',
        lat: 25.781,
        lon: 84.73089,
        name: "Muzaffarpur Institute of Technology"
    }, {
        id: 'pot303',
        lat: 25.5861484,
        lon: 85.0958548,
        name: "Nalanda College of Engineering"
    }, {
        id: 'pot304',
        lat: 25.7989309,
        lon: 87.5048042,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot305',
        lat: 25.55972,
        lon: 84.87118,
        name: "Saran College of Engineering"
    }, {
        id: 'pot306',
        lat: 26.29857,
        lon: 87.2671,
        name: "Seemanchal Institute of Technology"
    }, {
        id: 'pot307',
        lat: 26.65738,
        lon: 84.91922,
        name: "Sitamarhi Institute of Technology"
    }, {
        id: 'pot308',
        lat: 25.37556,
        lon: 86.47352,
        name: "Supual College of Engineering"
    }, {
        id: 'pot309',
        lat: 26.12259,
        lon: 85.39055,
        name: "Vaishali Institute of Technology"
    }, {
        id: 'pot310',
        lat: 25.3203775,
        lon: 85.4110417,
        name: "MIT, Muzaffarpur"
    }, {
        id: 'pot311',
        lat: 25.60222,
        lon: 85.11936,
        name: "College of Agricultural Engineering, Pusa"
    }, {
        id: 'pot312',
        lat: 25.55972,
        lon: 84.87118,
        name: "MIT, Muzaffarpur"
    }, {
        id: 'pot313',
        lat: 25.75,
        lon: 85.41667,
        name: "Kishanganj College of Engineering"
    }, {
        id: 'pot314',
        lat: 25.7612593,
        lon: 87.4673783,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot315',
        lat: 25.60222,
        lon: 85.11936,
        name: "College of Agricultural Engineering, Pusa"
    }, {
        id: 'pot316',
        lat: 25.41853,
        lon: 86.13389,
        name: "B.P. Mandal College of Engineering"
    }, {
        id: 'pot317',
        lat: 25.8818916,
        lon: 86.6094658,
        name: "Motihari College of Engineering"
    }, {
        id: 'pot318',
        lat: 24.94872,
        lon: 84.01693,
        name: "Bakhtiyarpur College of Engineering"
    }, {
        id: 'pot319',
        lat: 26.14845,
        lon: 87.51404,
        name: "Katihar College of Engineering"
    }, {
        id: 'pot320',
        lat: 26.59357,
        lon: 85.4906,
        name: "Purnea College of Engineering"
    }, {
        id: 'pot321',
        lat: 26.22152,
        lon: 84.35879,
        name: "Muzaffarpur Institute of Technology"
    }, {
        id: 'pot322',
        lat: 26.11503,
        lon: 86.59527,
        name: "S.P. College of Engineering"
    }, {
        id: 'pot323',
        lat: 25.7420371,
        lon: 87.461033,
        name: "Saharsa College of Engineering"
    }, {
        id: 'pot324',
        lat: 25.57473,
        lon: 83.97867,
        name: "M.I.T. Muzaffarpur"
    }, {
        id: 'pot325',
        lat: 26.15216,
        lon: 85.89707,
        name: "Vaishali College of Engineering"
    }, {
        id: 'pot326',
        lat: 15.420282,
        lon: 73.980485,
        name: "Goa College of Engineering"
    }, {
        id: 'pot327',
        lat: 15.409270,
        lon: 73.788690,
        name: "Indian Institute of Technology (IIT) Goa"
    }, {
        id: 'pot328',
        lat: 15.204250,
        lon: 74.167330,
        name: "Padre Conceição College of Engineering"
    }, {
        id: 'pot329',
        lat: 15.204250,
        lon: 74.167330,
        name: "Shree Rayeshwar Institute of Engineering & Information Technology"
    }, {
        id: 'pot330',
        lat: 15.409270,
        lon: 73.788690,
        name: "National Institute of Technology (NIT) Goa"
    }, {
        id: 'pot331',
        lat: 15.300000,
        lon: 74.000000,
        name: "Don Bosco College of Engineering"
    }, {
        id: 'pot332',
        lat: 15.409270,
        lon: 73.788690,
        name: "Goa Institute of Management"
    }, {
        id: 'pot333',
        lat: 15.300000,
        lon: 74.000000,
        name: "Goa University"
    }, {
        id: 'pot334',
        lat: 15.400000,
        lon: 73.800000,
        name: "BITS Pilani K.K. Birla Goa Campus"
    }, {
        id: 'pot335',
        lat: 15.300000,
        lon: 74.000000,
        name: "P.E.S. College of Engineering"
    }, {
        id: 'pot336',
        lat: 15.300000,
        lon: 74.000000,
        name: "Goa College of Pharmacy"
    }, {
        id: 'pot337',
        lat: 15.300000,
        lon: 74.000000,
        name: "Goa College of Architecture"
    }, {
        id: 'pot338',
        lat: 15.300000,
        lon: 74.000000,
        name: "Goa College of Art"
    }, {
        id: 'pot339',
        lat: 24.170970,
        lon: 72.438210,
        name: "Government Engineering College"
    }, {
        id: 'pot340',
        lat: 23.809583,
        lon: 72.103377,
        name: "Government Engineering College"
    }, {
        id: 'pot341',
        lat: 23.025790,
        lon: 72.587270,
        name: "L.D.College Of Engineering"
    }, {
        id: 'pot342',
        lat: 22.817310,
        lon: 70.837700,
        name: "L.E.College"
    }, {
        id: 'pot343',
        lat: 21.666670,
        lon: 71.833330,
        name: "Shantilal Shah Engineering College"
    }, {
        id: 'pot344',
        lat: 22.296310,
        lon: 73.197020,
        name: "Birla Vishvakarma Mahavidyalaya"
    }, {
        id: 'pot345',
        lat: 21.180290,
        lon: 72.827360,
        name: "Sardar Vallabhbhai National Institute of Technology (SVNIT)"
    }, {
        id: 'pot346',
        lat: 23.076320,
        lon: 72.544170,
        name: "Ahmedabad University"
    }, {
        id: 'pot347',
        lat: 22.307187,
        lon: 73.181219,
        name: "Maharaja Sayajirao University of Baroda"
    }, {
        id: 'pot348',
        lat: 23.215635,
        lon: 72.636940,
        name: "Dhirubhai Ambani Institute of Information and Communication Technology (DA-IICT)"
    }, {
        id: 'pot349',
        lat: 23.022505,
        lon: 72.571362,
        name: "Gujarat University"
    }, {
        id: 'pot350',
        lat: 23.022505,
        lon: 72.571362,
        name: "Nirma University"
    }, {
        id: 'pot351',
        lat: 23.022505,
        lon: 72.571362,
        name: "CEPT University"
    }, {
        id: 'pot352',
        lat: 22.307187,
        lon: 73.181219,
        name: "Faculty of Technology and Engineering, MSU"
    }, {
        id: 'pot353',
        lat: 23.022505,
        lon: 72.571362,
        name: "Institute of Technology, Nirma University"
    }, {
        id: 'pot354',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Valsad"
    }, {
        id: 'pot355',
        lat: 23.022505,
        lon: 72.571362,
        name: "Vishwakarma Government Engineering College"
    }, {
        id: 'pot356',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Palanpur"
    }, {
        id: 'pot357',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Modasa"
    }, {
        id: 'pot358',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Patan"
    }, {
        id: 'pot359',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Rajkot"
    }, {
        id: 'pot360',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Bhavnagar"
    }, {
        id: 'pot361',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Dahod"
    }, {
        id: 'pot362',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Godhra"
    }, {
        id: 'pot363',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Himatnagar"
    }, {
        id: 'pot364',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Bhuj"
    }, {
        id: 'pot365',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Junagadh"
    }, {
        id: 'pot366',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Porbandar"
    }, {
        id: 'pot367',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Surat"
    }, {
        id: 'pot368',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Gandhinagar"
    }, {
        id: 'pot369',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Mehsana"
    }, {
        id: 'pot370',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Morbi"
    }, {
        id: 'pot371',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Surendranagar"
    }, {
        id: 'pot372',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Vyara"
    }, {
        id: 'pot373',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Bardoli"
    }, {
        id: 'pot374',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Anand"
    }, {
        id: 'pot375',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Bharuch"
    }, {
        id: 'pot376',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Amreli"
    }, {
        id: 'pot377',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Botad"
    }, {
        id: 'pot378',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Devbhumi Dwarka"
    }, {
        id: 'pot379',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Gir Somnath"
    }, {
        id: 'pot380',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Jamnagar"
    }, {
        id: 'pot381',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Kutch"
    }, {
        id: 'pot382',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Mahisagar"
    }, {
        id: 'pot383',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Narmada"
    }, {
        id: 'pot384',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Navsari"
    }, {
        id: 'pot385',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Panchmahal"
    }, {
        id: 'pot386',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Sabarkantha"
    }, {
        id: 'pot387',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Tapi"
    }, {
        id: 'pot388',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Vadodara"
    }, {
        id: 'pot389',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Chhota Udaipur"
    }, {
        id: 'pot390',
        lat: 22.307187,
        lon: 73.181219,
        name: "Government Engineering College, Aravalli"
    }, {
        id: 'pot391',
        lat: 23.022505,
        lon: 72.571362,
        name: "Government Engineering College, Dahod"
    }, {
        id: 'pot392',
        lat: 29.39005,
        lon: 76.96949,
        name: "Asia Pacific Institute of Information Technology SD India"
    }, {
        id: 'pot393',
        lat: 29.25000,
        lon: 76.33333,
        name: "AL Institute of Engineering and Technology"
    }, {
        id: 'pot394',
        lat: 30.41667,
        lon: 77.16667,
        name: "Ambala College of Engineering & Applied Research"
    }, {
        id: 'pot395',
        lat: 28.46010,
        lon: 77.02635,
        name: "Anupama College of Engineering"
    }, {
        id: 'pot396',
        lat: 28.24737,
        lon: 77.06544,
        name: "Apeejay Engineering College"
    }, {
        id: 'pot397',
        lat: 28.84755,
        lon: 77.07340,
        name: "BM College of Technology & Management"
    }, {
        id: 'pot398',
        lat: 28.98333,
        lon: 76.06667,
        name: "Deenbandhu Chhotu Ram University of Science and Technology"
    }, {
        id: 'pot399',
        lat: 29.08333,
        lon: 76.33333,
        name: "Guru Jambheshwar University of Science and Technology"
    }, {
        id: 'pot400',
        lat: 29.38333,
        lon: 76.96667,
        name: "National Institute of Technology, Kurukshetra"
    }, {
        id: 'pot401',
        lat: 28.89552,
        lon: 76.06947,
        name: "Maharshi Dayanand University"
    }, {
        id: 'pot402',
        lat: 29.25000,
        lon: 76.33333,
        name: "YMCA University of Science and Technology"
    }, {
        id: 'pot403',
        lat: 28.38333,
        lon: 77.31667,
        name: "Manav Rachna International University"
    }, {
        id: 'pot404',
        lat: 28.48333,
        lon: 77.03333,
        name: "Amity University, Gurgaon"
    }, {
        id: 'pot405',
        lat: 28.40000,
        lon: 77.00000,
        name: "KR Mangalam University"
    }, {
        id: 'pot406',
        lat: 28.46010,
        lon: 77.02635,
        name: "G. D. Goenka University"
    }, {
        id: 'pot407',
        lat: 28.24737,
        lon: 77.06544,
        name: "NorthCap University"
    }, {
        id: 'pot408',
        lat: 28.84755,
        lon: 77.07340,
        name: "Lingaya's University"
    }, {
        id: 'pot409',
        lat: 28.98333,
        lon: 76.06667,
        name: "Maharaja Agrasen University"
    }, {
        id: 'pot410',
        lat: 29.08333,
        lon: 76.33333,
        name: "SRM University, Sonepat"
    }, {
        id: 'pot411',
        lat: 29.38333,
        lon: 76.96667,
        name: "Ansal University"
    }, {
        id: 'pot412',
        lat: 28.89552,
        lon: 76.06947,
        name: "World University of Design"
    }, {
        id: 'pot413',
        lat: 29.25000,
        lon: 76.33333,
        name: "Jind Institute of Engineering and Technology"
    }, {
        id: 'pot414',
        lat: 28.38333,
        lon: 77.31667,
        name: "P.D.M. University"
    }, {
        id: 'pot415',
        lat: 28.48333,
        lon: 77.03333,
        name: "St.are University"
    }, {
        id: 'pot416',
        lat: 28.40000,
        lon: 77.00000,
        name: "Maharaja Surajmal Institute of Technology"
    }, {
        id: 'pot417',
        lat: 28.46010,
        lon: 77.02635,
        name: "Delhi Technological University"
    }, {
        id: 'pot418',
        lat: 28.24737,
        lon: 77.06544,
        name: "Indraprastha Institute of Information Technology, Delhi"
    }, {
        id: 'pot419',
        lat: 28.84755,
        lon: 77.07340,
        name: "Netaji Subhas University of Technology"
    }, {
        id: 'pot420',
        lat: 28.98333,
        lon: 76.06667,
        name: "Guru Gobind Singh Indraprastha University"
    }, {
        id: 'pot421',
        lat: 29.08333,
        lon: 76.33333,
        name: "Jamia Millia Islamia"
    }, {
        id: 'pot422',
        lat: 29.38333,
        lon: 76.96667,
        name: "Indian Institute of Technology Delhi"
    }, {
        id: 'pot423',
        lat: 28.89552,
        lon: 76.06947,
        name: "National Brain Research Centre"
    }, {
        id: 'pot424',
        lat: 29.25000,
        lon: 76.33333,
        name: "Delhi University"
    }, {
        id: 'pot425',
        lat: 28.38333,
        lon: 77.31667,
        name: "Jawaharlal Nehru University"
    }, {
        id: 'pot426',
        lat: 28.48333,
        lon: 77.03333,
        name: "All India Institute of Medical Sciences (AIIMS)"
    }, {
        id: 'pot427',
        lat: 28.40000,
        lon: 77.00000,
        name: "National Law University, Delhi"
    }, {
        id: 'pot428',
        lat: 28.46010,
        lon: 77.02635,
        name: "Delhi School of Economics"
    }, {
        id: 'pot429',
        lat: 28.24737,
        lon: 77.06544,
        name: "Indian Agricultural Research Institute"
    }, {
        id: 'pot430',
        lat: 28.84755,
        lon: 77.07340,
        name: "Institute of Liver and Biliary Sciences (ILBS)"
    }, {
        id: 'pot431',
        lat: 28.98333,
        lon: 76.06667,
        name: "National Centre for Disease Control (NCDC)"
    }, {
        id: 'pot432',
        lat: 29.08333,
        lon: 76.33333,
        name: "Indian Institute of Public Administration (IIPA)"
    }, {
        id: 'pot433',
        lat: 29.38333,
        lon: 76.96667,
        name: "National Museum Institute of History of Art, Conservation and Museology"
    }, {
        id: 'pot434',
        lat: 28.89552,
        lon: 76.06947,
        name: "National School of Drama"
    }, {
        id: 'pot435',
        lat: 29.25000,
        lon: 76.33333,
        name: "National Institute of Fashion Technology (NIFT)"
    }, {
        id: 'pot436',
        lat: 28.38333,
        lon: 77.31667,
        name: "School of Planning and Architecture, Delhi"
    }, {
        id: 'pot437',
        lat: 28.48333,
        lon: 77.03333,
        name: "Lady Shri Ram College for Women"
    }, {
        id: 'pot438',
        lat: 28.40000,
        lon: 77.00000,
        name: "St. Stephen's College"
    }, {
        id: 'pot439',
        lat: 28.46010,
        lon: 77.02635,
        name: "Miranda House"
    }, {
        id: 'pot440',
        lat: 28.24737,
        lon: 77.06544,
        name: "Hindu College"
    }, {
        id: 'pot441',
        lat: 28.84755,
        lon: 77.07340,
        name: "Hansraj College"
    }, {
        id: 'pot442',
        lat: 28.98333,
        lon: 76.06667,
        name: "Ramjas College"
    }, {
        id: 'pot443',
        lat: 29.08333,
        lon: 76.33333,
        name: "Kirori Mal College"
    }, {
        id: 'pot444',
        lat: 29.38333,
        lon: 76.96667,
        name: "Shri Ram College of Commerce"
    }, {
        id: 'pot445',
        lat: 28.89552,
        lon: 76.06947,
        name: "Venkateswara College"
    }, {
        id: 'pot446',
        lat: 29.25000,
        lon: 76.33333,
        name: "Gargi College"
    }, {
        id: 'pot447',
        lat: 28.38333,
        lon: 77.31667,
        name: "Kamala Nehru College"
    }, {
        id: 'pot448',
        lat: 28.48333,
        lon: 77.03333,
        name: "Daulat Ram College"
    }, {
        id: 'pot449',
        lat: 28.40000,
        lon: 77.00000,
        name: "Shaheed Sukhdev College of Business Studies"
    }, {
        id: 'pot450',
        lat: 28.46010,
        lon: 77.02635,
        name: "Vivekananda Institute of Professional Studies"
    }, {
        id: 'pot451',
        lat: 28.24737,
        lon: 77.06544,
        name: "Maharaja Agrasen Institute of Technology"
    }, {
        id: 'pot452',
        lat: 28.84755,
        lon: 77.07340,
        name: "Jagan Institute of Management Studies (JIMS)"
    }, {
        id: 'pot453',
        lat: 28.98333,
        lon: 76.06667,
        name: "Northern India Engineering College"
    }, {
        id: 'pot454',
        lat: 29.08333,
        lon: 76.33333,
        name: "Amity School of Engineering & Technology, Delhi"
    }, {
        id: 'pot455',
        lat: 22.5269276,
        lon: 75.9262066,
        name: "Indian Institute of Technologyy, Delhi"
    }, {
        id: 'pot456',
        lat: 12.97194,
        lon: 77.59369,
        name: "SKSJTI"
    }, {
        id: 'pot457',
        lat: 12.97194,
        lon: 77.59369,
        name: "SKSJTI Evening College"
    }, {
        id: 'pot458',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot459',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering"
    }, {
        id: 'pot460',
        lat: 13.010368,
        lon: 76.1208049,
        name: "Government Engineering College"
    }, {
        id: 'pot461',
        lat: 14.79354,
        lon: 75.40448,
        name: "Government Engineering College"
    }, {
        id: 'pot462',
        lat: 12.448861,
        lon: 75.940958,
        name: "Government Engineering College"
    }, {
        id: 'pot463',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot464',
        lat: 16.2723268,
        lon: 77.3572764,
        name: "Government Engineering College"
    }, {
        id: 'pot465',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot466',
        lat: 14.81361,
        lon: 74.12972,
        name: "Government Engineering College"
    }, {
        id: 'pot467',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot468',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot469',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot470',
        lat: 14.66667,
        lon: 75.83333,
        name: "Government Engineering College"
    }, {
        id: 'pot471',
        lat: 17.91331,
        lon: 77.53011,
        name: "Government Engineering College"
    }, {
        id: 'pot472',
        lat: 12.97194,
        lon: 77.59369,
        name: "University Visvesvaraya College of Engineering (Evening)"
    }, {
        id: 'pot473',
        lat: 14.46693,
        lon: 75.92694,
        name: "University BDT College of Engineering"
    }, {
        id: 'pot474',
        lat: 12.97194,
        lon: 77.59369,
        name: "B.M.S. College of Engineering"
    }, {
        id: 'pot1020',
        lat: 12.9644398,
        lon: 77.506069,
        name: "Dr. Ambedkar Institute of Technology"
    }, {
        id: 'pot1021',
        lat: 16.1723239,
        lon: 75.6613401,
        name: "Basaveswara Engineering College"
    }, {
        id: 'pot1022',
        lat: 15.34776,
        lon: 75.13378,
        name: "B.V. B. College of Engineering and Technology"
    }, {
        id: 'pot1023',
        lat: 17.33763,
        lon: 76.83787,
        name: "P.D.A College of Engg."
    }, {
        id: 'pot1024',
        lat: 13.0238143,
        lon: 76.1037125,
        name: "Malnad College of Engineering"
    }, {
        id: 'pot1025',
        lat: 12.52145,
        lon: 76.89527,
        name: "P.E.S College of Engineering"
    }, {
        id: 'pot1026',
        lat: 12.29791,
        lon: 76.63925,
        name: "The National Institute of Engineering"
    }, {
        id: 'pot1027',
        lat: 12.3152625,
        lon: 76.6119107,
        name: "Sri Jayachamarajendra College of Engineering"
    }, {
        id: 'pot1028',
        lat: 12.97194,
        lon: 77.59369,
        name: "B.M.S College of Engineering (Evening)"
    }, {
        id: 'pot1029',
        lat: 12.29791,
        lon: 76.63925,
        name: "National Institute of Engineering (Evening)"
    }, {
        id: 'pot1030',
        lat: 16.33354,
        lon: 75.28305,
        name: "Biluru Gurubasava Mahaswamiji Institute of Technology"
    }, {
        id: 'pot1031',
        lat: 14.66667,
        lon: 75.83333,
        name: "Jain Acharya Gundharnandi Maharaj Institute of Technology"
    }, {
        id: 'pot1032',
        lat: 15.8806681,
        lon: 74.5186038,
        name: "S.G. Balekundri Institute of Technology"
    }, {
        id: 'pot1033',
        lat: 15.82059456,
        lon: 74.49866387,
        name: "K L E Dr. M S Sheshagiri College of Engineering and Technology"
    }, {
        id: 'pot1034',
        lat: 16.4689343,
        lon: 74.60272421,
        name: "K L E College of Engineering and Technology"
    }, {
        id: 'pot1035',
        lat: 16.33333,
        lon: 74.75,
        name: "Angadi Institute Of Technology & Management"
    }, {
        id: 'pot1036',
        lat: 15.8152707,
        lon: 74.4874436,
        name: "K.L.S. Gogte Institute of Technology"
    }, {
        id: 'pot1037',
        lat: 15.8756167,
        lon: 74.5164404,
        name: "Maratha Mandal Engineering College"
    }, {
        id: 'pot1038',
        lat: 16.33333,
        lon: 74.75,
        name: "Shaikh College of Engineering & Technology"
    }, {
        id: 'pot1039',
        lat: 14.66667,
        lon: 75.83333,
        name: "Jain College of Engineering"
    }, {
        id: 'pot1040',
        lat: 14.66667,
        lon: 75.83333,
        name: "V S M Institute of Technology"
    }, {
        id: 'pot1041',
        lat: 14.66667,
        lon: 75.83333,
        name: "Hirasugar Institute of Technology"
    }, {
        id: 'pot1042',
        lat: 14.66667,
        lon: 75.83333,
        name: "Jain College of Engineering and Research"
    }, {
        id: 'pot1043',
        lat: 15.15,
        lon: 76.55,
        name: "Ballari Institute of Technology and Management"
    }, {
        id: 'pot1044',
        lat: 15.26954,
        lon: 76.3871,
        name: "Proudadevaraya Institute of Technology"
    }, {
        id: 'pot1045',
        lat: 15.15,
        lon: 76.55,
        name: "Rao Bahadur Y.Mahabaleswarappa Engineering College"
    }, {
        id: 'pot1046',
        lat: 17.87445,
        lon: 76.94972,
        name: "Basavakalyan Engineering College"
    }, {
        id: 'pot1047',
        lat: 18.04348,
        lon: 77.206,
        name: "Bheemanna Khandre Institute of Technology"
    }, {
        id: 'pot1048',
        lat: 17.91331,
        lon: 77.53011,
        name: "Lingarajappa Engineering College"
    }, {
        id: 'pot1049',
        lat: 47.88453,
        lon: 12.41813,
        name: "B L D E A`s V.P. Dr. P. G. Hallakatti College of Engineering and Technology"
    }, {
        id: 'pot1050',
        lat: 13.29506,
        lon: 77.80228,
        name: "Basava Engineering School of Technology"
    }, {
        id: 'pot1051',
        lat: 14.66667,
        lon: 75.83333,
        name: "Ekalavya Institute Of Technology"
    }, {
        id: 'pot1052',
        lat: 14.66667,
        lon: 75.83333,
        name: "S.J.C.Institute of Technology"
    }, {
        id: 'pot1053',
        lat: 13.55,
        lon: 77.87,
        name: "Sha-Shib College of Engineering"
    }, {
        id: 'pot1054',
        lat: 14.66667,
        lon: 75.83333,
        name: "Adhichunchanagiri Institute of Technology"
    }, {
        id: 'pot1055',
        lat: 14.22262,
        lon: 76.40038,
        name: "S.J.M. Institute of Technology"
    }, {
        id: 'pot1056',
        lat: 14.4443949,
        lon: 75.9027655,
        name: "Bapuji Institute of Engineering and Technology"
    }, {
        id: 'pot1057',
        lat: 14.46693,
        lon: 75.92694,
        name: "G M Institute of Technology"
    }, {
        id: 'pot1058',
        lat: 14.4322295,
        lon: 75.9578548,
        name: "Jain Institute of Technology"
    }, {
        id: 'pot1059',
        lat: 15.34776,
        lon: 75.13378,
        name: "KLEâ€™s/KLE Institute of Technology"
    }, {
        id: 'pot1060',
        lat: 15.20833,
        lon: 75.14254,
        name: "AGM Rural Engineering College"
    }, {
        id: 'pot1061',
        lat: 15.34776,
        lon: 75.13378,
        name: "Jain College of Engineering & Technology"
    }, {
        id: 'pot1062',
        lat: 14.66667,
        lon: 75.83333,
        name: "Alva`s Institute of Engineering and Technology"
    }, {
        id: 'pot1063',
        lat: 14.66667,
        lon: 75.83333,
        name: "Yenepoya Institute Of Technology(Formerly Dr. MVSIT)"
    }, {
        id: 'pot1064',
        lat: 14.66667,
        lon: 75.83333,
        name: "Karavali Institute of Technology"
    }, {
        id: 'pot1065',
        lat: 12.56458,
        lon: 75.39085,
        name: "KVG College of Engineering"
    }, {
        id: 'pot1066',
        lat: 13.0510297,
        lon: 74.9648434,
        name: "Mangalore Institute of Technology & Engineering"
    }, {
        id: 'pot1067',
        lat: 14.66667,
        lon: 75.83333,
        name: "Prasanna College of Engineering and Technology"
    }, {
        id: 'pot1068',
        lat: 12.91723,
        lon: 74.85603,
        name: "Sahyadri College of Engineering and Management"
    }, {
        id: 'pot1069',
        lat: 14.66667,
        lon: 75.83333,
        name: "Shreedevi Institute of Technology"
    }, {
        id: 'pot1070',
        lat: 12.8754777,
        lon: 74.9396264,
        name: "Srinivas Institute of Technology"
    }, {
        id: 'pot1071',
        lat: 12.7810465,
        lon: 75.1848841,
        name: "Vivekananda College of Engineering & Technology"
    }, {
        id: 'pot1072',
        lat: 12.91723,
        lon: 74.85603,
        name: "Mangalore Marine College and Technology"
    }, {
        id: 'pot1073',
        lat: 14.66667,
        lon: 75.83333,
        name: "A J Institute Of Engineering And Technology"
    }, {
        id: 'pot1074',
        lat: 15.09977035,
        lon: 75.45481635,
        name: "Smt. Kamala and Sri Venkappa M.Agadi College of Engg. and Tech."
    }, {
        id: 'pot1075',
        lat: 15.4126417,
        lon: 75.6360909,
        name: "Tontadarya College of Engineering"
    }, {
        id: 'pot1076',
        lat: 15.42344,
        lon: 75.54389,
        name: "R.T.E Socity`s Rural Engineering College"
    }, {
        id: 'pot1077',
        lat: 17.33763,
        lon: 76.83787,
        name: "Shetty Institute of Technology"
    }, {
        id: 'pot1078',
        lat: 12.9902344,
        lon: 76.1152288,
        name: "Rajeev Institute of Technology"
    }, {
        id: 'pot1079',
        lat: 13.00715,
        lon: 76.0962,
        name: "Navkis College of Engineering"
    }, {
        id: 'pot1080',
        lat: 14.66667,
        lon: 75.83333,
        name: "S.T.J. Institute of Technology"
    }, {
        id: 'pot1081',
        lat: 14.66667,
        lon: 75.83333,
        name: "Coorg Institute of Technology"
    }, {
        id: 'pot1082',
        lat: 13.13671,
        lon: 78.12917,
        name: "C Byregowda Institute Of Technology"
    }, {
        id: 'pot1083',
        lat: 14.66667,
        lon: 75.83333,
        name: "Dr. T. Thimmaiah Institute of Technology"
    }, {
        id: 'pot1084',
        lat: 13.13671,
        lon: 78.12917,
        name: "Sri Vinayaka Institute of Technology"
    }, {
        id: 'pot1085',
        lat: 12.29791,
        lon: 76.63925,
        name: "Maharaja Institute of Technology"
    }, {
        id: 'pot1086',
        lat: 12.5839,
        lon: 77.04344,
        name: "G. Madegowda Institute of Technology"
    }, {
        id: 'pot1087',
        lat: 12.52145,
        lon: 76.89527,
        name: "Cauvery Institute of Technology"
    }, {
        id: 'pot1088',
        lat: 12.29791,
        lon: 76.63925,
        name: "G.S.S.S. college of Engineering for Women"
    }, {
        id: 'pot1089',
        lat: 12.29791,
        lon: 76.63925,
        name: "NIE Institute of Technology"
    }, {
        id: 'pot1090',
        lat: 12.3355135,
        lon: 76.6188852,
        name: "Vidya Vardhaka College of Engineering"
    }, {
        id: 'pot1091',
        lat: 12.29791,
        lon: 76.63925,
        name: "Vidya Vikas Institute of Engineering & Technology"
    }, {
        id: 'pot1092',
        lat: 12.3038443,
        lon: 76.7114295,
        name: "ATME College of Engineering"
    }, {
        id: 'pot1093',
        lat: 14.66667,
        lon: 75.83333,
        name: "Mysuru Royal Institute of Technology"
    }, {
        id: 'pot1094',
        lat: 12.29791,
        lon: 76.63925,
        name: "Mysore College of Engineering and Management"
    }, {
        id: 'pot1095',
        lat: 14.66667,
        lon: 75.83333,
        name: "Maharaja Institute of Technology"
    }, {
        id: 'pot1096',
        lat: 16.16,
        lon: 76.91,
        name: "Navodaya Institute of Technology"
    }, {
        id: 'pot1097',
        lat: 16.16,
        lon: 76.91,
        name: "H.K.E.'s S.L.N. College of Engineering"
    }, {
        id: 'pot1098',
        lat: 12.79894,
        lon: 77.38643,
        name: "Amrutha Institute of Engineering & Management Science"
    }, {
        id: 'pot1099',
        lat: 14.66667,
        lon: 75.83333,
        name: "Sampoorna Institute of Technology and Research"
    }, {
        id: 'pot1100',
        lat: 12.79894,
        lon: 77.38643,
        name: "Jnanavikasa Institute of Technology"
    }, {
        id: 'pot1101',
        lat: 14.05,
        lon: 75.16,
        name: "Jawaharlal Nehru National College of Engineering"
    }, {
        id: 'pot1102',
        lat: 13.9620733,
        lon: 75.5093573,
        name: "PES Institute of Technology & Management"
    }, {
        id: 'pot1103',
        lat: 13.5,
        lon: 77.0,
        name: "Akshaya Institute Of Technology"
    }, {
        id: 'pot1104',
        lat: 13.31216,
        lon: 76.94102,
        name: "Channa Basaveshwara Institute of Technology"
    }, {
        id: 'pot1105',
        lat: 13.5,
        lon: 77.0,
        name: "H.M.S. Institute of Technology"
    }, {
        id: 'pot1106',
        lat: 13.2631185,
        lon: 76.4550743,
        name: "Kalpataru Institute of Technology"
    }, {
        id: 'pot1107',
        lat: 13.3285139,
        lon: 77.1265772,
        name: "Siddaganga Institute of Technology"
    }, {
        id: 'pot1108',
        lat: 13.2563,
        lon: 76.47768,
        name: "Sri Basaveshwara Institute of Technology"
    }, {
        id: 'pot1109',
        lat: 14.66667,
        lon: 75.83333,
        name: "Shridevi Institute of Engineering & Technology"
    }, {
        id: 'pot1110',
        lat: 14.66667,
        lon: 75.83333,
        name: "K.L.S's Vishwanathrao Deshpande Rural Institute of Technology"
    }, {
        id: 'pot1111',
        lat: 14.81361,
        lon: 74.12972,
        name: "Girijabai Sail Institute of Technology"
    }, {
        id: 'pot1112',
        lat: 14.66667,
        lon: 75.83333,
        name: "N.M.A.M.Institute of Technology"
    }, {
        id: 'pot1113',
        lat: 14.66667,
        lon: 75.83333,
        name: "Shri Madhwa Vadiraja Institute of Technology & Management"
    }, {
        id: 'pot1114',
        lat: 14.66667,
        lon: 75.83333,
        name: "Moodalakatte Institute of Technology"
    }, {
        id: 'pot1115',
        lat: 16.521,
        lon: 76.75738,
        name: "Veerappa Nisty Engineering College"
    }, {
        id: 'pot1116',
        lat: 13.82425,
        lon: 75.0307,
        name: "Acharya Institute of Technology"
    }, {
        id: 'pot1117',
        lat: 14.66667,
        lon: 75.83333,
        name: "Acharya Patashala Rural College of Engineering"
    }, {
        id: 'pot1118',
        lat: 12.8910127,
        lon: 77.4654614,
        name: "ACS College of Engineering"
    }, {
        id: 'pot1119',
        lat: 13.0753189,
        lon: 77.6652503,
        name: "Alpha College of Engineering"
    }, {
        id: 'pot1120',
        lat: 12.8280492,
        lon: 77.5888674,
        name: "AMC Engineering College"
    }, {
        id: 'pot1121',
        lat: 14.66667,
        lon: 75.83333,
        name: "Atria Institute of Technology"
    }, {
        id: 'pot1122',
        lat: 12.97194,
        lon: 77.59369,
        name: "B N M Institute of Technology"
    }, {
        id: 'pot1123',
        lat: 14.66667,
        lon: 75.83333,
        name: "B.T.L Institute of Technology & Management"
    }, {
        id: 'pot1124',
        lat: 12.8113679,
        lon: 77.7102029,
        name: "Bangalore College of Engineering & Technology"
    }, {
        id: 'pot1125',
        lat: 12.9551259,
        lon: 77.5741985,
        name: "Bangalore Institute of Technology"
    }, {
        id: 'pot1126',
        lat: 13.1336977,
        lon: 77.5681546,
        name: "BMS Institute of Technology and Management"
    }, {
        id: 'pot1127',
        lat: 14.66667,
        lon: 75.83333,
        name: "Brindavan College of Engineering"
    }, {
        id: 'pot1128',
        lat: 14.66667,
        lon: 75.83333,
        name: "Cambridge Institute of Technology"
    }, {
        id: 'pot1129',
        lat: 14.66667,
        lon: 75.83333,
        name: "City Engineering College"
    }, {
        id: 'pot1130',
        lat: 14.66667,
        lon: 75.83333,
        name: "CMR Institute of Technology"
    }, {
        id: 'pot1131',
        lat: 14.66667,
        lon: 75.83333,
        name: "Dayanand Sagar College of Engineering"
    }, {
        id: 'pot1132',
        lat: 14.66667,
        lon: 75.83333,
        name: "DONBOSCO Institute of Technology"
    }, {
        id: 'pot1133',
        lat: 12.97194,
        lon: 77.59369,
        name: "East Point College of Engineering & Technology"
    }, {
        id: 'pot1134',
        lat: 12.97194,
        lon: 77.59369,
        name: "East West Institute of Technology Bangalore"
    }, {
        id: 'pot1135',
        lat: 14.66667,
        lon: 75.83333,
        name: "Global Academy of Technology"
    }, {
        id: 'pot1136',
        lat: 13.05833,
        lon: 77.57318,
        name: "Impact College of Engineering and Applied Sciences"
    }, {
        id: 'pot1137',
        lat: 12.8741911,
        lon: 77.5965106,
        name: "Islamia Institute of Technology"
    }, {
        id: 'pot1138',
        lat: 12.97194,
        lon: 77.59369,
        name: "J.S.S. Academy of Technical Education"
    }, {
        id: 'pot1139',
        lat: 12.97194,
        lon: 77.59369,
        name: "K N S Institute of Technology"
    }, {
        id: 'pot1140',
        lat: 14.66667,
        lon: 75.83333,
        name: "K.S. Institute of Technology"
    }, {
        id: 'pot1141',
        lat: 13.0309167,
        lon: 77.5647392,
        name: "M.S Ramaiah Institute of Technology"
    }, {
        id: 'pot1142',
        lat: 13.1288782,
        lon: 77.5872496,
        name: "Nitte Meenakshi Institute of Technology"
    }, {
        id: 'pot1143',
        lat: 12.97194,
        lon: 77.59369,
        name: "R N S Institute of Technology"
    }, {
        id: 'pot1144',
        lat: 14.66667,
        lon: 75.83333,
        name: "R.R. Institute of Technology"
    }, {
        id: 'pot1145',
        lat: 12.9232191,
        lon: 77.5006464,
        name: "R.V. College of Engineering"
    }, {
        id: 'pot1146',
        lat: 12.8867779,
        lon: 77.4497119,
        name: "Rajarajeshwari College of Engineering"
    }, {
        id: 'pot1147',
        lat: 13.0332655,
        lon: 77.5979698,
        name: "Rajiv Gandhi Institute of Technology"
    }, {
        id: 'pot1148',
        lat: 12.97194,
        lon: 77.59369,
        name: "Sai Vidya Institute of Technology"
    }, {
        id: 'pot1149',
        lat: 13.0895883,
        lon: 77.5458435,
        name: "Sambhram Institute of Technology"
    }, {
        id: 'pot1150',
        lat: 12.97194,
        lon: 77.59369,
        name: "Saptagiri College of Engineering"
    }, {
        id: 'pot1151',
        lat: 14.66667,
        lon: 75.83333,
        name: "SEA College of Engineering & Technology"
    }, {
        id: 'pot1152',
        lat: 12.7111,
        lon: 77.69557,
        name: "Sri Sai Ram College of Engineering"
    }, {
        id: 'pot1153',
        lat: 12.97194,
        lon: 77.59369,
        name: "Sir M. Visveswarayya Institute of Technology"
    }, {
        id: 'pot1154',
        lat: 12.97194,
        lon: 77.59369,
        name: "Sri Jagadguru Balagangadharanatha Swamiji Institute of Technology"
    }, {
        id: 'pot1155',
        lat: 13.0747948,
        lon: 77.4990814,
        name: "Sri Krishna Institute of Technology"
    }, {
        id: 'pot1156',
        lat: 13.1597373,
        lon: 77.635887,
        name: "Sri Venkateshwara College of Engineering"
    }, {
        id: 'pot1157',
        lat: 12.97194,
        lon: 77.59369,
        name: "T. John Engineering. college"
    }, {
        id: 'pot1158',
        lat: 12.929616,
        lon: 77.6227302,
        name: "Vemana Institute of Technology"
    }, {
        id: 'pot1159',
        lat: 12.97194,
        lon: 77.59369,
        name: "Vijaya Vitala Institute Of Technology"
    }, {
        id: 'pot1160',
        lat: 12.97194,
        lon: 77.59369,
        name: "Vivekananda Institute of Technology"
    }, {
        id: 'pot1161',
        lat: 14.66667,
        lon: 75.83333,
        name: "Yellamma Dasappa Institute of Technology"
    }, {
        id: 'pot1162',
        lat: 12.8856999,
        lon: 77.6997438,
        name: "Bangalore Technological Institute"
    }, {
        id: 'pot1163',
        lat: 14.66667,
        lon: 75.83333,
        name: "Gopalan College of Engineering & Management"
    }, {
        id: 'pot1164',
        lat: 14.66667,
        lon: 75.83333,
        name: "K.S School Of Engineering"
    }, {
        id: 'pot1165',
        lat: 12.91123,
        lon: 77.57292,
        name: "Dayanand Sagar Academy of Technology"
    }, {
        id: 'pot1166',
        lat: 12.8408706,
        lon: 77.5117259,
        name: "Jyothi Institute of Technology"
    }, {
        id: 'pot1167',
        lat: 14.66667,
        lon: 75.83333,
        name: "Sri Vidya Vinayaka Institute of Technology"
    }, {
        id: 'pot1168',
        lat: 13.0957576,
        lon: 77.5901076,
        name: "East West College of Engineering"
    }, {
        id: 'pot1169',
        lat: 13.82425,
        lon: 75.0307,
        name: "Nadgir Institute of Engineering and Technology"
    }, {
        id: 'pot1170',
        lat: 13.2039637,
        lon: 77.6220221,
        name: "M S Engineering College"
    }, {
        id: 'pot1171',
        lat: 14.66667,
        lon: 75.83333,
        name: "R L Jalappa Institute of Technology"
    }, {
        id: 'pot1172',
        lat: 14.66667,
        lon: 75.83333,
        name: "Nagarjuna College of Engineering. & Technology"
    }, {
        id: 'pot1173',
        lat: 14.66667,
        lon: 75.83333,
        name: "Dr. Sri.Sri.Sri. Shivakumara Mahaswamy College of Engineering."
    }, {
        id: 'pot1174',
        lat: 14.66667,
        lon: 75.83333,
        name: "Cambridge Institutute of Technology-North Campus"
    }, {
        id: 'pot1175',
        lat: 14.66667,
        lon: 75.83333,
        name: "Adarsha Institute of Technology"
    }, {
        id: 'pot1176',
        lat: 12.29791,
        lon: 76.63925,
        name: "Sri Jayachamarajendra College of Engineering (Evening)"
    }, {
        id: 'pot1177',
        lat: 12.97194,
        lon: 77.59369,
        name: "P E S University (Formerly PESIT)"
    }, {
        id: 'pot1178',
        lat: 12.97194,
        lon: 77.59369,
        name: "P E S University (Electronic City Campus)"
    }, {
        id: 'pot1179',
        lat: 13.1154491,
        lon: 77.6357787,
        name: "Reva University"
    }, {
        id: 'pot1180',
        lat: 12.7297587,
        lon: 77.7087603,
        name: "Alliance University"
    }, {
        id: 'pot1181',
        lat: 13.0184747,
        lon: 77.5091024,
        name: "M.S. Ramaiah University of Applied Sciences"
    }, {
        id: 'pot1182',
        lat: 13.1677715,
        lon: 77.5360687,
        name: "Presidency University"
    }, {
        id: 'pot1183',
        lat: 13.1186746,
        lon: 77.6601937,
        name: "CMR University"
    }, {
        id: 'pot1184',
        lat: 12.97194,
        lon: 77.59369,
        name: "Dayananda Sagar University"
    }, {
        id: 'pot1185',
        lat: 14.66667,
        lon: 75.83333,
        name: "Rai Technology University"
    }, {
        id: 'pot1186',
        lat: 13.2874212,
        lon: 77.5953498,
        name: "Gitam School Of Technology"
    }, {
        id: 'pot1187',
        lat: 12.91723,
        lon: 74.85603,
        name: "Srinivas University"
    }, {
        id: 'pot1188',
        lat: 15.34776,
        lon: 75.13378,
        name: "KLE Technological University(Formerly BVBCET)"
    }, {
        id: 'pot1189',
        lat: 14.66667,
        lon: 75.83333,
        name: "Sharnabasava University(Formerly Appa Inst. of Tech.)"
    }, {
        id: 'pot1190',
        lat: 14.66667,
        lon: 75.83333,
        name: "Sharnabasava University (Formerly Godutai College for Women)"
    }, {
        id: 'pot1191',
        lat: 12.29791,
        lon: 76.63925,
        name: "JSS Science and Technology University(Formerly SJCE)"
    }, {
        id: 'pot1192',
        lat: 12.861,
        lon: 76.74,
        name: "Adichunchanagiri University(Formerly BGSIT)"
    }, {
        id: 'pot1193',
        lat: 12.91123,
        lon: 77.57292,
        name: "Jain University School of Engineering and Technology"
    }, {
        id: 'pot1194',
        lat: 13.5,
        lon: 77.0,
        name: "Sri Siddartha Institute of Technology"
    }, {
        id: 'pot1195',
        lat: 13.9972679,
        lon: 74.5575274,
        name: "Anjuman Engineering College"
    }, {
        id: 'pot1196',
        lat: 12.97194,
        lon: 77.59369,
        name: "School of Architecture University Visvesvaraya College of Engineering"
    }, {
        id: 'pot1197',
        lat: 14.66667,
        lon: 75.83333,
        name: "Acharya N.R.V School of Architecture"
    }, {
        id: 'pot1198',
        lat: 13.10129,
        lon: 77.59626,
        name: "B M S School of Architecure"
    }, {
        id: 'pot1199',
        lat: 14.66667,
        lon: 75.83333,
        name: "B M S College of Architecure"
    }, {
        id: 'pot1200',
        lat: 13.06376,
        lon: 77.58519,
        name: "Impact School of Architecture"
    }, {
        id: 'pot1201',
        lat: 12.97194,
        lon: 77.59369,
        name: "R.V. College of Architecture"
    }, {
        id: 'pot1202',
        lat: 12.91207,
        lon: 77.48098,
        name: "SJB School of Achitecture & Planning"
    }, {
        id: 'pot1203',
        lat: 13.00029,
        lon: 77.67351,
        name: "Gopalan School of Architecture and Planning"
    }, {
        id: 'pot1204',
        lat: 14.66667,
        lon: 75.83333,
        name: "R R School of Architecture"
    }, {
        id: 'pot1205',
        lat: 14.66667,
        lon: 75.83333,
        name: "BGS School of Architecture and Planning"
    }, {
        id: 'pot1206',
        lat: 14.66667,
        lon: 75.83333,
        name: "Adithya Academy of Architecture and Design"
    }, {
        id: 'pot1207',
        lat: 12.97194,
        lon: 77.59369,
        name: "The Oxford School of Architecture"
    }, {
        id: 'pot1208',
        lat: 12.97194,
        lon: 77.59369,
        name: "K S School of Architecture"
    }, {
        id: 'pot1209',
        lat: 12.97194,
        lon: 77.59369,
        name: "Nitte Institute of Architecture"
    }, {
        id: 'pot1210',
        lat: 12.97194,
        lon: 77.59369,
        name: "Brindavana College of Architecture"
    }, {
        id: 'pot1211',
        lat: 13.0309167,
        lon: 77.5647392,
        name: "M.S.Ramaiah Institute of Technology"
    }, {
        id: 'pot1212',
        lat: 12.97194,
        lon: 77.59369,
        name: "Dayanand Sagar Academy of Technology"
    }, {
        id: 'pot1213',
        lat: 12.9089389,
        lon: 77.5664343,
        name: "Dayanand Sagar College of Engineering"
    }, {
        id: 'pot1214',
        lat: 12.97194,
        lon: 77.59369,
        name: "R N S School of Architecture"
    }, {
        id: 'pot1215',
        lat: 14.66667,
        lon: 75.83333,
        name: "Sir M V School of Architecture"
    }, {
        id: 'pot1216',
        lat: 12.97550725,
        lon: 77.48221908,
        name: "East West School of Architecture"
    }, {
        id: 'pot1217',
        lat: 15.84897315,
        lon: 74.47367428,
        name: "Angadi School of Architecture"
    }, {
        id: 'pot1218',
        lat: 16.33333,
        lon: 74.75,
        name: "School of Architecture K.L.S. Gogte Institute of Technology"
    }, {
        id: 'pot1219',
        lat: 13.29506,
        lon: 77.80228,
        name: "Mallik Sandal Institute of Technology"
    }, {
        id: 'pot1220',
        lat: 16.84870785,
        lon: 75.71740686,
        name: "BLDEA's V P Dr PG Halakatti College of Engineering & Technology"
    }, {
        id: 'pot1221',
        lat: 14.66667,
        lon: 75.83333,
        name: "Bearys Enviro-Arctitecture Design School"
    }, {
        id: 'pot1222',
        lat: 12.91723,
        lon: 74.85603,
        name: "School of Architecture Srinivas inst. of tech."
    }, {
        id: 'pot1223',
        lat: 17.33763,
        lon: 76.83787,
        name: "School of Architecture P.D.A College of Engg."
    }, {
        id: 'pot1224',
        lat: 14.66667,
        lon: 75.83333,
        name: "Mysore School of Architecture"
    }, {
        id: 'pot1225',
        lat: 12.29791,
        lon: 76.63925,
        name: "Wadiyar Centre For Architecture (Formerly CFA)"
    }, {
        id: 'pot1226',
        lat: 13.2967218,
        lon: 77.1631117,
        name: "HMS School of Architecture"
    }, {
        id: 'pot1227',
        lat: 13.5,
        lon: 77.0,
        name: "School of Architecture Siddaganga Institute of Technology"
    }, {
        id: 'pot1228',
        lat: 12.97194,
        lon: 77.59369,
        name: "CMR University School of Architecture"
    }, {
        id: 'pot1229',
        lat: 12.91723,
        lon: 74.85603,
        name: "NITTE Institute of Architecture"
    }, {
        id: 'pot1230',
        lat: 13.0895883,
        lon: 77.5458435,
        name: "Sambhram Institute of Technology"
    }, {
        id: 'pot1231',
        lat: 12.9343108,
        lon: 77.6925122,
        name: "New Horizon College of Engineering"
    }, {
        id: 'pot1232',
        lat: 12.97194,
        lon: 77.59369,
        name: "Dayananda Sagar College of Engineering"
    }, {
        id: 'pot1233',
        lat: 12.97194,
        lon: 77.59369,
        name: "M.V.J. College of Engineering"
    }, {
        id: 'pot1234',
        lat: 14.66667,
        lon: 75.83333,
        name: "Shreedevi Institute of Technology"
    }, {
        id: 'pot1235',
        lat: 12.8754777,
        lon: 74.9396264,
        name: "Srinivas Institute of Technology"
    }, {
        id: 'pot1236',
        lat: 14.66667,
        lon: 75.83333,
        name: "Alva`s Institute of Engineering and Technology"
    }, {
        id: 'pot1237',
        lat: 14.66667,
        lon: 75.83333,
        name: "P.A. College of Engineering"
    }, {
        id: 'pot1238',
        lat: 12.9112094,
        lon: 74.8992513,
        name: "St. Joseph Engineering College"
    }, {
        id: 'pot1239',
        lat: 15.85212,
        lon: 74.50447,
        name: "Jain College of Engineering"
    }, {
        id: 'pot1240',
        lat: 15.20833,
        lon: 75.14254,
        name: "AGM Rural Engineering College"
    },

    // Kerala Colleges
    {
        id: 'pot1100',
        lat: 11.24802,
        lon: 75.7804,
        name: "National Institute of Technology Calicut"
    }, {
        id: 'pot1101',
        lat: 8.4855,
        lon: 76.94924,
        name: "ER&DCI Institute of Technology"
    }, {
        id: 'pot1102',
        lat: 11.24802,
        lon: 75.7804,
        name: "National Institute of Electronics & Information Technology"
    }, {
        id: 'pot1103',
        lat: 8.6266888,
        lon: 77.0336875,
        name: "Indian Institute of Space Science and Technology"
    }, {
        id: 'pot1104',
        lat: 9.7554364,
        lon: 76.649535,
        name: "Indian Institute of Information Technology Kottayam"
    }, {
        id: 'pot1105',
        lat: 10.8018655,
        lon: 76.8185065,
        name: "Indian Institute of Technology Palakkad"
    }, {
        id: 'pot1106',
        lat: 8.6822416,
        lon: 77.1356558,
        name: "Indian Institute of Science Education and Research"
    }, {
        id: 'pot1107',
        lat: 8.5441425,
        lon: 76.9043013,
        name: "College of Engineering"
    }, {
        id: 'pot1108',
        lat: 10.51667,
        lon: 76.21667,
        name: "Government Engineering College"
    }, {
        id: 'pot1109',
        lat: 8.9137199,
        lon: 76.6324404,
        name: "Thangal Kunju Musaliar College of Engineering"
    }, {
        id: 'pot1110',
        lat: 10.8239334,
        lon: 76.6410927,
        name: "NSS College of Engineering"
    }, {
        id: 'pot1111',
        lat: 10.0539422,
        lon: 76.6199244,
        name: "Mar Athanasius College of Engineering"
    }, {
        id: 'pot1112',
        lat: 11.9854362,
        lon: 75.381483,
        name: "Government College of Engineering"
    }, {
        id: 'pot1113',
        lat: 9.5780844,
        lon: 76.6224038,
        name: "Rajiv Gandhi Institute of Technology"
    }, {
        id: 'pot1114',
        lat: 10.9035663,
        lon: 76.435268,
        name: "Government Engineering College"
    }, {
        id: 'pot1115',
        lat: 8.505275,
        lon: 76.9406789,
        name: "Government Engineering College"
    }, {
        id: 'pot1116',
        lat: 11.2864519,
        lon: 75.7700465,
        name: "Government Engineering College"
    }, {
        id: 'pot1117',
        lat: 11.8337856,
        lon: 75.9702212,
        name: "Government Engineering College"
    }, {
        id: 'pot1118',
        lat: 9.8519724,
        lon: 76.9392672,
        name: "Government Engineering College"
    }, {
        id: 'pot1119',
        lat: 9.93988,
        lon: 76.26022,
        name: "Government Model Engineering College"
    }, {
        id: 'pot1120',
        lat: 12.49838,
        lon: 74.98959,
        name: "L.B.S College of Engineering"
    }, {
        id: 'pot1121',
        lat: 8.4855,
        lon: 76.94924,
        name: "L B S Institute of Technology for Women"
    }, {
        id: 'pot1122',
        lat: 8.6911253,
        lon: 76.8194276,
        name: "College of Engineering Attingal"
    }, {
        id: 'pot1123',
        lat: 9.7440825,
        lon: 76.3639753,
        name: "College of Engineering"
    }, {
        id: 'pot1124',
        lat: 9.4128239,
        lon: 76.6424877,
        name: "College of Engineering"
    }, {
        id: 'pot1125',
        lat: 9.0644519,
        lon: 76.5564384,
        name: "College of Engineering"
    }, {
        id: 'pot1126',
        lat: 8.9841995,
        lon: 76.7647965,
        name: "College of Engineering"
    }, {
        id: 'pot1127',
        lat: 9.6733517,
        lon: 76.8264857,
        name: "College of Engineering"
    }, {
        id: 'pot1128',
        lat: 9.3221842,
        lon: 76.6836534,
        name: "College of Engineering"
    }, {
        id: 'pot1129',
        lat: 9.6681541,
        lon: 76.621539,
        name: "College of Engineering"
    }, {
        id: 'pot1130',
        lat: 9.43333,
        lon: 76.35,
        name: "College of Engineering & Management"
    }, {
        id: 'pot1131',
        lat: 9.0521975,
        lon: 76.906671,
        name: "College of Engineering"
    }, {
        id: 'pot1132',
        lat: 8.9646526,
        lon: 76.6202442,
        name: "College of Engineering"
    }, {
        id: 'pot1133',
        lat: 11.7826867,
        lon: 75.5153859,
        name: "College of Engineering"
    }, {
        id: 'pot1134',
        lat: 10.41667,
        lon: 76.5,
        name: "College of Engineering"
    }, {
        id: 'pot1135',
        lat: 10.41667,
        lon: 76.5,
        name: "College of Engineering"
    }, {
        id: 'pot1136',
        lat: 10.41667,
        lon: 76.5,
        name: "College of Engineering Muttathara"
    }, {
        id: 'pot1137',
        lat: 10.0928899,
        lon: 77.0679661,
        name: "College of Engineering Munnar"
    }, {
        id: 'pot1138',
        lat: 9.1316395,
        lon: 76.7171442,
        name: "College of Engineering"
    }, {
        id: 'pot1139',
        lat: 9.3172457,
        lon: 76.617795,
        name: "College of Engineering Chengannur"
    }, {
        id: 'pot1140',
        lat: 8.4703736,
        lon: 76.979704,
        name: "Sree Chitra Thirunal College of Engineering"
    }, {
        id: 'pot1141',
        lat: 10.41667,
        lon: 76.5,
        name: "School of Engineering"
    }, {
        id: 'pot1142',
        lat: 9.4607922,
        lon: 76.438044,
        name: "Cochin University College of Engineering Kuttanad"
    }, {
        id: 'pot1143',
        lat: 10.41667,
        lon: 76.5,
        name: "Calicut University Institute of Engineering & Technology"
    }, {
        id: 'pot1144',
        lat: 10.41667,
        lon: 76.5,
        name: "University College of Engineering"
    }, {
        id: 'pot1145',
        lat: 9.8459329,
        lon: 76.7404353,
        name: "University College of Engineering"
    }, {
        id: 'pot1146',
        lat: 10.8529287,
        lon: 75.9862914,
        name: "Kelappaji College of Agricultural Engineering and Technology"
    }, {
        id: 'pot1147',
        lat: 11.0393971,
        lon: 76.371539,
        name: "College of Avian Sciences and Management"
    }, {
        id: 'pot1148',
        lat: 9.85,
        lon: 76.96667,
        name: "College of Dairy Science and Technology"
    }, {
        id: 'pot1149',
        lat: 10.5332318,
        lon: 76.2683382,
        name: "College of Dairy Science and Technology"
    }, {
        id: 'pot1150',
        lat: 8.4855,
        lon: 76.94924,
        name: "College of dairy science and technology"
    }, {
        id: 'pot1151',
        lat: 10.2999284,
        lon: 76.4369006,
        name: "College of Food Technology"
    }, {
        id: 'pot1152',
        lat: 11.5477697,
        lon: 76.0203836,
        name: "College of Veterinary and Animal Sciences"
    }, {
        id: 'pot1153',
        lat: 10.5332318,
        lon: 76.2683382,
        name: "Kerala Veterinary College"
    }, {
        id: 'pot1154',
        lat: 8.4376795,
        lon: 76.9664014,
        name: "ACE College of Engineering"
    }, {
        id: 'pot1155',
        lat: 10.178084,
        lon: 76.4308145,
        name: "Adi Shankara Institute of Engineering Technology"
    }, {
        id: 'pot1156',
        lat: 10.7744,
        lon: 76.65625,
        name: "Ahalia School of Engineering and Technology"
    }, {
        id: 'pot1157',
        lat: 9.91817574,
        lon: 76.71642304,
        name: "Al Azhar College of Engineering and Technology"
    }, {
        id: 'pot1158',
        lat: 10.7887671,
        lon: 76.292971,
        name: "Al-Ameen Engineering College"
    }, {
        id: 'pot1159',
        lat: 10.050272,
        lon: 76.329273,
        name: "Albertian Institute of Science and Technology"
    }, {
        id: 'pot1160',
        lat: 9.5285956,
        lon: 76.8216631,
        name: "Amal Jyothi College of Engineering"
    }, {
        id: 'pot1161',
        lat: 10.7885345,
        lon: 76.5099764,
        name: "Ammini College of Engineering"
    }, {
        id: 'pot1162',
        lat: 9.1954168,
        lon: 76.6588232,
        name: "Archana College of Engineering"
    }, {
        id: 'pot1163',
        lat: 10.7744,
        lon: 76.65625,
        name: "Aryanet Institute of Technology"
    }, {
        id: 'pot1164',
        lat: 11.2587092,
        lon: 75.8749878,
        name: "AWH Engineering College"
    }, {
        id: 'pot1165',
        lat: 10.51667,
        lon: 76.21667,
        name: "Axis College of Engineering and Technology"
    }, {
        id: 'pot1166',
        lat: 9.0426109,
        lon: 76.6446871,
        name: "Baselios Mathews Ii College of Engineering"
    }, {
        id: 'pot1167',
        lat: 10.0,
        lon: 76.5,
        name: "Baselios Thomas I Catholicose College of Engineering and Technology"
    }, {
        id: 'pot1168',
        lat: 9.26667,
        lon: 76.78333,
        name: "Believers Church Caarmel Engineering College"
    }, {
        id: 'pot1169',
        lat: 8.8840476,
        lon: 76.6029077,
        name: "Bishop Jerome Institute"
    }, {
        id: 'pot1170',
        lat: 9.4385058,
        lon: 76.3428947,
        name: "Carmel College of Engineering and Technology"
    }, {
        id: 'pot1171',
        lat: 10.3569086,
        lon: 76.2126289,
        name: "Christ College of Engineering"
    }, {
        id: 'pot1172',
        lat: 10.0463006,
        lon: 76.5178262,
        name: "Christ Knowledge City"
    }, {
        id: 'pot1173',
        lat: 10.8973676,
        lon: 76.1139421,
        name: "Cochin College of Engineering and Technology"
    }, {
        id: 'pot1174',
        lat: 9.9309875,
        lon: 76.554404,
        name: "Cochin Institute of Science and Technology"
    }, {
        id: 'pot1175',
        lat: 12.1404828,
        lon: 75.2512276,
        name: "College of Engineering and Technology"
    }, {
        id: 'pot1176',
        lat: 11.1334751,
        lon: 76.1854121,
        name: "Eranad Knowledge City Technical Campus"
    }, {
        id: 'pot1177',
        lat: 10.2314111,
        lon: 76.4086192,
        name: "Federal Institute of Science and Technology"
    }, {
        id: 'pot1178',
        lat: 10.51667,
        lon: 76.21667,
        name: "College Of Engineering Poomala"
    }, {
        id: 'pot1179',
        lat: 9.5698785,
        lon: 76.599544,
        name: "Gurudeva Institute of Science And Technology"
    }, {
        id: 'pot1180',
        lat: 8.6496509,
        lon: 76.9846807,
        name: "Heera College of Engineering and Technology"
    }, {
        id: 'pot1181',
        lat: 8.8442967,
        lon: 77.0334145,
        name: "Hindustan College of Engineering"
    }, {
        id: 'pot1182',
        lat: 10.2313715,
        lon: 76.2764415,
        name: "Holy Grace Academy of Engineering"
    }, {
        id: 'pot1183',
        lat: 10.0,
        lon: 76.5,
        name: "MGM College of Engineering & Technology (Holy Kings College of Engineering and Technology)"
    }, {
        id: 'pot1184',
        lat: 10.5648522,
        lon: 76.1487346,
        name: "IES College of Engineering"
    }, {
        id: 'pot1185',
        lat: 10.028136,
        lon: 76.5980994,
        name: "Ilahia College of Engineering Technology"
    }, {
        id: 'pot1186',
        lat: 10.0,
        lon: 76.5,
        name: "Ilahia School of Science and Technology"
    }, {
        id: 'pot1187',
        lat: 10.0,
        lon: 76.5,
        name: "ILM College of Engineering and Technology"
    }, {
        id: 'pot1188',
        lat: 10.0,
        lon: 76.5,
        name: "Indira Gandhi Institute of Engineering and Technology For Women"
    }, {
        id: 'pot1189',
        lat: 10.0,
        lon: 76.5,
        name: "Jai Bharath College of Management and Engineering Technology"
    }, {
        id: 'pot1190',
        lat: 10.7783699,
        lon: 76.4306185,
        name: "Jawaharlal College of Engineering and Technology"
    }, {
        id: 'pot1191',
        lat: 8.4855,
        lon: 76.94924,
        name: "John Cox Memorial C S I Institute of Technology"
    }, {
        id: 'pot1192',
        lat: 10.7278631,
        lon: 76.2896699,
        name: "Jyothi Engineering College"
    }, {
        id: 'pot1193',
        lat: 10.0,
        lon: 76.5,
        name: "K M E A Engineering College"
    }, {
        id: 'pot1194',
        lat: 9.41667,
        lon: 76.5,
        name: "K R Gouri Amma College of Engineering For Women"
    }, {
        id: 'pot1195',
        lat: 11.3137536,
        lon: 75.9527682,
        name: "KMCT College of Engineering"
    }, {
        id: 'pot1196',
        lat: 11.5,
        lon: 76.0,
        name: "KMCT College of Engineering For Women"
    }, {
        id: 'pot1197',
        lat: 10.0937469,
        lon: 76.5448375,
        name: "KMP College of Engineering"
    }, {
        id: 'pot1198',
        lat: 9.58692,
        lon: 76.52132,
        name: "Kottayam Institute of Technology and Science"
    }, {
        id: 'pot1199',
        lat: 9.41667,
        lon: 76.5,
        name: "KVM College of Engineering and Information Technology"
    }, {
        id: 'pot1200',
        lat: 8.5576321,
        lon: 77.100037,
        name: "Lourdes Matha College of Science and Technology"
    }, {
        id: 'pot1201',
        lat: 11.0382036,
        lon: 76.2628591,
        name: "MEA Engineering College"
    }, {
        id: 'pot1202',
        lat: 10.8268806,
        lon: 76.0180488,
        name: "MES College of Engineering"
    }, {
        id: 'pot1203',
        lat: 8.4855,
        lon: 76.94924,
        name: "M G College of Engineering"
    }, {
        id: 'pot1204',
        lat: 11.4376718,
        lon: 75.7643341,
        name: "M. Dasan Institute of Technology"
    }, {
        id: 'pot1205',
        lat: 10.7614495,
        lon: 76.2306063,
        name: "Malabar College of Engineering and Technology"
    }, {
        id: 'pot1206',
        lat: 11.8775581,
        lon: 75.4974102,
        name: "Malabar Institute of Technology"
    }, {
        id: 'pot1207',
        lat: 9.6775387,
        lon: 76.5748234,
        name: "Mangalam College of Engineering"
    }, {
        id: 'pot1208',
        lat: 9.5861337,
        lon: 76.982865,
        name: "Mar Baselios Christian College of Engineering and Technology"
    }, {
        id: 'pot1209',
        lat: 8.548288,
        lon: 76.9384815,
        name: "Mar Baselios College of Engineering and Technology"
    }, {
        id: 'pot1210',
        lat: 10.0567707,
        lon: 76.6710331,
        name: "Mar Baselios Institute of Technology and Science"
    }, {
        id: 'pot1211',
        lat: 10.1413743,
        lon: 76.272101,
        name: "Matha College of Technology"
    }, {
        id: 'pot1212',
        lat: 10.0,
        lon: 76.5,
        name: "MES College of Engineering and Technology"
    }, {
        id: 'pot1213',
        lat: 8.8681818,
        lon: 76.7088397,
        name: "MES Institute of Technology and Management"
    }, {
        id: 'pot1214',
        lat: 10.2247257,
        lon: 76.272675,
        name: "MET'S School of Engineering"
    }, {
        id: 'pot1215',
        lat: 8.6379657,
        lon: 77.0069315,
        name: "Mohandas College of Engineering and Technology"
    }, {
        id: 'pot1216',
        lat: 9.9308484,
        lon: 76.5529518,
        name: "Mookambika Technical Campus"
    }, {
        id: 'pot1217',
        lat: 9.3273205,
        lon: 76.7605749,
        name: "Mount Zion College of Engineering"
    }, {
        id: 'pot1218',
        lat: 9.41667,
        lon: 76.5,
        name: "Mount Zion College of Engineering For Women"
    }, {
        id: 'pot1219',
        lat: 8.645271,
        lon: 76.7873312,
        name: "Musaliar College of Engineering"
    }, {
        id: 'pot1220',
        lat: 9.26667,
        lon: 76.78333,
        name: "Musaliar College of Engineering and Technology"
    }, {
        id: 'pot1221',
        lat: 8.6971919,
        lon: 76.9145815,
        name: "Muslim Association College of Engineering"
    }, {
        id: 'pot1222',
        lat: 9.964073295,
        lon: 76.40847085,
        name: "Muthoot Institute of Technology and Science"
    }, {
        id: 'pot1223',
        lat: 10.7441208,
        lon: 76.4346238,
        name: "Nehru College of Engineering and Research Centre"
    }, {
        id: 'pot1224',
        lat: 10.3052703,
        lon: 76.3898223,
        name: "Nirmala College of Engineering"
    }, {
        id: 'pot1225',
        lat: 12.3535277,
        lon: 75.1436922,
        name: "North Malabar Institute of Technology"
    }, {
        id: 'pot1226',
        lat: 8.95687,
        lon: 76.85274,
        name: "Pinnacle School of Engineering and Technology"
    }, {
        id: 'pot1227',
        lat: 10.7575823,
        lon: 76.7013956,
        name: "Prime College of Engineering"
    }, {
        id: 'pot1228',
        lat: 9.2991674,
        lon: 76.6147062,
        name: "Providence College of Engineering"
    }, {
        id: 'pot1229',
        lat: 8.4855,
        lon: 76.94924,
        name: "Prs College of Engineering and Technology"
    }, {
        id: 'pot1230',
        lat: 8.7366516,
        lon: 76.8347508,
        name: "Rajadhani Institute of Engineering and Technology"
    }, {
        id: 'pot1231',
        lat: 9.993692843,
        lon: 76.35813381,
        name: "Rajagiri School of Engineering and Technology"
    }, {
        id: 'pot1232',
        lat: 10.51667,
        lon: 76.21667,
        name: "Royal College of Engineering and Technology"
    }, {
        id: 'pot1233',
        lat: 12.3112111,
        lon: 75.08241,
        name: "Sadguru Swami Nithyananda Institute of Technology"
    }, {
        id: 'pot1234',
        lat: 10.3589334,
        lon: 76.2860422,
        name: "Sahrdaya College of Engineering and Technology"
    }, {
        id: 'pot1235',
        lat: 9.5101204,
        lon: 76.5508664,
        name: "Saintgits College of Engineering"
    }, {
        id: 'pot1236',
        lat: 8.5558967,
        lon: 77.0673662,
        name: "Sarabhai Institute of Science and Technology"
    }, {
        id: 'pot1237',
        lat: 10.2698917,
        lon: 76.3999616,
        name: "SCMS School of Engineering and Technology"
    }, {
        id: 'pot1238',
        lat: 8.8262038,
        lon: 76.937776,
        name: "Shahul Hameed Memorial Engineering College"
    }, {
        id: 'pot1239',
        lat: 10.1816097,
        lon: 76.1826246,
        name: "SNM Institute of Management and Technology"
    }, {
        id: 'pot1240',
        lat: 9.2116756,
        lon: 76.6424474,
        name: "Sree Buddha College of Engineering"
    }, {
        id: 'pot1241',
        lat: 9.26667,
        lon: 76.78333,
        name: "Sree Buddha College of Engineering For Women"
    }, {
        id: 'pot1242',
        lat: 10.51667,
        lon: 76.21667,
        name: "Sree Ernakulathappan College of Engineering and Management"
    }, {
        id: 'pot1243',
        lat: 12.1404828,
        lon: 75.2512276,
        name: "Sree Narayana Guru College of Engineering and Technology"
    }, {
        id: 'pot1244',
        lat: 10.0,
        lon: 76.5,
        name: "Sree Narayana Guru Institute of Science and Technology"
    }, {
        id: 'pot1245',
        lat: 10.0094539,
        lon: 76.4526745,
        name: "Sree Narayana Gurukulam College of Engineering"
    }, {
        id: 'pot1246',
        lat: 9.1608128,
        lon: 76.7964739,
        name: "Sree Narayana Institute of Technology"
    }, {
        id: 'pot1247',
        lat: 10.7638314,
        lon: 76.1517417,
        name: "Sreepathy Institute of Management and Technology"
    }, {
        id: 'pot1248',
        lat: 9.162438,
        lon: 76.5473983,
        name: "Sri Vellappally Natesan College of Engineering"
    }, {
        id: 'pot1249',
        lat: 12.49838,
        lon: 74.98959,
        name: "St. Gregorios College of Engineering"
    }, {
        id: 'pot1250',
        lat: 9.7284855,
        lon: 76.7271075,
        name: "St. Joseph's College of Engineering and Technology"
    }, {
        id: 'pot1251',
        lat: 12.16667,
        lon: 75.33333,
        name: "St. Thomas College of Engineering and Technology"
    }, {
        id: 'pot1252',
        lat: 9.277022,
        lon: 76.6262941,
        name: "St. Thomas College of Engineering and Technology"
    }, {
        id: 'pot1253',
        lat: 8.5932623,
        lon: 76.8913706,
        name: "St.Thomas Institute for Science and Technology"
    }, {
        id: 'pot1254',
        lat: 8.9950319,
        lon: 76.695958,
        name: "TKM Institute of Technology"
    }, {
        id: 'pot1255',
        lat: 10.6794024,
        lon: 76.1369474,
        name: "Thejus Engineering College"
    }, {
        id: 'pot1256',
        lat: 9.8921537,
        lon: 76.4379517,
        name: "Toc H Institute of Science and Technology"
    }, {
        id: 'pot1257',
        lat: 9.641918,
        lon: 76.6488733,
        name: "Toms College of Engineering For Startups"
    }, {
        id: 'pot1258',
        lat: 8.8882971,
        lon: 76.815368,
        name: "Travancore Engineering College"
    }, {
        id: 'pot1259',
        lat: 8.4554299,
        lon: 77.0307736,
        name: "Trinity College of Engineering"
    }, {
        id: 'pot1260',
        lat: 8.95687,
        lon: 76.85274,
        name: "UKF College of Engineering and Technology"
    }, {
        id: 'pot1261',
        lat: 10.2945348,
        lon: 76.1978418,
        name: "Universal Engineering College"
    }, {
        id: 'pot1262',
        lat: 8.95687,
        lon: 76.85274,
        name: "Valia Koonambaikulathamma College of Engineering and Technology"
    }, {
        id: 'pot1263',
        lat: 11.04019,
        lon: 76.08237,
        name: "Vedavyasa Institute of Technology"
    }, {
        id: 'pot1264',
        lat: 10.6275265,
        lon: 76.1456479,
        name: "Vidya Academy of Science and Technology"
    }, {
        id: 'pot1265',
        lat: 8.4855,
        lon: 76.94924,
        name: "Vidya Academy of Science and Technology Technical Campus"
    }, {
        id: 'pot1266',
        lat: 10.0,
        lon: 76.5,
        name: "VISAT Engineering College"
    }, {
        id: 'pot1267',
        lat: 12.0986648,
        lon: 75.5615073,
        name: "Vimal Jyothi Engineering College"
    }, {
        id: 'pot1268',
        lat: 9.949865,
        lon: 76.6317008,
        name: "Viswajyothi College of Engineering and Technology"
    }, {
        id: 'pot1269',
        lat: 8.8805296,
        lon: 76.6290958,
        name: "Younus College of Engineering"
    }, {
        id: 'pot1270',
        lat: 8.8805296,
        lon: 76.6290958,
        name: "Younus College of Engineering & Technology"
    }, {
        id: 'pot1271',
        lat: 8.95687,
        lon: 76.85274,
        name: "Younus Institute of Technology"
    }, {
        id: 'pot1272',
        lat: 22.5269276,
        lon: 75.9262066,
        name: "Indian Institute of Technology"
    }, {
        id: 'pot1273',
        lat: 23.25469,
        lon: 77.40289,
        name: "Maulana Azad National Institute of Technology"
    }, {
        id: 'pot1274',
        lat: 26.2508341,
        lon: 78.1715634,
        name: "Indian Institute of Information Technology and Management"
    }, {
        id: 'pot1275',
        lat: 23.1758267,
        lon: 80.0224215,
        name: "Indian Institute of Information Technology Design and Manufacturing"
    }, {
        id: 'pot1276',
        lat: 23.1631755,
        lon: 79.996521,
        name: "Jabalpur Engineering College"
    }, {
        id: 'pot1277',
        lat: 22.71792,
        lon: 75.8333,
        name: "Shri Govindram Seksaria Institute of Technology and Science"
    }, {
        id: 'pot1278',
        lat: 26.22983,
        lon: 78.17337,
        name: "Madhav Institute of Technology and Science"
    }, {
        id: 'pot1279',
        lat: 23.91667,
        lon: 78.0,
        name: "Samrat Ashok Technological Institute"
    }, {
        id: 'pot1280',
        lat: 23.41667,
        lon: 75.5,
        name: "Ujjain Engineering College"
    }, {
        id: 'pot1281',
        lat: 24.55592924,
        lon: 81.31356288,
        name: "Rewa Engineering College"
    }, {
        id: 'pot1282',
        lat: 23.84251,
        lon: 78.74386,
        name: "Indira Gandhi Engineering College"
    }, {
        id: 'pot1283',
        lat: 25.06096,
        lon: 79.44153,
        name: "Engineering College"
    }, {
        id: 'pot1284',
        lat: 25.14858267,
        lon: 80.85469291,
        name: "Mahatma Gandhi Chitrakoot Gramodaya Vishwavidyalaya"
    }, {
        id: 'pot1285',
        lat: 23.25469,
        lon: 77.40289,
        name: "Barkatullah University Institute of Technology"
    }, {
        id: 'pot1286',
        lat: 22.71792,
        lon: 75.8333,
        name: "Institute of Engineering and Technology"
    }, {
        id: 'pot1287',
        lat: 26.22983,
        lon: 78.17337,
        name: "Rustamji Institute of Technology"
    }, {
        id: 'pot1288',
        lat: 23.25469,
        lon: 77.40289,
        name: "University Institute of Technology"
    }, {
        id: 'pot1272',
        lat: 23.15276454,
        lon: 75.81190927,
        name: "School of Engineering and Technology (Vikram University)"
    }, {
        id: 'pot1273',
        lat: 23.29356,
        lon: 81.3619,
        name: "University Institute of Technology"
    }, {
        id: 'pot1274',
        lat: 23.16697,
        lon: 79.95006,
        name: "LNCT Jabalpur"
    }, {
        id: 'pot1275',
        lat: 23.09977472,
        lon: 75.8955628,
        name: "MIT Group of Institutes"
    }, {
        id: 'pot1276',
        lat: 22.71792,
        lon: 75.8333,
        name: "Indore Institute of Science and Technology"
    }, {
        id: 'pot1277',
        lat: 23.25469,
        lon: 77.40289,
        name: "Sagar Institute of Science and Technology (SISTec)"
    }, {
        id: 'pot1278',
        lat: 23.25469,
        lon: 77.40289,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1279',
        lat: 23.25469,
        lon: 77.40289,
        name: "Bansal Institute of Science & Technology"
    }, {
        id: 'pot1280',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1281',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1282',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1283',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga Institute of Technology and Sciences"
    }, {
        id: 'pot1284',
        lat: 23.16697,
        lon: 79.95006,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1285',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1286',
        lat: 23.2462887,
        lon: 77.502373,
        name: "Oriental Institute of Science and Technology"
    }, {
        id: 'pot1287',
        lat: 23.25469,
        lon: 77.40289,
        name: "Sagar Institute of Science and Technology (SISTec)"
    }, {
        id: 'pot1288',
        lat: 23.25469,
        lon: 77.40289,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1289',
        lat: 23.25469,
        lon: 77.40289,
        name: "Bansal Institute of Science & Technology"
    }, {
        id: 'pot1290',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1292',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1293',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga Institute of Technology and Sciences"
    }, {
        id: 'pot1294',
        lat: 23.16697,
        lon: 79.95006,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1295',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1288',
        lat: 23.25469,
        lon: 77.40289,
        name: "Sagar Institute of Science and Technology (SISTec)"
    }, {
        id: 'pot1289',
        lat: 23.25469,
        lon: 77.40289,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1290',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1292',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1293',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga Institute of Technology and Sciences"
    }, {
        id: 'pot1294',
        lat: 23.16697,
        lon: 79.95006,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1295',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1289',
        lat: 23.25469,
        lon: 77.40289,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1290',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1292',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1293',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga Institute of Technology and Sciences"
    }, {
        id: 'pot1294',
        lat: 23.16697,
        lon: 79.95006,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1295',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1286',
        lat: 22.71792,
        lon: 75.8333,
        name: "Shri Vaishnav Institute of Technology and Science"
    }, {
        id: 'pot1287',
        lat: 24.56852529,
        lon: 80.79302658,
        name: "AKS University"
    }, {
        id: 'pot1288',
        lat: 23.25469,
        lon: 77.40289,
        name: "Bhabha Engineering Research Institute"
    }, {
        id: 'pot1289',
        lat: 22.71792,
        lon: 75.8333,
        name: "Institute Of Engineering & Science IPS Academy"
    }, {
        id: 'pot1290',
        lat: 23.308601,
        lon: 77.38666405,
        name: "Truba Group of Institutes"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "NRI Group of Institutions"
    }, {
        id: 'pot1292',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology and Science"
    }, {
        id: 'pot1293',
        lat: 26.2508341,
        lon: 78.1715634,
        name: "Institute of Technology & Management"
    }, {
        id: 'pot1294',
        lat: 26.22983,
        lon: 78.17337,
        name: "Amity University"
    }, {
        id: 'pot1295',
        lat: 24.4355362,
        lon: 77.1623521,
        name: "Jaypee University of Engineering and Technology"
    }, {
        id: 'pot1286',
        lat: 23.25469,
        lon: 77.40289,
        name: "Millennium Group of Institutions"
    }, {
        id: 'pot1287',
        lat: 22.71792,
        lon: 75.8333,
        name: "SKITM Shivaji Rao Kadam Institute of Technology"
    }, {
        id: 'pot1288',
        lat: 22.71792,
        lon: 75.8333,
        name: "Sushila Devi Bansal College of Technology"
    }, {
        id: 'pot1289',
        lat: 22.71792,
        lon: 75.8333,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1290',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1292',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1293',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga Institute of Technology and Sciences"
    }, {
        id: 'pot1294',
        lat: 23.16697,
        lon: 79.95006,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1295',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology"
    }, {
        id: 'pot1286',
        lat: 22.71792,
        lon: 75.8333,
        name: "Lord Krishna College of Engineering"
    }, {
        id: 'pot1287',
        lat: 24.56852529,
        lon: 80.79302658,
        name: "AKS University"
    }, {
        id: 'pot1288',
        lat: 23.25469,
        lon: 77.40289,
        name: "Bhabha Engineering Research Institute"
    }, {
        id: 'pot1289',
        lat: 22.71792,
        lon: 75.8333,
        name: "Institute Of Engineering & Science IPS Academy"
    }, {
        id: 'pot1290',
        lat: 23.308601,
        lon: 77.38666405,
        name: "Truba Group of Institutes"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "NRI Group of Institutions"
    }, {
        id: 'pot1292',
        lat: 23.25469,
        lon: 77.40289,
        name: "Lakshmi Narain College of Technology and Science"
    }, {
        id: 'pot1293',
        lat: 26.2508341,
        lon: 78.1715634,
        name: "Institute of Technology & Management"
    }, {
        id: 'pot1294',
        lat: 26.22983,
        lon: 78.17337,
        name: "Amity University"
    }, {
        id: 'pot1295',
        lat: 24.4355362,
        lon: 77.1623521,
        name: "Jaypee University of Engineering and Technology"
    }, {
        id: 'pot1286',
        lat: 23.25469,
        lon: 77.40289,
        name: "Millennium Group of Institutions"
    }, {
        id: 'pot1287',
        lat: 22.71792,
        lon: 75.8333,
        name: "SKITM Shivaji Rao Kadam Institute of Technology"
    }, {
        id: 'pot1288',
        lat: 22.71792,
        lon: 75.8333,
        name: "Sushila Devi Bansal College of Technology"
    }, {
        id: 'pot1289',
        lat: 22.71792,
        lon: 75.8333,
        name: "Patel Group of Institutions"
    }, {
        id: 'pot1290',
        lat: 23.84251,
        lon: 78.74386,
        name: "Gyansagar College Of Engineering"
    }, {
        id: 'pot1291',
        lat: 23.25469,
        lon: 77.40289,
        name: "Technocrats Institute of Technology"
    }, {
        id: 'pot1292',
        lat: 23.16697,
        lon: 79.95006,
        name: "Gyan Ganga College of Technology"
    }, {
        id: 'pot1293',
        lat: 26.22983,
        lon: 78.17337,
        name: "Maharana Pratap College of Technology"
    }, {
        id: 'mp51',
        lat: 22.59840725,
        lon: 75.89317683,
        name: "Vindhya Institute of Technology and Science (VITS)"
    }, {
        id: 'jh1',
        lat: 23.80199,
        lon: 86.44324,
        name: "ISM Dhanbad - Indian Institute of Technology - [IITISM]"
    }, {
        id: 'jh2',
        lat: 22.7758993,
        lon: 86.1478023,
        name: "National Institute of Technology - [NIT]"
    }, {
        id: 'jh3',
        lat: 23.4175695,
        lon: 85.4394094,
        name: "Birla Institute of Technology - [BIT Mesra]"
    }, {
        id: 'jh4',
        lat: 23.54179535,
        lon: 85.40157153,
        name: "Indian Institute of Information Technology - [IIIT]"
    }, {
        id: 'jh5',
        lat: 23.63996,
        lon: 86.50978,
        name: "Birsa Institute of Technology - [BIT] Sindri"
    }, {
        id: 'jh6',
        lat: 24.48983,
        lon: 86.69902,
        name: "Birla Institute of Technology Extension Centre - [BIT]"
    }, {
        id: 'jh7',
        lat: 23.2934301,
        lon: 85.30964831,
        name: "National Institute Of Advanced Manufacturing Technology (NIAMT)"
    }, {
        id: 'jh8',
        lat: 23.99507,
        lon: 85.36109,
        name: "UCET VB University"
    }, {
        id: 'jh9',
        lat: 23.3500519,
        lon: 85.3256983,
        name: "Amity University"
    }, {
        id: 'jh10',
        lat: 23.36111065,
        lon: 85.3222051,
        name: "Nilai Institute of Technology"
    }, {
        id: 'jh11',
        lat: 22.80278,
        lon: 86.18545,
        name: "RVS College of Engineering and Technology"
    }, {
        id: 'jh12',
        lat: 23.3837214,
        lon: 85.4633335,
        name: "Cambridge Institute of Technology"
    }, {
        id: 'jh13',
        lat: 22.54825,
        lon: 85.80458,
        name: "Chaibasa Engineering College"
    }, {
        id: 'jh14',
        lat: 24.26778,
        lon: 87.24855,
        name: "Dumka Engineering College"
    }, {
        id: 'jh15',
        lat: 24.4349,
        lon: 85.52951,
        name: "Ramgovind Institute of Technology"
    }, {
        id: 'jh16',
        lat: 23.63018,
        lon: 85.51926,
        name: "Government Engineering College"
    }, {
        id: 'jh17',
        lat: 23.43673418,
        lon: 85.51206252,
        name: "Usha Martin University"
    }, {
        id: 'jh18',
        lat: 23.0,
        lon: 85.0,
        name: "Sai Nath University"
    }, {
        id: 'jh19',
        lat: 23.80199,
        lon: 86.44324,
        name: "KK College of Engineering and Management"
    }, {
        id: 'jh20',
        lat: 23.47277771,
        lon: 85.48922146,
        name: "RTC Institute of Technology"
    }, {
        id: 'jh21',
        lat: 23.91667,
        lon: 84.08333,
        name: "DAV Institute of Engineering and Technology"
    }, {
        id: 'jh22',
        lat: 22.80278,
        lon: 86.18545,
        name: "BA College of Engineering and Technology"
    }, {
        id: 'jh23',
        lat: 23.78732,
        lon: 85.95622,
        name: "Guru Gobind Singh Educational Society's Technical Campus"
    }, {
        id: 'jh24',
        lat: 23.3718004,
        lon: 85.3242526,
        name: "Ranchi University"
    }, {
        id: 'jh25',
        lat: 23.4421777,
        lon: 85.1455277,
        name: "Central University of Jharkhand"
    }, {
        id: 'jh26',
        lat: 23.0,
        lon: 85.0,
        name: "Jharkhand Rai University"
    }, {
        id: 'jh27',
        lat: 22.54825,
        lon: 85.80458,
        name: "Kolhan University"
    }, {
        id: 'jh28',
        lat: 24.4349,
        lon: 85.52951,
        name: "Capital University"
    }, {
        id: 'jh29',
        lat: 23.91667,
        lon: 84.08333,
        name: "Ramchandra Chandravansi University"
    }, {
        id: 'jh30',
        lat: 22.80278,
        lon: 86.18545,
        name: "Maryland Institute of Technology And Management"
    }, {
        id: 'jh31',
        lat: 22.84727899,
        lon: 86.10263816,
        name: "Arka Jain University"
    }, {
        id: 'jh32',
        lat: 23.91667,
        lon: 84.08333,
        name: "Ramchandra Chandarvansi Institute of Technology"
    }, {
        id: 'jh33',
        lat: 23.45544108,
        lon: 85.60542614,
        name: "Alice Institute of Technology"
    }, {
        id: 'jh34',
        lat: 23.63018,
        lon: 85.51926,
        name: "Ramgarh Engineering College"
    }, {
        id: 'jh35',
        lat: 23.42789452,
        lon: 85.40423993,
        name: "International School for Applied Technology"
    }, {
        id: 'jh36',
        lat: 23.8148779,
        lon: 86.4425786,
        name: "Dhanbad Institute Of Technology"
    }, {
        id: 'jh37',
        lat: 24.05792318,
        lon: 84.17481164,
        name: "Government Engineering College"
    }, {
        id: 'jh38',
        lat: 23.4423211,
        lon: 85.318192,
        name: "Birsa Agricultural University"
    }, {
        id: 'jh39',
        lat: 23.3495491,
        lon: 85.3077677,
        name: "ICFAI University"
    }, {
        id: 'jh40',
        lat: 22.81030547,
        lon: 86.26336102,
        name: "Netaji Subhas University"
    }, {
        id: 'jh41',
        lat: 23.0,
        lon: 85.0,
        name: "Sarala Birla University"
    }, {
        id: 'jh42',
        lat: 23.29516338,
        lon: 85.42810645,
        name: "YBN University"
    }, {
        id: 'jh43',
        lat: 23.63018,
        lon: 85.51926,
        name: "Radha Govind University"
    }, {
        id: 'jh44',
        lat: 23.80199,
        lon: 86.44324,
        name: "Binod Bihar Mahto Koylanchal University"
    }, {
        id: 'jh45',
        lat: 22.80278,
        lon: 86.18545,
        name: "Srinath University"
    }, {
        id: 'jh46',
        lat: 23.31583434,
        lon: 85.37457914,
        name: "Jharkhand University of Technology"
    }, {
        id: 'jh47',
        lat: 23.36208,
        lon: 84.79952,
        name: "Sona Devi University"
    }, {
        id: 'jh48',
        lat: 24.07494,
        lon: 83.71023,
        name: "BABU DINESH SINGH UNIVERSITY"
    }, {
        id: 'jk1',
        lat: 32.8032545,
        lon: 74.8954449,
        name: "Indian Institute of Technology (IIT) Jammu"
    }, {
        id: 'jk2',
        lat: 34.50344,
        lon: -82.65013,
        name: "Shri Mata Vaishno Devi University (SMVDU) - College of Engineering"
    }, {
        id: 'jk3',
        lat: 32.73569,
        lon: 74.86911,
        name: "Government College of Engineering and Technology (GCET) Jammu"
    }, {
        id: 'jk4',
        lat: 32.73569,
        lon: 74.86911,
        name: "Model Institute of Engineering and Technology (MIET) Jammu"
    }, {
        id: 'jk5',
        lat: 33.91667,
        lon: 76.66667,
        name: "MBS College of Engineering & Technology"
    }, {
        id: 'jk6',
        lat: 33.91667,
        lon: 76.66667,
        name: "Yogananda College of Engineering and Technology"
    }, {
        id: 'jk7',
        lat: 32.56113,
        lon: 75.12493,
        name: "Bhargava College of Engineering and Technology"
    }, {
        id: 'jk8',
        lat: 33.25,
        lon: 74.25,
        name: "Baba Ghulam Shah Badshah University - College of Engineering and Technology"
    }, {
        id: 'jk9',
        lat: 32.58333,
        lon: 75.5,
        name: "University of Jammu (Kathua Campus)"
    }, {
        id: 'jk10',
        lat: 34.1244218,
        lon: 74.841641,
        name: "National Institute of Technology (NIT) Srinagar"
    }, {
        id: 'jk11',
        lat: 34.08842,
        lon: 74.80298,
        name: "Institute of Technology University of Kashmir (Zakura Campus)"
    }, {
        id: 'jk12',
        lat: 34.08842,
        lon: 74.80298,
        name: "SSM College of Engineering and Technology"
    }, {
        id: 'jk13',
        lat: 34.22992,
        lon: 74.7783,
        name: "Government Polytechnic College"
    }, {
        id: 'jk14',
        lat: 34.50344,
        lon: -82.65013,
        name: "Central University of Kashmir - School of Engineering and Technology"
    }, {
        id: 'jk15',
        lat: 34.19287,
        lon: 74.3692,
        name: "University of Kashmir"
    }, {
        id: 'jk16',
        lat: 33.91667,
        lon: 76.66667,
        name: "T.R. Memorial College of Engineering and Research"
    }, {
        id: 'jk17',
        lat: 34.32384323,
        lon: 76.8869913,
        name: "Sindhu Central University M.Tech programs"
    }, {
        id: 'jk18',
        lat: 34.57082512,
        lon: 77.50330965,
        name: "Government Polytechnic College Diploma in Mechanical/Civil Engineering"
    }, {
        id: 'jk19',
        lat: 34.52024967,
        lon: 76.13592245,
        name: "Government Polytechnic College Diploma in Civil/Electrical Engineering"
    }, {
        id: 'jk20',
        lat: 34.15214368,
        lon: 77.57856575,
        name: "NIELIT"
    }, {
        id: 'jk21',
        lat: 34.16504,
        lon: 77.58402,
        name: "Industrial Training Institute (ITI) NCVT certified trades"
    }, {
        id: 'jk22',
        lat: 34.33333,
        lon: 77.41667,
        name: "Industrial Training Institute (ITI) Kargil â NCVT certified trades"
    }, {
        id: 'tn1',
        lat: 11.13849,
        lon: 79.07556,
        name: "Anna University - Ariyalur Campus"
    }, {
        id: 'tn2',
        lat: 12.7521894,
        lon: 80.1961009,
        name: "Sri Sivasubramaniya Nadar College of Engineering"
    }, {
        id: 'tn3',
        lat: 12.69274,
        lon: 79.9773,
        name: "Sri Sai Ram Engineering College"
    }, {
        id: 'tn4',
        lat: 12.9607461,
        lon: 80.0537617,
        name: "Sri Sairam Institute of Technology"
    }, {
        id: 'tn5',
        lat: 12.69274,
        lon: 79.9773,
        name: "Sri Sairam College of Engineering & Technology"
    }, {
        id: 'tn6',
        lat: 13.00806,
        lon: 80.21944,
        name: "College of Engineering"
    }, {
        id: 'tn7',
        lat: 13.08784,
        lon: 80.27847,
        name: "Meenakshi Sundararajan Engineering College"
    }, {
        id: 'tn8',
        lat: 13.0549811,
        lon: 80.226481,
        name: "Meenakshi College of Engineering"
    }, {
        id: 'tn9',
        lat: 12.9941561,
        lon: 80.2366826,
        name: "Madras Institute of Technology"
    }, {
        id: 'tn10',
        lat: 13.0078848,
        lon: 80.2383327,
        name: "Alagappa College of Technology"
    }, {
        id: 'tn11',
        lat: 12.9941561,
        lon: 80.2366826,
        name: "Indian Institute of Technology Madras"
    }, {
        id: 'tn12',
        lat: 13.0592289,
        lon: 80.2336108,
        name: "Loyola-ICAM College of Engineering and Technology"
    }, {
        id: 'tn13',
        lat: 13.08784,
        lon: 80.27847,
        name: "BSA Crescent Engineering College"
    }, {
        id: 'tn14',
        lat: 12.8420834,
        lon: 80.1552761,
        name: "Chennai Institute of Technology"
    }, {
        id: 'tn15',
        lat: 13.08784,
        lon: 80.27847,
        name: "Mohamed Sathak A.J. College of Engineering"
    }, {
        id: 'tn16',
        lat: 12.9456344,
        lon: 80.2079506,
        name: "Jerusalem College of Engineering"
    }, {
        id: 'tn17',
        lat: 12.8690355,
        lon: 80.2151565,
        name: "St. Joseph's College of Engineering"
    }, {
        id: 'tn18',
        lat: 11.0246833,
        lon: 77.0028425,
        name: "PSG College of Technology"
    }, {
        id: 'tn19',
        lat: 11.0276998,
        lon: 77.0273693,
        name: "Coimbatore Institute of Technology"
    }, {
        id: 'tn20',
        lat: 11.018482,
        lon: 76.9364446,
        name: "Government College of Technology"
    }, {
        id: 'tn21',
        lat: 11.00555,
        lon: 76.96612,
        name: "Rathinam Technical Campus"
    }, {
        id: 'tn22',
        lat: 11.0778243,
        lon: 76.9895628,
        name: "Kumaraguru College of Technology"
    }, {
        id: 'tn23',
        lat: 11.0765677,
        lon: 77.1421032,
        name: "KPR Institute of Engineering and Technology"
    }, {
        id: 'tn24',
        lat: 11.1020978,
        lon: 76.9654004,
        name: "Sri Ramakrishna Engineering College"
    }, {
        id: 'tn25',
        lat: 10.8783102,
        lon: 77.0208023,
        name: "Karpagam College of Engineering"
    }, {
        id: 'tn26',
        lat: 10.9371249,
        lon: 76.9564045,
        name: "Sri Krishna College of Engineering & Technology"
    }, {
        id: 'tn27',
        lat: 11.00555,
        lon: 76.96612,
        name: "SNS College of Technology"
    }, {
        id: 'tn28',
        lat: 10.6562936,
        lon: 77.0353429,
        name: "Dr. Mahalingam College of Engineering and Technology"
    }, {
        id: 'tn29',
        lat: 11.00555,
        lon: 76.96612,
        name: "Tamil Nadu College of Engineering"
    }, {
        id: 'tn30',
        lat: 11.00555,
        lon: 76.96612,
        name: "Hindusthan College Of Engineering And Technology"
    }, {
        id: 'tn31',
        lat: 11.00555,
        lon: 76.96612,
        name: "Sri Shakthi Institute of Engineering & Technology"
    }, {
        id: 'tn32',
        lat: 11.52,
        lon: 79.51,
        name: "Anna University - Panruti Campus"
    }, {
        id: 'tn33',
        lat: 11.52,
        lon: 79.51,
        name: "CK College of Engineering"
    }, {
        id: 'tn34',
        lat: 11.2772401,
        lon: 79.5373264,
        name: "MRK Institute of Technology"
    }, {
        id: 'tn35',
        lat: 11.52,
        lon: 79.51,
        name: "Dr. Navalar Nedunchezhiyan College of Engineering"
    }, {
        id: 'tn36',
        lat: 11.52,
        lon: 79.51,
        name: "Krishnaswamy College of Engineering and Technology"
    }, {
        id: 'tn37',
        lat: 11.52,
        lon: 79.51,
        name: "St. Anne College of Engineering and Technology"
    }, {
        id: 'tn38',
        lat: 12.1277,
        lon: 78.15794,
        name: "Government College of Engineering"
    }, {
        id: 'tn39',
        lat: 10.36896,
        lon: 77.98036,
        name: "Anna University - Dindigul Campus"
    }, {
        id: 'tn40',
        lat: 11.3428,
        lon: 77.72741,
        name: "Government College of Engineering"
    }, {
        id: 'tn41',
        lat: 11.2721791,
        lon: 77.6039999,
        name: "Kongu Engineering College"
    }, {
        id: 'tn42',
        lat: 11.3428,
        lon: 77.72741,
        name: "Bannari Amman Institute of Technology"
    }, {
        id: 'tn43',
        lat: 11.3137329,
        lon: 77.5503416,
        name: "Erode Sengunthar Engineering College"
    }, {
        id: 'tn44',
        lat: 11.3428,
        lon: 77.72741,
        name: "Velalar College of Engineering and Technology"
    }, {
        id: 'tn45',
        lat: 11.3428,
        lon: 77.72741,
        name: "Nandha College of Technology"
    }, {
        id: 'tn46',
        lat: 12.83515,
        lon: 79.70006,
        name: "Anna University College of Engineering Kanchipuram"
    }, {
        id: 'tn47',
        lat: 12.83515,
        lon: 79.70006,
        name: "Indian Institute of Information Technology Design & Manufacturing"
    }, {
        id: 'tn48',
        lat: 12.83515,
        lon: 79.70006,
        name: "Thangavelu Engineering College (TEC)"
    }, {
        id: 'tn49',
        lat: 12.83515,
        lon: 79.70006,
        name: "Kings Engineering College (KEC)"
    }, {
        id: 'tn50',
        lat: 12.83515,
        lon: 79.70006,
        name: "Adhiparasakthi Engineering College"
    }, {
        id: 'tn51',
        lat: 8.17731,
        lon: 77.43437,
        name: "University College of Engineering"
    }, {
        id: 'tn52',
        lat: 8.32,
        lon: 77.34,
        name: "Arunachala College of Engineering for Women"
    }, {
        id: 'tn53',
        lat: 11.0544141,
        lon: 78.0486074,
        name: "M. Kumarasamy College of Engineering"
    }, {
        id: 'tn54',
        lat: 10.95771,
        lon: 78.08095,
        name: "Chettinad College of Engineering and Technology"
    }, {
        id: 'tn55',
        lat: 12.54245,
        lon: 78.35724,
        name: "Government College of Engineering"
    }, {
        id: 'tn56',
        lat: 12.7151533,
        lon: 77.8678071,
        name: "Adhiyamaan College of Engineering"
    }, {
        id: 'tn57',
        lat: 9.8816162,
        lon: 78.0834328,
        name: "Thiagarajar College of Engineering"
    }, {
        id: 'tn58',
        lat: 9.91735,
        lon: 78.11962,
        name: "Velammal College of Engineering and Technology"
    }, {
        id: 'tn59',
        lat: 9.91735,
        lon: 78.11962,
        name: "Kamaraj College of Engineering and Technology"
    }, {
        id: 'tn60',
        lat: 9.9257865,
        lon: 78.1985782,
        name: "Solamalai College of Engineering"
    }, {
        id: 'tn61',
        lat: 9.8744346,
        lon: 78.0143466,
        name: "P.T.R College of Engineering and Technology"
    }, {
        id: 'tn62',
        lat: 9.8760502,
        lon: 78.2745304,
        name: "Fathima Michael College of Engineering and Technology"
    }, {
        id: 'tn63',
        lat: 10.0724732,
        lon: 78.2403502,
        name: "Latha Mathavan Engineering College"
    }, {
        id: 'tn64',
        lat: 9.9721129,
        lon: 78.2106261,
        name: "Ultra College of Engineering and Technology"
    }, {
        id: 'tn65',
        lat: 9.91735,
        lon: 78.11962,
        name: "Vaigai College of Engineering"
    }, {
        id: 'tn66',
        lat: 11.10354,
        lon: 79.655,
        name: "A.V.C College of Engineering"
    }, {
        id: 'tn67',
        lat: 10.76393,
        lon: 79.84454,
        name: "E.G.S Pillay Engineering College"
    }, {
        id: 'tn68',
        lat: 10.76393,
        lon: 79.84454,
        name: "Sembodai Rukumani College of Engineering College"
    }, {
        id: 'tn69',
        lat: 10.76393,
        lon: 79.84454,
        name: "Sir Issac Newton College of Engineering and Technology"
    }, {
        id: 'tn70',
        lat: 10.76393,
        lon: 79.84454,
        name: "Arifa Institute of Engineering and Technology"
    }, {
        id: 'tn71',
        lat: 10.76393,
        lon: 79.84454,
        name: "Prime College of Architecture and Planning"
    }, {
        id: 'tn72',
        lat: 11.22126,
        lon: 78.16524,
        name: "Selvam College of Technology"
    }, {
        id: 'tn73',
        lat: 11.22126,
        lon: 78.16524,
        name: "J.K.K. Nattraja College of Engineering and Technology"
    }, {
        id: 'tn74',
        lat: 11.22126,
        lon: 78.16524,
        name: "Sengunthar Engineering College (Autonomous)"
    }, {
        id: 'tn75',
        lat: 11.3586742,
        lon: 77.8284048,
        name: "K. S. Rangasamy College of Technology"
    }, {
        id: 'tn76',
        lat: 11.46009,
        lon: 78.18635,
        name: "Muthayammal Engineering College"
    }, {
        id: 'tn77',
        lat: 11.3989494,
        lon: 78.1606289,
        name: "Paavai Engineering College"
    }, {
        id: 'tn78',
        lat: 11.38016,
        lon: 77.89444,
        name: "SENGUNTHAR Engineering College"
    }, {
        id: 'tn79',
        lat: 11.23333,
        lon: 78.88333,
        name: "Dhanalakshmi Srinivasan College of Engineering"
    }, {
        id: 'tn80',
        lat: 9.37158,
        lon: 78.83077,
        name: "Anna University - Ramanathapuram Campus"
    }, {
        id: 'tn81',
        lat: 9.37158,
        lon: 78.83077,
        name: "Mohamed Sathak Engineering College"
    }, {
        id: 'tn82',
        lat: 9.37158,
        lon: 78.83077,
        name: "Syed Ammal Engineering College"
    }, {
        id: 'tn83',
        lat: 12.9184,
        lon: 79.13255,
        name: "Ranipetai Engineering College"
    }, {
        id: 'tn84',
        lat: 11.65117,
        lon: 78.15867,
        name: "Government College of Engineering"
    }, {
        id: 'tn85',
        lat: 11.6634248,
        lon: 78.1833888,
        name: "AVS Engineering College"
    }, {
        id: 'tn86',
        lat: 11.65117,
        lon: 78.15867,
        name: "Government College of Engineering"
    }, {
        id: 'tn87',
        lat: 11.65117,
        lon: 78.15867,
        name: "Sona College of Technology"
    }, {
        id: 'tn88',
        lat: 11.65117,
        lon: 78.15867,
        name: "Tagore Institute of Engineering and Technology"
    }, {
        id: 'tn89',
        lat: 9.84701,
        lon: 78.48358,
        name: "Alagappa Chettiar College of Engineering and Technology"
    }, {
        id: 'tn90',
        lat: 12.9871008,
        lon: 79.9719323,
        name: "Sri Venkateswara College of Engineering"
    }, {
        id: 'tn91',
        lat: 10.78523,
        lon: 79.13909,
        name: "Anna University - Pattukkottai Campus"
    }, {
        id: 'tn92',
        lat: 10.78523,
        lon: 79.13909,
        name: "Government College of Engineering"
    }, {
        id: 'tn93',
        lat: 10.78523,
        lon: 79.13909,
        name: "Parisutham Institute of Technology & Science"
    }, {
        id: 'tn94',
        lat: 10.01171,
        lon: 77.34976,
        name: "Government College of Engineering"
    }, {
        id: 'tn95',
        lat: 10.77269,
        lon: 79.6368,
        name: "Anna University - Thirukkuvalai Campus"
    }, {
        id: 'tn96',
        lat: 10.7792109,
        lon: 79.3646114,
        name: "Anjalai Ammal Mahalingam Engineering College"
    }, {
        id: 'tn97',
        lat: 8.76735,
        lon: 78.13425,
        name: "Anna University V.O.Chidambaranar College of Engineering"
    }, {
        id: 'tn98',
        lat: 8.7369064,
        lon: 78.0142891,
        name: "St. Mother Theresa Engineering College"
    }, {
        id: 'tn99',
        lat: 8.49725,
        lon: 78.11906,
        name: "Dr. Sivanthi Adithanar College of Engineering"
    }, {
        id: 'tn100',
        lat: 9.147855,
        lon: 77.8348368,
        name: "National Engineering College"
    }, {
        id: 'tn101',
        lat: 10.85733,
        lon: 78.69713,
        name: "Government College of Engineering"
    }, {
        id: 'tn102',
        lat: 10.8155,
        lon: 78.69651,
        name: "Indian Institute of Information Technology Tiruchirappalli"
    }, {
        id: 'tn103',
        lat: 10.7633854,
        lon: 78.8150292,
        name: "National Institute of Technology"
    }, {
        id: 'tn104',
        lat: 10.8155,
        lon: 78.69651,
        name: "Vetri Vinayaha College of Engineering and Technology"
    }, {
        id: 'tn105',
        lat: 8.6871836,
        lon: 77.7258209,
        name: "Government College of Engineering"
    }, {
        id: 'tn106',
        lat: 8.72518,
        lon: 77.68452,
        name: "Francis Xavier Engineering College"
    }, {
        id: 'tn107',
        lat: 8.6871836,
        lon: 77.7258209,
        name: "Government College of Engineering"
    }, {
        id: 'tn108',
        lat: 13.14376,
        lon: 79.90889,
        name: "RMK Engineering College"
    }, {
        id: 'tn109',
        lat: 13.14376,
        lon: 79.90889,
        name: "Apollo Engineering College"
    }, {
        id: 'tn110',
        lat: 13.14376,
        lon: 79.90889,
        name: "Prathyusha Engineering College"
    }, {
        id: 'tn111',
        lat: 13.14376,
        lon: 79.90889,
        name: "Saveetha Engineering College"
    }, {
        id: 'tn112',
        lat: 13.14376,
        lon: 79.90889,
        name: "Velammal Institute of Technology"
    }, {
        id: 'tn113',
        lat: 12.66987,
        lon: 79.28555,
        name: "Anna University College of Engineering Arni"
    }, {
        id: 'tn114',
        lat: 12.7823822,
        lon: 79.627722,
        name: "Arulmigu Meenakshi Amman College of Engineering"
    }, {
        id: 'tn115',
        lat: 12.9184,
        lon: 79.13255,
        name: "Thanthai Periyar Government Institute of Technology"
    }, {
        id: 'tn116',
        lat: 12.9184,
        lon: 79.13255,
        name: "Thanthai Periyar Government Institute of Technology"
    }, {
        id: 'tn117',
        lat: 12.9184,
        lon: 79.13255,
        name: "C. Abdul Hakeem College of Engineering & Technology"
    }, {
        id: 'tn118',
        lat: 13.0123482,
        lon: 79.1341009,
        name: "Kingston Engineering College"
    }, {
        id: 'tn119',
        lat: 12.9184,
        lon: 79.13255,
        name: "Global Institute of Technology"
    }, {
        id: 'tn120',
        lat: 12.9184,
        lon: 79.13255,
        name: "Annai Meera Engineering College"
    }, {
        id: 'tn121',
        lat: 12.9184,
        lon: 79.13255,
        name: "Sree Krishna Engineering College"
    }, {
        id: 'tn122',
        lat: 12.9184,
        lon: 79.13255,
        name: "Priyadarshini Engineering College"
    }, {
        id: 'tn123',
        lat: 12.9184,
        lon: 79.13255,
        name: "Bharathi Dhasan Engineering College"
    }, {
        id: 'tn124',
        lat: 11.0,
        lon: 78.33333,
        name: "Anna University - College of Engineering Viluppuram"
    }, {
        id: 'tn125',
        lat: 11.0,
        lon: 78.33333,
        name: "Anna University College of Engineering Tindivanam"
    }, {
        id: 'tn126',
        lat: 9.45,
        lon: 77.92,
        name: "Mepco Schlenk Engineering College"
    }, {
        id: 'tn127',
        lat: 9.45,
        lon: 77.92,
        name: "Sethu Institute of Technology"
    }, {
        id: 'wc1',
        lat: 22.56263,
        lon: 88.36304,
        name: "Advanced Institute of Modern Management & Technology"
    }, {
        id: 'wc2',
        lat: 26.49633153,
        lon: 89.69989635,
        name: "Alipurduar Government Engineering and Management College"
    }, {
        id: 'wc3',
        lat: 23.49957,
        lon: 87.32155,
        name: "Aryabhatta Institute of Engineering & Management Durgapur"
    }, {
        id: 'wc4',
        lat: 23.7155238,
        lon: 86.9510664,
        name: "Asansol Engineering College"
    }, {
        id: 'wc5',
        lat: 23.2073304,
        lon: 87.0280952,
        name: "Bankura Unnayani Institute of Engineering"
    }, {
        id: 'wc6',
        lat: 23.5217315,
        lon: 87.3407551,
        name: "Bengal College of Engineering & Technology"
    }, {
        id: 'wc7',
        lat: 23.49957,
        lon: 87.32155,
        name: "Bengal College of Engineering & Technology for Women"
    }, {
        id: 'wc8',
        lat: 23.64251656,
        lon: 87.6278959,
        name: "Bengal Institute of Technology & Management"
    }, {
        id: 'wc9',
        lat: 23.93549385,
        lon: 87.52731378,
        name: "Birbhum Institute of Engineering & Technology"
    }, {
        id: 'wc10',
        lat: 22.56263,
        lon: 88.36304,
        name: "Birla Institute of Technology (Polytechnic)"
    }, {
        id: 'wc11',
        lat: 22.56263,
        lon: 88.36304,
        name: "Brainware University"
    }, {
        id: 'wc12',
        lat: 22.43333,
        lon: 87.86667,
        name: "College of Engineering and Management"
    }, {
        id: 'wc13',
        lat: 26.32539,
        lon: 89.44508,
        name: "Cooch Behar Government Engineering College"
    }, {
        id: 'wc14',
        lat: 24.0,
        lon: 88.0,
        name: "Dumkal Institute of Engineering & Technology"
    }, {
        id: 'wc15',
        lat: 22.3782815,
        lon: 88.44092004,
        name: "Gargi Memorial Institute of Technology"
    }, {
        id: 'wc16',
        lat: 25.04237,
        lon: 88.13867,
        name: "Ghani Khan Choudhury Institute of Engineering & Technology"
    }, {
        id: 'wc17',
        lat: 22.7511541,
        lon: 88.3536277,
        name: "Government College of Engineering & Textile Technology"
    }, {
        id: 'wc18',
        lat: 22.0521107,
        lon: 88.0712466,
        name: "Haldia Institute of Technology"
    }, {
        id: 'wc19',
        lat: 22.90877,
        lon: 88.39674,
        name: "Hooghly Engineering and Technology College"
    }, {
        id: 'wc20',
        lat: 22.555057,
        lon: 88.3058486,
        name: "IIEST"
    }, {
        id: 'wc21',
        lat: 22.3144275,
        lon: 87.310392,
        name: "IIT Kharagpur"
    }, {
        id: 'wc22',
        lat: 22.555057,
        lon: 88.3058486,
        name: "Indian Institute of Engineering Science and Technology (IIEST)"
    }, {
        id: 'wc23',
        lat: 22.4995216,
        lon: 88.3711493,
        name: "Jadavpur University"
    }, {
        id: 'wc24',
        lat: 26.5466036,
        lon: 88.7034601,
        name: "Jalpaiguri Government Engineering College"
    }, {
        id: 'wc25',
        lat: 22.56263,
        lon: 88.36304,
        name: "JIS College of Engineering"
    }, {
        id: 'wc26',
        lat: 22.990591,
        lon: 88.4480648,
        name: "Kalyani Government Engineering College"
    }, {
        id: 'wc27',
        lat: 23.49957,
        lon: 87.32155,
        name: "Kanad Institute of Engineering and Management"
    }, {
        id: 'wc28',
        lat: 22.72154,
        lon: 88.48198,
        name: "Adamas Institute of Technology"
    }, {
        id: 'wc29',
        lat: 23.0738,
        lon: 87.31991,
        name: "Mallabhum Institute of Technology"
    }, {
        id: 'wc30',
        lat: 22.56263,
        lon: 88.36304,
        name: "MCKV Institute of Engineering"
    }, {
        id: 'wc31',
        lat: 22.56263,
        lon: 88.36304,
        name: "Modern Institute of Engineering and Technology"
    }, {
        id: 'wc32',
        lat: 24.1839,
        lon: 88.27171,
        name: "Murshidabad College of Engineering & Technology"
    }, {
        id: 'wc33',
        lat: 22.56263,
        lon: 88.36304,
        name: "OmDayal Group of Institutions"
    }, {
        id: 'wc34',
        lat: 23.33062,
        lon: 86.36303,
        name: "Ramkrishna Mahato Government Engineering College"
    }, {
        id: 'wc35',
        lat: 22.5578201,
        lon: 88.3966291,
        name: "RCC Institute of Information Technology"
    }, {
        id: 'wc36',
        lat: 22.5388413,
        lon: 88.3286153,
        name: "St. Thomas' College of Engineering and Technology"
    }, {
        id: 'wc37',
        lat: 23.57325092,
        lon: 87.4039097,
        name: "Sanaka Education Trusts Group of Institutions"
    }, {
        id: 'wc38',
        lat: 22.90877,
        lon: 88.39674,
        name: "Saroj Mohan Institute of Technology"
    }, {
        id: 'wc39',
        lat: 26.71004,
        lon: 88.42851,
        name: "Siliguri Institute of Technology"
    }, {
        id: 'wc40',
        lat: 22.63629,
        lon: 88.33828,
        name: "Sree Ramkrishna Silpa Vidyapith"
    }, {
        id: 'wc41',
        lat: 22.56263,
        lon: 88.36304,
        name: "Supreme Knowledge Foundation Group of Institutions"
    }, {
        id: 'wc42',
        lat: 26.74770819,
        lon: 88.38444587,
        name: "Surendra Institute of Engineering & Management"
    }, {
        id: 'wc43',
        lat: 22.56263,
        lon: 88.36304,
        name: "Swami Vivekananda Institute of Science and Technology"
    }, {
        id: 'wc44',
        lat: 22.56263,
        lon: 88.36304,
        name: "Syamaprasad Institute of Technology & Management"
    }, {
        id: 'wc45',
        lat: 22.6,
        lon: 88.25,
        name: "Technique Polytechnic Institute"
    }, {
        id: 'wc46',
        lat: 23.49957,
        lon: 87.32155,
        name: "Techno India"
    }, {
        id: 'wc47',
        lat: 22.6,
        lon: 88.25,
        name: "Techno International Batanagar"
    }, {
        id: 'wc48',
        lat: 23.25572,
        lon: 87.85691,
        name: "University Institute of Technology Burdwan University"
    }, {
        id: 'mah1000',
        lat: 20.93333,
        lon: 77.75,
        name: "Sant Gadge Baba Amravati University"
    }, {
        id: 'mah1001',
        lat: 20.4118278,
        lon: 78.1342893,
        name: "Government College of Engineering"
    }, {
        id: 'mah1002',
        lat: 20.7932,
        lon: 76.69921,
        name: "Shri Sant Gajanan Maharaj College of Engineering"
    }, {
        id: 'mah1003',
        lat: 19.33333,
        lon: 75.83333,
        name: "Government College of Engineering"
    }, {
        id: 'mah1004',
        lat: 19.88062,
        lon: 75.32766,
        name: "Government College of Engineering, Aurangabad"
    }, {
        id: 'mah1005',
        lat: 20.93333,
        lon: 77.75,
        name: "Prof Ram Meghe Institute of Technology and Research"
    }, {
        id: 'mah1006',
        lat: 20.69560387,
        lon: 76.94111587,
        name: "COLLEGE OF ENGINEERING & TECHNOLOGY"
    }, {
        id: 'mah1007',
        lat: 20.93333,
        lon: 77.75,
        name: "Vidarbha Institute of Technology"
    }, {
        id: 'mah1008',
        lat: 20.93333,
        lon: 77.75,
        name: "P. R. Pote (Patil) Education & Welfare Trust's Group of Institution(Integrated Campus)"
    }, {
        id: 'mah1009',
        lat: 20.93333,
        lon: 77.75,
        name: "Sipna Shikshan Prasarak Mandal College of Engineering & Technology"
    }, {
        id: 'mah1010',
        lat: 20.93333,
        lon: 77.75,
        name: "Shri Hanuman Vyayam Prasarak Mandal College of Engineering"
    }, {
        id: 'mah1011',
        lat: 19.9974542,
        lon: 73.7898023,
        name: "K.K. Wagh Institute of Engineering Education and Research"
    }, {
        id: 'mah1012',
        lat: 19.46788,
        lon: 77.58572,
        name: "Shivaji University, Kolhapur"
    }, {
        id: 'mah1013',
        lat: 21.1458,
        lon: 79.0882,
        name: "Government College of Engineering, Nagpur"
    }, {
        id: 'mah1014',
        lat: 21.1702,
        lon: 72.8311,
        name: "S.V. National Institute of Technology"
    }, {
        id: 'mah1015',
        lat: 18.5204,
        lon: 73.8567,
        name: "College of Engineering, Pune"
    }, {
        id: 'mah1016',
        lat: 19.0760,
        lon: 72.8777,
        name: "Indian Institute of Technology Bombay"
    }, {
        id: 'mah1017',
        lat: 17.06734,
        lon: 74.52627,
        name: "Walchand College of Engineering"
    }, {
        id: 'mah1018',
        lat: 17.68589,
        lon: 73.99333,
        name: "Dnyanshree Institute Engineering and Technology"
    }, {
        id: 'mah1019',
        lat: 16.82417,
        lon: 74.64663,
        name: "Vishveshwarya Technical Campus"
    }, {
        id: 'mah1020',
        lat: 18.65318,
        lon: 73.78955,
        name: "Dr. D.Y.Patil Institute of Engineering Management & Reseach"
    }, {
        id: 'mah1021',
        lat: 16.22291,
        lon: 74.3501,
        name: "Sant Gajanan Maharaj College of Engineering"
    }, {
        id: 'mah1022',
        lat: 18.4469859,
        lon: 73.9373206,
        name: "Keystone School of Engineering"
    }, {
        id: 'mah1023',
        lat: 16.69563,
        lon: 74.23167,
        name: "Sanjay Ghodawat Institute"
    }, {
        id: 'mah1024',
        lat: 18.75275,
        lon: 73.40575,
        name: "Vidya Prasarini Sabha's College of Engineering & Technology"
    }, {
        id: 'mah1025',
        lat: 18.65067411,
        lon: 73.74523296,
        name: "Pimpri Chinchwad College Of Engineering And Research"
    }, {
        id: 'mah1026',
        lat: 21.11071,
        lon: 78.20106,
        name: "Jawaharlal Darda Institute of Engineering & Technology"
    }, {
        id: 'mah1027',
        lat: 18.89248,
        lon: 73.3444,
        name: "Konkan Gyanpeeth College of Engineering"
    }, {
        id: 'mah1311',
        lat: 19.88062,
        lon: 75.32766,
        name: "Government College of Engineering, Aurangabad"
    }, {
        id: 'mah1332',
        lat: 20.93333,
        lon: 77.75,
        name: "P. R. Pote (Patil) Education & Welfare Trust's Group of Institution(Integrated Campus)"
    }, {
        id: 'mah1333',
        lat: 19.9974542,
        lon: 73.7898023,
        name: "K.K. Wagh Institute of Engineering Education and Research"
    }, {
        id: 'mah1028',
        lat: 19.22744,
        lon: 77.29176,
        name: "SRTMUN"
    }, {
        id: 'odi1000',
        lat: 20.4698754,
        lon: 85.8518556,
        name: "Ajay Binay Institute of Technology"
    }, {
        id: 'odi1001',
        lat: 21.49266,
        lon: 86.93348,
        name: "Balasore College of Engineering and Technology"
    }, {
        id: 'odi1002',
        lat: 21.05447,
        lon: 86.5156,
        name: "Bhadrak Institute of Engineering & Technology"
    }, {
        id: 'odi1003',
        lat: 20.5,
        lon: 86.25,
        name: "Bhubanananda Odisha School of Engineering"
    }, {
        id: 'odi1004',
        lat: 20.2951508,
        lon: 85.7440293,
        name: "International Institute of Information Technology"
    }, {
        id: 'odi1005',
        lat: 22.2459907,
        lon: 84.8172658,
        name: "Biju Patnaik University of Technology"
    }, {
        id: 'odi1006',
        lat: 20.2201981,
        lon: 85.736219,
        name: "C. V. Raman Global University"
    }, {
        id: 'odi1007',
        lat: 20.27241,
        lon: 85.83385,
        name: "College of Agricultural Engineering & Technology"
    }, {
        id: 'odi1008',
        lat: 20.27241,
        lon: 85.83385,
        name: "College of Engineering"
    }, {
        id: 'odi1009',
        lat: 20.27241,
        lon: 85.83385,
        name: "College of IT and Management Education"
    }, {
        id: 'odi1010',
        lat: 20.18268,
        lon: 85.61629,
        name: "Eastern Academy of Science and Technology"
    }, {
        id: 'odi1011',
        lat: 20.27241,
        lon: 85.83385,
        name: "Gandhi Institute for Technology (GIFT)"
    }, {
        id: 'odi1012',
        lat: 19.1846709,
        lon: 83.3980467,
        name: "Gandhi Institute of Advanced Computer & Research"
    }, {
        id: 'odi1013',
        lat: 19.9,
        lon: 85.6,
        name: "Ghanashyam Hemalata Institute of Technology and Management"
    }, {
        id: 'odi1014',
        lat: 19.0,
        lon: 83.0,
        name: "Gopal Krushna College of Engineering & Technology"
    }, {
        id: 'odi1015',
        lat: 19.75,
        lon: 83.0,
        name: "Government College of Engineering"
    }, {
        id: 'odi1016',
        lat: 21.62962,
        lon: 85.5934,
        name: "Government College of Engineering"
    }, {
        id: 'odi1017',
        lat: 21.05447,
        lon: 86.5156,
        name: "Government Polytechnic"
    }, {
        id: 'odi1018',
        lat: 20.1478932,
        lon: 85.6759728,
        name: "IIT Bhubaneswar"
    }, {
        id: 'odi1019',
        lat: 20.5,
        lon: 84.41667,
        name: "Indira Gandhi Institute of Technology"
    }, {
        id: 'odi1020',
        lat: 20.5,
        lon: 86.25,
        name: "Institute of Management and Information Technology"
    }, {
        id: 'odi1021',
        lat: 21.49266,
        lon: 86.93348,
        name: "Jhadeswar Institute of Engineering & Technology"
    }, {
        id: 'odi1022',
        lat: 21.8617146,
        lon: 84.0409687,
        name: "Jharsuguda Engineering School"
    }, {
        id: 'odi1023',
        lat: 20.18268,
        lon: 85.61629,
        name: "Kalam Institute of Technology"
    }, {
        id: 'odi1024',
        lat: 20.27241,
        lon: 85.83385,
        name: "Krupajal Engineering College"
    }, {
        id: 'odi1025',
        lat: 21.86159,
        lon: 84.01788,
        name: "Mahavir Institute of Engineering and Technology"
    }, {
        id: 'odi1026',
        lat: 19.4,
        lon: 83.5,
        name: "Majhighariani Institute of Technology and Science"
    }, {
        id: 'odi1027',
        lat: 20.18268,
        lon: 85.61629,
        name: "National Institute of Science Education and Research (NISER)"
    }, {
        id: 'odi1028',
        lat: 22.2501589,
        lon: 84.9066856,
        name: "National Institute of Technology"
    }, {
        id: 'odi1029',
        lat: 20.18268,
        lon: 85.61629,
        name: "NIST University"
    }, {
        id: 'odi1030',
        lat: 20.18268,
        lon: 85.61629,
        name: "NM Institute of Engineering and Technology"
    }, {
        id: 'odi1031',
        lat: 20.2754506,
        lon: 85.7766657,
        name: "Odisha University of Technology and Research"
    }, {
        id: 'odi1032',
        lat: 20.5,
        lon: 86.25,
        name: "Orissa Engineering College"
    }, {
        id: 'odi1033',
        lat: 22.22496,
        lon: 84.86414,
        name: "Padmanava College of Engineering"
    }, {
        id: 'odi1034',
        lat: 19.31151,
        lon: 84.7929,
        name: "Parala Maharaja Engineering College"
    }, {
        id: 'odi1035',
        lat: 19.31151,
        lon: 84.7929,
        name: "Roland Institute of Technology"
    }, {
        id: 'odi1036',
        lat: 22.2501589,
        lon: 84.9066856,
        name: "Rourkela Institute of Technology"
    }, {
        id: 'odi1037',
        lat: 22.22496,
        lon: 84.86414,
        name: "S. K. D. A. V. Government Polytechnic"
    }, {
        id: 'odi1038',
        lat: 21.45,
        lon: 83.96667,
        name: "Sambalpur University Institute of Information Technology"
    }, {
        id: 'odi1039',
        lat: 19.31151,
        lon: 84.7929,
        name: "Sanjay Memorial Institute of Technology"
    }, {
        id: 'odi1040',
        lat: 21.75,
        lon: 86.5,
        name: "Seemanta Engineering College"
    }, {
        id: 'odi1041',
        lat: 21.45,
        lon: 83.96667,
        name: "Silicon Institute of Technology"
    }, {
        id: 'odi1042',
        lat: 20.5,
        lon: 86.25,
        name: "Sri Sri University"
    }, {
        id: 'odi1043',
        lat: 20.65744,
        lon: 85.59693,
        name: "Synergy Institute of Engineering & Technology"
    }, {
        id: 'odi1044',
        lat: 19.4,
        lon: 83.5,
        name: "Utkal Gourav Madhusudan Institute of Technology"
    }, {
        id: 'odi1045',
        lat: 19.9,
        lon: 85.6,
        name: "Utkalmani Gopabandhu Institute of Engineering & Technology"
    }, {
        id: 'odi1046',
        lat: 21.5,
        lon: 83.86667,
        name: "Veer Surendra Sai University of Technology (VSSUT)"
    }, {
        id: 'odi1047',
        lat: 20.18268,
        lon: 85.61629,
        name: "Vignan Institute of Technology and Management"
    }, {
        id: 'raj1000',
        lat: 26.26841,
        lon: 73.00594,
        name: "Indian Institute of Technology (IIT) Jodhpur"
    }, {
        id: 'raj1001',
        lat: 26.91962,
        lon: 75.78781,
        name: "Malaviya National Institute of Technology (MNIT Jaipur)"
    }, {
        id: 'raj1002',
        lat: 28.3586647,
        lon: 75.5882558,
        name: "Birla Institute of Technology and Science (BITS Pilani)"
    }, {
        id: 'raj1003',
        lat: 26.91962,
        lon: 75.78781,
        name: "LNM Institute of Information Technology (LNMIIT)"
    }, {
        id: 'raj1004',
        lat: 25.18254,
        lon: 75.83907,
        name: "Indian Institute of Information Technology Kota (IIIT Kota)"
    }, {
        id: 'raj1005',
        lat: 24.57117,
        lon: 73.69183,
        name: "University College of Engineering & Technology"
    }, {
        id: 'raj1006',
        lat: 28.02094,
        lon: 73.30749,
        name: "University College of Engineering & Technology"
    }, {
        id: 'raj1007',
        lat: 25.18254,
        lon: 75.83907,
        name: "Rajasthan Technical University (RTU)"
    }, {
        id: 'raj1008',
        lat: 28.02094,
        lon: 73.30749,
        name: "Bikaner Technical University (BTU)"
    }, {
        id: 'raj1009',
        lat: 26.44976,
        lon: 74.64116,
        name: "Central University of Rajasthan (CURAJ)"
    }, {
        id: 'raj1010',
        lat: 27.56246,
        lon: 76.625,
        name: "NIIT University"
    }, {
        id: 'raj1011',
        lat: 26.8429063,
        lon: 75.5654289,
        name: "Manipal University Jaipur"
    }, {
        id: 'raj1012',
        lat: 26.91962,
        lon: 75.78781,
        name: "Vivekananda Global University"
    }, {
        id: 'raj1013',
        lat: 27.1734749,
        lon: 75.9553184,
        name: "Amity University Rajasthan"
    }, {
        id: 'raj1014',
        lat: 26.84832,
        lon: 75.8593996,
        name: "Jaipur National University"
    }, {
        id: 'raj1015',
        lat: 26.91962,
        lon: 75.78781,
        name: "Jagannath University"
    }, {
        id: 'raj1016',
        lat: 26.91962,
        lon: 75.78781,
        name: "JK Lakshmipat University"
    }, {
        id: 'raj1017',
        lat: 26.91962,
        lon: 75.78781,
        name: "UEM University Jaipur"
    }, {
        id: 'raj1018',
        lat: 26.91962,
        lon: 75.78781,
        name: "Poornima College of Engineering"
    }, {
        id: 'raj1019',
        lat: 26.91962,
        lon: 75.78781,
        name: "Swami Keshvanand Institute of Technology Management & Gramothan (SKIT)"
    }, {
        id: 'raj1020',
        lat: 26.91962,
        lon: 75.78781,
        name: "Rajasthan College of Engineering for Women"
    }, {
        id: 'raj1021',
        lat: 26.91962,
        lon: 75.78781,
        name: "JECRC University (formerly Jaipur Engg. College & Research Centre)"
    }, {
        id: 'raj1022',
        lat: 26.91962,
        lon: 75.78781,
        name: "Suresh Gyan Vihar University"
    }, {
        id: 'raj1023',
        lat: 26.91962,
        lon: 75.78781,
        name: "Baldev Ram Mirdha Institute of Technology (BMIT)"
    }, {
        id: 'raj1024',
        lat: 26.91962,
        lon: 75.78781,
        name: "Arya College of Engineering & IT"
    }, {
        id: 'raj1025',
        lat: 26.91962,
        lon: 75.78781,
        name: "Global Institute of Technology"
    }, {
        id: 'raj1026',
        lat: 26.91962,
        lon: 75.78781,
        name: "Rajasthan Institute of Engineering & Technology (RIET)"
    }, {
        id: 'raj1027',
        lat: 26.91962,
        lon: 75.78781,
        name: "Mahal Institute of Engineering & Technology (MIE)"
    }, {
        id: 'raj1028',
        lat: 26.91962,
        lon: 75.78781,
        name: "ICFAI University Jaipur"
    }, {
        id: 'raj1029',
        lat: 26.91962,
        lon: 75.78781,
        name: "CIPET – Central Institute of Plastics Engg. & Tech."
    }, {
        id: 'raj1030',
        lat: 26.44976,
        lon: 74.64116,
        name: "Central University of Rajasthan – Engineering School (CUTR)"
    }, {
        id: 'raj1031',
        lat: 26.91962,
        lon: 75.78781,
        name: "Malaviya Malvital University (MMU)"
    }, {
        id: 'raj1032',
        lat: 27.56246,
        lon: 76.625,
        name: "University Engineering College (Alwar Institute of Engg. & Tech.)"
    }, {
        id: 'raj1033',
        lat: 26.44976,
        lon: 74.64116,
        name: "Government Engineering College"
    }, {
        id: 'raj1034',
        lat: 26.44976,
        lon: 74.64116,
        name: "Government Women Engineering College"
    }, {
        id: 'raj1035',
        lat: 26.44976,
        lon: 74.64116,
        name: "Bhagwant University – Engineering"

    }, {
        id: 'raj1040',
        lat: 24.5,
        lon: 74.5,
        name: "Mewar University – School of Engineering"
    }, {
        id: 'raj1041',
        lat: 26.69286,
        lon: 77.87968,
        name: "Engineering College"
    },

    {
        id: 'raj1049',
        lat: 29.92009,
        lon: 73.87496,
        name: "Government Engineering College – Ganganagar"
    }, {
        id: 'raj1050',
        lat: 26.91962,
        lon: 75.78781,
        name: "Central Institute of Plastics Engineering & Technology (CIPET)"
    }, {
        id: 'raj1051',
        lat: 26.2684494,
        lon: 73.036634,
        name: "MBM Engineering College"
    }, {
        id: 'raj1052',
        lat: 26.75,
        lon: 72.75,
        name: "Jodhpur Institute of Engineering & Technology (JIET)"
    }, {
        id: 'raj1053',
        lat: 26.75,
        lon: 72.75,
        name: "Raj Engineering College"
    }, {
        id: 'raj1054',
        lat: 26.75,
        lon: 72.75,
        name: "Jai Narain Vyas University – Engineering"
    }, {
        id: 'raj1055',
        lat: 26.75,
        lon: 72.75,
        name: "Government Engineering College"
    }, {
        id: 'raj1056',
        lat: 28.3654,
        lon: 75.60296,
        name: "Shridhar University Eng. School"
    }, {
        id: 'raj1058',
        lat: 26.91962,
        lon: 75.78781,
        name: "Poornima Group of Institutions (Faculty of Engineering)"
    }, {
        id: 'raj1059',
        lat: 26.91962,
        lon: 75.78781,
        name: "Arya Institute of Engineering & Tech."
    }, {
        id: 'raj1060',
        lat: 24.57117,
        lon: 73.69183,
        name: "Geetanjali Institute of Technical Studies"
    }, {
        id: 'raj1061',
        lat: 24.5991548,
        lon: 73.7764558,
        name: "Pacific Institute of Technology"
    }, {
        id: 'raj1062',
        lat: 24.57117,
        lon: 73.69183,
        name: "Pacific Institute of Fire & Safety Management"
    }, {
        id: 'raj1063',
        lat: 24.57117,
        lon: 73.69183,
        name: "Institute of Engineering & Technology – MPUAT"
    }, {
        id: 'raj1064',
        lat: 23.84306,
        lon: 73.71466,
        name: "Dungarpur College of Engineering & Tech"
    }, {
        id: 'raj1065',
        lat: 29.92009,
        lon: 73.87496,
        name: "Surendra Group of Institutions – Eng."
    }, {
        id: 'raj1066',
        lat: 25.18254,
        lon: 75.83907,
        name: "Bal Krishna Institute of Tech. (BKIT)"
    }, {
        id: 'raj1067',
        lat: 26.69286,
        lon: 77.87968,
        name: "Engineering College Dholpur (RTU)"
    }, {
        id: 'raj1068',
        lat: 25.5,
        lon: 74.75,
        name: "MLV Textile & Engineering College"
    }, {
        id: 'raj1069',
        lat: 26.02301,
        lon: 76.34408,
        name: "Sawai Madhopur College of Engg. & Tech."
    }, {
        id: 'raj1070',
        lat: 26.16667,
        lon: 75.58333,
        name: "Banasthali Vidyapith – Institute of Engg."
    }, {
        id: 'raj1071',
        lat: 24.5,
        lon: 74.5,
        name: "U.S. Ostwal Group of Colleges"
    }, {
        id: 'raj1072',
        lat: 26.91962,
        lon: 75.78781,
        name: "Rajasthan Institute of Engineering & Technology – Rajasthan"
    }, {
        id: 'raj1073',
        lat: 27.61206,
        lon: 75.13996,
        name: "Pandit Deendayal Upadhyaya Shekhawati University – Eng."
    }, {
        id: 'raj1074',
        lat: 28.02094,
        lon: 73.30749,
        name: "RNB Global University – School of Engg. & Tech."
    }, {
        id: 'raj1075',
        lat: 24.5,
        lon: 74.5,
        name: "Mewar University – School of Engg. & Tech"
    }, {
        id: 'raj1076',
        lat: 28.02094,
        lon: 73.30749,
        name: "Marudhar Engineering College"
    }, {
        id: 'raj1077',
        lat: 26.75,
        lon: 72.75,
        name: "Marwar Institute of Technology"
    }, {
        id: 'raj1078',
        lat: 27.61206,
        lon: 75.13996,
        name: "Shekhawati Institute of Engg. & Tech"
    }, {
        id: 'raj1079',
        lat: 27.0,
        lon: 74.25,
        name: "Tagore Engg. College"
    }, {
        id: 'raj1080',
        lat: 26.91962,
        lon: 75.78781,
        name: "Apex Institute of Engg. & Tech – Jaipur"
    }, {
        id: 'raj1081',
        lat: 25.43855,
        lon: 75.63735,
        name: "Vedant College of Engg. & Tech – Bundi"
    }, {
        id: 'raj1082',
        lat: 26.91962,
        lon: 75.78781,
        name: "Kautilya Institute of Tech. & Engg. – Jaipur"
    }, {
        id: 'raj1083',
        lat: 25.18254,
        lon: 75.83907,
        name: "Modi Institute of Tech. – Kota"
    }, {
        id: 'raj1084',
        lat: 27.56246,
        lon: 76.625,
        name: "Institute of Engg. & Tech – Alwar"
    }, {
        id: 'raj1085',
        lat: 29.58182,
        lon: 74.32938,
        name: "Saraf Institute of Engg. – Hanumangarh"
    }, {
        id: 'tel1000',
        lat: 17.31005336,
        lon: 78.45530536,
        name: "AAR Mahaveer Engineering College"
    }, {
        id: 'tel1001',
        lat: 18.22038409,
        lon: 78.30310429,
        name: "ACE Engineering College"
    }, {
        id: 'tel1002',
        lat: 18.87224913,
        lon: 79.37880604,
        name: "Aizza College of Engineering & Technology"
    }, {
        id: 'tel1003',
        lat: 17.30790227,
        lon: 78.73653823,
        name: "Annamacharya Institute Of Technology And Sciences"
    }, {
        id: 'tel1004',
        lat: 17.61105587,
        lon: 80.68872046,
        name: "AnuBose Institute of Technology"
    }, {
        id: 'tel1005',
        lat: 17.03989468,
        lon: 79.9778277,
        name: "ANURAG ENGINEERING COLLGE"
    }, {
        id: 'tel1006',
        lat: 17.42009627,
        lon: 78.65603611,
        name: "Anurag University"
    }, {
        id: 'tel1007',
        lat: 17.31247551,
        lon: 78.72507351,
        name: "Arjun College Of Technology & Sciences"
    }, {
        id: 'tel1008',
        lat: 17.92794644,
        lon: 78.47888554,
        name: "Aurora's Scientific & Technological Institute"
    }, {
        id: 'tel1009',
        lat: 17.38922761,
        lon: 78.60374367,
        name: "AURORAS TECHNOLOGICAL AND RESEARCH INSTITUTE"
    }, {
        id: 'tel1010',
        lat: 17.28492086,
        lon: 78.7090943,
        name: "Avanthi Institute Of Engineering & Technology"
    }, {
        id: 'tel1011',
        lat: 17.28645637,
        lon: 78.70985334,
        name: "AVANTHIS SCIENTIFIC TECH AND RESEARCH ACADEMY"
    }, {
        id: 'tel1012',
        lat: 17.24596228,
        lon: 78.62048863,
        name: "AVN Institute of Engineering and Technology"
    }, {
        id: 'tel1013',
        lat: 17.33516168,
        lon: 78.26299027,
        name: "Azad College Of Engineering & Technology"
    }, {
        id: 'tel1014',
        lat: 17.93775991,
        lon: 79.84926878,
        name: "Balaji Institute of Technology & Science"
    }, {
        id: 'tel1015',
        lat: 17.20666399,
        lon: 78.60112399,
        name: "Bharat Institute of engineering and technology."
    }, {
        id: 'tel1016',
        lat: 17.20653587,
        lon: 78.60108107,
        name: "BHARAT INSTITUTE OF TECHNOLOGY"
    }, {
        id: 'tel1017',
        lat: 17.34489181,
        lon: 78.29439715,
        name: "Bhaskar Engineering College"
    }, {
        id: 'tel1018',
        lat: 17.35434332,
        lon: 78.50869943,
        name: "Bhoj Reddy Engineering College for Women"
    }, {
        id: 'tel1019',
        lat: 17.20805426,
        lon: 80.20241261,
        name: "Bomma Institute of Technology and Science"
    }, {
        id: 'tel1020',
        lat: 17.71876587,
        lon: 78.47888554,
        name: "Brilliant grammar school educational society group of institutions integrated campus"
    }, {
        id: 'tel1021',
        lat: 17.63502509,
        lon: 78.52283085,
        name: "Brilliant Institute of Engineering and Technology"
    }, {
        id: 'tel1022',
        lat: 17.72538614,
        lon: 78.25718329,
        name: "BVRIT"
    }, {
        id: 'tel1023',
        lat: 18.59565366,
        lon: 78.47888554,
        name: "BVRIT Hyderabad College of Engineering for Women"
    }, {
        id: 'tel1024',
        lat: 17.39348877,
        lon: 78.31935097,
        name: "Chaitanya Bharathi Institute of Technology"
    }, {
        id: 'tel1025',
        lat: 17.72497063,
        lon: 79.19951322,
        name: "Christu Jyothi Institute of Technology & Science"
    }, {
        id: 'tel1026',
        lat: 18.59565366,
        lon: 78.52283085,
        name: "CMR Engineering College"
    }, {
        id: 'tel1027',
        lat: 18.42896821,
        lon: 78.56677617,
        name: "CMR Technical Campus (Autonomous Engineering College)"
    }, {
        id: 'tel1028',
        lat: 17.40681218,
        lon: 78.51853654,
        name: "College of Engineering Osmania University"
    }, {
        id: 'tel1029',
        lat: 17.44352189,
        lon: 78.48663278,
        name: "CSI Wesley Institute of Technology and Sciences"
    }, {
        id: 'tel1030',
        lat: 18.38727152,
        lon: 78.83044805,
        name: "CVR College Of Engineering"
    }, {
        id: 'tel1031',
        lat: 17.54978687,
        lon: 78.40070601,
        name: "D R K INSTITUTE OF SCI AND TECHNOLOGY"
    }, {
        id: 'tel1032',
        lat: 17.26067915,
        lon: 80.11437842,
        name: "DARIPALLY ANANTHA RAMULU COLLEGE OF ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1033',
        lat: 17.38465846,
        lon: 78.4651269,
        name: "Deccan College Of Engineering & Technology"
    }, {
        id: 'tel1034',
        lat: 17.35281369,
        lon: 78.33361867,
        name: "DR VRK WOMENS COLL OF ENGG AND TECHNOLOGY"
    }, {
        id: 'tel1035',
        lat: 18.30384791,
        lon: 78.47888554,
        name: "DRK COLLEGE OF ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1036',
        lat: 17.54626546,
        lon: 78.28340038,
        name: "Ellenki College of Engineering and Technology (UGC Autonomous)"
    }, {
        id: 'tel1037',
        lat: 17.41165465,
        lon: 78.39869312,
        name: "G. Narayanamma Institute of Technology and Science"
    }, {
        id: 'tel1038',
        lat: 17.94549939,
        lon: 79.58979565,
        name: "Ganapathy Engineering College"
    }, {
        id: 'tel1039',
        lat: 17.40142216,
        lon: 78.50500403,
        name: "Gates Institute Of Technology (P) Ltd"
    }, {
        id: 'tel1040',
        lat: 18.34556475,
        lon: 78.17126835,
        name: "Geethanjali College of Engineering and Technology"
    }, {
        id: 'tel1041',
        lat: 17.67690036,
        lon: 79.0062293,
        name: "Global Institute Of Engineering And Technology"
    }, {
        id: 'tel1042',
        lat: 18.22038409,
        lon: 78.52283085,
        name: "Gokaraju Rangaraju Institute of Engineering & Technology"
    }, {
        id: 'tel1043',
        lat: 17.16326146,
        lon: 78.66022723,
        name: "Gurunanak Institute of Technology - Ibrahimpatnam"
    }, {
        id: 'tel1044',
        lat: 17.88612999,
        lon: 78.83044805,
        name: "GURUNANAK UNIVERSITY - HYDERABAD"
    }, {
        id: 'tel1045',
        lat: 17.7606216,
        lon: 78.52283085,
        name: "Holy Mary Institute of Technology & Science"
    }, {
        id: 'tel1046',
        lat: 18.42896821,
        lon: 78.21521366,
        name: "Hyderabad Institute of Technology and Management"
    }, {
        id: 'tel1047',
        lat: 18.06901938,
        lon: 78.85529317,
        name: "Indur Institute Of Engineering & Technology"
    }, {
        id: 'tel1048',
        lat: 18.67893534,
        lon: 78.12732303,
        name: "Institute of Aeronautical Engineering"
    }, {
        id: 'tel1049',
        lat: 17.30543724,
        lon: 78.45610605,
        name: "ISL Engineering College"
    }, {
        id: 'tel1050',
        lat: 17.96975302,
        lon: 78.3470496,
        name: "Jawaharlal Nehru Technological University Hyderabad"
    }, {
        id: 'tel1051',
        lat: 16.69891669,
        lon: 77.94055025,
        name: "Jaya Prakash Narayan College Of Engineering"
    }, {
        id: 'tel1052',
        lat: 17.90122642,
        lon: 79.87535526,
        name: "Jayamukhi Institute of Technological Sciences"
    }, {
        id: 'tel1053',
        lat: 18.26212101,
        lon: 78.52283085,
        name: "Jb institute of engineering and technology (JBIET)"
    }, {
        id: 'tel1054',
        lat: 18.42975178,
        lon: 78.83379525,
        name: "JNTUH College of Engineering Rajanna sircilla"
    }, {
        id: 'tel1055',
        lat: 18.64424849,
        lon: 79.54742576,
        name: "JNTUH College of Engineering-Manthani@Centenary Colony"
    }, {
        id: 'tel1056',
        lat: 18.6657067,
        lon: 78.90837989,
        name: "JNTUH University College of Engineering Jagtial"
    }, {
        id: 'tel1057',
        lat: 17.72324905,
        lon: 78.09451019,
        name: "JNTUH University College of Engineering Sultanpur"
    }, {
        id: 'tel1058',
        lat: 18.42896821,
        lon: 77.95154178,
        name: "Joginpally B.R. Engineering College"
    }, {
        id: 'tel1059',
        lat: 18.35017765,
        lon: 79.16036757,
        name: "Jyothishmathi Institute of Technology and Science (AUTONOMOUS)"
    }, {
        id: 'tel1060',
        lat: 17.58111191,
        lon: 80.65769704,
        name: "K U COLLEGE OF ENGG KOTHAGUDEM"
    }, {
        id: 'tel1061',
        lat: 18.05375318,
        lon: 79.53763212,
        name: "Kakatiya Institute of Technology & Science KITSW"
    }, {
        id: 'tel1062',
        lat: 18.71640849,
        lon: 78.13394526,
        name: "Kakatiya Institute of Technology and Science for Women"
    }, {
        id: 'tel1063',
        lat: 18.23612669,
        lon: 79.36637195,
        name: "Kamala Institute Of Technology And Sciences College"
    }, {
        id: 'tel1064',
        lat: 17.67690036,
        lon: 78.87439336,
        name: "Kasireddy narayanareddy college of engineering and research"
    }, {
        id: 'tel1065',
        lat: 17.39705812,
        lon: 78.62266953,
        name: "Keshav Memorial Engineering College"
    }, {
        id: 'tel1066',
        lat: 17.39716438,
        lon: 78.49023574,
        name: "Keshav Memorial Institute of Technology"
    }, {
        id: 'tel1067',
        lat: 17.96975302,
        lon: 78.56677617,
        name: "KG Reddy College of Engineering and Technology"
    }, {
        id: 'tel1068',
        lat: 17.23514822,
        lon: 80.05548807,
        name: "KHAMMAM INST OF TECHNOLOGY AND SCIENCE"
    }, {
        id: 'tel1069',
        lat: 17.596864,
        lon: 80.72999063,
        name: "KLR College of Engineering and Technology"
    }, {
        id: 'tel1070',
        lat: 17.59691927,
        lon: 80.73004427,
        name: "KLRCOLLEGE OF ENGG AND TECHNOLOGY PALONCHA"
    }, {
        id: 'tel1071',
        lat: 17.00563947,
        lon: 79.96888664,
        name: "Kodada Institute Of Technology & Sciences"
    }, {
        id: 'tel1072',
        lat: 17.43345215,
        lon: 78.6853468,
        name: "Kommuri Pratap Reddy Institute Of Technology (Autonomous Institute)"
    }, {
        id: 'tel1073',
        lat: 18.78960709,
        lon: 78.32833381,
        name: "Kshatriya College of Engineering"
    }, {
        id: 'tel1074',
        lat: 18.03572212,
        lon: 79.56158578,
        name: "KUCET"
    }, {
        id: 'tel1075',
        lat: 17.3420159,
        lon: 78.36745631,
        name: "Lords Institute of Engineering & Technology"
    }, {
        id: 'tel1076',
        lat: 16.92896824,
        lon: 79.89693238,
        name: "Madhira Institute of Technology & Sciences"
    }, {
        id: 'tel1077',
        lat: 17.39250589,
        lon: 78.32244087,
        name: "Mahatma Gandhi Institute of Technology (MGIT)"
    }, {
        id: 'tel1078',
        lat: 17.30820714,
        lon: 78.45661222,
        name: "Mahaveer Institute of Science & Technology"
    }, {
        id: 'tel1079',
        lat: 17.56038266,
        lon: 78.45813547,
        name: "Malla Reddy College of Engineering (MRCE)"
    }, {
        id: 'tel1080',
        lat: 17.56232614,
        lon: 78.45546399,
        name: "MALLA REDDY COLLEGE OF ENGINEERING AND TECHNOLOGY (MRCET)"
    }, {
        id: 'tel1081',
        lat: 17.54690019,
        lon: 78.46573151,
        name: "Malla Reddy Engineering College"
    }, {
        id: 'tel1082',
        lat: 17.56029084,
        lon: 78.44943197,
        name: "MALLA REDDY ENGINEERING COLLEGE FOR WOMEN"
    }, {
        id: 'tel1083',
        lat: 17.5609148,
        lon: 78.44606312,
        name: "Malla Reddy Institute Of Technology - MLTM"
    }, {
        id: 'tel1084',
        lat: 17.56142732,
        lon: 78.45780656,
        name: "Malla Reddy Institute of Technology and Science"
    }, {
        id: 'tel1085',
        lat: 17.55912585,
        lon: 78.45110193,
        name: "MALLAREDDY ENGINEERING COLLEGE (AUTONOMOUS)"
    }, {
        id: 'tel1086',
        lat: 17.59940959,
        lon: 78.41715413,
        name: "Marri Laxman Reddy Institute of Technology and Management"
    }, {
        id: 'tel1087',
        lat: 17.35799926,
        lon: 78.50789231,
        name: "Matrusri Engineering college"
    }, {
        id: 'tel1088',
        lat: 17.28177412,
        lon: 78.53784706,
        name: "Maturi Venkata Subba Rao Engineering College"
    }, {
        id: 'tel1089',
        lat: 17.42583204,
        lon: 78.7131406,
        name: "Megha Institute Of Engineering And Technology For Women (MIETW)"
    }, {
        id: 'tel1090',
        lat: 17.39187549,
        lon: 78.47856281,
        name: "Methodist College of Engineering and Technology"
    }, {
        id: 'tel1091',
        lat: 17.08079091,
        lon: 79.29643604,
        name: "MGU COLLEGE OF ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1092',
        lat: 16.88769059,
        lon: 79.5618122,
        name: "Mina Institute Of Engineering &Technology for Women"
    }, {
        id: 'tel1093',
        lat: 17.59464453,
        lon: 78.44121066,
        name: "MLR Institute of Technology"
    }, {
        id: 'tel1094',
        lat: 17.61829216,
        lon: 78.12369613,
        name: "MNR College of Engineering & Technology"
    }, {
        id: 'tel1095',
        lat: 17.18848932,
        lon: 80.82756851,
        name: "Mother Teresa Institute of Science and Technology"
    }, {
        id: 'tel1096',
        lat: 18.57948032,
        lon: 79.37484301,
        name: "Mother Theressa College of Engineering & Technology"
    }, {
        id: 'tel1097',
        lat: 17.42828676,
        lon: 78.44289459,
        name: "Muffakham Jah College of Engineering & Technology (MJCET)"
    }, {
        id: 'tel1098',
        lat: 17.36859734,
        lon: 78.50825508,
        name: "Mumtaz College Of Engineering & Technology"
    }, {
        id: 'tel1099',
        lat: 17.40575122,
        lon: 78.62158806,
        name: "Nalla Malla Reddy Engineering College"
    }, {
        id: 'tel1100',
        lat: 17.40283669,
        lon: 78.65265617,
        name: "Nalla Narasimha Reddy Education Society’s Group of Institutions"
    }, {
        id: 'tel1101',
        lat: 17.56283953,
        lon: 78.45607011,
        name: "Narsimha Reddy Engineering College (NRCM)"
    }, {
        id: 'tel1102',
        lat: 17.3720824,
        lon: 78.4936846,
        name: "Nawab Shah Alam Khan College of Engineering and Technology"
    }, {
        id: 'tel1103',
        lat: 17.39580061,
        lon: 78.62198436,
        name: "Neil Gogte Institute of Technology"
    }, {
        id: 'tel1104',
        lat: 17.30226167,
        lon: 78.76472543,
        name: "Netaji Institute Of Engineering And Technology"
    }, {
        id: 'tel1105',
        lat: 19.05319448,
        lon: 79.05017462,
        name: "Nigama Engineering College"
    }, {
        id: 'tel1106',
        lat: 18.05333649,
        lon: 78.83044805,
        name: "Noble College of Engineering And Technology for Women"
    }, {
        id: 'tel1107',
        lat: 17.40695645,
        lon: 78.51856738,
        name: "O U COLLEGE OF ENGG HYDERABAD - SELF FINANCE"
    }, {
        id: 'tel1108',
        lat: 17.42001032,
        lon: 78.52742213,
        name: "Osmania University"
    }, {
        id: 'tel1109',
        lat: 18.01154971,
        lon: 79.57751838,
        name: "Palamuru University"
    }, {
        id: 'tel1110',
        lat: 18.17863715,
        lon: 78.78650274,
        name: "Pallavi Engineering College"
    }, {
        id: 'tel1111',
        lat: 17.4212312,
        lon: 78.6419757,
        name: "Princeton Institute of Engineering & Technology For Women"
    }, {
        id: 'tel1112',
        lat: 17.24045743,
        lon: 80.12245581,
        name: "Priyadarshini Institute Of Science and Technology For Women"
    }, {
        id: 'tel1113',
        lat: 17.50069956,
        lon: 78.39077181,
        name: "Rishi MS Institute of Engineering and Technology for Women"
    }, {
        id: 'tel1114',
        lat: 17.43975373,
        lon: 78.49628887,
        name: "S.V.I.T"
    }, {
        id: 'tel1115',
        lat: 17.21172446,
        lon: 80.89723619,
        name: "Sai Spurthi Institute Of Technology"
    }, {
        id: 'tel1116',
        lat: 17.46167121,
        lon: 78.69381841,
        name: "Samskruti College of Engineering and Technology"
    }, {
        id: 'tel1117',
        lat: 18.92853434,
        lon: 78.91833868,
        name: "Satavahana University"
    }, {
        id: 'tel1118',
        lat: 17.17457629,
        lon: 78.65991533,
        name: "SCIENT INSTITUTE OF TECHNOLOGY"
    }, {
        id: 'tel1119',
        lat: 17.40910763,
        lon: 78.46086998,
        name: "Shadan Women's College of Engineering & Technology"
    }, {
        id: 'tel1120',
        lat: 17.41250808,
        lon: 78.45973653,
        name: "Shadan Women's College of Engineering & Technology"
    }, {
        id: 'tel1121',
        lat: 17.35681775,
        lon: 78.37562252,
        name: "SHADHAN COLL OF ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1122',
        lat: 17.20935663,
        lon: 78.66597277,
        name: "Siddhartha Institute of Engineering & Technology"
    }, {
        id: 'tel1123',
        lat: 17.41077027,
        lon: 78.6378343,
        name: "Siddhartha Institute of Technology & Sciences(SITS)"
    }, {
        id: 'tel1124',
        lat: 17.28203153,
        lon: 78.55377171,
        name: "Sphoorthy Engineering College (Autonomous) Hyderabad"
    }, {
        id: 'tel1125',
        lat: 18.09280886,
        lon: 79.46825188,
        name: "SR University"
    }, {
        id: 'tel1126',
        lat: 19.26075311,
        lon: 78.87439336,
        name: "Sree Chaitanya College of Engineering"
    }, {
        id: 'tel1127',
        lat: 17.20982687,
        lon: 78.62346439,
        name: "Sree Dattha Group of Institutions"
    }, {
        id: 'tel1128',
        lat: 17.20898671,
        lon: 78.6229499,
        name: "Sree Dattha Institute Of Engineering And Science"
    }, {
        id: 'tel1129',
        lat: 17.25771225,
        lon: 77.55603396,
        name: "SREE VISVESVARAYA INSTITUTE OF TECHNOLOGY & SCIENCE"
    }, {
        id: 'tel1130',
        lat: 17.45552188,
        lon: 78.66643213,
        name: "Sreenidhi Institute of Science & Technology - SNIST"
    }, {
        id: 'tel1131',
        lat: 17.35463699,
        lon: 78.59349918,
        name: "SREYAS INST OF ENGG AND TECHNOLOGY"
    }, {
        id: 'tel1132',
        lat: 17.20782825,
        lon: 78.6082721,
        name: "SRI CHAITANYA ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1133',
        lat: 17.20784495,
        lon: 78.60822935,
        name: "SRI CHAITANYA TECHNICAL CAMPUS"
    }, {
        id: 'tel1134',
        lat: 17.21009041,
        lon: 78.61190764,
        name: "Sri Indu College Of Engineering & Technology"
    }, {
        id: 'tel1135',
        lat: 17.21003132,
        lon: 78.61191207,
        name: "SRI INDU INSTITUTE OF ENGINEERING AND TECHNOLOGY"
    }, {
        id: 'tel1136',
        lat: 17.14350045,
        lon: 79.59907629,
        name: "Sri Venkateswara Engineering College - Suryapet City"
    }, {
        id: 'tel1137',
        lat: 16.66338699,
        lon: 77.8147998,
        name: "SRI VISHWESWARAYA INST OF TECHNOLOGY AND SCI"
    }, {
        id: 'tel1138',
        lat: 17.42480673,
        lon: 78.29565562,
        name: "Sridevi Women’s Engineering College"
    }, {
        id: 'tel1139',
        lat: 17.33201763,
        lon: 78.72429978,
        name: "ST MARYS INTEGRATED CAMPUS"
    }, {
        id: 'tel1140',
        lat: 17.33258327,
        lon: 78.72898229,
        name: "St. Mary's Engineering College"
    }, {
        id: 'tel1141',
        lat: 17.33274713,
        lon: 78.72666486,
        name: "St. Mary's Group of Institutions"
    }, {
        id: 'tel1142',
        lat: 17.33310327,
        lon: 78.72408521,
        name: "St. Mary's Integrated Campus Hyderabad"
    }, {
        id: 'tel1143',
        lat: 17.56616351,
        lon: 78.45118679,
        name: "St. Peter’s Engineering College"
    }, {
        id: 'tel1144',
        lat: 17.54164402,
        lon: 78.47444136,
        name: "St.Martin's Engineering College"
    }, {
        id: 'tel1145',
        lat: 17.39650626,
        lon: 78.47302583,
        name: "Stanley College Of Engineering & Technology For Women"
    }, {
        id: 'tel1146',
        lat: 18.09243199,
        lon: 79.4727671,
        name: "Sumathi Reddy Institute of Technology for Women"
    }, {
        id: 'tel1147',
        lat: 18.03986339,
        lon: 79.53602213,
        name: "SVS GROUP OF INSTITUTIONS"
    }, {
        id: 'tel1148',
        lat: 17.43990565,
        lon: 78.49627344,
        name: "SWAMI VIVEKANANDA INST OF TECHNOLOGY"
    }, {
        id: 'tel1149',
        lat: 17.84430369,
        lon: 79.84119026,
        name: "Swarna Bharathi Institute of Science & Technology"
    }, {
        id: 'tel1150',
        lat: 17.29109877,
        lon: 78.73004,
        name: "Swathi Institute of Technology & Sciences"
    }, {
        id: 'tel1151',
        lat: 17.99272482,
        lon: 79.49266481,
        name: "Talla Padmavathi College of Engineering (Autonomous)"
    }, {
        id: 'tel1152',
        lat: 17.32349286,
        lon: 78.53569991,
        name: "TEEGALA KRISHNA REDDY ENGINEERING COLLEGE (AUTONOMOUS)"
    }, {
        id: 'tel1153',
        lat: 17.32334276,
        lon: 78.53566303,
        name: "TKR College of Engineering & Technology"
    }, {
        id: 'tel1154',
        lat: 18.76217612,
        lon: 79.05017462,
        name: "TRINITY COLLEGE OF ENGINEERING & TECHNOLOGY (TCTK)"
    }, {
        id: 'tel1155',
        lat: 18.023303,
        lon: 79.55090292,
        name: "University College of Engineering & Technology for Women"
    }, {
        id: 'tel1156',
        lat: 17.08082682,
        lon: 79.29643604,
        name: "University College of Engineering and Technology"
    }, {
        id: 'tel1157',
        lat: 17.58093007,
        lon: 80.65765145,
        name: "University College Of Engineering Main Campus"
    }, {
        id: 'tel1158',
        lat: 17.41039312,
        lon: 78.52826883,
        name: "University College of Technology"
    }, {
        id: 'tel1159',
        lat: 17.89101135,
        lon: 79.60006546,
        name: "Vaagdevi Engineering College"
    }, {
        id: 'tel1160',
        lat: 19.05319448,
        lon: 79.05017462,
        name: "Vaageswari College Of Engineeringthimmapur"
    }, {
        id: 'tel1161',
        lat: 17.53905146,
        lon: 78.385477,
        name: "Vallurupalli Nageswara Rao Vignana Jyothi Institute of Engineering &Technology"
    }, {
        id: 'tel1162',
        lat: 17.25442319,
        lon: 78.30748211,
        name: "Vardhaman College of Engineering"
    }, {
        id: 'tel1163',
        lat: 17.38053828,
        lon: 78.38253802,
        name: "Vasavi College of Engineering"
    }, {
        id: 'tel1164',
        lat: 17.50323078,
        lon: 78.84297042,
        name: "Vathsalya Institute of Science and Technology"
    }, {
        id: 'tel1165',
        lat: 17.34560242,
        lon: 78.32359008,
        name: "Vidya Jyothi Institute of Technology"
    }, {
        id: 'tel1166',
        lat: 17.34622429,
        lon: 78.72153008,
        name: "Vignan Institute of Technology and Science"
    }, {
        id: 'tel1167',
        lat: 17.47713316,
        lon: 78.6918712,
        name: "Vignan's Institute of Management and Technology for Women"
    }, {
        id: 'tel1168',
        lat: 17.47064272,
        lon: 78.72149714,
        name: "VIGNANA BHARATHI ENGINEERING COLLEGE"
    }, {
        id: 'tel1169',
        lat: 17.47052025,
        lon: 78.72145088,
        name: "Vignana Bharathi Institute of Technology (VBIT) | Top Engineering Colleges In Telangana"
    }, {
        id: 'tel1170',
        lat: 18.72531734,
        lon: 78.1478183,
        name: "Vijay Rural Engineering College(VREC)"
    }, {
        id: 'tel1171',
        lat: 18.09511333,
        lon: 80.58826058,
        name: "Vijaya Engineering College"
    }, {
        id: 'tel1172',
        lat: 17.22393253,
        lon: 78.58844432,
        name: "Visvesvaraya College of Engineering and Technology."
    }, {
        id: 'tel1173',
        lat: 18.42542752,
        lon: 79.15523947,
        name: "VIVEKANANDA INSTT OF TECH AND SCI BOMMAKAL"
    }, {
        id: 'tel1174',
        lat: 18.42896821,
        lon: 77.99548709,
        name: "VRK Women's College of Engineering and Technology"
    }, {
        id: 'tel1175',
        lat: 18.07848859,
        lon: 79.70402209,
        name: "Warangal Institute of Technology and Science"
    }
]
console.log("Loaded data.js:", existingContributions.length);