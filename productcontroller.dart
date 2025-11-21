import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:module14assingment/crud/model/productmodel.dart';
import 'package:module14assingment/crud/utils/url.dart';
class ProductController{
  List<Data>products=[];
  bool isLoading=true;
  Future fetchProduct()async{

    final response = await http.get(Uri.parse(Urls.readproduct));
    if(response.statusCode==200){
      isLoading=false;
      final data = jsonDecode(response.body);

      productmodel model=productmodel.fromJson(data);
      products=model.data??[];
    }
  }


  Future<bool>createproduct(Data data) async {
    final response=await http.post(Uri.parse(Urls.createproduct),
    headers:{
      'Content-Type':'application/json'
    } ,
    body: jsonEncode(
      {
          "ProductName":data.productName ,
          "ProductCode": DateTime.now().microsecondsSinceEpoch ,
          "Img":data.img,
          "Qty": data.qty,
          "UnitPrice": data.unitPrice,
          "TotalPrice":data.totalPrice,

      }
    ),
    );
    print(response.body);
    if(response.statusCode==200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool>deletproduct(String ProductId)async{
    final response=await http.get(Uri.parse(Urls.deletproduct(ProductId)));
    print(Urls.deletproduct(ProductId));
    if(response.statusCode==200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> updateproduct(String id, Data updatedData) async {
    final url = Uri.parse('updateproductL/$id');
    final body = jsonEncode(updatedData.toJson());
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

}



Future<bool> updateProduct(String id, Data updatedData) async {

  final url = Uri.parse(Urls.updateproduct(id));
  final body = jsonEncode(updatedData.toJson());
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Update failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating product: $e');
    return false;
  }
}