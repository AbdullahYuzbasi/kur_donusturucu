import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey ="3669da7dea64f9f6f1a9765503dfd078";

  final String _baseUrl = "http://api.exchangeratesapi.io/v1/latest?access_key=";
  //final olmasi degismeyecegi anlamina gelir.

  Map<String,double> _oranlar = {};

  String _seciliKur = "USD";
  double _sonuc = 0;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _internettenVeriCek();
    });
  }


  // asagidaki json formatini mape donustururken gormemiz icin onumuze koyduk
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
            "KUR DONUSTURUCU",
        ),
      ),
      body: _oranlar.isNotEmpty ? _buildBody(): Center(child: CircularProgressIndicator()),
      //egerler oranlar bos degilse body'i yukkler ama bos ise ortada bir yukleme isaretini animsatan donen cember olur.
    );
  }

  Widget _buildBody(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKurDonusturucuRow(),
          SizedBox(height: 16),
          _buildSonucText(),
          SizedBox(height: 8),
          _builtAyiriciCizgi(),
          SizedBox(height: 8),
          _builtKurList(),
        ],
      ),
    );
  }

  Widget _buildKurDonusturucuRow(){
    return Row(
      children: [
        Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  )
              ),
              onChanged: (String yeniDeger){
                _hesapla();
              },
            )
        ),//x ekseninde sonsuz uzunluktaki seyi row icine koyamayiz Expanded ile sarmalariz
        SizedBox(width: 16),
        DropdownButton<String>(
          icon: Icon(Icons.arrow_downward),
          value: _seciliKur,
          items: _oranlar.keys.map((String kur){
            return DropdownMenuItem<String>(
              value: kur,
              child: Text(kur),
            );
          }).toList(),
          onChanged: (String? yeniDeger){
            if(yeniDeger != null){
              _seciliKur = yeniDeger;
              _hesapla();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSonucText(){
    return Text(
      "${_sonuc.toStringAsFixed(2)} TL",
      style: TextStyle(fontSize: 24
      ),
    );
  }

  Widget _builtAyiriciCizgi(){
    return Container(
      color: Colors.red,
      height: 3,
    );
  }

  Widget _builtKurList(){
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: buildListItem,
      ),
    );
  }

  //----yukaridaki her ayri fonksiyon ilk basta her seyi yazdigimiz built icindeki kisimlardir.

  Widget buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text("${_oranlar.values.toList()[index].toStringAsFixed(2)} TL"),
    );
  }

  void _hesapla(){
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_seciliKur];

    if(deger != null && oran != null){
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _internettenVeriCek() async {
    await Future.delayed(Duration(seconds: 2));  //2 saniye gec yuklenmesini saglayacak.
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String , dynamic> parsedResponse = jsonDecode(response.body);
    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTlKuru = rates["TRY"];

    if(baseTlKuru != null){
      for(String ulkeKuru in rates.keys){
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());//DARTTA INT DOGRUDAN DOUBLEA CEVRILEMEZ
        if(baseKur != null){                                      //ILK STRINGE SONRA DOUBLE'A DONUSTURULUR
          double tlKuru = baseTlKuru/baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }
    setState(() {});
  }
}


