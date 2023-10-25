import 'package:flutter/foundation.dart';

const String baseUrl = kReleaseMode
    ? 'https://ysf-api.leohalim.online/api'
    : 'https://basicpos-api.leohalim.online/api';

String login = '$baseUrl/login';
String supplier = '$baseUrl/suppliers';
String pelanggan = '$baseUrl/customers';
String barang = '$baseUrl/products';
String brand = '$baseUrl/brands';
String ekspedisi = '$baseUrl/expeditions';
String kategori_barang = '$baseUrl/product-categories';
String kategori_pelanggan = '$baseUrl/customer-categories';
String sales = '$baseUrl/salespersons';
