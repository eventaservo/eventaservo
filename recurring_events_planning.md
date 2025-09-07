# Planejamento para Implementação de Eventos Recorrentes no Eventaservo

## Task List - Fases de Implementação

### ✅ Fase 0: Análise e Planejamento (Concluída)
- [x] Analisar estrutura atual do sistema de eventos
- [x] Identificar pontos de integração
- [x] Definir arquitetura da solução
- [x] Criar documento de planejamento

### 🔄 Fase 1: Estrutura Base (1-2 semanas)
- [ ] Criar migration para tabela `event_recurrences`
- [ ] Adicionar campos `parent_event_id` e `is_recurring_master` na tabela events
- [ ] Implementar modelo `EventRecurrence` com validações
- [ ] Adicionar associações no modelo `Event`
- [ ] Criar factory para `EventRecurrence` nos testes
- [ ] Implementar testes unitários do modelo `EventRecurrence`
- [ ] Implementar testes unitários das novas associações em `Event`

### 📋 Fase 2: Serviços de Negócio (1-2 semanas)
- [ ] Implementar `Events::Recurring::Create`
- [ ] Implementar `Events::Recurring::GenerateEvents`
- [ ] Implementar `Events::Recurring::Update`
- [ ] Implementar `Events::Recurring::Delete`
- [ ] Criar job `RecurringEventsGeneratorJob`
- [ ] Configurar job recorrente no `recurring.yml`
- [ ] Implementar testes para todos os serviços
- [ ] Implementar testes para o job

### 🎨 Fase 3: Interface do Usuário (2-3 semanas)
- [ ] Adicionar campos de recorrência no formulário de eventos
- [ ] Implementar Stimulus controller para recorrência
- [ ] Criar componente `RecurringEventsComponent`
- [ ] Adicionar validações JavaScript no frontend
- [ ] Implementar preview das próximas ocorrências
- [ ] Atualizar controller `EventsController` para suportar recorrência
- [ ] Criar views para gerenciar séries de eventos
- [ ] Implementar testes de sistema para criação de eventos recorrentes

### ⚡ Fase 4: Funcionalidades Avançadas (1-2 semanas)
- [ ] Implementar edição de séries (este evento, futuros, todos)
- [ ] Implementar cancelamento de séries
- [ ] Adicionar visualização de séries na página do evento
- [ ] Implementar filtros para eventos recorrentes
- [ ] Otimizar consultas com índices apropriados
- [ ] Implementar cache para séries frequentemente acessadas
- [ ] Adicionar suporte a exceções (eventos únicos modificados)
- [ ] Implementar testes para todas as funcionalidades avançadas

### 🚀 Fase 5: Polimento e Deploy (1 semana)
- [ ] Revisar e otimizar performance
- [ ] Implementar testes de integração completos
- [ ] Criar documentação técnica
- [ ] Atualizar documentação do usuário
- [ ] Deploy em ambiente de staging
- [ ] Testes de aceitação
- [ ] Deploy em produção
- [ ] Monitoramento pós-deploy

---

## 1. Análise da Estrutura Atual

### Sistema de Eventos Existente
- **Modelo Event**: Bem estruturado com campos `date_start`, `date_end`, `time_zone`
- **Infraestrutura de Jobs**: SolidQueue com suporte a jobs recorrentes (`recurring.yml`)
- **Serviços**: Padrão ApplicationService com Response objects
- **Interface**: Formulário robusto com campos de data/hora e timezone

### Pontos de Integração Identificados
- Campo `metadata` (JSONB) no Event para armazenar configurações de recorrência
- Sistema de jobs existente para processamento em background
- Estrutura de serviços modularizada (`EventServices::`)

## 2. Estrutura de Dados

### 2.1 Modelo de Recorrência
Criar um novo modelo `EventRecurrence` para gerenciar as regras de recorrência:

```ruby
# app/models/event_recurrence.rb
class EventRecurrence < ApplicationRecord
  belongs_to :parent_event, class_name: 'Event'
  has_many :generated_events, class_name: 'Event', foreign_key: 'parent_event_id'

  # Enums
  enum frequency: { daily: 'daily', weekly: 'weekly', monthly: 'monthly', yearly: 'yearly' }
  enum end_type: { never: 'never', after_count: 'after_count', on_date: 'on_date' }

  # Validações
  validates :frequency, presence: true
  validates :interval, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :end_type, presence: true
  validates :end_count, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, if: -> { end_type == 'after_count' }
  validates :end_date, presence: true, if: -> { end_type == 'on_date' }
  validate :end_date_in_future, if: -> { end_type == 'on_date' }
  validate :days_of_week_valid, if: -> { frequency == 'weekly' }

  # Serialização
  serialize :days_of_week, Array

  private

  def end_date_in_future
    errors.add(:end_date, 'deve ser no futuro') if end_date && end_date <= Date.current
  end

  def days_of_week_valid
    return if days_of_week.blank?

    valid_days = (0..6).to_a
    invalid_days = days_of_week - valid_days
    errors.add(:days_of_week, 'contém dias inválidos') if invalid_days.any?
  end
end
```

