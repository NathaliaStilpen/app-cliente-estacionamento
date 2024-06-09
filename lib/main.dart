import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(Colors.blue[900]),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final email = _cpfController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );

      print('Login Response: ${response.body}');
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email ou senha incorretos')),
        );
      }
    } catch (e) {
      print('Login Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede. Tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: 100,
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cpfController,
                decoration: InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Cadastrar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register(BuildContext context) async {
    final cpf = _cpfController.text;
    final email = _emailController.text;
    final carPlate = _carPlateController.text;
    final state = _stateController.text;
    final city = _cityController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cpf': cpf,
          'email': email,
          'placadocarro': carPlate,
          'estado': state,
          'cidade': city,
          'senha': password,
        }),
      );

      print('Register Response: ${response.body}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro bem-sucedido')),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: ${data['message']}')),
        );
      }
    } catch (e) {
      print('Register Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede. Tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _cpfController,
                decoration: InputDecoration(labelText: 'CPF', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _carPlateController,
                decoration: InputDecoration(labelText: 'Placa do Carro', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text('Cadastrar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? activeSpotInfo = 'Carregando...'; // Informações da vaga ativa

  // Função para buscar e exibir a vaga ativa do cliente
  void _fetchActiveSpot() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/active_spot'), // URL para buscar a vaga ativa
      );

      if (response.statusCode == 200) {
        final activeSpotData = jsonDecode(response.body);
        final activeSpotID = activeSpotData['IDVaga'];
        final horaEntrada = activeSpotData['horaEntrada'];
        final horaSaida = activeSpotData['horaSaida'];

        setState(() {
          // Atualiza o estado para exibir as informações da vaga ativa
          activeSpotInfo = 'Vaga Ativa: ID $activeSpotID, Hora de Entrada: $horaEntrada, Hora de Saída: $horaSaida';
        });
      } else {
        setState(() {
          // Se não houver vaga ativa, exibe uma mensagem informando ao usuário
          activeSpotInfo = 'Não há vaga ativa para o cliente';
        });
      }
    } catch (e) {
      print('Erro ao buscar vaga ativa: $e');
      setState(() {
        // Em caso de erro, exibe uma mensagem de erro
        activeSpotInfo = 'Erro ao buscar vaga ativa';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Chama a função para buscar a vaga ativa ao iniciar a página
    _fetchActiveSpot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuyCreditsPage()),
                  );
                },
                child: Text('Comprar Créditos', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewParkedSpotsPage()),
                  );
                },
                child: Text('Ver Vagas Estacionadas', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Text(
                activeSpotInfo ?? 'Carregando...', // Exibe as informações da vaga ativa
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BuyCreditsPage extends StatefulWidget {
  @override
  _BuyCreditsPageState createState() => _BuyCreditsPageState();
}

class _BuyCreditsPageState extends State<BuyCreditsPage> {
  String? selectedCity;
  String? selectedArea;
  String? selectedTime;

  final List<String> cities = ['Cidade 1', 'Cidade 2', 'Cidade 3'];
  final List<String> areas = ['Área Azul 1', 'Área Azul 2', 'Área Azul 3'];
  final List<String> times = ['1h', '2h', '3h', '4h'];

  void _buyCredits() async {
    if (selectedCity != null && selectedArea != null && selectedTime != null) {
      final response = await http.post(
        Uri.parse('https://seu-backend.com/buy_credits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'city': selectedCity!,
          'area': selectedArea!,
          'time': selectedTime!,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Créditos comprados com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao comprar créditos')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprar Créditos'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCity,
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedArea,
                items: areas.map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedArea = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Área Azul', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTime,
                items: times.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Tempo', border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _buyCredits,
                child: Text('Comprar Créditos', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewParkedSpotsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vagas Estacionadas'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aqui você poderá visualizar as vagas estacionadas',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
