class Urls {

  static const String baseURL = 'http://35.73.30.144:2008/api/v1';


  static const String readproduct = '$baseURL/ReadProduct';


  static const String createproduct = '$baseURL/CreateProduct';


  static String deletproduct(String id) => '$baseURL/DeleteProduct/$id';


  static String updateproduct(String id) => '$baseURL/UpdateProduct/$id';
}