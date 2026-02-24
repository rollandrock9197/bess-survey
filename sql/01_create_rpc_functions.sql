-- ============================================
-- ETAPE 1 : Creer les fonctions RPC dans Supabase SQL Editor
-- Executer CE SCRIPT EN PREMIER, AVANT de toucher aux policies RLS
-- ============================================

-- 1a. Fonction INSERT (remplace POST /rest/v1/leads)
CREATE OR REPLACE FUNCTION insert_lead(
  p_nom TEXT, p_email TEXT, p_telephone TEXT, p_entreprise TEXT
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE new_id UUID;
BEGIN
  INSERT INTO leads (nom, email, telephone, entreprise)
  VALUES (p_nom, p_email, p_telephone, p_entreprise)
  RETURNING id INTO new_id;
  RETURN new_id;
END; $$;

GRANT EXECUTE ON FUNCTION insert_lead(TEXT, TEXT, TEXT, TEXT) TO anon;

-- 1b. Fonction UPDATE (remplace PATCH /rest/v1/leads?id=eq.xxx)
-- Gardes : refuse si lead deja complete OU cree depuis plus de 2h
CREATE OR REPLACE FUNCTION update_lead_results(
  p_lead_id UUID, p_tarif TEXT, p_puissance NUMERIC,
  p_option_utilisation TEXT, p_profil_consommation NUMERIC,
  p_economies_annuelles INTEGER, p_puissance_batterie INTEGER,
  p_capacite_batterie INTEGER, p_cout_batterie INTEGER,
  p_retour_investissement NUMERIC
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE leads SET
    tarif = p_tarif, puissance = p_puissance,
    option_utilisation = p_option_utilisation,
    profil_consommation = p_profil_consommation,
    economies_annuelles = p_economies_annuelles,
    puissance_batterie = p_puissance_batterie,
    capacite_batterie = p_capacite_batterie,
    cout_batterie = p_cout_batterie,
    retour_investissement = p_retour_investissement,
    survey_completed = TRUE
  WHERE id = p_lead_id
    AND (survey_completed IS NULL OR survey_completed = FALSE)
    AND created_at > NOW() - INTERVAL '2 hours';
END; $$;

GRANT EXECUTE ON FUNCTION update_lead_results(UUID, TEXT, NUMERIC, TEXT, NUMERIC, INTEGER, INTEGER, INTEGER, INTEGER, NUMERIC) TO anon;