### 2.2 Atualização do Modelo Event
```ruby
# Adicionar ao app/models/event.rb
class Event < ApplicationRecord
  # Associações para recorrência
  belongs_to :parent_event, class_name: 'Event', optional: true
  has_many :child_events, class_name: 'Event', foreign_key: 'parent_event_id', dependent: :destroy
  has_one :recurrence, class_name: 'EventRecurrence', foreign_key: 'parent_event_id', dependent: :destroy

  # Scopes
  scope :recurring_parents, -> { where(is_recurring_master: true) }
  scope :recurring_children, -> { where.not(parent_event_id: nil) }
  scope :standalone_events, -> { where(parent_event_id: nil, is_recurring_master: false) }

  # Métodos
  def recurring_parent?
    is_recurring_master?
  end

  def recurring_child?
    parent_event_id.present?
  end

  def part_of_series?
    recurring_parent? || recurring_child?
  end

  def root_event
    recurring_child? ? parent_event : self
  end
end
```

### 2.3 Migration
```ruby
class CreateEventRecurrences < ActiveRecord::Migration[7.0]
  def change
    create_table :event_recurrences do |t|
      t.references :parent_event, null: false, foreign_key: { to_table: :events }
      t.string :frequency, null: false # daily, weekly, monthly, yearly
      t.integer :interval, default: 1, null: false
      t.text :days_of_week # Serialized array para dias da semana (0=domingo, 6=sábado)
      t.integer :day_of_month # Para recorrência mensal (1-31)
      t.string :end_type, null: false # never, after_count, on_date
      t.integer :end_count
      t.date :end_date
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_column :events, :parent_event_id, :bigint
    add_column :events, :is_recurring_master, :boolean, default: false, null: false

    add_index :events, :parent_event_id
    add_index :events, :is_recurring_master
    add_index :event_recurrences, [:active, :frequency]

    add_foreign_key :events, :events, column: :parent_event_id
  end
end
```

## 3. Serviços de Negócio

### 3.1 EventServices::CreateRecurring
```ruby
module EventServices
  class CreateRecurring < ApplicationService
    # Cria evento pai e configura recorrência
    # @param event_params [Hash] Parâmetros do evento
    # @param recurrence_params [Hash] Parâmetros da recorrência
    def initialize(event_params, recurrence_params)
      @event_params = event_params
      @recurrence_params = recurrence_params
    end

    # @return [Response] success com evento criado ou failure com erro
    def call
      ActiveRecord::Base.transaction do
        create_parent_event
        create_recurrence_rule
        schedule_generation_job
        success(@parent_event)
      end
    rescue => e
      failure(e.message)
    end

    private

    def create_parent_event
      @parent_event = Event.new(@event_params.merge(is_recurring_master: true))
      @parent_event.save!
    end

    def create_recurrence_rule
      @recurrence = EventRecurrence.new(@recurrence_params.merge(parent_event: @parent_event))
      @recurrence.save!
    end

    def schedule_generation_job
      GenerateRecurringEventsJob.perform_later(@recurrence.id)
    end
  end
end
```

