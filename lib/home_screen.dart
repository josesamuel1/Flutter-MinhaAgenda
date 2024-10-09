import 'package:flutter/material.dart';

import 'db_manager.dart';

// Classe da minha tela HomeScreen()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Criando um state para a HomeScreen
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista que vai armazenar os dados da aplicação enquanto em reprodução
  List<Map<String, dynamic>> _allData = [];
  // Valor booleano para simular o carregamento dos dados do bd
  bool _isLoading = true;

  // Função para atualizar os dados na aplicação enquanto em produção
  void _refreshData() async {
    // Armazenando todos os dados do bd na variável
    final data = await SqlCRUD.readAllTask();
    // Informando valores e dados para as variáveis já existentes
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  // Variáveis que vão controlar as entradas de texto do usuário
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Função de inicialização do código que
  // atualiza o aplicativo assim que é iniciado
  @override
  void initState() {
    super.initState();
    // Chamando função para rearmazenar os dados da bd na aplicação
    _refreshData();
  }

  // Função que controla a criação dos dados e atualiza o bd
  Future<void> _createTask() async {
    await SqlCRUD.createTask(_titleController.text, _descController.text);
    _refreshData();
  }

  // Função que atualiza os dados de uma task e atualiza o bd
  Future<void> _updateTask(int id) async {
    await SqlCRUD.updateTask(id, _titleController.text, _descController.text);
    _refreshData();
  }

  // Função que deleta uma task e atualiza o bd
  void _deleteTask(int id) async {
    await SqlCRUD.deleteTask(id);
    // Exibe mensagem de confirmação de exclusão
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          "Task deletada com sucesso.",
          style: TextStyle(
            color: Colors.lightGreen[900],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );

    _refreshData();
  }

  // Função do menu da barra inferior para adicionar ou atualizar uma task
  void showBottomSheet(int? id) async {
    // Caso a task já exista, recupera os dados do título e descrição para serem alteradas
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['description'];
    }

    // Menu inferior que aparece ao adicionar ou atualizar uma task
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Campo de texto do título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.green,
                ),
                hintText: "Título",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Campo de texto da descrição
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.green,
                ),
                hintText: "Descrição",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              // Botão de adicionar/atualizar a task
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.lightGreen,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    // Caso de decisão que se altera conforme a task está sendo criada ou atualizada
                    id == null ? "Adicionar" : "Atualizar",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Caso seja pressionado, vai criar ou atualizar a nova task com os novos dados
                onPressed: () async {
                  if (id == null) {
                    // Cria uma nova task com os dados
                    await _createTask();
                  }
                  if (id != null) {
                    // Atualiza a task com base no seu id
                    await _updateTask(id);
                  }

                  // Retorna os valores padrões da caixa de título e descrição para "nada"
                  _titleController.text = "";
                  _descController.text = "";

                  // Retira o menu de criação/atualização da tela
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[900],
      appBar: AppBar(
        // Aumenta o tamanho da appBar verticalmente
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5.0),
          child: Container(),
        ),
        backgroundColor: Colors.lightGreen,
        // Título do aplicativo
        title: const Center(
          child: Text(
            "Minha Agenda",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              // Caso o conteúdo do banco de dados ainda esteja sendo carregado
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              // Caso o conteúdo do banco de dados tenha sido carregado com sucesso
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 20.0,
                    top: 5.0,
                    right: 10.0,
                    bottom: 5.0,
                  ),
                  title: Text(
                    _allData[index]['title'],
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    _allData[index]['description'],
                  ),
                  // Parte ("bloco") da direita do widget das tasks
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de editar a task
                      IconButton(
                        // Caso seja pressionado, abre uma aba de edição
                        onPressed: () {
                          showBottomSheet(
                            _allData[index]['id'],
                          );
                        },
                        color: Colors.green,
                        icon: const Icon(Icons.edit),
                      ),
                      // Botão de excluir a task
                      IconButton(
                        // Caso seja pressionado, deleta a task e exibe uma mensagem
                        onPressed: () {
                          _deleteTask(
                            _allData[index]['id'],
                          );
                        },
                        color: Colors.red,
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
        onPressed: () => showBottomSheet(null),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
