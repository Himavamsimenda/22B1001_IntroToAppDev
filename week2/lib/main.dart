import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BudgetTrackerHome(),
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // Change primary color to deep orange
        scaffoldBackgroundColor: lightOrange, // Set the background color to light orange
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: deepOrange, // Set button color to deep orange
          ),
        ),
      ),
    );
  }
}

const Color lightOrange = Color(0xFFFFF0E1);
const Color deepOrange = Color(0xFFFF5722);
const Color mediumOrange = Color(0xFFFFAB91); // New color for medium orange

class BudgetTrackerHome extends StatefulWidget {
  @override
  _BudgetTrackerHomeState createState() => _BudgetTrackerHomeState();
}

class _BudgetTrackerHomeState extends State<BudgetTrackerHome> {
  bool _showCategories = false;
  Color _categoryBackgroundColor = Colors.transparent;
  Map<String, double> _categoryValues = {};

  String _calculateTotal() {
    if (_categoryValues.isNotEmpty) {
      double total = _categoryValues.values.reduce((sum, value) => sum + value);
      return NumberFormat.decimalPattern().format(total);
    } else {
      return '0';
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    String categoryName = '';
    String categoryValue = '';
    TextEditingController nameController = TextEditingController();
    TextEditingController valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Category Name'),
                onChanged: (value) {
                  categoryName = value;
                },
              ),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Category Value'),
                onChanged: (value) {
                  categoryValue = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryName.isNotEmpty && categoryValue.isNotEmpty) {
                  double value = double.tryParse(categoryValue) ?? 0;
                  setState(() {
                    _categoryValues[categoryName] = value;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BudgetTrackerApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCategories = !_showCategories;
                  _categoryBackgroundColor = _showCategories ? mediumOrange : Colors.transparent;
                });
              },
              child: Container(
                height: 50,
                color: Colors.deepOrange,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showCategories ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        ' TOTAL = ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _calculateTotal(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: _categoryBackgroundColor,
              child: Column(
                children: [
                  if (_showCategories)
                    ..._categoryValues.entries.map((entry) => CategoryItem(entry.key, entry.value)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String categoryName;
  final double categoryValue;

  CategoryItem(this.categoryName, this.categoryValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            categoryName,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            categoryValue.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}