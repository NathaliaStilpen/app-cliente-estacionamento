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
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainPage(
          placaDoCarro: ModalRoute.of(context)?.settings.arguments as String?,
        ),
        '/comprar_vaga': (context) => ComprarVagaPage(
          placaDoCarro: ModalRoute.of(context)?.settings.arguments as String?,
        ),
        '/ver_vagas_antigas': (context) => VagasAntigasPage(
          placaDoCarro: ModalRoute.of(context)?.settings.arguments as String?,
        ),
      },
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

  void _login(BuildContext context) async {
    final email = _cpfController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );

      print('Login Response: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final placaDoCarro = responseData['placaDoCarro'];
        print('Placa do Carro: $placaDoCarro');

        if (placaDoCarro != null) {
          Navigator.pushNamed(context, '/main', arguments: placaDoCarro);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no login: Placa do carro não encontrada')),
          );
        }
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
                onPressed: () => _login(context),
                child: Text('Entrar'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Cadastrar'),
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
        Uri.parse('http://localhost:5001/register'),
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
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String? placaDoCarro;

  MainPage({required this.placaDoCarro});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? activeSpot;
  Timer? _timer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    print('Placa do Carro na MainPage: ${widget.placaDoCarro}');
    _loadActiveSpot();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveSpot() async {
    final url = Uri.parse('http://localhost:5001/active_spot');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'placaDoCarro': widget.placaDoCarro}),
      );

      print('Load Active Spot Response: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          activeSpot = jsonDecode(response.body);
          if (activeSpot != null) {
            final entrada = DateTime.parse(activeSpot!['horaEntrada']);
            final saida = DateTime.parse(activeSpot!['horaSaida']);
            _timeRemaining = saida.difference(DateTime.now());
            _startTimer();
          }
        });
      } else {
        setState(() {
          activeSpot = null;
        });
      }
    } catch (e) {
      print('Error loading active spot: $e');
    }
  }

  void _startTimer() {
    if (_timeRemaining != null) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeRemaining!.inSeconds > 0) {
            _timeRemaining = _timeRemaining! - Duration(seconds: 1);
          } else {
            _timer?.cancel();
          }
        });
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                context,
                '/comprar_vaga',
                arguments: widget.placaDoCarro,
                );
              },
              child: Text('Comprar Vaga'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/ver_vagas_antigas',
                  arguments: widget.placaDoCarro,
                );
              },
              child: Text('Ver Vagas Antigas'),
            ),
            SizedBox(height: 20),
            activeSpot != null
                ? Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vaga Ativa',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text('Rua: ${activeSpot!['rua']}'),
                          Text('Cidade: ${activeSpot!['cidade']}'),
                          Text('Hora de Entrada: ${activeSpot!['horaEntrada']}'),
                          Text('Hora de Saída: ${activeSpot!['horaSaida']}'),
                          SizedBox(height: 10),
                          Text(
                            'Tempo Restante: ${_timeRemaining != null ? _formatDuration(_timeRemaining!) : 'Carregando...'}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Não há vaga ativa no momento',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class VagaAntiga {
  final DateTime horaEntrada;
  final DateTime horaSaida;
  final String nomeRua;
  final String nomeCidade;

  VagaAntiga({
    required this.horaEntrada,
    required this.horaSaida,
    required this.nomeRua,
    required this.nomeCidade,
  });

  factory VagaAntiga.fromJson(Map<String, dynamic> json) {
    return VagaAntiga(
      horaEntrada: DateTime.parse(json['horaEntrada']),
      horaSaida: DateTime.parse(json['horaSaida']),
      nomeRua: json['rua'],
      nomeCidade: json['cidade'],
    );
  }
}

class VagasAntigasPage extends StatefulWidget {
  final String? placaDoCarro;

  VagasAntigasPage({required this.placaDoCarro});

  @override
  _VagasAntigasPageState createState() => _VagasAntigasPageState();
}

class _VagasAntigasPageState extends State<VagasAntigasPage> {
  List<VagaAntiga> _vagasAntigas = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchVagasAntigas();
  }

  Future<void> _fetchVagasAntigas() async {
    final url = Uri.parse('http://localhost:5001/all_spots');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'placaDoCarro': widget.placaDoCarro}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _vagasAntigas = data.map((json) => VagaAntiga.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching expired spots: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vagas Antigas'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _hasError
                ? Text('Erro ao carregar vagas antigas.')
                : _vagasAntigas.isEmpty
                    ? Text('Nenhuma vaga antiga encontrada.')
                    : ListView.builder(
                        itemCount: _vagasAntigas.length,
                        itemBuilder: (context, index) {
                          final vaga = _vagasAntigas[index];
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rua: ${vaga.nomeRua}'),
                                  Text('Cidade: ${vaga.nomeCidade}'),
                                  Text('Hora de Entrada: ${vaga.horaEntrada}'),
                                  Text('Hora de Saída: ${vaga.horaSaida}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}


class ComprarVagaPage extends StatefulWidget {
  final String? placaDoCarro;

  ComprarVagaPage({required this.placaDoCarro});

  @override
  _ComprarVagaPageState createState() => _ComprarVagaPageState();
}

class _ComprarVagaPageState extends State<ComprarVagaPage> {
  final _tempoController = TextEditingController();
  String? _selectedCity;
  String? _selectedStreet;
  List<String> _cities = [];
  List<String> _streets = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5001/all_cities'));
      if (response.statusCode == 200) {
        setState(() {
          _cities = List<String>.from(jsonDecode(response.body));
        });
      } else {
        _showErrorSnackbar('Erro ao carregar cidades');
      }
    } catch (e) {
      _showErrorSnackbar('Erro de rede. Tente novamente mais tarde.');
    }
  }

  Future<void> _fetchStreets(String city) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/all_streets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cidade': city}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _streets = List<String>.from(jsonDecode(response.body));
        });
      } else {
        _showErrorSnackbar('Erro ao carregar ruas');
      }
    } catch (e) {
      _showErrorSnackbar('Erro de rede. Tente novamente mais tarde.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _comprarVaga() async {
    final city = _selectedCity;
    final street = _selectedStreet;
    final tempo = int.tryParse(_tempoController.text);

    if (city == null || street == null || tempo == null) {
      _showErrorSnackbar('Por favor, preencha todos os campos');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/buy_spot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cidade': city,
          'rua': street,
          'tempo': tempo,
          'placaDoCarro': widget.placaDoCarro,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vaga comprada com sucesso')),
        );
        Navigator.pop(context);
      } else {
        _showErrorSnackbar('Erro ao comprar vaga');
      }
    } catch (e) {
      _showErrorSnackbar('Erro de rede. Tente novamente mais tarde.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprar Vaga'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                    _selectedStreet = null;
                    _streets = [];
                  });
                  if (value != null) {
                    _fetchStreets(value);
                  }
                },
                value: _selectedCity,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Rua',
                  border: OutlineInputBorder(),
                ),
                items: _streets.map((street) {
                  return DropdownMenuItem(
                    value: street,
                    child: Text(street),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStreet = value;
                  });
                },
                value: _selectedStreet,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _tempoController,
                decoration: InputDecoration(
                  labelText: 'Tempo (horas)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _comprarVaga,
                child: Text('Comprar Vaga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
