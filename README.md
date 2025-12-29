# PL/SQL Challenge

Este repositório contém a solução para os três exercícios descritos no teste técnico de Analista de Desenvolvimento de Sistemas (foco em PL/SQL). Cada exercício foi implementado em um script independente para facilitar leitura e execução.

Para os enunciados completos e versões originais das procedures, consulte [exercicios.md](exercicios.md).

## Exercício 1 – Processamento de Apostas com Performance
Arquivo: `exercicio_1.sql`

- Cria as tabelas `apostas_temp` e `apostas_final`.
- Implementa uma versão otimizada da procedure `processa_apostas`, eliminando o processamento row-by-row.
- Utiliza `BULK COLLECT ... LIMIT` (10.000 linhas por lote) e `FORALL ... SAVE EXCEPTIONS` para garantir performance mesmo em cenários de alta volumetria.
- Após processar cada lote, remove da staging apenas as apostas inseridas com sucesso e escreve as falhas em `DBMS_OUTPUT` para depuração.

## Exercício 2 – Workflow Transacional Seguro
Arquivo: `exercicio_2.sql`

- Cria a tabela `apostadores` e as sequences `seq_apostador_id` e `seq_aposta_id`.
- Expõe a procedure `prc_cadastrar_aposta`, que recebe nome, idade, e-mail e valor:
  - Valida unicidade do e-mail.
  - Verifica idade mínima de 18 anos.
  - Insere o apostador, cria o lançamento em `apostas_temp` com `aposta_id` sequencial e chama `processa_apostas` para efetivar o processamento.
- Toda a lógica fica em uma única transação (rollback em caso de falha).

## Exercício 3 – Depuração e Ajuste de Regras de Negócio
Arquivo: `exercicio_3.sql`

- Cria as tabelas `times`, `partidas` e `apostas` conforme o enunciado.
- Corrige o bug legado da `atualizar_valores_aposta`, que atualizava partidas já passadas porque calculava `tempo_restante` com sinal invertido.
- Refatora para um único `UPDATE` set-based que:
  - Considera apenas partidas futuras dentro da janela de 1 hora usando `current_timestamp` (evita tempo negativo).
  - Aplica, em conjunto, o fator de tempo e o fator de pontos.
  - Mantém a transação consistente com tratamento de exceções.
  - Exemplo: partida futura em 30 min com 55 pontos passa de 100 → 285; partida já passada (2h) permanece 120.

## Como Executar

- Validação completa (roda os três exercícios e popula os testes):
  - `sql usuario/senha@conexao @validar_exercicios.sql`
- Exercícios individuais (um por vez):
  - `sql usuario/senha@conexao @exercicio_1.sql`
  - `sql usuario/senha@conexao @exercicio_2.sql`
  - `sql usuario/senha@conexao @exercicio_3.sql`
- Limpeza do ambiente (descarta procedures, tabelas e sequences antes de reexecutar):
  - `sql usuario/senha@conexao @limpar_ambiente.sql`

## Observações

- O script `validar_exercicios.sql` chama `limpar_ambiente.sql` antes de criar tudo de novo.
- Todas as procedures tratam exceções com `ROLLBACK` para garantir integridade transacional.
- Ajuste o tamanho do lote (`c_batch_limit`) na `processa_apostas` caso o ambiente tenha restrições diferentes de PGA.
