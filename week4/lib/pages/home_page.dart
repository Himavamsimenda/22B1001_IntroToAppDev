import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:week4/auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import for the fl_chart package

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'user email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BudgetTrackerHome(),
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: lightOrange,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: deepOrange,
          ),
        ),
      ),
    );
  }
}

const Color lightOrange = Color(0xFFFFF0E1);
const Color deepOrange = Color(0xFFFF5722);
const Color mediumOrange = Color(0xFFFFAB91);

class BudgetTrackerHome extends StatefulWidget {
  @override
  _BudgetTrackerHomeState createState() => _BudgetTrackerHomeState();
}

class _BudgetTrackerHomeState extends State<BudgetTrackerHome> {
  bool _showCategories = false;
  Color _categoryBackgroundColor = Colors.transparent;
  Map<String, double> _categoryValues = {};
  MapEntry<String, double>? _removedCategory;

  String _calculateTotal() {
    if (_categoryValues.isNotEmpty) {
      double total = _categoryValues.values.reduce((sum, value) => sum + value);
      return NumberFormat.decimalPattern().format(total);
    } else {
      return '0';
    }
  }

  void addItemToFirebase(String name, double price) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('items')
          .add({
        'name': name,
        'price': price,
      }).then((_) {
        setState(() {
          _categoryValues[name] = price;
        });
      }).catchError((error) {
        print("Error adding data: $error");
      });
    }
  }

  void removeItemFromFirebase(String name) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      // Find the document with the matching name and delete it
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('items')
          .where('name', isEqualTo: name)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      }).catchError((error) {
        print("Error removing data: $error");
      });
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
                  addItemToFirebase(categoryName, value);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String categoryName, double categoryValue) {
    setState(() {
      _categoryValues.remove(categoryName);
      _removedCategory = MapEntry(categoryName, categoryValue);
    });
    removeItemFromFirebase(categoryName);
  }

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(user?.email ?? 'user email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('sign Out'),
    );
  }

  void _showStatisticsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(_categoryValues),
      ),
    );
  }

  // Added: Minimum savings variable and update method
  double _minimumSavings = 0;

  void _updateMinimumSavings(String value) {
    setState(() {
      _minimumSavings = double.tryParse(value) ?? 0;
    });
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
                  _categoryBackgroundColor =
                      _showCategories ? mediumOrange : Colors.transparent;
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
                        _showCategories
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
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
                    ..._categoryValues.entries
                        .map(
                          (entry) => Dismissible(
                            key: Key(entry.key),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteCategory(entry.key, entry.value);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${entry.key} removed',
                                    textAlign: TextAlign.center,
                                  ),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      setState(() {
                                        _categoryValues[entry.key] =
                                            _removedCategory?.value ?? 0;
                                      });
                                      addItemToFirebase(entry.key,
                                          _removedCategory?.value ?? 0);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: CategoryItem(entry.key, entry.value),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Minimum Savings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Minimum Savings: ',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                Container(
                  width: 120,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: _updateMinimumSavings,
                    decoration: InputDecoration(
                      labelText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            // Savings Tracker Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: _calculateTotalAsDouble() >= _minimumSavings
                    ? Colors.green
                    : Colors.red,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Savings Tracker'),
                      content: Text(
                        _calculateTotalAsDouble() >= _minimumSavings
                            ? 'Congratulations! You have saved enough.'
                            : 'You need to save more to reach your goal.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Savings Tracker'),
            ),

            SizedBox(height: 8), // Added space between buttons

            // Statistics Button
            ElevatedButton(
              onPressed: () {
                _showStatisticsScreen();
              },
              child: Text('Statistics'),
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

  double _calculateTotalAsDouble() {
    return _categoryValues.values.isNotEmpty
        ? _categoryValues.values.reduce((sum, value) => sum + value)
        : 0;
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

class StatisticsScreen extends StatelessWidget {
  final Map<String, double> categoryValues;

  StatisticsScreen(this.categoryValues);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Category-wise Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: categoryValues.values.isNotEmpty
                        ? categoryValues.values.reduce(
                                (max, value) => max > value ? max : value) +
                            50
                        : 100,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (context, value) => TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        margin: 10,
                        getTitles: (double value) {
                          if (value >= 0 &&
                              value < categoryValues.keys.length) {
                            return categoryValues.keys.elementAt(value.toInt());
                          }
                          return '';
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: categoryValues.entries
                        .map(
                          (entry) => BarChartGroupData(
                            x: categoryValues.keys.toList().indexOf(entry.key),
                            barRods: [
                              BarChartRodData(
                                y: entry.value,
                                colors: [Colors.blue],
                                width: 16,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
