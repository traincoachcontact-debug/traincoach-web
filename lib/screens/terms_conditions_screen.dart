// lib/screens/terms_conditions_screen.dart
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TÉRMINOS Y CONDICIONES DE USO – TRAINCOACH',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Última actualización: 02 de junio de 2025'),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido a TrainCoach, una aplicación móvil que ofrece asistencia personalizada para rutinas de ejercicio, planes alimenticios y funciones de mensajería entre usuarios. Al utilizar nuestra aplicación, aceptas los siguientes términos y condiciones de uso. Si no estás de acuerdo con alguno de ellos, por favor, abstente de utilizar la aplicación.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '1. Aceptación de los Términos'),
            const Text(
              'Al descargar, instalar o utilizar la aplicación TrainCoach, aceptas estar legalmente obligado por estos Términos y Condiciones, así como por nuestra Política de Privacidad.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '2. Descripción del Servicio'),
            const Text(
              'TrainCoach proporciona:\n'
              '• Asistencia para rutinas de entrenamiento personalizadas.\n'
              '• Sugerencias de planes alimenticios basados en objetivos personales.\n'
              '• Un sistema de mensajería interno para interactuar con otros usuarios.\n\n'
              'TrainCoach no sustituye el asesoramiento médico, nutricional o profesional. Se recomienda consultar a un profesional antes de iniciar cualquier rutina de ejercicio o dieta.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '3. Requisitos de Edad y Supervisión de Menores'),
            const Text(
              'El uso de la aplicación está permitido para personas mayores de 14 años. Los menores de edad deben contar con la supervisión y consentimiento de su representante legal.\n\n'
              'Una vez el usuario indica su edad dentro de la aplicación, toda responsabilidad sobre el uso de la misma por parte de menores recae exclusivamente en el tutor o representante legal, quien deberá supervisar y aprobar el uso de TrainCoach por parte del menor.\n\n'
              'TrainCoach no se responsabiliza por el uso de la aplicación por parte de personas que proporcionen información falsa o inexacta, incluyendo la edad. Es responsabilidad del usuario proveer datos verídicos al momento del registro.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '4. Responsabilidad del Usuario'),
            const Text(
              'El usuario se compromete a:\n'
              '• Utilizar la aplicación únicamente para fines personales y lícitos.\n'
              '• No compartir contenido ofensivo, discriminatorio o que infrinja derechos de terceros en la mensajería interna.\n'
              '• Respetar a otros usuarios en todo momento.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '5. Limitación de Responsabilidad'),
            const Text(
              'TrainCoach no será responsable por:\n'
              '• Lesiones, daños físicos o perjuicios derivados del uso incorrecto de las rutinas o planes alimenticios.\n'
              '• Problemas de salud generados por seguir recomendaciones sin supervisión profesional.\n'
              '• Fallos del sistema, interrupciones del servicio o pérdida de datos.',
            ),
            const SizedBox(height: 16),
             _buildSectionTitle(context, '6. Privacidad'),
            const Text(
              'El tratamiento de los datos personales se realiza conforme a la legislación ecuatoriana y a nuestra Política de Privacidad. No compartimos información con terceros sin consentimiento expreso del usuario, salvo disposición legal en contrario.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '7. Legislación Aplicable y Jurisdicción'),
            const Text(
              'Estos Términos y Condiciones se rigen por las leyes de la República del Ecuador. En caso de controversias, las partes se someten a la jurisdicción de los tribunales competentes en la ciudad de Guayaquil, Ecuador.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '8. Modificaciones'),
            const Text(
              'TrainCoach se reserva el derecho de modificar estos Términos y Condiciones en cualquier momento. Las modificaciones serán publicadas dentro de la aplicación y entrarán en vigencia desde su publicación.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '9. Suscripciones y Pagos'),
            const Text(
              'TrainCoach ofrece servicios tanto gratuitos como de pago. El acceso a ciertas funciones avanzadas requiere la adquisición de una suscripción. Los pagos se procesarán a través de las plataformas oficiales (Google Play Store / App Store) y estarán sujetos a sus respectivas políticas. El usuario puede cancelar su suscripción en cualquier momento desde la configuración de su cuenta en la tienda correspondiente.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '10. Publicidad'),
            const Text(
              'TrainCoach incluye anuncios que pueden ser mostrados dentro de la app, los cuales podrían estar personalizados. Estos anuncios son proporcionados por plataformas de terceros como Google AdMob. TrainCoach no controla ni se responsabiliza por el contenido, productos o servicios ofrecidos en dichos anuncios.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
