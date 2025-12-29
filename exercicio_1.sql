set serveroutput on size unlimited;

prompt =========================================================================
prompt == EXERCICIO 1 :: PROCESSAMENTO DE APOSTAS COM BULK COLLECT/FORALL
prompt =========================================================================

prompt Limpando objetos existentes para reexecucao...
begin
    execute immediate 'drop table apostas_temp cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop table apostas_final cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop sequence seq_apostas_temp';
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

prompt Criando tabela apostas_temp conforme enunciado...
CREATE TABLE apostas_temp (
    aposta_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    data_aposta DATE NOT NULL,
    PRIMARY KEY (aposta_id)
);

create sequence seq_apostas_temp
    minvalue 1
    start with 1
    increment by 1
    cache 100;

prompt Criando tabela apostas_final conforme enunciado...
CREATE TABLE apostas_final (
    aposta_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    data_aposta DATE NOT NULL,
    PRIMARY KEY (aposta_id)
);

prompt Criando procedure processa_apostas otimizada...
create or replace procedure processa_apostas is
    type tp_aposta_tab is table of apostas_temp%rowtype;
    type tp_aposta_id_tab is table of apostas_temp.aposta_id%type;
    type tp_failed_idx is table of boolean index by pls_integer;

    cursor cur_apostas is
        select *
          from apostas_temp
         order by aposta_id;

    c_batch_limit constant pls_integer := 10000; -- protege PGA em cenarios > 100k linhas.

    vt_apostas         tp_aposta_tab;
    vt_ids_processadas tp_aposta_id_tab := tp_aposta_id_tab();
    vt_falhas          tp_failed_idx := tp_failed_idx();

    ex_bulk_errors exception;
    pragma exception_init(ex_bulk_errors, -24381);
begin
    open cur_apostas;
    loop
        fetch cur_apostas bulk collect into vt_apostas limit c_batch_limit;
        exit when vt_apostas.count = 0;

        vt_falhas := tp_failed_idx();
        vt_ids_processadas := tp_aposta_id_tab();

        begin
            forall i in 1 .. vt_apostas.count save exceptions
                insert into apostas_final (
                    aposta_id,
                    usuario_id,
                    valor,
                    data_aposta
                ) values (
                    vt_apostas(i).aposta_id,
                    vt_apostas(i).usuario_id,
                    vt_apostas(i).valor,
                    vt_apostas(i).data_aposta
                );
        exception
            when ex_bulk_errors then
                for idx in 1 .. sql%bulk_exceptions.count loop
                    vt_falhas(sql%bulk_exceptions(idx).error_index) := true;
                    dbms_output.put_line(
                        'Erro ao processar aposta ID ' ||
                        vt_apostas(sql%bulk_exceptions(idx).error_index).aposta_id ||
                        ': ' || sqlerrm(-sql%bulk_exceptions(idx).error_code)
                    );
                end loop;
        end;

        for i in 1 .. vt_apostas.count loop
            if not vt_falhas.exists(i) then
                vt_ids_processadas.extend;
                vt_ids_processadas(vt_ids_processadas.count) := vt_apostas(i).aposta_id;
            end if;
        end loop;

        if vt_ids_processadas.count > 0 then
            forall i in 1 .. vt_ids_processadas.count
                delete from apostas_temp
                 where aposta_id = vt_ids_processadas(i);
        end if;
    end loop;
    close cur_apostas;

    commit;
exception
    when others then
        rollback;
        raise;
end processa_apostas;
/
show errors procedure processa_apostas;