import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app_2/src/note.dart';

import '../db/databaseCategory.dart';
/*
void main() {
  runApp(const MyApp());
}*/

class MyInicio extends StatelessWidget {
  const MyInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        dark: ThemeData.dark(),
        light: ThemeData.light(),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme){
          return MaterialApp(
            title: 'Gestory Password',
            theme: theme,
            darkTheme: darkTheme,
            home: MyHomePage(),
          );
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File? _image; //se crea una variable de tipo archivo
  int _selectedChipIndex = -1;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState(); // Llama a super.initState() primero
    _loadCategories(); // Llama a _loadCategories al iniciar la pantalla
  }

  void _loadCategories() async {
    final dbHelper = DatabaseHelper();
    final categories = await dbHelper.getCategories(); // Supongamos que esta función devuelve una lista de categorías

    setState(() {
      _categories = categories;
    });
  }

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> _getImageFromGallery() async { //funcion asincrona
    final picker = ImagePicker(); //se crea una instacia de la clase ImagePicker
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Tomar foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromCamera();
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Text('Seleccionar desde galería'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color botonColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFFFFFFF) : Color(0xFF14181B);
    Color textColor = Theme.of(context).brightness == Brightness.light ? Color(0xFF57636C) : Color(0xFF95A1AC);
    Color chiocColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFE0E3E7) : Color(0xFF262D34);
    Color bordeColor = Theme.of(context).brightness == Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);
    Color backgroudcolor = Theme.of(context).brightness == Brightness.light ? Color(0xFFF1F4F8) : Color(0xFF1D2428);


    return Scaffold(
      backgroundColor: backgroudcolor,
      body: Stack(
        children: [
          Column(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20,top: 40),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 2),
                            child: Card(
                              elevation: 0,
                              color: Color(0xFFFFFF),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : AssetImage('assets/imagen.jpg') as ImageProvider<Object>,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        const Stack(
                          children: [
                            Text(
                              'Gestory Password',
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily:
                                'Title Large',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFE0E3E7), // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              const Positioned(
                                left: 6, // Alinea el icono de modo claro a la izquierda
                                top: 8,
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Color(0xFF57636C), // Cambia el color según el modo
                                  size: 24.0,
                                ),
                              ),
                              const Positioned(
                                right: 0, // Alinea el icono de modo oscuro a la derecha
                                top: 8,
                                child: Icon(
                                  Icons.mode_night_rounded,
                                  color: Colors.white, // Cambia el color según el modo
                                  size: 24.0,
                                ),
                              ),
                              Transform.scale(
                                scale: 2.0,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Switch(
                                    value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light,
                                    onChanged: (bool value) {
                                      if (value) {
                                        AdaptiveTheme.of(context).setLight();
                                      } else {
                                        AdaptiveTheme.of(context).setDark();
                                      }
                                    },
                                    activeColor: Colors.transparent, // Pulgar transparente en modo oscuro y claro
                                    activeTrackColor: Colors.transparent, // Riel transparente en modo oscuro y claro
                                    inactiveThumbColor: Colors.transparent, // Color del pulgar del interruptor cuando está desactivado
                                    inactiveTrackColor: Colors.transparent, // Color del riel cuando el interruptor está desactivado
                                  ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 20),

                        for (int index = 0; index < _categories.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_categories[index].name,
                                style: TextStyle(
                                  fontSize: 18, // Tamaño de fuente personalizado
                                ),
                              ),
                              selected: _selectedChipIndex == index, // Verifica si este ChoiceChip está seleccionado
                              backgroundColor: chiocColor,
                              labelStyle: TextStyle(
                                color: textColor,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: bordeColor, // Color del borde
                                  width: 1.0, // Ancho del borde
                                ),
                                borderRadius: BorderRadius.circular(16.0), // Radio del borde
                              ),
                              onSelected: (isSelected) {
                                setState(() {
                                  _selectedChipIndex = isSelected ? index : -1;// Selecciona o deselecciona este ChoiceChip
                                  print('Categoria Seleccionada: ${_categories[index].name}');
                                });
                              },
                            ),
                          ),
                        SizedBox(width: 12),
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: Color(0xFF2874cf).withOpacity(0.2), // se le asigno un color
                thickness: 2,
              ),

              //SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20,top: 10, right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF96692c),
                                        borderRadius: BorderRadius.circular(8)
                                      ),

                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500,// Peso de fuente
                                                  ),
                                                ),

                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFF96692c),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500, // Peso de fuente
                                                  ),
                                                ),

                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFF96692c),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500, // Peso de fuente
                                                  ),
                                                ),

                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFfc6849),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500, // Peso de fuente
                                                  ),
                                                ),

                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFfc6849),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500, // Peso de fuente
                                                  ),
                                                ),
                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: 330,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFfc6849),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Hello world',
                                                  style: TextStyle(
                                                    fontSize: 19, // Tamaño de fuente
                                                    fontFamily:
                                                    'Headline Small',
                                                    fontWeight: FontWeight.w500, // Peso de fuente
                                                  ),
                                                ),
                                                Text('Hello World',
                                                  style: TextStyle(
                                                    fontSize: 14, // Tamaño de fuente
                                                    fontFamily:
                                                    'Body Small',
                                                    fontWeight: FontWeight.normal, // Peso de fuente
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 80,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: botonColor,
                border: Border.all(
                  color: chiocColor, // Color del borde
                  width: 4.0, // Ancho del borde
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  print('Icono presionado');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyNote()),
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 48,
                  color: Color(0xFF2874cF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}