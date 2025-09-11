import 'package:flutter/material.dart';
// Importa las pantallas que se usarán en la BottomNavigationBar
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'messages_screen.dart';
import 'routine_assistant_screen.dart';

// Importa los widgets y servicios necesarios
import '../widgets/app_drawer.dart';
import '../services/ad_service.dart';
import '../main.dart'; // Para acceder a la instancia global de adService
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'progress_assistant_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;


  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProgressAssistantScreen(),
    MessagesScreen(),
    NutritionScreen(),
    RoutineAssistantScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar el banner publicitario
    adService.loadBannerAd(() {
      if (mounted) {
        setState(() {}); // Actualizar la UI para mostrar el banner
      }
    });
    // Cargar el primer anuncio intersticial
    adService.loadInterstitialAd();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Incrementar contador y potencialmente mostrar anuncio intersticial
    adService.incrementScreenChangeAndShowAd();
  }
 
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Asesoría Personal';
      case 2:
        return 'Mensajes';
      case 3:
        return 'Asesoría Nutricional';
      case 4:
        return 'Asistente de Rutinas';
      default:
        return 'TrainCoach';
    }
  }
  
  @override
  void dispose() {
    // Es buena práctica limpiar los anuncios, aunque en este caso
    // como es la pantalla principal, podría no llegar a llamarse nunca.
    adService.disposeBannerAd();
    adService.disposeInterstitialAd();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        elevation: 1.0,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Contenedor para el Banner Ad
          if (adService.isBannerAdLoaded && adService.bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: adService.bannerAd!.size.width.toDouble(),
              height: adService.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: adService.bannerAd!),
            )
          else
            const SizedBox(height: 50), // Placeholder para mantener el espacio
          
          // Contenido principal de la pantalla
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'INICIO',
          ),
          BottomNavigationBarItem( // <--- AÑADIR ESTE ITEM
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'PROGRESO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'MENSAJES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'ASESORIA',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'RUTINAS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
