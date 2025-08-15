# ⚙️ Scripts Utilitários - Azure DevOps

Esta pasta contém scripts Shell voltados para **Branches** dentro de pipelines no Azure DevOps. Eles são especialmente úteis para manter fluxos de trabalho organizados e seguros em diferentes ambientes (desenvolvimento, homologação, produção).

---

## 🧠 Função dos Scripts

### 📌 `check-branch-develop.sh`
Valida se a branch atual é a `develop`.

🔍 **Utilização sugerida:**
Inclua este script no início da sua pipeline para garantir que os próximos passos só sejam executados quando a execução estiver na branch `develop`.

💡 **Exemplo de uso:**
Fluxos onde somente a branch `develop` deve executar testes de integração ou deploy automático no ambiente de desenvolvimento.

---

### 📌 `check-branch-release.sh`
Valida se a branch atual segue o padrão `release/*`.

🔍 **Utilização sugerida:**
Ideal para pipelines com etapas específicas para ambientes de homologação. Garante que ações só ocorram em branches destinadas a releases.

💡 **Exemplo de uso:**
Pipelines que diferenciam deploys para homologação por meio de branches `release/v1.0`, `release/v1.0-alpha`, etc.

