import 'dart:ui';
import 'package:flutter/material.dart';
 import 'package:http/http.dart' as http;
import 'package:module14assingment/crud/model/productmodel.dart';
import 'dart:convert';

import 'package:module14assingment/crud/productcontroller.dart';

class ApiCall extends StatefulWidget {
  const ApiCall({super.key});
  @override
  State<ApiCall> createState() => _ApiCallState();
}

class _ApiCallState extends State<ApiCall> {
  ProductController productController=ProductController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData()async{
    await  productController.fetchProduct();
    if(mounted) setState(() {});
  }


  productDialog({Data? productToUpdate}){
    bool isUpdate = productToUpdate != null;


    TextEditingController productNameController=TextEditingController(text: isUpdate ? productToUpdate.productName : '');
    TextEditingController productIMGController=TextEditingController(text: isUpdate ? productToUpdate.img : '');
    TextEditingController productQTYController=TextEditingController(text: isUpdate ? productToUpdate.qty.toString() : '');
    TextEditingController productUnitPriceController=TextEditingController(text: isUpdate ? productToUpdate.unitPrice.toString() : '');
    TextEditingController productTotalPriceController=TextEditingController(text: isUpdate ? productToUpdate.totalPrice.toString() : '');


    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text(isUpdate ? 'Update Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: productNameController ,
              decoration: const InputDecoration(
                  labelText: 'Name'
              ),
            ),
            const SizedBox(height: 10,),


            TextField(
              controller: productIMGController ,
              decoration: const InputDecoration(
                  labelText: 'Image URL'
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10,),


            TextField(
              controller: productQTYController ,
              decoration: const InputDecoration(
                  labelText: 'QTY'
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10,),


            TextField(
              controller: productUnitPriceController ,
              decoration: const InputDecoration(
                  labelText: 'UnitPrice'
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10,),


            TextField(
              controller: productTotalPriceController ,
              decoration: const InputDecoration(
                  labelText: 'Total Price'
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: (){Navigator.pop(context);}, child:const Text("Cancel")),

                ElevatedButton(onPressed: () async {

                  int? qty = int.tryParse(productQTYController.text);
                  double? unitPrice = double.tryParse(productUnitPriceController.text);
                  double? totalPrice = double.tryParse(productTotalPriceController.text);


                  int finalUnitPrice = (unitPrice ?? 0.0).round();
                  int finalTotalPrice = (totalPrice ?? 0.0).round();


                  Data newProductData = Data(

                    productName: productNameController.text,
                    img: productIMGController.text,
                    qty: qty ?? 0,
                    unitPrice: finalUnitPrice,
                    totalPrice: finalTotalPrice,
                  );


                  if (isUpdate) {

                    bool success = await productController.updateproduct(
                      productToUpdate!.sId.toString(),
                      newProductData,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? 'Update Successful' : 'Update Failed'))
                      );
                    }


                  } else {

                    productController.createproduct(newProductData);
                  }

                  await fetchData();
                  Navigator.pop(context);
                }, child: Text(isUpdate ? 'Update' : 'Submit')),
              ],
            )

          ],
        ),
      ),
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: productController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 0.7
        ),
        itemCount: productController.products.length,
        itemBuilder: (context, index) {
          final item = productController.products[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                SizedBox(
                  height: 140,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item.img.toString(),
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {

                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
                              const Text('Image Load Failed', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        );
                      },

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('Price: \$${item.unitPrice.toString()} | QTY: ${item.qty}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [


                          IconButton(
                            onPressed: () {

                              productDialog(productToUpdate: item);
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                            tooltip: 'Edit Product',
                          ),


                          IconButton(
                            onPressed: () async {
                              await productController.deletproduct(item.sId.toString()).then((value) async {
                                if (value) {
                                  await fetchData();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Delete Successful'))
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Delete Unsuccessful'))
                                    );
                                  }
                                }
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Product',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){productDialog();},
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}