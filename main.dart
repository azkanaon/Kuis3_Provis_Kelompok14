import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// menampung data hasil pemanggilan API
class ActivityUMKM {
  String nama;
  String jenis;
  int id;

  ActivityUMKM(
      {required this.nama,
      required this.jenis,
      required this.id}); //constructor
}

class Activity {
  List<ActivityUMKM> ListPop = <ActivityUMKM>[];

  Activity(Map<String, dynamic> json) {
    var data = json["data"] ?? []; // ubah ke kondisi jika null
    for (var val in data) {
      var nama = val["nama"];
      var jenis = val["jenis"];
      var id = int.parse(val["id"]);
      ListPop.add(ActivityUMKM(nama: nama, jenis: jenis, id: id));
    }
  }
  //map dari json ke atribut
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(json ?? {}); // ubah ke kondisi jika null
  }
}

class ActivityCubit extends Cubit<Activity> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  //constructor
  ActivityCubit() : super(Activity({})) {
    fetchData();
  }

  //map dari json ke atribut
  void setFromJson(dynamic json) {
    try {
      emit(Activity.fromJson(json));
    } catch (e) {
      emit(Activity.fromJson({}));
    }
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetailActivityUMKM {
  String nama;
  String jenis;
  String omzet_bulan;
  String lama_usaha;
  String member_sejak;
  int jumlah_pinjaman_sukses;
  int id;

  DetailActivityUMKM({
    required this.nama,
    required this.jenis,
    required this.omzet_bulan,
    required this.lama_usaha,
    required this.member_sejak,
    required this.jumlah_pinjaman_sukses,
    required this.id,
  }); //constructor
}

class DetailActivity {
  List<DetailActivityUMKM> ListPop = <DetailActivityUMKM>[];

  DetailActivity(Map<String, dynamic> json) {
    var data = json["data"] ?? []; // ubah ke kondisi jika null
    for (var val in data) {
      var nama = val["nama"];
      var jenis = val["jenis"];
      var omzet_bulan = val["omzet_bulan"];
      var lama_usaha = val["lama_usaha"];
      var member_sejak = val["member_sejak"];
      var jumlah_pinjaman_sukses = val["jumlah_pinjaman_sukses"];
      var id = int.parse(val["id"]);
      ListPop.add(DetailActivityUMKM(
          nama: nama,
          jenis: jenis,
          omzet_bulan: omzet_bulan,
          lama_usaha: lama_usaha,
          member_sejak: member_sejak,
          jumlah_pinjaman_sukses: jumlah_pinjaman_sukses,
          id: id));
    }
  }
  //map dari json ke atribut
  factory DetailActivity.fromJson(Map<String, dynamic> json) {
    return DetailActivity(json ?? {}); // ubah ke kondisi jika null
  }
}

class DetailActivityCubit extends Cubit<Activity> {
  String url = "http://178.128.17.76:8000/detil_umkm/";
  int nilai = 0;
  //constructor
  DetailActivityCubit() : super(Activity({})) {
    fetchData();
  }
  //map dari json ke atribut
  void setFromJson(dynamic json) {
    try {
      emit(Activity.fromJson(json));
    } catch (e) {
      emit(Activity.fromJson({}));
    }
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url + nilai.toString()));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ActivityCubit()),
        BlocProvider(create: (context) => DetailActivityCubit()),
      ],
      child: MaterialApp(home: HalamanUtama()),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<HalamanUtama> {
  late Future<Activity> futureActivity; //menampung hasil
  bool isButtonPressed = false;

  @override
  // void init() async {
  //   return Activity.fromJson({"data": []});
  // }
  void init() async {
    super.initState();
    BlocProvider.of<ActivityCubit>(context).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(children: [
        Text(
            "2100812, Muhammad Azka Atqiya; 2101677, Muhammad Alam Basalamah; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang"),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isButtonPressed = true;
                BlocProvider.of<ActivityCubit>(context).fetchData();
              });
            },
            child: Text("Reload Daftar UMKM"),
          ),
        ),
        Expanded(child:
            BlocBuilder<ActivityCubit, Activity>(builder: (context, univ) {
          final activityCubit = BlocProvider.of<ActivityCubit>(context);
          if (!isButtonPressed) {
            return Text('Klik tombol untuk memuat data.');
          }
          if (univ.ListPop.isNotEmpty) {
            // gunakan listview builder
            return ListView.builder(
                itemCount: univ.ListPop.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(univ.ListPop[index].nama),
                      subtitle: Text(univ.ListPop[index].jenis),
                    ),
                  );
                });
          } else {
            return Text('Data universitas tidak ada.');
          }
        }))
      ]),
    ));
  }
}
