# Matriz de teste de campo — validação de proximidade via iBeacon

**Branch:** `feat/bt-proximity-attendance`
**Bloqueia merge?** Sim — não mergear sem matriz preenchida com ≥99% de acerto em todos os cenários "dentro da sala".

## Por que isso existe

A precisão de RSSI/CoreLocation iBeacon depende de hardware do device, paredes,
corpos no meio e ruído ambiente. O código mitiga (mediana de N amostras, critério
≥8/10, threshold de 5m) — mas só campo confirma. Esta matriz é o critério objetivo
de "está pronto" antes de habilitar a feature pra alunos reais.

## Setup do teste

- Um iPhone do **professor** rodando a build da branch `feat/bt-proximity-attendance`
  com Bluetooth e localização concedidos. Inicia uma chamada e mantém a tela
  desbloqueada (checklist obrigatório do app garante isso).
- Backend de QA rodando com `attendance.proximity.threshold.meters=5.0` (default).
- Cronômetro de celular separado para medir tempo de detecção.
- Caderno físico ou planilha pra registrar resultados.

## Cenários

Cada célula precisa de **20 tentativas** ("tries") para apurar taxa de acerto.

### Dimensão 1 — Modelos de iPhone do **aluno**

| ID    | Modelo                  | Chip Bluetooth |
|-------|-------------------------|----------------|
| A1    | iPhone 11 (mínimo)      | BLE 5.0        |
| A2    | iPhone 14               | BLE 5.3        |
| A3    | iPhone 15 Pro ou superior | BLE 5.3      |

Se vocês só têm modelos mais novos, ao menos rode A2/A3 e marque A1 como "não testado".

### Dimensão 2 — Distância prof ↔ aluno

| ID  | Distância | Esperado          |
|-----|-----------|-------------------|
| D1  | 1m        | PRESENTE (acerto) |
| D2  | 5m        | PRESENTE (acerto) |
| D3  | 10m       | REJEIÇÃO (acerto) |

### Dimensão 3 — Ambiente

| ID  | Cenário                                    |
|-----|--------------------------------------------|
| E1  | Sala vazia                                 |
| E2  | Sala cheia (≥15 pessoas em pé entre prof e aluno) |
| E3  | Parede de tijolo entre prof e aluno        |

## Tabela de resultados (preencher)

> **Métricas**:
> - **Acertos**: número de tentativas em que o sistema decidiu igual ao esperado.
> - **Tempo médio**: tempo entre abrir o fluxo no app do aluno até `phase == .codeEntry` ou `.outOfRange`.
> - **Acurácia mediana**: valor médio do `accuracy` reportado pelo `BeaconRanger.Reading` em metros.

| Modelo | Distância | Ambiente | Acertos / 20 | Tempo médio | Acurácia mediana | OK? (≥19/20 e <3s) |
|--------|-----------|----------|--------------|-------------|------------------|---------------------|
| A1     | D1 (1m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D1 (1m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D1 (1m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D2 (5m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D2 (5m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D2 (5m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D3 (10m)  | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D3 (10m)  | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A1     | D3 (10m)  | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D1 (1m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D1 (1m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D1 (1m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D2 (5m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D2 (5m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D2 (5m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D3 (10m)  | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D3 (10m)  | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A2     | D3 (10m)  | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D1 (1m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D1 (1m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D1 (1m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D2 (5m)   | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D2 (5m)   | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D2 (5m)   | E3       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D3 (10m)  | E1       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D3 (10m)  | E2       | ___ / 20     | ___ s       | ___ m            |                     |
| A3     | D3 (10m)  | E3       | ___ / 20     | ___ s       | ___ m            |                     |

## Critério de aceite

- **Dentro da sala (D1, D2):** ≥19 acertos em 20 tentativas (≥95%) em E1/E2 e ≥18/20 (≥90%) em E3.
- **Fora da sala (D3):** ≥19 acertos em 20 tentativas em qualquer cenário.
- **Tempo médio de decisão:** < 3s em qualquer cenário "dentro da sala", < 10s ("timeout" do ranger) pra rejeição.

Qualquer célula fora desse critério bloqueia merge — ajustar `proximityThresholdMeters`
ou `minValidSamples` / `windowSize` e refazer a célula.

## Cenários de falha controlada — também precisa testar

| Caso | Esperado |
|------|----------|
| Prof bloqueia a tela durante chamada | App mostra alerta de interrupção; alunos passam a falhar até prof reabrir |
| Prof troca de app durante chamada | Mesmo do anterior |
| Aluno entra na sala faltando 1 minuto pra fim | Detecta em <3s, registra PRESENTE |
| Bluetooth desligado no celular do aluno | OutOfRange dentro de 10s, mensagem clara |
| Bluetooth desligado no celular do prof | Banner do prof fica vermelho "Bluetooth desligado", nenhuma presença registra |

## Observações de campo (preencher)

> Anote anomalias relevantes: salas com forte interferência (perto de antena Wi-Fi),
> casos onde a mediana ficou inconsistente, casos onde aluno foi "near" mas a
> validação falhou, etc. Esses notes guiam a calibração futura.

(em branco — preencher após a sessão de campo)
