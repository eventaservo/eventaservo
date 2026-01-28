# Plano de Upgrade: Bootstrap 4 → Bootstrap 5

## Status: CONCLUÍDO ✓

## Resumo

Upgrade do Bootstrap 4.6.2 para Bootstrap 5.3 no projeto EventaServo (Rails 7.2). O projeto usa uma arquitetura híbrida de JavaScript: Sprockets (jQuery/Bootstrap) + esbuild (Stimulus).

## Decisões de Arquitetura

- **Manter jQuery**: O projeto depende de fullcalendar-rails, jquery-mask, jquery-smartphoto e jquery-ui. Bootstrap 5 funciona com jQuery (apenas não o requer).
- **Abordagem incremental**: Fazer mudanças em fases com testes entre cada fase.

---

## Fase 1: Atualizar Gem e Dependências

**Status:** [x] Concluído

### Arquivos a modificar:
- `Gemfile` (linha 22)

### Mudanças:
```ruby
# De:
gem "bootstrap", "~> 4.3"

# Para:
gem "bootstrap", "~> 5.3"
```

### Comandos:
```bash
bundle update bootstrap
```

---

## Fase 2: Atualizar JavaScript

**Status:** [x] Concluído

### 2.1 Arquivo: `app/assets/javascripts/application_pipeline.js`

**Mudanças:**
- Linha 18: Manter `bootstrap-sprockets` (a gem bootstrap 5 continua suportando)
- Linha 30: Remover ou atualizar o override do modal (Bootstrap 5 tem melhor gerenciamento de foco)

```javascript
// Remover esta linha (testar se ainda é necessária):
$.fn.modal.Constructor.prototype._enforceFocus = function () { }
```

### 2.2 Arquivo: `app/assets/javascripts/turbolinks_load.js` (linha 20)

```javascript
// De:
$('[data-toggle="tooltip"]').tooltip();

// Para:
$('[data-bs-toggle="tooltip"]').tooltip();
```

### 2.3 Arquivo: `app/javascript/controllers/report_problem_form_controller.js`

Os eventos `shown.bs.modal` continuam funcionando no Bootstrap 5. Não precisa de mudanças.

---

## Fase 3: Atualizar Data Attributes nas Views (~36 ocorrências)

**Status:** [x] Concluído

### Mudanças necessárias:
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `data-toggle` | `data-bs-toggle` |
| `data-dismiss` | `data-bs-dismiss` |
| `data-target` | `data-bs-target` |
| `data-placement` | `data-bs-placement` |

### Arquivos atualizados:
- [x] `app/views/layouts/_navbar.html.erb` - navbar toggler
- [x] `app/views/layouts/_uzanto.html.erb` - dropdown do usuário
- [x] `app/views/layouts/_admin.html.erb` - dropdown admin
- [x] `app/views/layouts/_navbar_tools.html.erb` - tooltips (5 ocorrências)
- [x] `app/views/layouts/navbar/_language_selector.html.erb` - dropdown
- [x] `app/views/events/_form.html.erb` - modals e button groups
- [x] `app/views/events/_options.html.erb` - dropdown e modal
- [x] `app/views/events/_report_problem_modal.html.erb`
- [x] `app/views/events/_cancel_event_modal.html.erb`
- [x] `app/views/layouts/_flash.html.erb` - alert dismiss
- [x] `app/views/layouts/_footer.html.erb` - dropdown
- [x] `app/views/organizations/_search_results.html.erb` - tooltips
- [x] `app/views/devise/registrations/_instruisto_form.html.erb` - btn-group
- [x] `app/views/events/_add_to_calendar.html.erb` - dropdown
- [x] `app/views/events/_timezone_modal.html.erb` - modal
- [x] `app/views/events/_partoprenonta_listo.html.erb` - modal
- [x] `app/views/events/_share_button_modal.html.erb` - modal
- [x] `app/views/events/by_continent.html.erb` - modal
- [x] `app/views/events/by_username.html.erb` - modal
- [x] `app/views/events/by_country.html.erb` - modal
- [x] `app/views/organizations/show.html.erb` - modal

---

## Fase 4: Atualizar Classes CSS Utilitárias (~40 ocorrências)

