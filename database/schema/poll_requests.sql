-- Table pour les demandes de questions soumises par les utilisateurs
CREATE TABLE IF NOT EXISTS poll_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    question TEXT NOT NULL CHECK (length(question) >= 10 AND length(question) <= 200),
    options JSONB NOT NULL CHECK (jsonb_array_length(options) >= 2 AND jsonb_array_length(options) <= 6),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id),
    rejection_reason TEXT,
    
    -- Contraintes supplémentaires
    CONSTRAINT valid_options CHECK (
        jsonb_typeof(options) = 'array' AND
        jsonb_array_length(options) >= 2 AND
        jsonb_array_length(options) <= 6
    ),
    CONSTRAINT valid_reviewed_at CHECK (
        (status = 'pending' AND reviewed_at IS NULL) OR
        (status IN ('approved', 'rejected') AND reviewed_at IS NOT NULL AND reviewed_by IS NOT NULL)
    ),
    CONSTRAINT valid_rejection_reason CHECK (
        (status = 'rejected' AND rejection_reason IS NOT NULL) OR
        (status != 'rejected')
    )
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_poll_requests_user_id ON poll_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_poll_requests_status ON poll_requests(status);
CREATE INDEX IF NOT EXISTS idx_poll_requests_requested_at ON poll_requests(requested_at);

-- RLS (Row Level Security)
ALTER TABLE poll_requests ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de voir leurs propres demandes
CREATE POLICY "Users can view their own poll requests" ON poll_requests
    FOR SELECT USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de créer leurs propres demandes
CREATE POLICY "Users can create their own poll requests" ON poll_requests
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Politique pour permettre aux admins de voir toutes les demandes
CREATE POLICY "Admins can view all poll requests" ON poll_requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Politique pour permettre aux admins de modifier les demandes
CREATE POLICY "Admins can update poll requests" ON poll_requests
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Fonction pour valider les options JSON
CREATE OR REPLACE FUNCTION validate_poll_request_options(options JSONB)
RETURNS BOOLEAN AS $$
BEGIN
    -- Vérifier que c'est un tableau
    IF jsonb_typeof(options) != 'array' THEN
        RETURN FALSE;
    END IF;
    
    -- Vérifier la longueur
    IF jsonb_array_length(options) < 2 OR jsonb_array_length(options) > 6 THEN
        RETURN FALSE;
    END IF;
    
    -- Vérifier que tous les éléments sont des chaînes non vides
    FOR i IN 0..jsonb_array_length(options)-1 LOOP
        IF jsonb_typeof(options->i) != 'string' OR 
           length((options->i)::text) < 1 THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour valider les options avant insertion/mise à jour
CREATE OR REPLACE FUNCTION validate_poll_request_options_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT validate_poll_request_options(NEW.options) THEN
        RAISE EXCEPTION 'Invalid poll request options';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_poll_request_options_trigger
    BEFORE INSERT OR UPDATE ON poll_requests
    FOR EACH ROW
    EXECUTE FUNCTION validate_poll_request_options_trigger(); 