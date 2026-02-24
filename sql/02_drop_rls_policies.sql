-- ============================================
-- ETAPE 6 : Supprimer les policies RLS
-- A EXECUTER SEULEMENT APRES avoir verifie que les RPC marchent !
-- ============================================

DROP POLICY IF EXISTS "Allow anonymous inserts" ON leads;
DROP POLICY IF EXISTS "Allow anonymous select" ON leads;
DROP POLICY IF EXISTS "Allow anonymous updates" ON leads;

-- S'assurer que RLS est bien active (les fonctions SECURITY DEFINER bypassent RLS)
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Verification : doit retourner 0 lignes
SELECT * FROM pg_policies WHERE tablename = 'leads';
