CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (
    id,
    created_at,
    username,
    gender,
    birth_date,
    age,
    country,
    role
  )
  VALUES (
    NEW.id,
    NOW(),
    COALESCE(NEW.raw_user_meta_data ->> 'username', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'gender', ''),
    CASE 
      WHEN NEW.raw_user_meta_data ->> 'birth_date' IS NOT NULL 
      THEN (NEW.raw_user_meta_data ->> 'birth_date')::date
      ELSE NULL
    END,
    CASE 
      WHEN NEW.raw_user_meta_data ->> 'age' IS NOT NULL 
      THEN (NEW.raw_user_meta_data ->> 'age')::integer
      ELSE NULL
    END,
    COALESCE(NEW.raw_user_meta_data ->> 'country', ''),
    'user' -- Rôle par défaut pour les nouveaux utilisateurs
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public; 