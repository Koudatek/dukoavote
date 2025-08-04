-- Table des sondages
CREATE TABLE IF NOT EXISTS public.polls (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_closed BOOLEAN NOT NULL DEFAULT false,
  created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  closed_reason TEXT NULL,
  CONSTRAINT polls_pkey PRIMARY KEY (id)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_polls_created_by ON public.polls(created_by);
CREATE INDEX IF NOT EXISTS idx_polls_is_closed ON public.polls(is_closed);
CREATE INDEX IF NOT EXISTS idx_polls_start_date ON public.polls(start_date);
CREATE INDEX IF NOT EXISTS idx_polls_end_date ON public.polls(end_date);

-- RLS (Row Level Security)
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;

-- Supprimer les politiques existantes si elles existent
DROP POLICY IF EXISTS "Users can view all polls" ON public.polls;
DROP POLICY IF EXISTS "Users can create polls" ON public.polls;
DROP POLICY IF EXISTS "Users can update own polls" ON public.polls;
DROP POLICY IF EXISTS "Admins can manage all polls" ON public.polls;

-- Politique pour que tous les utilisateurs puissent voir les sondages
CREATE POLICY "Users can view all polls" ON public.polls
  FOR SELECT USING (true);

-- Politique pour que les utilisateurs connectés puissent créer des sondages
CREATE POLICY "Users can create polls" ON public.polls
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Politique pour que les créateurs puissent modifier leurs sondages
CREATE POLICY "Users can update own polls" ON public.polls
  FOR UPDATE USING (auth.uid() = created_by);

-- Politique pour que les admins puissent gérer tous les sondages
CREATE POLICY "Admins can manage all polls" ON public.polls
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_polls_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS update_polls_updated_at ON public.polls;

-- Trigger pour mettre à jour updated_at automatiquement
CREATE TRIGGER update_polls_updated_at
  BEFORE UPDATE ON public.polls
  FOR EACH ROW EXECUTE FUNCTION update_polls_updated_at_column(); 