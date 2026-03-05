import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorAccepted.dart';
import 'package:medconnect_app/mainScreen.dart';
//import 'package:medconnect_app/mainScreen.dart';
//import 'homeScreen.dart';

//import 'homeScreen.dart'; // عشان نقدر نرجع على HomeScreen ونشغل search

// ---------------------
// Equipment Item & List Models
// ---------------------
class EquipmentItem {
  final String name;
  final double price;
  bool inStock;

  EquipmentItem({
    required this.name,
    required this.price,
    required this.inStock,
  });
}

class EquipmentListModel {
  String title;
  bool isExpanded;
  List<EquipmentItem> items;

  EquipmentListModel({
    required this.title,
    this.isExpanded = true,
    required this.items,
  });
}

// ---------------------
// Equipment Lists Screen
typedef void SearchCallback(String query);
// ---------------------
class EquipmentListsScreen extends StatefulWidget {
   final SearchCallback? onSearchRequested; // ⭐️ نفس النوع اللي في HomeScreen
  
  const EquipmentListsScreen({
    super.key, 
    this.onSearchRequested,
  });

  @override
  State<EquipmentListsScreen> createState() => _EquipmentListsScreenState();
}

class _EquipmentListsScreenState extends State<EquipmentListsScreen> {

  
  List<EquipmentListModel> lists = [
    EquipmentListModel(
      title: "Surgical Suite Setup",
      items: [
        EquipmentItem(name: "Anesthesia Machine", price: 1500, inStock: true),
        EquipmentItem(name: "MRI Machine", price: 4200, inStock: false),
        EquipmentItem(name: "Surgical Lights", price: 1800, inStock: true),
        EquipmentItem(name: "Electrosurgical Unit", price: 2500, inStock: true),
      ],
    ),
    EquipmentListModel(
      title: "Diagnostic Tools",
      items: [
        EquipmentItem(name: "ECG Machine", price: 3000, inStock: true),
        EquipmentItem(name: "Ultrasound", price: 6000, inStock: true),
      ],
    ),
  ];


  void addAllToCart(EquipmentListModel list) {
    for (var item in list.items) {
      if (item.inStock) {
       // cartItemsGlobal.add(
          // CartItem(
          //   name: item.name,
          //   image: "", // ممكن تحطي صورة افتراضية أو تحطيها لاحقًا
          //   quantity: 1,
          //   price: item.price,
          //   type: 'buy',
          //   dateRange: '',
       //   ),
      //  );
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Available items added to cart")),
    );
  }

  void deleteList(int index) {
    setState(() {
      lists.removeAt(index);
    });
  }

  void addNewList() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New List Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  lists.add(EquipmentListModel(title: controller.text, items: []));
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // void goToSearch(String deviceName) {
  //   // نرجع للهوم ونرسل اسم الجهاز للبحث
  //   Navigator.pop(context, deviceName);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        onPressed: addNewList,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Equipment Lists",style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    onPressed: () {  //new modification 
       Navigator.push(
        context,
        MaterialPageRoute(
         builder: (context) => const MainScreen(),
        ),
      );
    },
  ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 247, 246, 246),
        child: ListView.builder(
          
          padding: const EdgeInsets.all(12),
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
        
            return Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(list.title),
                    subtitle: Text("${list.items.length} Items"),
        trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Delete مع Confirmation
                        IconButton(
                          icon: const Icon(Icons.delete_outline,),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete List"),
                                content: const Text("Are you sure?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      deleteList(index);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(list.isExpanded ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              list.isExpanded = !list.isExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
        
                  if (list.isExpanded)
                    Column(
                      children: [
                        ...list.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name),
                                    Text("\$${item.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (!item.inStock)
                                      const Text("Out Of Stock", style: TextStyle(color: Color.fromARGB(255, 126, 12, 4))),
                                  ],
                                ),
                                if (!item.inStock)
                                  TextButton(
                                    onPressed: () {
                                      
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const MainScreen()), (Route)=>false);
                                     },
                                 
                                    child: const Text("Search Again", style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 62, 93, 193),
                        ),),
                                  ),
                                  
                              ],
                            ),
                          );
                        }).toList(),
                           Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    onPressed: () => addAllToCart(list),
                      child: const Text(
                        "Add All To Cart",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                        // ElevatedButton(
                        //   onPressed: () => addAllToCart(list),
                        //   child: const Text("Add All To Cart",style: TextStyle(
                        //   fontSize: 16,
                        //   fontWeight: FontWeight.bold,
                        //   color: Colors.white,
                        // ),),
                        // ),
        
                        const SizedBox(height: 10),
                      ],
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


        
 
