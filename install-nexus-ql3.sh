#!/usr/bin/env bash
# ============================================================
#  install-nexus-ql3.sh — NEXUS QL v3
#  Installe le langage de requête de sécurité, l'ouvre dans
#  Mozilla Firefox et installe le raccourci bureau.
#
#  Utilisation (depuis n'importe où) :
#    bash install-nexus-ql3.sh
#    bash install-nexus-ql3.sh chemin/vers/nexus-ql-3.0.tar.gz
#    bash install-nexus-ql3.sh --onglet   → Firefox en onglet
#    bash install-nexus-ql3.sh --kiosk    → Firefox plein écran
#
#  Il trouve tout seul l'archive : dossier courant, Téléchargements,
#  Bureau, ~/snap/firefox/…/Downloads (Firefox snap d'Ubuntu) et,
#  en dernier recours, toute la maison (recherche approfondie).
# ============================================================
set -u
if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi

STEP=0; TOTAL=6
step() { STEP=$((STEP+1)); echo; echo "── [${STEP}/${TOTAL}] $1 ─────────────────────────"; }
ok()   { echo "  [✓] $1"; }
warn() { echo "  [!] $1"; }
fail() { echo "  [✗] $1"; echo; echo "Installation abandonnée."; echo; exit 1; }

ARG=""; MODE="fenetre"
for a in "$@"; do
  case "$a" in
    --onglet|--mozilla) MODE="onglet"  ;;
    --kiosk)            MODE="kiosk"   ;;
    --fenetre)          MODE="fenetre" ;;
    -h|--help)          sed -n 's/^#  //p' "$0"; exit 0 ;;
    *)  if [ -z "$ARG" ]; then ARG="$a"; else warn "argument ignoré : $a"; fi ;;
  esac
done

TARGET="$HOME/NEXUS-QL3"
ARCHIVE_NAME="nexus-ql-3.0.tar.gz"

valid_tar() {
  gzip -t "$1" 2>/dev/null && tar -tzf "$1" 2>/dev/null | grep -q "nexus-ql\.sh$"
}

# ---------- 1) retrouver l'archive ----------
step "recherche de l'archive $ARCHIVE_NAME"
ARCHIVE=""
if [ -n "$ARG" ]; then
  [ -f "$ARG" ] && ARCHIVE="$ARG" || fail "fichier introuvable : $ARG"
fi
if [ -z "$ARCHIVE" ]; then
  # les endroits où elle atterrit naturellement (Firefox snap inclus)
  CANDIDATES=(
    "$PWD"
    "$HOME/Téléchargements" "$HOME/Downloads" "$HOME/Bureau" "$HOME/Desktop"
    "$HOME/snap/firefox/common/Downloads" "$HOME/snap/firefox/common/Téléchargements"
    "$HOME/.var/app/org.mozilla.firefox/config/caja"
  )
  for d in "${CANDIDATES[@]}"; do
    [ -f "$d/$ARCHIVE_NAME" ] && valid_tar "$d/$ARCHIVE_NAME" && { ARCHIVE="$d/$ARCHIVE_NAME"; break; }
  done
fi
if [ -z "$ARCHIVE" ]; then
  warn "pas dans les dossiers habituels — recherche approfondie dans la maison…"
  HIT="$(find "$HOME" -maxdepth 5 -name "$ARCHIVE_NAME" -not -path '*/nexus-tombes/*' -not -path '*/nexus-quarantaine/*' 2>/dev/null | head -1)"
  [ -n "$HIT" ] && valid_tar "$HIT" && ARCHIVE="$HIT"
fi
[ -n "$ARCHIVE" ] || fail "l'archive $ARCHIVE_NAME est introuvable.
    Place-la dans ton dossier Téléchargements (ou à côté de ce script)
    et relance. Rappel : ne JAMAIS coller son contenu dans le terminal —
    un fichier se sauvegarde, il ne se colle pas."
ok "archive trouvée : $ARCHIVE"

# ---------- 2) pré-requis ----------
step "vérification des pré-requis"
command -v python3 >/dev/null 2>&1 || fail "python3 est requis (sudo apt install python3)"
PV="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
ok "python3 $PV"
command -v curl >/dev/null 2>&1 && ok "curl présent" || warn "curl absent — le serveur marchera quand même"

# ---------- 3) installation ----------
step "installation dans $TARGET"
if [ -d "$TARGET" ] && [ -f "$TARGET/nexus-ql.sh" ]; then
  warn "une installation NEXUS QL v3 existe déjà — elle est sauvegardée puis remplacée"
  mv "$TARGET" "$TARGET.avant-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$TARGET"
