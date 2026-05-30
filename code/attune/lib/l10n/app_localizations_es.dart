// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get loginFailed =>
      'Error al iniciar sesión, verifica tu correo y contraseña';

  @override
  String get signUp => 'Registrarse';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get noAccount => '¿No tienes una cuenta? Regístrate aquí';

  @override
  String get signupFailed => 'No se pudo crear la cuenta, inténtalo de nuevo';

  @override
  String get topArtists => 'Artistas favoritos';

  @override
  String get topTracks => 'Canciones favoritas';

  @override
  String get topGenres => 'Géneros favoritos';

  @override
  String get sendFriendRequest => 'Enviar solicitud de amistad';

  @override
  String get friends => 'Amigos';

  @override
  String get friendRequests => 'Solicitudes de amistad';

  @override
  String get save => 'Guardar';

  @override
  String get noFriendsYet => 'Aún no tienes amigos';

  @override
  String get noFriendRequests => 'No hay solicitudes de amistad';

  @override
  String get profilePictureUrl => 'URL de foto de perfil';

  @override
  String get errorLoadingUsers => 'Error al cargar usuarios cercanos: ';

  @override
  String get nearby => 'Cerca: ';

  @override
  String get locationDisabled =>
      'Activa la ubicación para ver usuarios cercanos';

  @override
  String get allAlone => 'No hay usuarios en un radio de 20 millas';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get requestSent => 'Solicitud enviada';

  @override
  String get home => 'Inicio';

  @override
  String get profile => 'Perfil';

  @override
  String get connectSpotify => 'Conectar Spotify';

  @override
  String get somethingWentWrong => 'Algo salió mal. Inténtalo de nuevo.';
}
