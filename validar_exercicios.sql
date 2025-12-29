set serveroutput on size unlimited;
whenever sqlerror exit sql.sqlcode

prompt =========================================================================
prompt == Rodando scripts dos Exercicios 1, 2 e 3
prompt =========================================================================

prompt >> Exercício 1
@exercicio_1.sql

prompt >> Exercício 2
@exercicio_2.sql

prompt >> Exercício 3
@exercicio_3.sql

prompt =========================================================================
prompt == Populando dados de teste
prompt =========================================================================

prompt >> Inserindo apostadores e apostas temporárias
insert into apostadores (apostador_id, nome, idade, email, data_cadastro)
values (seq_apostador_id.nextval, 'Alice Tester', 28, 'alice@test.local', systimestamp);
insert into apostas_temp (aposta_id, usuario_id, valor, data_aposta)
select seq_aposta_id.nextval, a.apostador_id, 150.00, systimestamp from apostadores a where a.email = 'alice@test.local';

insert into apostadores (apostador_id, nome, idade, email, data_cadastro)
values (seq_apostador_id.nextval, 'Bob Tester', 35, 'bob@test.local', systimestamp);
insert into apostas_temp (aposta_id, usuario_id, valor, data_aposta)
select seq_aposta_id.nextval, a.apostador_id, 200.00, systimestamp from apostadores a where a.email = 'bob@test.local';

commit;

prompt >> Processando apostas (bulk)
exec processa_apostas;

prompt >> Conferindo movimentação
select count(*) as qtd_temp from apostas_temp;
select count(*) as qtd_final from apostas_final;
select * from apostas_final order by aposta_id fetch first 5 rows only;

prompt =========================================================================
prompt == Dados e teste para Exercício 2 (workflow)
prompt =========================================================================

declare
begin
  prc_cadastrar_aposta(
    pis_nome        => 'Carlos Workflow',
    pin_idade       => 22,
    pis_email       => 'carlos.workflow@test.local',
    pn_valor_aposta => 300.00
  );
end;
/

select * from apostadores where email = 'carlos.workflow@test.local';
select * from apostas_final order by aposta_id fetch first 5 rows only;

prompt =========================================================================
prompt == Dados e teste para Exercício 3 (debug set-based)
prompt =========================================================================

prompt >> Inserindo times
insert into times (id, nome, pontos) values (1, 'Time Casa', 45);
insert into times (id, nome, pontos) values (2, 'Time Visitante', 55);

prompt >> Inserindo partidas (uma futura, uma passada)
insert into partidas (id, nome, data_hora, id_time1, id_time2) values (10, 'Final Futuras', current_timestamp + interval '30' minute, 1, 2);
insert into partidas (id, nome, data_hora, id_time1, id_time2) values (11, 'Final Passadas', current_timestamp - interval '2' hour, 1, 2);

prompt >> Inserindo apostas vinculadas
insert into apostas (id, id_partida, id_time, valor_aposta) values (1001, 10, 1, 100.00);
insert into apostas (id, id_partida, id_time, valor_aposta) values (1002, 11, 2, 120.00);

commit;

prompt >> Rodando atualizar_valores_aposta
exec atualizar_valores_aposta;

prompt >> Conferindo apostas atualizadas (apenas partidas futuras dentro de 1 hora)
select * from apostas where id in (1001, 1002) order by id;

prompt =========================================================================
prompt == Fim da validação
prompt =========================================================================
exit