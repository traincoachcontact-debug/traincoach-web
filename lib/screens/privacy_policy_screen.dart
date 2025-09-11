// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POLÍTICA DE PRIVACIDAD – TRAINCOACH',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Última actualización: 07 de junio de 2025'),
            const SizedBox(height: 16),
            const Text(
              'La presente Política de Privacidad establece los términos en que TrainCoach (en adelante, “la aplicación” o “nosotros”) usa y protege la información que es proporcionada por sus usuarios al momento de utilizar la aplicación. Estamos comprometidos con la seguridad de los datos de nuestros usuarios. Cuando te pedimos llenar los campos de información personal con la cual puedas ser identificado, lo hacemos asegurando que solo se empleará de acuerdo con los términos de este documento.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, '1. Responsable del Tratamiento de Datos'),
            const Text(
              '• Nombre del desarrollador o empresa: TrainCoach (desarrollador independiente)\n'
              '• Correo de contacto: traincoachcontact@gmail.com\n'
              '• País: República del Ecuador',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '2. Datos Personales que Recopilamos'),
            const Text(
              'Al utilizar TrainCoach, podemos recopilar y procesar los siguientes datos:\n'
              '• Información de Identificación: Nombre, apellido y dirección de correo electrónico.\n'
              '• Datos Demográficos: Fecha de nacimiento (para calcular la edad) y género.\n'
              '• Información Física: Datos que proporcionas voluntariamente como peso, altura y objetivos de fitness.\n'
              '• Datos de Uso: Historial de rutinas completadas, ejercicios preferidos y otra actividad dentro de la aplicación.\n'
              '• Información de Pagos: No almacenamos directamente los datos de tu tarjeta. Las transacciones son procesadas de forma segura a través de los servicios de las tiendas de aplicaciones (Google Play o Apple App Store).\n'
              '• Datos Técnicos: ID de dispositivo anónimo, datos de uso y de fallos para análisis de rendimiento y mejora de la aplicación.\n'
              '• Información relacionada con la salud y condición física: Para personalizar tus planes, la IA podría solicitarte información que tú decidas proporcionar, como alergias o lesiones. No almacenamos diagnósticos clínicos.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '3. Finalidad del Tratamiento de Datos'),
            const Text(
              'Utilizamos tus datos para los siguientes fines legítimos: Proveer el servicio principal, gestionar tu cuenta, permitir la funcionalidad social, mostrar publicidad, mejorar y analizar el uso de la app y para comunicarnos contigo.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '4. Visibilidad del Perfil e Interacciones Sociales'),
            const Text(
              'Para permitir la funcionalidad social, tu nombre, foto de perfil principal y edad son visibles para otros usuarios. Tu historial de rutinas y tus conversaciones de chat son privados. La visibilidad está sujeta a nuestras reglas de protección de menores.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '5. Publicidad y Anuncios Personalizados'),
            const Text(
              'La aplicación muestra anuncios proporcionados por servicios como Google AdMob. Puedes gestionar tus preferencias de anuncios personalizados desde la configuración de tu dispositivo.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '6. Protección y Uso de Datos por Menores de Edad'),
            const Text(
              'La aplicación es para mayores de 14 años. Si eres menor de 18, debes tener permiso de tus tutores. Para proteger a los usuarios jóvenes, implementamos filtros de visibilidad y contacto para que menores solo interactúen con otros menores.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '7. Veracidad de los Datos'),
            const Text(
              'El usuario es el único responsable de que la información proporcionada sea real, exacta y actualizada.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '8. Transferencia y Almacenamiento de Datos'),
            const Text(
              'Tus datos pueden ser almacenados en servidores seguros de proveedores como Firebase, Google Cloud o AWS, y ser procesados por terceros como OpenAI para las funciones de IA. Al usar servicios de EE. UU., tus datos pueden estar sujetos a las leyes de dicho país, como la Ley CLOUD.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '9. Conservación de tus Datos'),
            const Text(
              'Conservaremos tu información mientras mantengas una cuenta activa. Si la eliminas, tus datos serán eliminados o anonimizados en un plazo de 30 a 90 días, salvo que necesitemos conservarlos por obligaciones legales.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '10. Seguridad de la Información'),
            const Text(
              'Implementamos medidas de seguridad razonables, pero ningún sistema es 100% seguro.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '11. Derechos del Usuario'),
            const Text(
              'De acuerdo con la Ley Orgánica de Protección de Datos Personales del Ecuador, tienes derecho a acceder, rectificar, eliminar, oponerte al tratamiento y revocar el consentimiento sobre tus datos. Puedes ejercerlos contactándonos a traincoachcontact@gmail.com.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '12. Cambios en esta Política'),
            const Text(
              'Nos reservamos el derecho de modificar esta Política de Privacidad. Se te notificará de cualquier cambio material.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '13. Legislación Aplicable'),
            const Text(
              'Esta Política de Privacidad se rige por las leyes de la República del Ecuador. Cualquier disputa será resuelta por los tribunales competentes en Ecuador.',
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
