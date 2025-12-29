set serveroutput on size unlimited;

prompt =========================================================================
prompt == EXERCICIO 2 :: FLUXO TRANSACIONAL COM VALIDACOES E PROCESSAMENTO
prompt =========================================================================

prompt Limpando objetos existentes para reexecucao...
begin
    execute immediate 'drop table apostadores cascade constraints';
exception
    when others then
        if sqlcode != -942 then raise; end if;
end;
/

begin
    execute immediate 'drop sequence seq_apostador_id';
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

begin
    execute immediate 'drop sequence seq_aposta_id';
exception
    when others then
        if sqlcode != -2289 then raise; end if;
end;
/

prompt Criando cadastro de apostadores...
create table apostadores (
    apostador_id   number primary key,
    nome           varchar2(120) not null,
    idade          number(3) not null,
    email          varchar2(200) not null unique,
    data_cadastro  timestamp default systimestamp not null
);

create sequence seq_apostador_id
    minvalue 1
    start with 1
    increment by 1
    cache 100;

prompt Criando sequence para gerar aposta_id sequencial...
create sequence seq_aposta_id
    minvalue 1
    start with 1
    increment by 1
    cache 500;

prompt Criando procedure prc_cadastrar_aposta conforme enunciado...
create or replace procedure prc_cadastrar_aposta (
    pis_nome         in apostadores.nome%type,
    pin_idade        in apostadores.idade%type,
    pis_email        in apostadores.email%type,
    pn_valor_aposta  in apostas_temp.valor%type
) is
    vn_apostador_id apostadores.apostador_id%type;
    vn_exist_email  number;

begin
        select count(1)
            into vn_exist_email
            from apostadores
         where upper(email) = upper(pis_email);

    if vn_exist_email > 0 then
        raise_application_error(-20100, 'Email ja cadastrado para outro apostador.');
    end if;

    if pin_idade < 18 then
        raise_application_error(-20101, 'Cadastro rejeitado: idade minima de 18 anos.');
    end if;

    insert into apostadores (
        apostador_id,
        nome,
        idade,
        email,
        data_cadastro
    ) values (
        seq_apostador_id.nextval,
        pis_nome,
        pin_idade,
        pis_email,
        systimestamp
    ) returning apostador_id into vn_apostador_id;

    insert into apostas_temp (
        aposta_id,
        usuario_id,
        valor,
        data_aposta
    ) values (
        seq_aposta_id.nextval,
        vn_apostador_id,
        pn_valor_aposta,
        systimestamp
    );

    processa_apostas;
exception
    when others then
        rollback;
        raise;
end prc_cadastrar_aposta;
/
show errors procedure prc_cadastrar_aposta;