**Status:** [x] Concluído

### 4.1 Espaçamento (margin/padding)
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `ml-*` | `ms-*` |
| `mr-*` | `me-*` |
| `pl-*` | `ps-*` |
| `pr-*` | `pe-*` |

### 4.2 Float e Alinhamento de Texto
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `float-left` | `float-start` |
| `float-right` | `float-end` |
| `text-left` | `text-start` |
| `text-right` | `text-end` |

### 4.3 Font Weight
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `font-weight-bold` | `fw-bold` |
| `font-weight-normal` | `fw-normal` |

### Arquivos atualizados:
- [x] `app/views/events/_form.html.erb` - `float-end`, `float-start`
- [x] `app/views/events/show.html.erb` - múltiplas classes utilitárias
- [x] `app/views/events/_user_social_links.html.erb` - `me-1`
- [x] `app/views/organizations/show.html.erb` - classes utilitárias
- [x] `app/views/home/index.html.erb` - `fw-bold`, `me-2`
- [x] `app/views/events/_okazantaj.html.erb` - `fw-bold`, `ps-4`
- [x] `app/views/events/_horzono.html.erb` - `float-end`
- [x] `app/views/events/_horoj.html.erb` - `text-end`, `fw-bold`
- [x] `app/views/events/_event_reports_sidebar.html.erb` - `text-end`, `float-end`
- [x] `app/views/events/_mi_interesighas_button.html.erb` - `w-100`, `fw-bold`
- [x] `app/views/events/_partoprenanta_butono.html.erb` - `fw-bold`
- [x] `app/views/events/_list.html.erb` - `fw-bold`
- [x] `app/views/events/_events_as_cards.html.erb` - `fw-bold`
- [x] `app/views/devise/registrations/edit.html.erb` - `float-end`, `float-start`, `fw-bold`
- [x] `app/views/devise/sessions/new.html.erb` - `text-end`, `fw-bold`
- [x] `app/views/home/prie.html.erb` - `text-end`
- [x] `app/views/video/new.html.erb` - `ms-2`
- [x] `app/views/international_calendar/year_list.html.erb` - `fw-bold`
- [x] `app/views/event/report/_events_with_report_list.html.erb` - `text-end`
- [x] `app/views/iloj/mallongilo/disponeblas.turbo_stream.erb` - `text-end`
- [x] `app/views/layouts/_navbar_tools.html.erb` - `me-2`
- [x] `app/views/layouts/_navbar_search.html.erb` - `me-2`
- [x] `app/views/organizations/_main_organizations.html.erb` - `me-2`
- [x] Todas as views com `text-left` → `text-start` (modais)

---

## Fase 5: Atualizar Classes de Componentes

**Status:** [x] Concluído

### 5.1 Botão Close (~10 ocorrências)
```html
<!-- De: -->
<button class="close" data-dismiss="alert"><span>&times;</span></button>

<!-- Para: -->
<button class="btn-close" data-bs-dismiss="alert"></button>
```

### 5.2 Badges
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `badge-primary` | `text-bg-primary` |
| `badge-info` | `text-bg-info` |
| `badge-pill` | `rounded-pill` |
| `badge-light` | `text-bg-light` |

### 5.3 Dropdown Menu
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `dropdown-menu-right` | `dropdown-menu-end` |

### 5.4 Formulários
| Bootstrap 4 | Bootstrap 5 |
|-------------|-------------|
| `form-row` | `row` |
| `input-group-append` | (remover wrapper) |
| `input-group-prepend` | (remover wrapper) |
| `custom-control custom-switch` | `form-check form-switch` |

### 5.5 Button Block
```html
<!-- De: -->
<button class="btn btn-primary btn-block">

<!-- Para: -->
<button class="btn btn-primary w-100">
```

### Arquivos atualizados:
- [x] `app/views/layouts/_flash.html.erb` - `btn-close`
- [x] `app/views/home/_filters.html.erb` - badges com `rounded-pill text-bg-info/text-bg-light`
- [x] `app/views/home/_instruisto_karto.html.erb` - `text-bg-info`
- [x] `app/views/users/_instruist_profilo.html.erb` - `text-bg-info`
- [x] `app/views/events/_mi_interesighas_button.html.erb` - `w-100`
- [x] `app/views/events/_form.html.erb` - `row`, input-group estrutura
- [x] `app/views/events/by_continent.html.erb` - badges, input-group
- [x] `app/views/events/by_country.html.erb` - badges, input-group
- [x] `app/views/events/by_username.html.erb` - input-group
- [x] `app/views/home/index.html.erb` - badges

