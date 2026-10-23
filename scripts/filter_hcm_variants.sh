#!/usr/bin/env bash

set -Eeuo pipefail
export LC_ALL=C

usage() {
    printf 'Usage: %s variant_summary.txt.gz output.tsv\n' "$(basename "$0")"
}

[[ $# -eq 2 ]] || { usage >&2; exit 2; }

input_file="$1"
output_file="$2"

[[ -f "$input_file" ]] || { printf 'Fichier introuvable: %s\n' "$input_file" >&2; exit 1; }
[[ "$input_file" == *.gz ]] || { printf 'Le fichier source doit etre au format .gz\n' >&2; exit 1; }

mkdir -p "$(dirname "$output_file")"
body_file="$(mktemp "${TMPDIR:-/tmp}/hcm-variants.XXXXXX")"

cleanup() {
    rm -f -- "$body_file"
}
trap cleanup EXIT INT TERM HUP

# Regle reproductible pour "specifiquement" : un element de PhenotypeList
# doit etre exactement "Hypertrophic cardiomyopathy", avec un numero de
# sous-type facultatif. Une simple sous-chaine (par exemple une maladie MTO1)
# ne suffit pas.
gzip -cd "$input_file" \
    | awk -F '\t' -v OFS='\t' '
        $1 == "#AlleleID" {
            for (i = 1; i <= NF; i++) index_of[$i] = i

            required[1] = "#AlleleID"
            required[2] = "VariationID"
            required[3] = "GeneID"
            required[4] = "GeneSymbol"
            required[5] = "ClinicalSignificance"
            required[6] = "PhenotypeList"
            required[7] = "OriginSimple"
            required[8] = "Assembly"
            required[9] = "ReviewStatus"
            required[10] = "NumberSubmitters"
            required[11] = "RCVaccession"

            for (j = 1; j <= 11; j++) {
                if (!(required[j] in index_of)) {
                    print "Colonne manquante: " required[j] > "/dev/stderr"
                    exit 3
                }
            }
            header_seen = 1
            next
        }

        header_seen && NF > 1 {
            if ($(index_of["Assembly"]) != "GRCh38") next
            if (tolower($(index_of["OriginSimple"])) != "germline") next

            phenotype = $(index_of["PhenotypeList"])
            count = split(phenotype, labels, /\|/)
            hcm = 0
            for (k = 1; k <= count; k++) {
                label = tolower(labels[k])
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", label)
                if (label ~ /^hypertrophic cardiomyopathy( [0-9]+)?$/) {
                    hcm = 1
                    break
                }
            }
            if (!hcm) next

            print \
                $(index_of["VariationID"]), \
                $(index_of["GeneID"]), \
                $(index_of["GeneSymbol"]), \
                $(index_of["ClinicalSignificance"]), \
                phenotype, \
                $(index_of["OriginSimple"]), \
                $(index_of["Assembly"]), \
                $(index_of["ReviewStatus"]), \
                $(index_of["NumberSubmitters"]), \
                $(index_of["RCVaccession"]), \
                $(index_of["#AlleleID"])
        }

        END {
            if (!header_seen) {
                print "En-tete ClinVar introuvable" > "/dev/stderr"
                exit 4
            }
        }
    ' \
    | sort -t $'\t' -k1,1n -k11,11n \
    | uniq > "$body_file"

printf '%s\n' $'VariationID\tGeneID\tGeneSymbol\tClinicalSignificance\tPhenotypeList\tOriginSimple\tAssembly\tReviewStatus\tNumberSubmitters\tRCVaccession\tAlleleID' > "$output_file"
cat "$body_file" >> "$output_file"

row_count="$(awk 'END { print NR - 1 }' "$output_file")"
printf 'Lignes HCM strictes conservees: %s\n' "$row_count"
