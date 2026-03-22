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

### Cenário 7: Job diário de geração é executado

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