---

## Fase 6: Atualizar SCSS

**Status:** [x] Concluído

### Arquivos atualizados:

#### `app/assets/stylesheets/partials/_buttons.scss`
- `@extend .btn-block` → `@extend .w-100`
- `@extend .mr-1` → `@extend .me-1`
- `@extend .rounded-sm` → `@extend .rounded-1`

#### `app/assets/stylesheets/partials/_es-lists.scss`
- `@extend .pl-2` → `@extend .ps-2`
- `@extend .pr-2` → `@extend .pe-2`

#### `app/assets/stylesheets/partials/_event-count.sass`
- `@extend .pl-3` → `@extend .ps-3`

#### `app/assets/stylesheets/partials/_organizations.sass`
- `@extend .badge-light` → `@extend .text-bg-light`

---

## Verificação

### Testes Automatizados
```bash
bin/rails test
bin/rails test:system
```

### Checklist de Testes Manuais

**Navegação:**
- [ ] Navbar collapse/expand em mobile
- [ ] Menus dropdown (usuário, idioma, admin)
- [ ] Busca funcionando

**Modais:**
- [ ] Modal de reportar problema
- [ ] Modal de cancelar evento
- [ ] Modal de timezone
- [ ] Modal de compartilhar

**Formulários:**
- [ ] Criação de evento com tags (btn-group-toggle → btn-check)
- [ ] Date pickers (jquery-ui)
- [ ] Máscaras de input (jquery-mask)

**Tooltips:**
- [ ] Tooltips na navbar de ferramentas

**Alertas Flash:**
- [ ] Fechar alertas com botão close

---

## Arquivos Críticos (Total: ~55 arquivos)

### Configuração:
1. `Gemfile`
2. `app/assets/javascripts/application_pipeline.js`
3. `app/assets/javascripts/turbolinks_load.js`

### Views com mais mudanças:
4. `app/views/events/_form.html.erb`
5. `app/views/layouts/_navbar.html.erb`
6. `app/views/layouts/_flash.html.erb`
7. `app/views/events/_report_problem_modal.html.erb`

### SCSS:
8. `app/assets/stylesheets/partials/_buttons.scss`

---

## Log de Execução

| Data | Fase | Ação | Status |
|------|------|------|--------|
| 2026-01-19 | Fase 1 | Atualizado `gem "bootstrap"` de 4.3 para 5.3 | Concluído |
| 2026-01-19 | Fase 1 | Executado `bundle update bootstrap` - instalado 5.3.8 | Concluído |
| 2026-01-19 | Fase 2 | Atualizado seletor tooltip em `turbolinks_load.js` | Concluído |
| 2026-01-19 | Fase 2 | Removido modal focus override em `application_pipeline.js` | Concluído |
| 2026-01-19 | Fase 3 | Atualizados data-toggle, data-dismiss, data-target, data-placement em 21 arquivos | Concluído |
| 2026-01-19 | Fase 4 | Atualizados ml→ms, mr→me, pl→ps, pr→pe em views | Concluído |
| 2026-01-19 | Fase 4 | Atualizados float-left→float-start, float-right→float-end | Concluído |
| 2026-01-19 | Fase 4 | Atualizados text-left→text-start, text-right→text-end | Concluído |
| 2026-01-19 | Fase 4 | Atualizados font-weight-bold→fw-bold | Concluído |
| 2026-01-19 | Fase 5 | Atualizados badges (badge-info→text-bg-info, badge-pill→rounded-pill) | Concluído |
| 2026-01-19 | Fase 5 | Atualizados btn-close, w-100, form-row→row, input-group | Concluído |
| 2026-01-19 | Fase 6 | Atualizados SCSS: _buttons.scss, _es-lists.scss, _event-count.sass, _organizations.sass | Concluído |
