# Build e Release - Cloudflare WordPress Plugin (Fork)

Este fork contém GitHub Actions e scripts para automatizar a criação de ZIPs do plugin para releases.

## 🚀 GitHub Actions Disponíveis

### 1. Fork Release (`.github/workflows/fork-release.yml`)
- **Trigger**: Quando uma release é publicada no GitHub
- **Função**: Cria automaticamente o ZIP do plugin e anexa à release
- **Características**:
  - Instala dependências do Composer (modo produção)
  - Remove arquivos de desenvolvimento
  - Corrige polyfills do Symfony para PHP 8
  - Anexa o ZIP à release com nome versionado

### 2. Manual Build (`.github/workflows/manual-build.yml`)
- **Trigger**: Manual (workflow_dispatch) ou push de tags `v*`
- **Função**: Permite criar ZIPs sob demanda
- **Características**:
  - Execução manual com parâmetros configuráveis
  - Opção de incluir ou não arquivos de desenvolvimento
  - Criação automática de release quando executado via tag
  - Upload como artifact para download

## 🔧 Script Local

### Build ZIP Local (`scripts/build-zip.sh`)
Para testar localmente antes de fazer release:

```bash
# Build de produção
./scripts/build-zip.sh v4.12.8

# Build de desenvolvimento (inclui testes, docs, etc.)
./scripts/build-zip.sh v4.12.8 dev
```

## 📋 Como Usar

### Opção 1: Release Automática
1. Crie uma tag no seu repositório:
   ```bash
   git tag v4.12.8
   git push origin v4.12.8
   ```
2. Crie uma release no GitHub baseada na tag
3. O workflow `fork-release.yml` será executado automaticamente
4. O ZIP será anexado à release

### Opção 2: Build Manual
1. Vá para a aba "Actions" no seu repositório GitHub
2. Selecione "Manual Build ZIP"
3. Clique em "Run workflow"
4. Especifique a versão e opções
5. O ZIP será criado como artifact para download

### Opção 3: Script Local
1. Execute o script local para testar:
   ```bash
   ./scripts/build-zip.sh v4.12.8
   ```
2. O ZIP será criado no diretório raiz do projeto

## 📦 Estrutura do ZIP

### Versão de Produção (padrão)
Inclui apenas arquivos necessários para o plugin:
- ✅ Código fonte PHP
- ✅ Assets (CSS, JS, imagens)
- ✅ Dependências do Composer (vendor/)
- ✅ Arquivos de configuração essenciais
- ❌ Testes e documentação de desenvolvimento
- ❌ Arquivos de build e CI/CD

### Versão de Desenvolvimento
Inclui tudo da versão de produção mais:
- ✅ Testes (src/Test/)
- ✅ Documentação (docs/, *.md)
- ✅ Arquivos de configuração de desenvolvimento

## 🛠️ Customização

### Modificar Arquivos Incluídos/Excluídos
Edite as listas `EXCLUDE_ALWAYS` e `EXCLUDE_PROD` em:
- `scripts/build-zip.sh` (para script local)
- `.github/workflows/fork-release.yml` (para release automática)
- `.github/workflows/manual-build.yml` (para build manual)

### Alterar Triggers
- **Fork Release**: Modifique a seção `on:` para mudar quando executa
- **Manual Build**: Adicione outros triggers como `schedule:` para builds periódicos

## 🔍 Verificações

Antes de fazer release, sempre:
1. Execute os testes: `./vendor/bin/phpunit`
2. Execute o linter: `composer format`
3. Teste o script local: `./scripts/build-zip.sh test-version`
4. Verifique o conteúdo do ZIP gerado

## 📝 Notas

- Os workflows usam PHP 8.3 para compatibilidade
- As dependências do Composer são instaladas em modo produção (`--no-dev`)
- Os polyfills do Symfony são automaticamente corrigidos para PHP 8
- O cache do Composer é utilizado para acelerar os builds
- Os ZIPs são nomeados com a versão para fácil identificação
