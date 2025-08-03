//data
export 'data/datasource/auth_remote_datasource.dart';

export 'data/models/user_model.dart';

export 'data/repository/auth_repository_impl.dart';

//domain
export 'domain/entities/user.dart';

export 'domain/repository/auth_repository.dart';

export 'domain/usecases/check_username_availability.dart';
export 'domain/usecases/get_current_user.dart';
export 'domain/usecases/sign_in_with_apple.dart';
export 'domain/usecases/sign_in_with_email.dart';
export 'domain/usecases/sign_in_with_google.dart';
export 'domain/usecases/sign_out.dart';
export 'domain/usecases/sign_up_with_email.dart';
export 'domain/usecases/upsert_user_profile.dart';


//presentation
export 'presentation/pages/login_page.dart'; 
export 'presentation/pages/signup_page.dart';

export 'presentation/providers/auth_provider.dart';
