import 'package:sqflite/sqflite.dart' as sql;

// Classe SQL que junta todas as funções CRUD em uma só
class SqlCRUD {
  // Classe criadora de tabelas
  static Future<void> createTables(sql.Database database) async {
    // Criando a tabela 'task' caso ela não exista
    await database.execute(
      """CREATE TABLE IF NOT EXISTS task(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )""",
    );
  }

  // Classe que dá o acesso ao banco de dados configurado abaixo
  static Future<sql.Database> db() async {
    return sql.openDatabase("minha_agenda.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      // Função que espera resposta interna do servidor
      await createTables(database);
    });
  }

  // Função de criar as tasks com um título e uma descrição
  static Future<int> createTask(String title, String? desc) async {
    // Aguardando resposta da classe SQL do bd
    final db = await SqlCRUD.db();
    // Armazenando os dados da criação da nova task
    final data = {
      'title': title,
      'description': desc,
    };
    // Inserindo os dados 'data' na tabela 'task'
    final id = await db.insert(
      'task',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    return id;
  }

  // Função que retorna todas as tasks existentes do bd
  static Future<List<Map<String, dynamic>>> readAllTask() async {
    // Aguardando resposta da classe SQL do bd
    final db = await SqlCRUD.db();
    // Realiza uma busca geral no banco de dados 'task' e ordena pelo 'id'
    return db.query(
      'task',
      orderBy: 'id',
    );
  }

  // Função que retorna uma task específica do bd
  static Future<List<Map<String, dynamic>>> readSingleTask(int id) async {
    // Aguardando resposta da classe SQL do bd
    final db = await SqlCRUD.db();
    // Realiza uma busca específica no banco de dados 'task' pelo 'id'
    return db.query(
      'task',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  // Função que atualiza uma task existente do bd
  static Future<int> updateTask(int id, String title, String? desc) async {
    // Aguardando resposta da classe SQL do bd
    final db = await SqlCRUD.db();
    // Armazenando os dadoa da criação da nova task
    final newTask = {
      'title': title,
      'description': desc,
      'createdAt': DateTime.now().toString(),
    };
    // Realiza uma atualização em uma task especificada pelo 'id'
    final result = await db.update(
      'task',
      newTask,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  // Função que deleta uma task existente do bd
  static Future<void> deleteTask(int id) async {
    // Aguardando resposta da classe SQL do bd
    final db = await SqlCRUD.db();

    try {
      // Realiza uma deleção em uma task especificada pelo 'id'
      await db.delete(
        'task',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (error) {
      // Caso algum erro seja acionado
    }
  }
}
