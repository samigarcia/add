
import 'package:app_2/db/notesdb.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  //instancia unica
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  // Constructor factory para crear una única instancia de DatabaseHelper
  factory DatabaseHelper() => _instance;
  static Database? _db;

  // Método para imprimir los nombres de las tablas en la base de datos
  Future<void> printTableNames() async {
    final db = await this.db;
    final result = await db!.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = result.map((row) => row['name'] as String).toList();

    for (final tableName in tableNames) {
      print('Nombre de la tabla: $tableName');
    }
  }


  Future<String> getDatabaseName() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gestorypassword.db');
    return path;
  }

  // Método asincrónico para obtener la base de datos SQLite
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
  // Constructor privado para garantizar que solo se pueda crear una instancia
  DatabaseHelper.internal();
  // Método para inicializar la base de datos
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'categories.db');
    final databaseName = await getDatabaseName();
    print('Nombre de la base de datos: $databaseName');
    // Abre la base de datos o crea una nueva si no existe
    //return await openDatabase(path, version: 1, onCreate: _onCreate);
    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }
  // Método para crear la tabla 'categories, images' en la base de datos
  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        category_id INTEGER,  -- Agrega una columna para la clave foránea
        FOREIGN KEY (category_id) REFERENCES categories (id)  -- Define la clave foránea
      )
    ''');

    await db.execute('''
    CREATE TABLE images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image_path TEXT
    )
    ''');
  }

  //Inserte la nueva imagen y si ya hay una imegen en la base de datos la elimina
  Future<void> insertImage(String imagePath) async {
    final db = await this.db;
    // Antes de insertar la nueva imagen, elimina la imagen anterior si existe
    await db!.delete('images');
    // Inserta la nueva imagen en la tabla
    await db.insert('images', {'image_path': imagePath});

  }

  Future<int> insertCategory(Category category) async {
    final dbClient = await db;

    // Verificar si ya existe una categoría con el mismo color
    final existingCategories = await dbClient!.query(
      'categories',
      where: 'color = ?',
      whereArgs: [category.color],
    );

    if (existingCategories.isNotEmpty) {
      // Ya existe una categoría con el mismo color, puedes manejar el error aquí
      return -1; // O algún otro valor que indique que la inserción falló
    }

    // Inserta la categoría en la tabla 'categories' sin especificar el ID
    return await dbClient.insert('categories', category.toMap());
  }

  /*
  // Método para insertar una categoría en la base de datos
  Future<int> insertCategory(Category category) async {
    final dbClient = await db;

    // Verificar si ya existe una categoría con el mismo color
    final existingCategories = await dbClient!.query(
      'categories',
      where: 'color = ?',
      whereArgs: [category.color],
    );

    if (existingCategories.isNotEmpty) {
      // Ya existe una categoría con el mismo color, puedes manejar el error aquí
      return -1; // O algún otro valor que indique que la inserción falló
    }
    // Inserta la categoría en la tabla 'categories'
    return await dbClient.insert('categories', category.toMap());
  }*/

  // Método para obtener todas las categorías de la base de datos
  Future<List<Category>> getCategories() async {
    final dbClient = await db;
    final list = await dbClient!.query('categories');
    return list.map((json) => Category.fromMap(json)).toList();
  }
  // Obtiene todas las notas de la base de datos y las convierte en una lista de `Notea`
  Future<List<Notea>> getAllNotes() async {
    final db = await _instance.db;
    final result = await db!.query('notes');
    return result.map((json) => Notea.fromMap(json)).toList();
  }

  /*Future<int> deleteCategory(String categoryName) async {
    final dbClient = await db;
    return await dbClient!.delete(
      'categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );
  }*/

// Funciones de la bd notes
// Inserta una nueva nota en la base de datos
  Future<int?> insert(Notea note, int categoryId) async {
    final db = await _instance.db;

    final noteMap = note.toMap();
    noteMap['category_id'] = categoryId;

    return await db?.insert('notes', note.toMap());
  }



  /*
  Future<List<Notea>?> getAllNotesWithCategoryColors() async {
    final db = await _instance.db;
    final result = await db?.rawQuery('''
    SELECT notes.*, categories.color as category_color
    FROM notes
    LEFT JOIN categories ON notes.category_id = categories.id
  ''');

    return result?.map((e) {
      final notea = Notea.fromMap(e);
      notea.color = e['category_color'] as int;
      return notea;
    }).toList();
  }*/

  /*
  Future<List<Notea>> getAllNotes() async {
    final db = await _instance.db;
    final result = await db?.rawQuery('''
    SELECT notes.*, categories.color AS category_color
    FROM notes
    LEFT JOIN categories ON notes.category_id = categories.id
  ''');

    if (result != null) {
      return result.map((row) {
        return Notea(
          id: row['id'] as int,
          title: row['title'] as String,
          content: row['content'] as String,
          categoryId: row['category_id'] as int,
          categoryColor: row['category_color'] as int,
        );
      }).toList();
    } else {
      return [];
    }
  }*/


  // Actualiza una nota en la base de datos
  Future<int?> update(Notea note) async {
    final db = await _instance.db;
    final id = note.id;
    return await db
        ?.update('notes', note.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  // Elimina una nota de la base de datos
  Future<int?> delete(int id) async {
    final db = await _instance.db;
    return await db?.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
// Clase que representa una categoría
class Category {
  int? id;
  String name;
  int color;

  Category({
    this.id,
    required this.name,
    required this.color,
  });
  // Método para convertir un objeto Category en un mapa (para la inserción en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
  // Constructor factory para crear un objeto Category desde un mapa (resultados de la consulta)
  factory Category.fromMap(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    color: json['color'],
  );
}

