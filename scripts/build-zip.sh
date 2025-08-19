#!/bin/bash

# Script para criar ZIP local do plugin Cloudflare WordPress
# Uso: ./scripts/build-zip.sh [versão] [incluir-dev]
# Exemplo: ./scripts/build-zip.sh v4.12.8
# Exemplo: ./scripts/build-zip.sh v4.12.8 dev (para incluir arquivos de desenvolvimento)

set -e

VERSION=${1:-"dev"}
INCLUDE_DEV=${2:-""}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="/tmp/cloudflare-build-$$"
PLUGIN_DIR="$BUILD_DIR/cloudflare"

echo "🔧 Iniciando build do plugin Cloudflare WordPress..."
echo "📦 Versão: $VERSION"

# Verificar se estamos no diretório correto
if [ ! -f "$PROJECT_DIR/cloudflare.php" ]; then
    echo "❌ Erro: Não foi possível encontrar cloudflare.php. Execute este script do diretório raiz do projeto."
    exit 1
fi

# Criar diretório temporário
echo "📁 Criando diretório temporário..."
mkdir -p "$PLUGIN_DIR"

# Instalar dependências do Composer (modo produção)
echo "📦 Instalando dependências do Composer..."
cd "$PROJECT_DIR"
composer install --no-dev --optimize-autoloader --no-progress --no-interaction

# Copiar arquivos
echo "📋 Copiando arquivos..."

# Lista de arquivos/diretórios sempre excluídos
EXCLUDE_ALWAYS=(
    ".git*"
    "node_modules"
    "phpcs.xml"
    "phpunit.xml" 
    "docker-compose.yaml"
    "Dockerfile.*"
    "scripts/"
    "xdebug/"
    ".github/"
)

# Lista adicional para versão de produção
EXCLUDE_PROD=(
    "*.md"
    "composer.json"
    "composer.lock"
    "src/Test/"
    "docs/"
    "CONTRIBUTING.md"
    "LICENSE.md"
    "README.md"
)

# Construir comando rsync
RSYNC_CMD="rsync -av --progress '$PROJECT_DIR/' '$PLUGIN_DIR/'"

# Adicionar exclusões básicas
for exclude in "${EXCLUDE_ALWAYS[@]}"; do
    RSYNC_CMD="$RSYNC_CMD --exclude='$exclude'"
done

# Adicionar exclusões de produção se não for build de desenvolvimento
if [ "$INCLUDE_DEV" != "dev" ]; then
    echo "🏗️  Build de produção (sem arquivos de desenvolvimento)"
    for exclude in "${EXCLUDE_PROD[@]}"; do
        RSYNC_CMD="$RSYNC_CMD --exclude='$exclude'"
    done
else
    echo "🔧 Build de desenvolvimento (com arquivos de desenvolvimento)"
fi

# Executar rsync
eval $RSYNC_CMD

# Corrigir problema dos polyfills do Symfony para PHP 8
echo "🔧 Corrigindo polyfills do Symfony..."
find "$PLUGIN_DIR/vendor/symfony/polyfill-intl-"* -name "bootstrap80.php" -exec sed -i 's/: string|false/ /g' {} \; 2>/dev/null || true

# Criar o ZIP
echo "📦 Criando arquivo ZIP..."
cd "$BUILD_DIR"
ZIP_NAME="cloudflare-wordpress-${VERSION}.zip"
zip -r "$ZIP_NAME" cloudflare/ > /dev/null

# Mover ZIP para o diretório do projeto
mv "$ZIP_NAME" "$PROJECT_DIR/"

# Limpeza
echo "🧹 Limpando arquivos temporários..."
rm -rf "$BUILD_DIR"

# Restaurar dependências de desenvolvimento
echo "🔄 Restaurando dependências de desenvolvimento..."
cd "$PROJECT_DIR"
composer install > /dev/null

echo "✅ Build concluído!"
echo "📁 Arquivo criado: $PROJECT_DIR/$ZIP_NAME"
echo "📊 Tamanho do arquivo:"
ls -lh "$PROJECT_DIR/$ZIP_NAME" | awk '{print $5, $9}'

# Mostrar conteúdo do ZIP
echo ""
echo "📋 Conteúdo do ZIP:"
unzip -l "$PROJECT_DIR/$ZIP_NAME" | head -20
echo "..."
echo ""
echo "🎉 Pronto para uso!"
