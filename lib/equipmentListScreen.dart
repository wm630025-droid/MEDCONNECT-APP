import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:medconnect_app/core/app_colorAccepted.dart';
//import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/services/equipment_service.dart'
    as EquipmentApiService;
import 'models/equipment_model.dart';

typedef void SearchCallback(String query);

class EquipmentListsScreen extends StatefulWidget {
  final SearchCallback? onSearchRequested;

  const EquipmentListsScreen({super.key, this.onSearchRequested});

  @override
  State<EquipmentListsScreen> createState() => _EquipmentListsScreenState();
}

class _EquipmentListsScreenState extends State<EquipmentListsScreen> {
  List<EquipmentList> lists = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEquipmentLists();
  }

  Future<void> fetchEquipmentLists() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final equipmentLists = await EquipmentApiService.getAllEquipmentLists();

      setState(() {
        lists = equipmentLists;
        isLoading = false;
      });
      print('✅ تم تحميل ${lists.length} قائمة');
    } catch (e) {
      setState(() {
        errorMessage = 'error: $e';
        isLoading = false;
      });
    }
  }

  void retryFetch() {
    fetchEquipmentLists();
  }

  void addAllToCart(EquipmentList list) {
    int addedCount = 0;
    for (var item in list.items) {
      if (item.isAva) {
        addedCount++;
        print('تمت إضافة: ${item.productName} إلى السلة');
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Added $addedCount items to cart"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createNewList(String listName) async {
    try {
      await EquipmentApiService.createEquipmentList(listName);
      await fetchEquipmentLists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ List created successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Error: ${e.toString().replaceAll('Exception:', '')}",
            ),
          ),
        );
      }
    }
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Equipment List"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter list name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _createNewList(controller.text.trim());
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _editListName(EquipmentList list, int index) async {
    final controller = TextEditingController(text: list.listName);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit List Name"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new list name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != list.listName) {
      try {
        await EquipmentApiService.updateEquipmentListName(list.id, newName);
        setState(() {
          lists[index].listName = newName;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("✏️ List name updated")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Error: ${e.toString().replaceAll('Exception:', '')}",
              ),
            ),
          );
        }
      }
    }
  }

  void _removeItemFromList(
    
    EquipmentList list,
    int listIndex,
    EquipmentItem item,
    int itemIndex,
    
  ) async {
      print('🗑️ Attempting to remove:');
  print('   listId: ${list.id}');
  print('   itemId: ${item.id}');  
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Item"),
        content: Text(
          "Are you sure you want to remove '${item.productName}' from this list?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 252, 251, 251)),
            child: const Text("Remove", style: TextStyle(color: Color.fromARGB(255, 243, 114, 114))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await EquipmentApiService.removeItemFromList(list.id, item.id);
      setState(() {
        lists[listIndex].items.removeAt(itemIndex);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Item removed from list")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Error: ${e.toString().replaceAll('Exception:', '')}",
            ),
          ),
        );
      }
    }
  }

  void _deleteList(int listId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete List"),
        content: Text(
          "Are you sure you want to delete '${lists[index].listName}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 246, 246, 246)),
            child: const Text("Delete", style: TextStyle(color: Color.fromARGB(255, 246, 94, 94))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await EquipmentApiService.deleteEquipmentList(listId);
      setState(() {
        lists.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("🗑️ List deleted")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Error: ${e.toString().replaceAll('Exception:', '')}",
            ),
          ),
        );
      }
    }
  }

  // void deleteList(int index) {
  //   setState(() {
  //     lists.removeAt(index);
  //   });
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("List deleted")),
  //   );
  // }

  // void addNewList() {
  //   TextEditingController controller = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("New List Name"),
  //       content: TextField(controller: controller),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (controller.text.isNotEmpty) {
  //               setState(() {
  //                 lists.add(EquipmentList(
  //                   id: DateTime.now().millisecondsSinceEpoch,
  //                   listName: controller.text,
  //                   isDefault: false,
  //                   createdAt: DateTime.now().toIso8601String(),
  //                   items: [],
  //                 ));
  //               });
  //             }
  //             Navigator.pop(context);
  //           },
  //           child: const Text("Add"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text(
          "Equipment Lists",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: retryFetch,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 247, 246, 246),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading equipment lists...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: retryFetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (lists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No equipment lists found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to create a new list',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: list.isDefault
                      ? AppColors.primary
                      : Colors.grey[300],
                  child: Icon(
                    Icons.format_list_bulleted,
                    color: list.isDefault ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                title: Text(
                  list.listName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${list.items.length} Items • ${list.createdAt.substring(0, 10)}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editListName(list, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color.fromARGB(255, 75, 87, 129)),
                      onPressed: () => _deleteList(list.id, index),

                      // showDialog(
                      //   context: context,
                      //   builder: (_) => AlertDialog(
                      //     title: const Text("Delete List"),
                      //     content: Text("Are you sure you want to delete '${list.listName}'?"),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () => Navigator.pop(context),
                      //         child: const Text("Cancel"),
                      //       ),
                      //       ElevatedButton(
                      //         onPressed: () {
                      //           deleteList(index);
                      //           Navigator.pop(context);
                      //         },
                      //         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      //         child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    ),
                    IconButton(
                      icon: Icon(
                        list.isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
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
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // ✅ قائمة فاضية - جملة تضغط تودي لـ HomeScreen
                      if (list.items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '✨ No items in this list',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // ✅ الجملة دي بس اللي بتتضغط
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Tap here to go to Home and search for products',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration
                                        .underline, // اختياري: يخليها متبطة عشان توضح إنها قابلة للضغط
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ✅ عرض العناصر
                      ...list.items.asMap().entries.map((entry) {
                        final itemIndex = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: !item.isAva
                                ? Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // ✅ علامة Out of Stock جنب المنتج
                                        if (!item.isAva)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'OUT OF STOCK',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // const SizedBox(height: 4),
                                    // Text(
                                    //   "Product ID: ${item.productId}",
                                    //   style: const TextStyle(
                                    //     fontSize: 12,
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                    // ✅ جملة out of stock تحت المنتج
                                    if (!item.isAva)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          "This product is out of stock",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // ✅ زر Search Again - يودي لـ MainScreen
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color.fromARGB(255, 54, 86, 158),
                                ),
                                onPressed: () => _removeItemFromList(
                                  list,
                                  index,
                                  item,
                                  itemIndex,
                                ),
                              ),

                              if (!item.isAva)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Search Again",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 8),

                      // زر إضافة الكل
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => addAllToCart(list),
                          child: const Text(
                            "Add All To Cart",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
