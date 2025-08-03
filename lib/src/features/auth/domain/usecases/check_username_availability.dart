
import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case pour vérifier la disponibilité d'un nom d'utilisateur
class CheckUsernameAvailability {
  final AuthRepository repository;

  CheckUsernameAvailability(this.repository);

  /// Vérifie si un nom d'utilisateur est disponible
  /// 
  /// [username] - Le nom d'utilisateur à vérifier
  /// 
  /// Retourne [Either<Failure, bool>] :
  /// - [Right(true)] si le nom d'utilisateur est disponible
  /// - [Right(false)] si le nom d'utilisateur est déjà pris
  /// - [Left(Failure)] en cas d'erreur
  Future<Either<Failure, bool>> call(String username) async {
    if (username.isEmpty) {
      return right(false);
    }
    
    if (username.length < 3) {
      return right(false);
    }
    
    // Vérifier le format (lettres, chiffres, underscore, tiret)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(username)) {
      return right(false);
    }
    
    return await repository.checkUsernameAvailability(username);
  }
} 