### 3.2 EventServices::GenerateRecurringEvents
```ruby
module EventServices
  class GenerateRecurringEvents < ApplicationService
    MAX_EVENTS_PER_SERIES = 100
    MAX_MONTHS_AHEAD = 24

    # Gera eventos futuros baseado na regra de recorrência
    # @param recurrence [EventRecurrence] Regra de recorrência
    # @param months_ahead [Integer] Quantos meses gerar à frente (padrão: 6)
    def initialize(recurrence, months_ahead: 6)
      @recurrence = recurrence
      @months_ahead = [months_ahead, MAX_MONTHS_AHEAD].min
      @parent_event = recurrence.parent_event
    end

    # @return [Response] success com eventos criados ou failure com erro
    def call
      return failure('Recorrência inativa') unless @recurrence.active?

      dates = calculate_next_dates
      events_created = create_events_for_dates(dates)

      success(events_created)
    rescue => e
      failure(e.message)
    end

    private

    def calculate_next_dates
      calculator = RecurrenceDateCalculator.new(@recurrence, @months_ahead)
      calculator.next_dates
    end

    def create_events_for_dates(dates)
      events = []

      dates.each do |date|
        next if event_exists_for_date?(date)

        event = create_child_event(date)
        events << event if event

        break if events.count >= MAX_EVENTS_PER_SERIES
      end

      events
    end

    def event_exists_for_date?(date)
      @parent_event.child_events.exists?(date_start: date)
    end

    def create_child_event(date)
      duration = @parent_event.date_end - @parent_event.date_start

      child_params = @parent_event.attributes.except(
        'id', 'code', 'created_at', 'updated_at', 'is_recurring_master'
      ).merge(
        parent_event_id: @parent_event.id,
        date_start: date,
        date_end: date + duration,
        is_recurring_master: false
      )

      child_event = Event.new(child_params)
      child_event.save!

      # Copiar tags e organizações
      copy_associations(child_event)

      child_event
    end

    def copy_associations(child_event)
      # Copiar tags
      @parent_event.tags.each do |tag|
        child_event.tags << tag unless child_event.tags.include?(tag)
      end

      # Copiar organizações
      @parent_event.organizations.each do |org|
        child_event.organizations << org unless child_event.organizations.include?(org)
      end
    end
  end
end
```

### 3.3 RecurrenceDateCalculator
```ruby
class RecurrenceDateCalculator
  def initialize(recurrence, months_ahead)
    @recurrence = recurrence
    @months_ahead = months_ahead
    @parent_event = recurrence.parent_event
  end

  def next_dates
    case @recurrence.frequency
    when 'daily'
      calculate_daily_dates
    when 'weekly'
      calculate_weekly_dates
    when 'monthly'
      calculate_monthly_dates
    when 'yearly'
      calculate_yearly_dates
    else
      []
    end
  end

  private

  def calculate_daily_dates
    dates = []
    current_date = next_occurrence_date
    end_date = limit_end_date

    while current_date <= end_date && !reached_count_limit?(dates)
      dates << current_date
      current_date += @recurrence.interval.days
    end

    dates
  end

  def calculate_weekly_dates
    dates = []
    current_date = next_occurrence_date
    end_date = limit_end_date

    while current_date <= end_date && !reached_count_limit?(dates)
      if @recurrence.days_of_week.present?
        # Recorrência em dias específicos da semana
        week_start = current_date.beginning_of_week
        @recurrence.days_of_week.each do |day|
          date = week_start + day.days
          dates << date if date >= next_occurrence_date && date <= end_date
        end
      else
        # Recorrência no mesmo dia da semana
        dates << current_date
      end

      current_date += (@recurrence.interval * 7).days
    end

    dates.sort
  end

  def calculate_monthly_dates
    dates = []
    current_date = next_occurrence_date
    end_date = limit_end_date

    while current_date <= end_date && !reached_count_limit?(dates)
      if @recurrence.day_of_month.present?
        # Dia específico do mês
        target_day = [@recurrence.day_of_month, current_date.end_of_month.day].min
        date = Date.new(current_date.year, current_date.month, target_day)
      else
        # Mesmo dia do mês do evento original
        target_day = [@parent_event.date_start.day, current_date.end_of_month.day].min
        date = Date.new(current_date.year, current_date.month, target_day)
      end

      dates << date if date >= next_occurrence_date
      current_date = current_date >> @recurrence.interval # Próximo mês
    end

    dates
  end

  def calculate_yearly_dates
    dates = []
    current_date = next_occurrence_date
    end_date = limit_end_date

    while current_date <= end_date && !reached_count_limit?(dates)
      dates << current_date
      current_date = current_date >> (12 * @recurrence.interval) # Próximo ano
    end

    dates
  end

  def next_occurrence_date
    @next_occurrence_date ||= begin
      base_date = [@parent_event.date_start.to_date, Date.current].max
      base_date + @recurrence.interval.send(@recurrence.frequency.singularize)
    end
  end

  def limit_end_date
    @limit_end_date ||= begin
      max_date = Date.current + @months_ahead.months

      case @recurrence.end_type
      when 'on_date'
        [@recurrence.end_date, max_date].min
      else
        max_date
      end
    end
  end

  def reached_count_limit?(dates)
    return false unless @recurrence.end_type == 'after_count'

    existing_count = @parent_event.child_events.count
    dates.count + existing_count >= @recurrence.end_count
  end
end
```

