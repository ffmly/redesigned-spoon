# Guide d'integration de l'equipe

Ce document fixe les interfaces attendues par `run.sh`. Chaque membre travaille
dans ses fichiers, puis transmet son livrable a l'etudiant 1 pour integration.

## Etudiant 1 - orchestration

Fichiers geres :

- `run.sh`
- `scripts/filter_hcm_variants.sh`
- structure de `config/dataset.env`
- arborescence, fiche du sujet, integration et test final

Le filtre Shell selectionne GRCh38, l'origine germinale et un element exact de
`PhenotypeList` nomme `Hypertrophic cardiomyopathy`, avec un numero facultatif.
Il n'accepte pas une simple occurrence du mot dans une autre maladie.

## Etudiant 2 - source des donnees

Fichiers a completer :

- `SOURCES.md`
- `config/dataset.env`

Travail demande : verifier l'URL officielle, relever la taille et la date,
calculer SHA-256, remplacer `TODO_ETUDIANT_2` et documenter les conditions de
reutilisation. Le fichier attendu est `variant_summary.txt.gz`.

## Etudiant 3 - analyse Python

Fichiers a creer :

- `scripts/analyze_genes.py`
- un test automatique dans `tests/`

Interface obligatoire :

```text
python3 scripts/analyze_genes.py \
  --variants data/processed/hcm_variants_grch38.tsv \
  --output-dir results \
  --top 15
```

Regles d'analyse :

1. accepter les classifications normalisees `Pathogenic`,
   `Likely pathogenic` et `Pathogenic/Likely pathogenic` ;
2. exclure les autres valeurs, notamment les classifications conflictuelles ;
3. normaliser `GeneSymbol` et exclure les genes manquants ou ambigus ;
4. compter chaque `VariationID` une seule fois ;
5. classer les genes par nombre decroissant de `VariationID` distincts ;
6. documenter dans le resume que `ClinicalSignificance` est une classification
   agregee au niveau du variant.

Sorties obligatoires :

- `results/gene_ranking.csv`
- `results/variants_hcm.csv`
- `results/excluded_variants.csv`
- `results/summary.json`
- `results/top_genes.png`

## Etudiant 4 - environnement et administration

Creer `requirements.txt`, un exemple dans `cron/`, verifier les journaux,
les permissions, les scripts executables et l'installation sur une autre
machine.

## Etudiant 5 - documentation et validation utilisateur

Creer `README.md`, le rapport et le support de presentation. Tester le projet
en suivant uniquement le README et signaler toute etape implicite.

## Integration finale

L'etudiant 1 execute :

```bash
./run.sh -h
./run.sh -n
./run.sh
python -m unittest discover -s tests -v
```

Il verifie les cinq sorties, le journal, l'archive datee et le rapport avant de
fixer le commit final dans `LIEN_GIT.txt`.
