import 'package:advanced_dropdown_flutter/advanced_dropdown_flutter.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DemoPage(),
    );
  }
}


class DemoPage extends StatefulWidget {
  const DemoPage({super.key});


  @override
  State<DemoPage> createState() => _DemoPageState();
}


class _DemoPageState extends State<DemoPage> {
  String? selectedFruit;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Dropdown Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AdvancedDropdown<String>(
              items: ['Apple', 'Banana', 'Mango'],
              hint: 'Choose fruit',
              fieldColor: Colors.white,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(20),
              textStyle: const TextStyle(fontSize: 16),
              onChanged: (value) {
                print(value);
              },
              itemBuilder: (context, item, selected) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.blue.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: selected ? Colors.blue : Colors.black,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20,),
            SearchableDropdown<String>(
              items: ['Red', 'Green', 'Blue', 'Yellow'],
              itemLabel: (e) => e,
              onChanged: (value) {
                print(value);
              },
            ),
            SizedBox(height: 20,),
            MultiSelectDropdown<String>(
              items: ['Red', 'Green', 'Blue', 'Yellow'],
              label: (e) => e,
              onChanged: (values) {
                print(values);
              },
            ),
            SizedBox(height: 20,),
            OverlayDropdown<String>(
              items: ['India', 'USA', 'UK'],
              label: (e) => e,
              onSelected: (v) {
                print(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}