## 4. Jobs em Background

### 4.1 RecurringEventsGeneratorJob
```ruby
class RecurringEventsGeneratorJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Iniciando geração de eventos recorrentes"

    EventRecurrence.active.find_each do |recurrence|
      result = EventServices::GenerateRecurringEvents.call(recurrence)

      if result.success?
        Rails.logger.info "Gerados #{result.payload.count} eventos para recorrência #{recurrence.id}"
      else
        Rails.logger.error "Erro ao gerar eventos para recorrência #{recurrence.id}: #{result.error}"
        Sentry.capture_message("Erro na geração de eventos recorrentes", extra: {
          recurrence_id: recurrence.id,
          error: result.error
        })
      end
    end

    Rails.logger.info "Geração de eventos recorrentes concluída"
  end
end
```

### 4.2 GenerateRecurringEventsJob
```ruby
class GenerateRecurringEventsJob < ApplicationJob
  queue_as :default

  def perform(recurrence_id)
    recurrence = EventRecurrence.find(recurrence_id)
    result = EventServices::GenerateRecurringEvents.call(recurrence)

    unless result.success?
      Rails.logger.error "Erro ao gerar eventos para recorrência #{recurrence_id}: #{result.error}"
      raise result.error
    end
  end
end
```

### 4.3 Configuração no recurring.yml
```yaml
# Adicionar ao config/recurring.yml
generate_recurring_events:
  class: RecurringEventsGeneratorJob
  schedule: every day at 2am
```

## 5. Interface do Usuário

### 5.1 Atualização do Formulário
Adicionar ao `app/views/events/_form.html.erb`:

```erb
<!-- Adicionar após a seção de tags -->
<div class="form-group">
  <div class="form-check">
    <%= check_box_tag 'is_recurring', '1', false,
        class: 'form-check-input',
        data: {
          'event--form-target': 'recurringToggle',
          action: 'change->event--form#toggleRecurring'
        } %>
    <%= label_tag 'is_recurring', '🔄 Evento recorrente',
        class: 'form-check-label' %>
  </div>
  <small class="form-text text-muted">
    Marque esta opção para criar uma série de eventos que se repetem automaticamente
  </small>
</div>

<div id="recurring-options" style="display: none;"
     data-event--form-target="recurringOptions">

  <div class="card border-info">
    <div class="card-header bg-info text-white">
      <h6 class="mb-0">⚙️ Configurações de Recorrência</h6>
    </div>
    <div class="card-body">

      <!-- Frequência -->
      <div class="form-group">
        <%= label_tag 'recurrence[frequency]', 'Repetir' %>
        <%= select_tag 'recurrence[frequency]',
            options_for_select([
              ['Diariamente', 'daily'],
              ['Semanalmente', 'weekly'],
              ['Mensalmente', 'monthly'],
              ['Anualmente', 'yearly']
            ]),
            class: 'form-control',
            data: {
              'event--form-target': 'frequency',
              action: 'change->event--form#frequencyChanged'
            } %>
      </div>

      <!-- Intervalo -->
      <div class="form-group">
        <%= label_tag 'recurrence[interval]', 'A cada' %>
        <div class="input-group">
          <%= number_field_tag 'recurrence[interval]', 1,
              min: 1, max: 100,
              class: 'form-control' %>
          <div class="input-group-append">
            <span class="input-group-text" data-event--form-target="intervalUnit">
              dia(s)
            </span>
          </div>
        </div>
      </div>

      <!-- Dias da semana (apenas para frequência semanal) -->
      <div class="form-group" data-event--form-target="weeklyOptions" style="display: none;">
        <%= label_tag 'recurrence[days_of_week]', 'Dias da semana' %>
        <div class="btn-group-toggle" data-toggle="buttons">
          <% %w[Domingo Segunda Terça Quarta Quinta Sexta Sábado].each_with_index do |day, index| %>
            <label class="btn btn-outline-primary btn-sm">
              <%= check_box_tag 'recurrence[days_of_week][]', index, false %>
              <%= day %>
            </label>
          <% end %>
        </div>
        <small class="form-text text-muted">
          Deixe em branco para repetir no mesmo dia da semana do evento original
        </small>
      </div>

      <!-- Dia do mês (apenas para frequência mensal) -->
      <div class="form-group" data-event--form-target="monthlyOptions" style="display: none;">
        <%= label_tag 'recurrence[day_of_month]', 'Dia do mês' %>
        <%= number_field_tag 'recurrence[day_of_month]', nil,
            min: 1, max: 31,
            class: 'form-control',
            placeholder: 'Deixe em branco para usar o dia do evento original' %>
        <small class="form-text text-muted">
          Para meses com menos dias, será usado o último dia disponível
        </small>
      </div>

      <!-- Término -->
      <div class="form-group">
        <%= label_tag 'recurrence[end_type]', 'Terminar' %>
        <%= select_tag 'recurrence[end_type]',
            options_for_select([
              ['Nunca', 'never'],
              ['Após um número de ocorrências', 'after_count'],
              ['Em uma data específica', 'on_date']
            ]),
            class: 'form-control',
            data: {
              'event--form-target': 'endType',
              action: 'change->event--form#endTypeChanged'
            } %>
      </div>

      <!-- Número de ocorrências -->
      <div class="form-group" data-event--form-target="endCountOptions" style="display: none;">
        <%= label_tag 'recurrence[end_count]', 'Número de ocorrências' %>
        <%= number_field_tag 'recurrence[end_count]', 10,
            min: 1, max: 100,
            class: 'form-control' %>
      </div>

      <!-- Data de término -->
      <div class="form-group" data-event--form-target="endDateOptions" style="display: none;">
        <%= label_tag 'recurrence[end_date]', 'Data de término' %>
        <%= date_field_tag 'recurrence[end_date]', nil,
            class: 'form-control',
            min: Date.current %>
      </div>

      <!-- Preview -->
      <div class="alert alert-light" data-event--form-target="preview">
        <strong>Preview:</strong>
        <div data-event--form-target="previewText">
          Configure a recorrência para ver um preview das próximas ocorrências
        </div>
      </div>

    </div>
  </div>
</div>
```

