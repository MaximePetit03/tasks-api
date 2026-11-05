#!/usr/bin/env bash
# Met à jour le tag de l'image (et APP_VERSION) dans un manifeste Kubernetes.
# Usage : bash scripts/set-image-tag.sh k8s/deployment.yaml 0.2.0
set -euo pipefail

file="${1:?usage: set-image-tag.sh <fichier> <version>}"
version="${2:?usage: set-image-tag.sh <fichier> <version>}"

# Nettoie le 'v' au début de la version si présent (ex: v0.2.0 -> 0.2.0)
version="${version#v}"

if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version invalide : '$version' (attendu : 1.2.3)" >&2
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "Fichier introuvable : $file" >&2
  exit 1
fi

# Remplacement insensible à la casse pour le nom de l'image (ghcr.io/.../tasks-api:tag)
sed -i -E "s|(image: ghcr\.io/[^/]+/[^:]+:).*|\1${version}|I" "$file"

# Remplacement de la variable d'environnement APP_VERSION si présente
sed -i -E "/name: APP_VERSION/{n;s|value: .*|value: \"${version}\"|;}" "$file"

echo "Image et APP_VERSION mis à jour avec la version : ${version}"