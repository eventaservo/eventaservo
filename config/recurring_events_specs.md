# Especificação de Eventos Recorrentes

## Regras Gerais

- Um evento recorrente é criado a partir de um evento master, que serve como template para a série.
- O evento master é o primeiro evento da série e é exibido normalmente.
- Os eventos filhos são cópias completas do master (estratégia materializada), armazenados como registros independentes na tabela `events`.
- A quantidade de eventos futuros gerados é controlada por `max_children` em `config/recurring_events.yml`.
- Um job diário (`GenerateRecurringEventsJob`, às 2h) repõe a série conforme os eventos vão ocorrendo.
- Eventos filhos mantêm um FK `recurrent_master_event_id` apontando para o master.
- Um master é identificado pela existência de um registro `EventRecurrence` (sem coluna booleana na tabela events).
- O detachment é rastreado via `metadata['detached_from_recurrent_series']` (coluna JSONB já existente na tabela events).

## Frequências Suportadas

| Frequência | Configuração | Exemplo |
|-----------|--------------|---------|
| Diário | A cada N dias | Todo dia, a cada 3 dias |
| Semanal | A cada N semanas em dias específicos | Toda terça e quinta |
| Mensal (dia fixo) | A cada N meses no dia X | Todo dia 10 do mês |
| Mensal (Nth dia da semana) | A cada N meses no Nth dia da semana | Primeiro sábado de cada mês |
| Anual | A cada N anos em mês/dia | Todo 17 de julho |

## Limites de Geração (config/recurring_events.yml)

| Frequência | max_children | horizon |
|-----------|-------------|---------|
| Diário | 7 | 30 dias |
| Semanal | 10 | 6 meses |
| Mensal | 6 | 2 anos |
| Anual | 5 | 10 anos |

- `max_children`: quantidade máxima de eventos filhos **futuros** mantidos gerados a qualquer momento.
- `horizon`: teto de segurança para o calculador de datas não varrer indefinidamente.

## Cenários

### Cenário 1: Evento master é apagado

- O master é **soft-deleted** (`deleted = true`).
- Todos os eventos filhos **futuros** são **permanentemente apagados** do banco de dados.
- Todos os eventos filhos **passados** são mantidos (já aconteceram).
- O registro `EventRecurrence` é **destruído**.
- Disparado por: service `Events::SoftDelete`.

### Cenário 2: Informações do evento master são atualizadas

- O master é atualizado normalmente (título, descrição, local, etc.).
- Todos os eventos filhos **futuros e não-detached** são atualizados com as mesmas alterações.
- A propagação roda de forma assíncrona via `EventRecurrences::PropagateChangesJob`.
- Eventos filhos **passados** não são afetados.
- Eventos filhos **detached** não são afetados.
- Campos propagados: `title`, `description`, `city`, `country_id`, `address`, `format`, `site`, `email`, `time_zone`, `specolisto`, `latitude`, `longitude`, `online`, tags e organizações.
- Disparado por: `EventsController#update` quando o evento é um recurring master.

### Cenário 3: Regra de recorrência é atualizada

- Todos os eventos filhos **futuros e não-detached** são **permanentemente apagados**.
- Todos os eventos filhos **passados** são mantidos.
- Eventos filhos **detached** são mantidos.
- O `last_generated_date` é resetado para `nil`.
- Novos eventos futuros são gerados imediatamente com o novo padrão de recorrência.
- Apenas campos que afetam o agendamento disparam a regeneração: `frequency`, `interval`, `days_of_week`, `day_of_month`, `week_of_month`, `day_of_week_monthly`, `month_of_year`.
- Disparado por: service `EventRecurrences::Update`.

### Cenário 4: Um evento filho é editado individualmente

- O evento filho é automaticamente **detached** da série (`metadata['detached_from_recurrent_series'] = true`).
- O `recurrent_master_event_id` é preservado (link histórico).
- O evento detached fica excluído de:
  - Propagação futura de alterações do master.
  - Deleção quando a regra de recorrência é atualizada.
  - Verificações de regeneração (o sistema não cria duplicata para aquela data).
- Disparado por: service `EventRecurrences::DetachChild`.

### Cenário 5: Recorrência é desativada

- O registro `EventRecurrence` é marcado como `active = false`.
- Eventos filhos existentes **não são afetados**.
- O job diário de geração ignora recorrências inativas.
- Pode ser reativada posteriormente pelo painel admin.
- Disparado por: painel admin (ações deactivate/reactivate).

### Cenário 6: Recorrência é destruída

- O registro `EventRecurrence` é **destruído**.
- Todos os eventos filhos **futuros** são **permanentemente apagados** (por padrão).
- Eventos filhos **passados** são mantidos.
- O evento master permanece, mas deixa de ser um recurring master.
- Disparado por: service `EventRecurrences::Destroy`.

### Cenário 7: Evento filho é apagado individualmente

- O evento filho é automaticamente **detached** da série antes de ser soft-deleted.
- Isso impede que o job diário de geração recrie um evento para aquela data.
- O `recurrent_master_event_id` é preservado (link histórico).
- Disparado por: service `Events::SoftDelete` (detecta que o evento é um filho e faz o detach).

### Cenário 8: Evento master é cancelado