tar -xzf "$ARCHIVE" -C "$TARGET" || fail "extraction impossible (archive corrompue ?)"
# si l'archive emballe un dossier racine, on le remonte d'un étage
if [ ! -f "$TARGET/nexus-ql.sh" ]; then
  INNER="$(find "$TARGET" -maxdepth 2 -name nexus-ql.sh | head -1)"
  [ -n "$INNER" ] && { INNER_DIR="$(dirname "$INNER")"; mv "$INNER_DIR"/* "$TARGET"/ 2>/dev/null; rmdir "$INNER_DIR" 2>/dev/null; }
fi
[ -f "$TARGET/nexus-ql.sh" ] || fail "l'archive ne contient pas nexus-ql.sh à la racine"
chmod +x "$TARGET/nexus-ql.sh" "$TARGET"/*.py 2>/dev/null
ok "installé : $TARGET ($(du -sh "$TARGET" | cut -f1))"

# ---------- 4) test de santé (réel, avant d'annoncer la victoire) ----------
step "test de santé — le moteur répond-il ?"
TEST_OUT="$(python3 "$TARGET/cli.py" check "$TARGET/rules/builtin.nql" 2>&1)"
echo "$TEST_OUT" | grep -q "règle" || fail "le moteur ne charge pas les règles :
$TEST_OUT"
ok "$(echo "$TEST_OUT" | head -1)"
DEMO_OUT="$(python3 "$TARGET/cli.py" scan "$TARGET/workspace/demo.py" 2>&1)"
echo "$DEMO_OUT" | grep -q "py-shell" || fail "l'analyse de démonstration ne trouve pas la vulnérabilité attendue"
ok "analyse de démonstration : vulnérabilité détectée avec son chemin source→sink"

# ---------- 5) serveur + Firefox ----------
step "serveur local + Mozilla Firefox"
( bash "$TARGET/nexus-ql.sh" serve ) || warn "le serveur n'a pas démarré — lance-le plus tard : bash ~/NEXUS-QL3/nexus-ql.sh serve"
URL="http://localhost:3620"
FF=""
for B in firefox firefox-esr firefox-developer-edition; do
  command -v "$B" >/dev/null 2>&1 && FF="$B" && break
done
if [ -n "$FF" ]; then
  case "$MODE" in
    onglet) nohup "$FF" --new-tab "$URL" >/dev/null 2>&1 & disown; ok "Mozilla Firefox (onglet) → $URL" ;;
    kiosk)  nohup "$FF" --kiosk "$URL" >/dev/null 2>&1 & disown; ok "Mozilla Firefox plein écran → $URL (Alt+F4 pour sortir)" ;;
    *)      nohup "$FF" --new-window "$URL" >/dev/null 2>&1 & disown; ok "Mozilla Firefox (fenêtre dédiée) → $URL" ;;
  esac
elif command -v xdg-open >/dev/null 2>&1; then
  warn "Firefox introuvable — navigateur par défaut utilisé → $URL"
  nohup xdg-open "$URL" >/dev/null 2>&1 & disown
else
  warn "ouvre manuellement : $URL"
fi

# ---------- 6) raccourci bureau ----------
step "raccourci bureau (sans sudo)"
bash "$TARGET/nexus-ql.sh" install >/dev/null 2>&1 && ok "menu applications → NEXUS QL v3" || warn "raccourci non installé (pas grave)"

echo
echo -e "\033[1;35m  ╔══════════════════════════════════════════════════════╗
  ║   N E X U S   Q L   v 3   —   I N S T A L L É         ║
  ║   le langage de requête de sécurité · sans cloud       ║
  ╚══════════════════════════════════════════════════════╝\033[0m"
echo
echo "  l'éditeur    : $URL   (Firefox)"
echo "  le dossier   : $TARGET"
echo
echo "  à essayer tout de suite :"
echo "    bash ~/NEXUS-QL3/nexus-ql.sh demo"
echo "    bash ~/NEXUS-QL3/nexus-ql.sh scan ~/tes-projets"
echo "    bash ~/NEXUS-QL3/nexus-ql.sh explain py-eval"
echo
echo "  écrire TA première règle : rules/builtin.nql est un fichier NQL —"
echo "  copie-le, modifie-le, puis : bash ~/NEXUS-QL3/nexus-ql.sh scan cible --nql ta-regle.nql"
echo
