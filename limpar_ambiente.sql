set serveroutput on size unlimited;
whenever sqlerror continue

prompt =========================================================================
prompt == LIMPANDO AMBIENTE - Dropando objetos existentes
prompt =========================================================================

prompt >> Dropando procedures
begin
    execute immediate 'drop procedure processa_apostas';
    dbms_output.put_line('Procedure processa_apostas dropada.');
exception
    when others then
        if sqlcode != -4043 then raise; end if;
end;
/

begin
    execute immediate 'drop procedure prc_cadastrar_aposta';
    dbms_output.put_line('Procedure prc_cadastrar_aposta dropada.');
exception
    when others then
        if sqlcode != -4043 then raise; end if;
end;
/

begin
    execute immediate 'drop procedure atualizar_valores_aposta';
    dbms_output.put_line('Procedure atualizar_valores_aposta dropada.');
exception
    when others then
        if sqlcode != -4043 then raise; end if;
end;
/

prompt >> Dropando tabelas
begin
    execute immediate 'drop table apostas cascade constraints';
    dbms_output.put_line('Tabela apostas dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table partidas cascade constraints';
    dbms_output.put_line('Tabela partidas dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table times cascade constraints';
    dbms_output.put_line('Tabela times dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table apostas_final cascade constraints';
    dbms_output.put_line('Tabela apostas_final dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table apostas_temp cascade constraints';
    dbms_output.put_line('Tabela apostas_temp dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table apostadores cascade constraints';
    dbms_output.put_line('Tabela apostadores dropada.');
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

prompt >> Dropando sequences
begin
    execute immediate 'drop sequence seq_apostas_temp';
    dbms_output.put_line('Sequence seq_apostas_temp dropada.');
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

begin
    execute immediate 'drop sequence seq_apostador_id';
    dbms_output.put_line('Sequence seq_apostador_id dropada.');
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

begin
    execute immediate 'drop sequence seq_aposta_id';
    dbms_output.put_line('Sequence seq_aposta_id dropada.');
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

commit;

prompt =========================================================================
prompt == Ambiente limpo - pronto para executar os exercicios
prompt =========================================================================