- O master é marcado como cancelado (`cancelled = true`).
- Todos os eventos filhos **futuros** são **permanentemente apagados** do banco de dados.
- A recorrência é **desativada** (`active = false`), mas não destruída.
- Eventos filhos **passados** são mantidos.
- Se o master for des-cancelado posteriormente, a recorrência pode ser reativada pelo painel admin.
- Disparado por: `EventsController#nuligi`.

### Cenário 9: Horário do evento master é alterado

- A mudança de horário (hora de início/fim) é propagada para todos os eventos filhos **futuros e não-detached**.
- Cada filho mantém sua data original, mas recebe o novo horário e a duração do master.
- Exemplo: master muda de 18:00–19:00 para 20:00–21:00 → todos os filhos futuros passam para 20:00–21:00.
- A propagação ocorre junto com as demais alterações de campo via `EventRecurrences::PropagateChangesJob`.

### Cenário 10: Regra de recorrência alterada com master no passado

- Quando o master tem uma data no passado e a regra de recorrência é alterada (ex: de terça para quarta), a regeneração **nunca cria eventos com datas anteriores a hoje**.
- Exemplo: master começou em 3 de março, hoje é 22 de março. Ao mudar de terça para quarta, os novos eventos começam a partir da próxima quarta-feira (25 de março), nunca em 4, 11 ou 18 de março.
- Implementação: o `GenerateChildren` usa `max(last_generated_date, ontem)` como base de cálculo, garantindo que o dia mais antigo gerado é hoje.
- Eventos filhos passados que existiam com o padrão anterior já foram apagados pelo `Update` (cenário 3).

### Cenário 11: Data final da recorrência é definida ou antecipada

- A recorrência foi criada sem data final ("Never") e posteriormente é editada para ter uma data final.
- Todos os eventos filhos **não-detached** com data **posterior à data final** são **permanentemente apagados**.
- Eventos filhos antes da data final e eventos detached não são afetados.
- Também se aplica quando a data final já existia e é movida para uma data mais cedo.
- O `GenerateChildren` já respeita o `end_date` via `horizon_end_date`, então novos eventos não serão gerados além do limite.
- Disparado por: service `EventRecurrences::Update` (método `delete_children_beyond_end_date`).

### Cenário 12: Tentativa de editar recorrência inativa

- Se a recorrência está desativada (`active = false`), **não é possível editá-la**.
- O link "Edit recurrence" **não é exibido** na página do evento.
- Um badge "Inactive" é mostrado no lugar, indicando o estado da recorrência.
- Tanto a página de edição quanto o submit do formulário são bloqueados no controller.
- O usuário é redirecionado para o evento com uma mensagem de erro caso tente acessar diretamente a URL.
- Para editar, a recorrência deve primeiro ser reativada pelo painel admin.
- Disparado por: `EventRecurrencesController` (ações `edit` e `update`) e `_recurrence_info.html.erb`.

### Cenário 13: Job diário de geração é executado

- `GenerateRecurringEventsJob` roda às 2h diariamente.
- Para cada recorrência ativa, conta os eventos filhos futuros existentes.
- Se a contagem está abaixo de `max_children`, gera novos eventos para preencher a lacuna.
- Pula datas que já possuem um evento filho (previne duplicatas).
- Erros são capturados por recorrência via Sentry (uma falha não bloqueia as outras).

## Interface Admin

- **Index** (`/admin/event_recurrences`): lista todas as recorrências ativas com título do master, descrição da recorrência, contagem de filhos e status.
- **Show** (`/admin/event_recurrences/:id`): detalhes da recorrência + todos os eventos da série (master + filhos, passados e futuros).
- Admins podem desativar/reativar recorrências.
- Recorrências com masters soft-deleted são automaticamente excluídas das listagens.

## Arquitetura

### Banco de Dados

- Tabela `event_recurrences`: armazena a regra de recorrência (frequência, intervalo, dias, tipo de término, etc.).
- `events.recurrent_master_event_id`: FK ligando filho → master.
- `events.metadata` (JSONB): armazena o flag `detached_from_recurrent_series`.

### Arquivos Principais

| Arquivo | Propósito |
|---------|-----------|
| `app/models/event_recurrence.rb` | Modelo da regra de recorrência |
| `app/models/concerns/recurring_events.rb` | Concern incluído no modelo Event |
| `config/recurring_events.yml` | Configuração dos limites de geração |
| `config/initializers/recurring_events.rb` | Carrega config como `RecurringEventsConfig` |
| `app/services/event_recurrences/create.rb` | Cria recorrência + gera filhos iniciais |
| `app/services/event_recurrences/update.rb` | Atualiza regra, regenera se o agendamento mudou |
| `app/services/event_recurrences/destroy.rb` | Destrói regra + apaga filhos futuros |
| `app/services/event_recurrences/generate_children.rb` | Gera eventos filhos até max_children |
| `app/services/event_recurrences/propagate_changes.rb` | Propaga alterações do master para filhos futuros |
| `app/services/event_recurrences/detach_child.rb` | Desvincula um filho da série |
| `app/services/event_recurrences/recurrence_date_calculator.rb` | Calcula datas de ocorrência |
| `app/jobs/generate_recurring_events_job.rb` | Job diário para repor a série |
| `app/jobs/event_recurrences/propagate_changes_job.rb` | Propagação assíncrona de alterações do master |
