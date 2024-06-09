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

    final response = await http.post(
      Uri.parse('http://localhost:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Navegar para a página principal passando o token
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(token: token),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email ou senha incorretos')),
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

    final response = await http.post(
      Uri.parse('http://localhost:5000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cpf': cpf,
        'email': email,
        'placa_do_carro': carPlate,
        'estado': state,
        'cidade': city,
        'senha': password,
      }),
    );

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

class MainPage extends StatelessWidget {
  final String token;

  MainPage({required this.token});

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
                    MaterialPageRoute(builder: (context) => BuyCreditsPage(token: token)),
                  );
                },
                child: Text('Comprar Créditos', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewParkedSpotsPage(token: token)),
                  );
                },
                child: Text('Ver Vagas Estacionadas', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Text(
                'Informações sobre a vaga ativa e o tempo restante',
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
  final String token;

  BuyCreditsPage({required this.token});

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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
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
          SnackBar(content: Text('Falha na compra de créditos')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Selecione a cidade', border: OutlineInputBorder()),
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
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Selecione a rua ou área azul', border: OutlineInputBorder()),
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
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Selecione o tempo', border: OutlineInputBorder()),
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buyCredits,
              child: Text('Comprar Créditos', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewParkedSpotsPage extends StatefulWidget {
  final String token;

  ViewParkedSpotsPage({required this.token});

  @override
  _ViewParkedSpotsPageState createState() => _ViewParkedSpotsPageState();
}

class _ViewParkedSpotsPageState extends State<ViewParkedSpotsPage> {
  List<Map<String, dynamic>> parkedSpots = [];

  @override
  void initState() {
    super.initState();
    _fetchParkedSpots();
  }

  Future<void> _fetchParkedSpots() async {
    final response = await http.get(
      Uri.parse('https://seu-backend.com/parked_spots'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        parkedSpots = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar vagas estacionadas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vagas Estacionadas'),
      ),
      body: ListView.builder(
        itemCount: parkedSpots.length,
        itemBuilder: (context, index) {
          final spot = parkedSpots[index];
          return ListTile(
            title: Text('${spot['city']} - ${spot['area']}'),
            subtitle: Text('Tempo: ${spot['time']} horas'),
          );
        },
      ),
    );
  }
}