### 5.2 Stimulus Controller
```javascript
// app/javascript/controllers/event/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "recurringToggle", "recurringOptions", "frequency", "intervalUnit",
    "weeklyOptions", "monthlyOptions", "endType", "endCountOptions",
    "endDateOptions", "preview", "previewText"
  ]

  connect() {
    this.updateIntervalUnit()
    this.updateFrequencyOptions()
    this.updateEndTypeOptions()
    this.updatePreview()
  }

  toggleRecurring() {
    const isChecked = this.recurringToggleTarget.checked
    this.recurringOptionsTarget.style.display = isChecked ? 'block' : 'none'

    if (isChecked) {
      this.updatePreview()
    }
  }

  frequencyChanged() {
    this.updateIntervalUnit()
    this.updateFrequencyOptions()
    this.updatePreview()
  }

  endTypeChanged() {
    this.updateEndTypeOptions()
    this.updatePreview()
  }

  updateIntervalUnit() {
    const frequency = this.frequencyTarget.value
    const units = {
      'daily': 'dia(s)',
      'weekly': 'semana(s)',
      'monthly': 'mês(es)',
      'yearly': 'ano(s)'
    }

    this.intervalUnitTarget.textContent = units[frequency] || 'dia(s)'
  }

  updateFrequencyOptions() {
    const frequency = this.frequencyTarget.value

    // Mostrar/esconder opções específicas da frequência
    this.weeklyOptionsTarget.style.display = frequency === 'weekly' ? 'block' : 'none'
    this.monthlyOptionsTarget.style.display = frequency === 'monthly' ? 'block' : 'none'
  }

  updateEndTypeOptions() {
    const endType = this.endTypeTarget.value

    this.endCountOptionsTarget.style.display = endType === 'after_count' ? 'block' : 'none'
    this.endDateOptionsTarget.style.display = endType === 'on_date' ? 'block' : 'none'
  }

  updatePreview() {
    if (!this.recurringToggleTarget.checked) return

    // Simular preview das próximas ocorrências
    const frequency = this.frequencyTarget.value
    const interval = document.querySelector('[name="recurrence[interval]"]').value

    let previewText = `Este evento se repetirá ${this.getFrequencyText(frequency, interval)}`

    this.previewTextTarget.innerHTML = previewText
  }

  getFrequencyText(frequency, interval) {
    const intervalNum = parseInt(interval) || 1

    switch (frequency) {
      case 'daily':
        return intervalNum === 1 ? 'todos os dias' : `a cada ${intervalNum} dias`
      case 'weekly':
        return intervalNum === 1 ? 'todas as semanas' : `a cada ${intervalNum} semanas`
      case 'monthly':
        return intervalNum === 1 ? 'todos os meses' : `a cada ${intervalNum} meses`
      case 'yearly':
        return intervalNum === 1 ? 'todos os anos' : `a cada ${intervalNum} anos`
      default:
        return ''
    }
  }
}
```

