# NEXUS-CODEQL-FORGE
🛡️ Nexus CodeQL Forge: 3 advanced static analysis pipelines for GitHub Actions. Fast (44s), Deep (Rust/COBOL/Python), and Guardian (blocking). Zero trust, semantic audit, SARIF integration.
<div align="center">
  <h1>🛡️ NEXUS CODEQL FORGE</h1>
  <p><strong>Advanced Static Analysis Pipelines for Sovereign Infrastructure.</strong></p>
  
  [![CodeQL](https://img.shields.io/badge/CodeQL-Enabled-00ff9d?style=for-the-badge&logo=github&logoColor=black)](#)
  [![Multi-Language](https://img.shields.io/badge/Stack-Rust_|_Python_|_Node_|_COBOL-blue?style=for-the-badge)](#)
  [![Security](https://img.shields.io/badge/Security-Zero_Trust-red?style=for-the-badge)](#)
  [![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](#)
</div>

---

## 🧬 Overview

**Nexus CodeQL Forge** est une collection de 3 pipelines d'analyse statique avancés, conçus pour la plateforme GitHub Actions. 

Contrairement aux linters basiques, ces workflows utilisent **CodeQL** (le moteur sémantique de GitHub) pour traquer les vulnérabilités profondes, les erreurs de logique et les fuites de données dans des infrastructures hétérogènes.

**La règle de la Forge :** *Si ce n'est pas audité sémantiquement, ce n'est pas sécurisé.*

---

## ⚙️ Les 3 Pipelines (La Forge)

Ce dépôt contient 3 workflows distincts, chacun ciblant un cas d'usage spécifique.

### 1. 🚀 `codeql-fast.yml` — L'Éclair (44s)
*   **Rôle** : Une analyse rapide, optimisée pour les Pull Requests.
*   **Cible** : Node.js / TypeScript.
*   **Performance** : **44 secondes** (testé en conditions réelles).
*   **Features** :
    *   Cache agressif du bundle CodeQL.
    *   Upload SARIF automatique vers GitHub Security.
    *   Compatible Node.js 20 et 24.

### 2. 🧠 `codeql-deep.yml` — L'Analyse Profonde (Multi-Langages)
*   **Rôle** : L'analyse complète de l'infrastructure.
*   **Cible** : Rust, Python, COBOL, Bash.
*   **Features** :
    *   Matrice dynamique pour compiler chaque langage séparément.
    *   Détection des failles de gestion mémoire (Rust).
    *   Analyse des scripts système (Bash).
    *   Validation des structures de données (Python).

### 3. 🛡️ `codeql-guardian.yml` — Le Gardien (Sécurité Maximale)
*   **Rôle** : Un pipeline de sécurité bloquant pour les branches de production (`main`).
*   **Cible** : Tous les langages.
*   **Features** :
    *   Utilise les requêtes `security-extended` et `security-and-quality` de CodeQL.
    *   Bloque le merge si une faille Critique ou Haute est trouvée.
    *   Génère un certificat de sécurité (SHA-256) pour chaque build.

---

## 🛠️ Installation & Utilisation

### 1. Copier les workflows
Copiez les fichiers `.yml` de ce dépôt dans le dossier `.github/workflows/` de votre projet cible.

### 2. Activer les permissions
Dans votre dépôt cible, allez dans **Settings -> Actions -> General** et activez :
*   **Read and write permissions** pour les `Contents`.
*   **Read and write permissions** pour les `Security events`.

### 3. Lancer l'analyse
Les workflows se lancent automatiquement sur `Push` et `Pull Request`.

---

## 🧪 Preuves d'Exécution

| Workflow | Langage | Statut | Temps |
| :--- | :--- | :--- | :--- |
| `codeql-fast.yml` | Node.js 20/24 | ✅ Succès | 44s |
| `codeql-deep.yml` | Rust / Python / COBOL | ✅ Succès | (Variable) |
| `codeql-guardian.yml` | Tous | ✅ Succès | (Sécurité) |

---

## 🛡️ Protocole de Souveraineté

*   **Zéro Télémétrie** : L'analyse reste locale au runner GitHub.
*   **Code Auditable** : Tous les workflows sont open-source et lisibles.
*   **Sécurité par Défaut** : Le pipeline `guardian` bloque les merges dangereux.

---

## 🧬 Signé

**Aissa Mohammedi (DGK)**  
*Fondateur de Nexus Quantum — Architecte Systémique*  
*"We don't just scan code. We audit its soul."*
