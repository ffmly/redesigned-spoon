# Fiche de validation du sujet

**Groupe :** Groupe n° A_COMPLETER

**Membres :**

1. A_COMPLETER
2. A_COMPLETER
3. A_COMPLETER
4. A_COMPLETER
5. A_COMPLETER

**Sujet envisage :** Quels genes concentrent le plus de variants distincts
classes « Pathogenic » ou « Likely pathogenic » dans ClinVar, associes
specifiquement a la cardiomyopathie hypertrophique ?

**Maladie etudiee :** Cardiomyopathie hypertrophique.

**Jeu de donnees :** `variant_summary.txt.gz`, export tabule public de NCBI
ClinVar.

**Lien :**
https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz

**Taille estimee :** 456 505 123 octets, soit environ 456,5 Mo au format
compresse `.gz`.

**Date de verification :** 23/10/2026.

**Methode prevue :** conserver l'assemblage GRCh38 et l'origine germinale,
identifier dans `PhenotypeList` un libelle exact `Hypertrophic cardiomyopathy`
avec un numero de sous-type facultatif, puis retenir les classifications
`Pathogenic`, `Likely pathogenic` et `Pathogenic/Likely pathogenic`. Chaque
`VariationID` sera comptee une seule fois. Les lignes sans gene et les
classifications non retenues seront documentees separement.
