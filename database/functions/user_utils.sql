-- Fonction pour obtenir le profil utilisateur complet
CREATE OR REPLACE FUNCTION get_user_profile(user_id UUID DEFAULT auth.uid())
RETURNS TABLE (
  id UUID,
  username TEXT,
  gender TEXT,
  birth_date DATE,
  age INTEGER,
  country TEXT,
  role TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.username,
    u.gender,
    u.birth_date,
    u.age,
    u.country,
    u.role,
    u.created_at
  FROM public.users u
  WHERE u.id = user_id;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

-- Fonction pour mettre à jour le profil utilisateur
CREATE OR REPLACE FUNCTION update_user_profile(
  p_username TEXT DEFAULT NULL,
  p_gender TEXT DEFAULT NULL,
  p_birth_date DATE DEFAULT NULL,
  p_country TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.users
  SET 
    username = COALESCE(p_username, username),
    gender = COALESCE(p_gender, gender),
    birth_date = COALESCE(p_birth_date, birth_date),
    age = CASE 
      WHEN p_birth_date IS NOT NULL 
      THEN EXTRACT(YEAR FROM AGE(p_birth_date))
      ELSE age
    END,
    country = COALESCE(p_country, country)
  WHERE id = auth.uid();
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

-- Fonction pour vérifier si un username est disponible
CREATE OR REPLACE FUNCTION is_username_available(p_username TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM public.users 
    WHERE username = p_username
  );
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

-- Fonction pour obtenir les statistiques des utilisateurs (admin seulement)
CREATE OR REPLACE FUNCTION get_user_statistics()
RETURNS TABLE (
  total_users BIGINT,
  users_by_country JSON,
  age_distribution JSON,
  gender_distribution JSON
) AS $$
BEGIN
  -- Vérifier que l'utilisateur est admin
  IF NOT EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin role required';
  END IF;

  RETURN QUERY
  SELECT 
    COUNT(*)::BIGINT as total_users,
    json_object_agg(country, count) FILTER (WHERE country IS NOT NULL) as users_by_country,
    json_object_agg(age_group, count) as age_distribution,
    json_object_agg(gender, count) FILTER (WHERE gender IS NOT NULL) as gender_distribution
  FROM (
    SELECT 
      country,
      gender,
      CASE 
        WHEN age < 18 THEN 'under_18'
        WHEN age BETWEEN 18 AND 25 THEN '18_25'
        WHEN age BETWEEN 26 AND 35 THEN '26_35'
        WHEN age BETWEEN 36 AND 50 THEN '36_50'
        WHEN age > 50 THEN 'over_50'
        ELSE 'unknown'
      END as age_group,
      COUNT(*) as count
    FROM public.users
    GROUP BY country, gender, age_group
  ) stats;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public; 