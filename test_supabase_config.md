# Guide de résolution du problème d'email invalide

## Problème identifié
L'erreur `email_address_invalid` indique que Supabase rejette l'email `test@example.com` comme invalide.

## Solutions possibles

### 1. Vérifier la configuration Supabase
Dans votre dashboard Supabase :
- Allez dans **Authentication** > **Settings**
- Vérifiez les **Email Templates** et **SMTP Settings**
- Assurez-vous qu'il n'y a pas de restrictions sur les domaines d'email

### 2. Emails de test recommandés
Essayez avec ces emails qui sont généralement acceptés :
- `user@gmail.com`
- `test@yahoo.com`
- `demo@hotmail.com`
- `admin@outlook.com`

### 3. Vérifier les RLS policies
Assurez-vous que les policies RLS permettent l'insertion dans la table `users` :
```sql
-- Policy pour permettre l'insertion d'un nouvel utilisateur
CREATE POLICY "Users can insert their own data" ON users
FOR INSERT WITH CHECK (auth.uid() = id);
```

### 4. Test de configuration
Essayez d'abord avec un email Gmail valide comme `user@gmail.com` pour voir si le problème est spécifique à certains domaines.

### 5. Vérifier les logs Supabase
Dans votre dashboard Supabase :
- Allez dans **Logs** > **Auth**
- Vérifiez les erreurs d'authentification récentes

## Test recommandé
Utilisez `user@gmail.com` avec le nom d'utilisateur `testuser` et mot de passe `123456`. 