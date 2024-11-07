import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/Telas_QRCODE/Tela_GerarQRCode.dart';

class TelaRegistrarExtintor extends StatefulWidget {
  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _composicaoController = TextEditingController();
  final TextEditingController _linhaController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _dataRegistroController = TextEditingController();

  // Função que abre o modal de confirmação
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Registro Concluído',
            style: TextStyle(color: Color(0xFF003366)),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'O extintor foi registrado com sucesso.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color(0xFF003366)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToGenerateQRCode();
              },
              child: const Text('Gerar QR Code'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF003366),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navegação para a tela de gerar QR Code
  void _navigateToGenerateQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaGerarQRCode(
          numero: _numeroController.text,
          composicao: _composicaoController.text,
          linha: _linhaController.text,
          localizacao: _localizacaoController.text,
          observacao: _observacaoController.text,
          dataRegistro: _dataRegistroController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8), // Fundo claro e suave
      appBar: AppBar(
        title: const Text(
          'Registrar Extintor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366), // Azul escuro profissional
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Título da tela com instruções
            const Text(
              "Clique no botão abaixo para registrar o extintor.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF003366),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Botão para abrir o modal de registro
            ElevatedButton(
              onPressed: () {
                _showFormDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Registrar Extintor',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para abrir o modal de formulário de registro
  void _showFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do formulário
                  const Text(
                    'Registrar Extintor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Campos de entrada
                  _buildInputField(
                    controller: _numeroController,
                    label: 'Número do Extintor',
                    icon: Icons.confirmation_number,
                  ),
                  _buildInputField(
                    controller: _composicaoController,
                    label: 'Composição',
                    icon: Icons.science,
                  ),
                  _buildInputField(
                    controller: _linhaController,
                    label: 'Linha',
                    icon: Icons.train,
                  ),
                  _buildInputField(
                    controller: _localizacaoController,
                    label: 'Localização',
                    icon: Icons.location_on,
                  ),
                  _buildInputField(
                    controller: _observacaoController,
                    label: 'Observação',
                    icon: Icons.note_alt,
                    isOptional: true,
                  ),
                  GestureDetector(
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        // Personalize o tema do calendário
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF003366), // Cor azul escuro para o cabeçalho
            hintColor: Color(0xFF003366), // Cor do selecione
            primaryColorDark: Color(0xFF003366), // Cor da barra de seleção
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dataRegistroController.text =
            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  },
  child: AbsorbPointer(
    child: _buildInputField(
      controller: _dataRegistroController,
      label: 'Data do Registro',
      icon: Icons.calendar_today,
    ),
  ),
)

                   SizedBox(height: 20),
                  // Botão de confirmação centralizado e estilizado
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _showConfirmationDialog();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Confirmar Registro',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Campo de entrada reutilizável
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF003366)), // Ícone azul
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF003366)), // Cor do texto do label
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003366)), // Cor da borda ao focar
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003366)), // Cor da borda padrão
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003366)), // Cor da borda
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003366)), // Cor da borda se erro
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Por favor, insira $label';
          }
          return null;
        },
      ),
    );
  }
}