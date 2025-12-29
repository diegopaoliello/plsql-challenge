set serveroutput on size unlimited;

prompt =========================================================================
prompt == EXERCICIO 3 :: IDENTIFICACAO E CORRECAO DE BUG NA LOGICA
prompt =========================================================================

prompt Limpando objetos existentes para reexecucao...
begin
    execute immediate 'drop table apostas cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table partidas cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table times cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

prompt Criando tabela times conforme enunciado...
CREATE TABLE times (
    id NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    pontos NUMBER
);

prompt Criando tabela partidas...
CREATE TABLE partidas (
    id NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    data_hora TIMESTAMP,
    id_time1 NUMBER,
    id_time2 NUMBER,
    FOREIGN KEY (id_time1) REFERENCES times(id),
    FOREIGN KEY (id_time2) REFERENCES times(id)
);

prompt Criando tabela apostas...
CREATE TABLE apostas (
    id NUMBER PRIMARY KEY,
    id_partida NUMBER,
    id_time NUMBER,
    valor_aposta NUMBER,
    FOREIGN KEY (id_partida) REFERENCES partidas(id),
    FOREIGN KEY (id_time) REFERENCES times(id)
);

/*
Bug legado: v_tempo_restante era v_data_hora - systimestamp. Partidas passadas geravam
valor negativo, ainda assim < 1 hora e entravam no update. Ademais, o cursor loop processava
linha-a-linha e ignorava o fator_pontos definido. A refatoracao abaixo troca por um update
set-based, filtra apenas partidas futuras dentro da janela de 1 hora e aplica ambos fatores.
*/

prompt Refatorando procedure atualizar_valores_aposta...
create or replace procedure atualizar_valores_aposta is
    c_fator_tempo  constant number := 1.5;
    c_fator_pontos constant number := 2.0;
    v_now timestamp := current_timestamp;
    v_rows_updated number := 0;
begin
    update apostas a
       set a.valor_aposta = (
           select ((a.valor_aposta * (1 + (c_fator_pontos * t.pontos) / 100)) * c_fator_tempo)
             from partidas p
             join times t on t.id = a.id_time
            where p.id = a.id_partida
              and p.data_hora > v_now
              and p.data_hora <= v_now + interval '1' hour
       )
     where exists (
           select 1
             from partidas p
            where p.id = a.id_partida
              and p.data_hora > v_now
              and p.data_hora <= v_now + interval '1' hour
       );

    v_rows_updated := sql%rowcount;
    dbms_output.put_line('Apostas atualizadas: ' || v_rows_updated);

    commit;
exception
    when others then
        rollback;
        raise;
end atualizar_valores_aposta;
/
show errors procedure atualizar_valores_aposta;