### 5.3 Componente de Visualização
```ruby
# app/components/recurring_events_component.rb
class RecurringEventsComponent < ViewComponent::Base
  # @param parent_event [Event] Evento pai da série
  def initialize(parent_event)
    @parent_event = parent_event
    @recurrence = parent_event.recurrence
    @upcoming_events = parent_event.child_events.venontaj.limit(5).order(:date_start)
  end

  private

  attr_reader :parent_event, :recurrence, :upcoming_events

  def recurrence_description
    return '' unless recurrence

    frequency_text = case recurrence.frequency
    when 'daily'
      recurrence.interval == 1 ? 'Diariamente' : "A cada #{recurrence.interval} dias"
    when 'weekly'
      recurrence.interval == 1 ? 'Semanalmente' : "A cada #{recurrence.interval} semanas"
    when 'monthly'
      recurrence.interval == 1 ? 'Mensalmente' : "A cada #{recurrence.interval} meses"
    when 'yearly'
      recurrence.interval == 1 ? 'Anualmente' : "A cada #{recurrence.interval} anos"
    end

    end_text = case recurrence.end_type
    when 'never'
      'sem data de término'
    when 'after_count'
      "por #{recurrence.end_count} ocorrências"
    when 'on_date'
      "até #{I18n.l(recurrence.end_date, format: :short)}"
    end

    "#{frequency_text}, #{end_text}"
  end
end
```

```erb
<!-- app/components/recurring_events_component.html.erb -->
<div class="card border-info mb-3">
  <div class="card-header bg-info text-white">
    <h6 class="mb-0">
      🔄 Série de Eventos Recorrentes
    </h6>
  </div>
  <div class="card-body">
    <p class="card-text">
      <strong>Padrão:</strong> <%= recurrence_description %>
    </p>

    <% if upcoming_events.any? %>
      <h6>Próximas ocorrências:</h6>
      <ul class="list-unstyled">
        <% upcoming_events.each do |event| %>
          <li class="mb-1">
            <%= link_to event_path(code: event.code), class: 'text-decoration-none' do %>
              📅 <%= I18n.l(event.date_start, format: :short) %>
              <small class="text-muted">(<%= event.komenca_tago %>)</small>
            <% end %>
          </li>
        <% end %>
      </ul>

      <% if parent_event.child_events.venontaj.count > 5 %>
        <small class="text-muted">
          ... e mais <%= parent_event.child_events.venontaj.count - 5 %> ocorrências
        </small>
      <% end %>
    <% else %>
      <p class="text-muted mb-0">
        Nenhuma ocorrência futura agendada ainda.
      </p>
    <% end %>
  </div>
</div>
```

## 6. Atualização do Controller

### 6.1 EventsController
```ruby
# Adicionar ao app/controllers/events_controller.rb

def create
  if params[:is_recurring] == '1' && recurrence_params_present?
    create_recurring_event
  else
    create_single_event
  end
end

private

def create_recurring_event
  result = EventServices::CreateRecurring.call(event_params, recurrence_params)

  if result.success?
    @event = result.payload
    process_event_associations(@event)

    NovaEventaSciigoJob.perform_later(@event)
    ahoy.track "Create recurring event", event_url: @event.short_url
    Log.create(text: "Created recurring event series #{@event.title}", user: current_user, event_id: @event.id)

    redirect_to event_path(code: @event.ligilo),
                flash: { notice: "Série de eventos recorrentes criada com sucesso." }
  else
    @event = Event.new(event_params)
    @event.errors.add(:base, result.error)
    render :new
  end
end

def create_single_event
  @event = Event.new(event_params)
  @event.user_id ||= current_user.id

  if @event.save
    process_event_associations(@event)

    NovaEventaSciigoJob.perform_later(@event)
    ahoy.track "Create event", event_url: @event.short_url
    Log.create(text: "Created event #{@event.title}", user: current_user, event_id: @event.id)

    redirect_to event_path(code: @event.ligilo),
                flash: { notice: "Evento criado com sucesso." }
  else
    render :new
  end
end

def process_event_associations(event)
  # Process categories tags
  if params[:tags_categories].present?
    params[:tags_categories].each do |id|
      tag = Tag.find(id)
      event.tags << tag unless event.tags.include?(tag)
    end
  end

  # Process characteristics tags
  if params[:tags_characteristics].present?
    params[:tags_characteristics].each do |id|
      tag = Tag.find(id)
      event.tags << tag unless event.tags.include?(tag)
    end
  end

  event.update_event_organizations(params[:organization_ids])
  set_event_format(event)
end

def recurrence_params_present?
  params[:recurrence].present? &&
  params[:recurrence][:frequency].present? &&
  params[:recurrence][:end_type].present?
end

def recurrence_params
  params.require(:recurrence).permit(
    :frequency, :interval, :end_type, :end_count, :end_date, :day_of_month,
    days_of_week: []
  )
end
```

