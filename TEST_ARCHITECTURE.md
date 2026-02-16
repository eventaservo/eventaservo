# Proposta de Reorganização da Arquitetura de Testes

Este documento detalha a análise da estrutura atual de testes da aplicação Ruby on Rails e propõe uma nova arquitetura modularizada, focada em escalabilidade, manutenibilidade e facilidade de automação por IA.

## 1. Análise da Organização Atual

A aplicação utiliza Minitest e segue uma estrutura monolítica padrão do Rails, mas apresenta inconsistências e arquivos que tendem ao crescimento desordenado.

### Estrutura Existente
- **`test/models/`**: Arquivos únicos por model (ex: `event_test.rb` com ~200 linhas). Misturam validações, escopos, métodos de instância e callbacks em um único arquivo.
- **`test/controllers/`**: Arquivos únicos por controller (ex: `events_controller_test.rb`). Utilizam classes aninhadas (`class NewTest < EventsControllerTest`) para separar contextos, o que ajuda na organização lógica, mas mantém tudo no mesmo arquivo físico.
- **`test/services/`**: Organização inconsistente. Alguns diretórios usam sufixo `_services` (ex: `test/services/event_services/`) enquanto outros usam o nome do recurso no plural (ex: `test/services/events/`).
- **Factories (`test/factory_bot/`)**: Definidas fora do padrão `test/factories/`. Factories como `event` criam associações pesadas por padrão, tornando os testes lentos.
- **Fixtures (`test/fixtures/`)**: Já utilizadas para dados estáticos (`countries.yml`, `tags.yml`), o que é uma prática positiva.

### Problemas Identificados
1.  **Arquivos Monolíticos**: `test/models/event_test.rb` e `test/controllers/events_controller_test.rb` acumulam muitas responsabilidades, dificultando a leitura e manutenção.
2.  **Dificuldade de Localização**: Encontrar um teste específico dentro de um arquivo de 200+ linhas requer busca textual.
3.  **Inconsistência em Serviços**: A mistura de padrões de nomenclatura (`event_services` vs `events`) confunde a estrutura.
4.  **Acoplamento em Controllers**: O uso de classes aninhadas em um único arquivo cria dependências implícitas e dificulta a execução isolada de um contexto específico via linha de comando de forma simples.
5.  **Factories Pesadas**: Factories criam dados desnecessários para testes simples (ex: validação), impactando a performance.

## 2. Nova Arquitetura de Testes Modularizada

A proposta visa dividir arquivos grandes em componentes menores e focados, facilitando a geração de testes por IA e a manutenção humana.

### Princípios Fundamentais
1.  **Um Arquivo, Uma Responsabilidade**: Cada arquivo de teste deve focar em um aspecto específico (validação, escopo, ação de controller).
2.  **Limite de Tamanho**: Arquivos não devem exceder **200 linhas**. Se excederem, devem ser refatorados em sub-contextos.
3.  **Independência**: Testes devem ser capazes de rodar isoladamente sem depender de estados globais complexos definidos em classes pai.
4.  **Fixtures > Factories**: Utilizar Fixtures para dados estáticos ou de referência. Utilizar Factories apenas quando a variabilidade de dados for essencial.

### Organização de Diretórios Proposta

#### Models (`test/models/<model_name>/`)
Ao invés de `test/models/event_test.rb`, teremos um diretório:

```ruby
test/models/event/
├── validation_test.rb    # Testes de validações (presence, length, format)
├── association_test.rb   # Testes de associações (belongs_to, has_many)
├── scope_test.rb         # Testes de escopos (past?, online?, etc)
├── method_test.rb        # Testes de métodos de instância complexos
└── callback_test.rb      # Testes de callbacks (se houver lógica complexa)
```

#### Controllers (`test/controllers/<controller_name>/`)
Ao invés de `test/controllers/events_controller_test.rb`, teremos um diretório com testes independentes por action:

```ruby
test/controllers/events/
├── index_test.rb         # Testes para GET /events
├── show_test.rb          # Testes para GET /events/:code
├── create_test.rb        # Testes para POST /events
├── update_test.rb        # Testes para PATCH/PUT /events/:code
└── destroy_test.rb       # Testes para DELETE /events/:code
```

#### Services (`test/services/<resource_plural>/`)
Padronização para usar o nome do recurso no plural, eliminando sufixos redundantes como `_services`.

```ruby
test/services/events/     # Antes: test/services/event_services/
├── move_to_system_account_test.rb
├── schedule_reminders_test.rb
└── soft_delete_test.rb
```

## 3. Convenções de Nomenclatura e Código

### Classes de Teste
Devem refletir o caminho do arquivo para facilitar o autoloading e localização.

**Model:**
```ruby
# test/models/event/validation_test.rb
require "test_helper"

class Event::ValidationTest < ActiveSupport::TestCase
  test "validates presence of title" do
    event = Event.new
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end
end
```

**Controller:**
Testes de controller devem herdar diretamente de `ActionDispatch::IntegrationTest` (ou `IntegrationTest` se configurado), evitando aninhamento em classes "Pai" vazias.

```ruby
# test/controllers/events/index_test.rb
require "test_helper"

class Events::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get events_url
    assert_response :success
  end
end
```

### Factories e Fixtures

**Localização:**
- Factories: Manter em `test/factory_bot/` (conforme preferência atual).
- Fixtures: Manter em `test/fixtures/`.

**Estratégia:**
1.  **Fixture First**: Para tabelas de domínio fixo (Countries, Tags, Roles), use sempre Fixtures.
2.  **Minimal Factory**: A factory padrão (`:event`) deve conter apenas o estritamente necessário para o objeto ser válido.
3.  **Traits para Complexidade**: Use traits para adicionar associações ou estados complexos.

```ruby
# Exemplo de Factory Otimizada
FactoryBot.define do
  factory :event do
    title { "Evento Simples" }
    association :user # Obrigatório

    trait :with_participants do
      after(:create) { |event| create_list(:participant, 3, event: event) }
    end
  end
end
```

## 4. Guia de Migração Gradual

Não tente migrar tudo de uma vez. Siga esta ordem para evitar quebra de CI/CD:

1.  **Padronizar Serviços**:
    - Mover `test/services/event_services/` para `test/services/events/`.
    - Ajustar namespaces nos arquivos movidos.

2.  **Refatorar Models Críticos (Ex: Event)**:
    - Criar diretório `test/models/event/`.
    - Criar `validation_test.rb` e mover testes de validação do `event_test.rb`.
    - Criar `scope_test.rb` e mover testes de escopo.
    - Manter `event_test.rb` apenas com o que sobrar, até que esteja vazio e possa ser removido.

3.  **Refatorar Controllers Críticos (Ex: EventsController)**:
    - Criar diretório `test/controllers/events/`.
    - Extrair classe `IndexTest` para `test/controllers/events/index_test.rb`.
    - Remover a classe aninhada do arquivo original.
    - Repetir para outras actions.

## 5. Diretrizes para Automação (IA)

Ao solicitar novos testes a uma IA, forneça estas regras:
- "Crie o teste em `test/models/<model>/<context>_test.rb`."
- "Não adicione ao arquivo principal do model."
- "Use Fixtures para dados estáticos se disponíveis."
- "Mantenha o arquivo abaixo de 200 linhas."