## 7. Testes

### 7.1 Testes de Modelo
```ruby
# spec/models/event_recurrence_spec.rb
require 'rails_helper'

RSpec.describe EventRecurrence, type: :model do
  describe 'associations' do
    it { should belong_to(:parent_event).class_name('Event') }
    it { should have_many(:generated_events).class_name('Event').with_foreign_key('parent_event_id') }
  end

  describe 'validations' do
    it { should validate_presence_of(:frequency) }
    it { should validate_presence_of(:interval) }
    it { should validate_presence_of(:end_type) }
    it { should validate_numericality_of(:interval).is_greater_than(0).is_less_than_or_equal_to(100) }

    context 'when end_type is after_count' do
      subject { build(:event_recurrence, end_type: 'after_count') }
      it { should validate_presence_of(:end_count) }
      it { should validate_numericality_of(:end_count).is_greater_than(0).is_less_than_or_equal_to(100) }
    end

    context 'when end_type is on_date' do
      subject { build(:event_recurrence, end_type: 'on_date') }
      it { should validate_presence_of(:end_date) }

      it 'validates end_date is in the future' do
        recurrence = build(:event_recurrence, end_type: 'on_date', end_date: Date.yesterday)
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:end_date]).to include('deve ser no futuro')
      end
    end

    context 'when frequency is weekly' do
      it 'validates days_of_week contains valid days' do
        recurrence = build(:event_recurrence, frequency: 'weekly', days_of_week: [0, 1, 7])
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:days_of_week]).to include('contém dias inválidos')
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:frequency).with_values(daily: 'daily', weekly: 'weekly', monthly: 'monthly', yearly: 'yearly') }
    it { should define_enum_for(:end_type).with_values(never: 'never', after_count: 'after_count', on_date: 'on_date') }
  end
end
```

### 7.2 Testes de Serviços
```ruby
# spec/services/event_services/create_recurring_spec.rb
require 'rails_helper'

RSpec.describe EventServices::CreateRecurring, type: :service do
  let(:user) { create(:user) }
  let(:event_params) do
    {
      title: 'Evento Recorrente',
      description: 'Descrição do evento',
      date_start: 1.week.from_now,
      date_end: 1.week.from_now + 2.hours,
      city: 'São Paulo',
      country_id: create(:country).id,
      user_id: user.id
    }
  end

  let(:recurrence_params) do
    {
      frequency: 'weekly',
      interval: 1,
      end_type: 'after_count',
      end_count: 5
    }
  end

  subject { described_class.new(event_params, recurrence_params) }

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a parent event' do
        expect { subject.call }.to change(Event, :count).by(1)

        event = Event.last
        expect(event.is_recurring_master).to be true
        expect(event.title).to eq('Evento Recorrente')
      end

      it 'creates a recurrence rule' do
        expect { subject.call }.to change(EventRecurrence, :count).by(1)

        recurrence = EventRecurrence.last
        expect(recurrence.frequency).to eq('weekly')
        expect(recurrence.interval).to eq(1)
        expect(recurrence.end_count).to eq(5)
      end

      it 'schedules generation job' do
        expect(GenerateRecurringEventsJob).to receive(:perform_later)
        subject.call
      end

      it 'returns success response' do
        result = subject.call
        expect(result.success?).to be true
        expect(result.payload).to be_a(Event)
      end
    end

    context 'with invalid event parameters' do
      let(:event_params) { { title: '' } }

      it 'returns failure response' do
        result = subject.call
        expect(result.failure?).to be true
        expect(result.error).to be_present
      end

      it 'does not create any records' do
        expect { subject.call }.not_to change(Event, :count)
        expect { subject.call }.not_to change(EventRecurrence, :count)
      end
    end
  end
end
```

### 7.3 Testes de Sistema
```ruby
# spec/system/recurring_events_spec.rb
require 'rails_helper'

RSpec.describe 'Recurring Events', type: :system do
  let(:user) { create(:user) }
  let(:country) { create(:country) }

  before do
    sign_in user
  end

  describe 'creating a recurring event' do
    it 'allows user to create weekly recurring event' do
      visit new_event_path

      fill_in 'Titolo', with: 'Reunião Semanal'
      fill_in 'Priskribo', with: 'Reunião de equipe'
      fill_in 'Urbo (aŭ loko)', with: 'São Paulo'
      select country.name, from: 'event_country_id'

      # Marcar como recorrente
      check 'Evento recorrente'

      # Configurar recorrência
      select 'Semanalmente', from: 'recurrence[frequency]'
      fill_in 'recurrence[interval]', with: '1'
      select 'Após um número de ocorrências', from: 'recurrence[end_type]'
      fill_in 'recurrence[end_count]', with: '10'

      click_button 'Krei eventon'

      expect(page).to have_content('Série de eventos recorrentes criada com sucesso')
      expect(page).to have_content('Série de Eventos Recorrentes')
      expect(page).to have_content('Semanalmente, por 10 ocorrências')
    end

    it 'shows validation errors for invalid recurrence' do
      visit new_event_path

      fill_in 'Titolo', with: 'Evento Inválido'
      check 'Evento recorrente'

      # Não preencher campos obrigatórios da recorrência
      click_button 'Krei eventon'

      expect(page).to have_content('erro')
    end
  end

  describe 'viewing recurring events' do
    let(:parent_event) { create(:event, user: user, is_recurring_master: true) }
    let(:recurrence) { create(:event_recurrence, parent_event: parent_event) }

    before do
      create_list(:event, 3, parent_event: parent_event, user: user)
    end

    it 'shows recurring events series information' do
      visit event_path(code: parent_event.code)

      expect(page).to have_content('Série de Eventos Recorrentes')
      expect(page).to have_content('Próximas ocorrências')
    end
  end
end
```

## 8. Considerações de Performance

### 8.1 Índices de Banco de Dados
```ruby
# Adicionar à migration
add_index :events, [:is_recurring_master, :date_start]
add_index :events, [:parent_event_id, :date_start]
add_index :event_recurrences, [:active, :frequency]
add_index :event_recurrences, [:parent_event_id, :active]
```

### 8.2 Otimizações de Query
```ruby
# Scopes otimizados no modelo Event
scope :upcoming_in_series, ->(parent_id) {
  where(parent_event_id: parent_id)
    .where('date_start >= ?', Time.current)
    .order(:date_start)
    .limit(10)
}

scope :recurring_series_with_next_events, -> {
  includes(:recurrence, child_events: [:country])
    .where(is_recurring_master: true)
}
```

### 8.3 Cache
```ruby
# Cache para séries frequentemente acessadas
def upcoming_events_cached
  Rails.cache.fetch("event_#{id}_upcoming_events", expires_in: 1.hour) do
    child_events.venontaj.limit(5).includes(:country).to_a
  end
end
```

## 9. Segurança e Validações

### 9.1 Permissões
```ruby
# Verificar se usuário pode editar série
def can_edit_series?(user)
  return false unless user
  return true if user.admin?
  return true if self.user == user

  # Verificar se é membro de organização do evento
  organizations.any? { |org| org.users.include?(user) }
end
```

### 9.2 Limitações
- Máximo de 100 eventos por série
- Máximo de 24 meses de antecedência
- Máximo de 10 séries ativas por usuário não-admin

## 10. Documentação

### 10.1 README para Desenvolvedores
```markdown
# Eventos Recorrentes

## Visão Geral
O sistema de eventos recorrentes permite criar séries de eventos que se repetem automaticamente baseado em regras configuráveis.

## Modelos
- `EventRecurrence`: Armazena regras de recorrência
- `Event`: Estendido com campos para suportar hierarquia de eventos

## Serviços
- `EventServices::CreateRecurring`: Cria evento pai e regra
- `EventServices::GenerateRecurringEvents`: Gera eventos futuros
- `EventServices::UpdateRecurring`: Atualiza séries

## Jobs
- `RecurringEventsGeneratorJob`: Executado diariamente
- `GenerateRecurringEventsJob`: Gera eventos para uma série específica

## Uso
1. Marcar checkbox "Evento recorrente" no formulário
2. Configurar frequência, intervalo e término
3. Sistema gera automaticamente eventos futuros
```

---

## Status do Projeto

**Última atualização:** $(date)
**Status atual:** Planejamento concluído, pronto para implementação
**Próximo passo:** Iniciar Fase 1 - Estrutura Base

---

*Este documento será atualizado conforme o progresso da implementação.*
