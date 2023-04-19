libname fdhdata odbc datasrc=svi_pg user='cloud-user' pw="{SAS002}9AA3E9543D60DCE83752A87B4DF92ECF0F0864A4220A534E" schema='fdhdata';
libname catalog odbc datasrc=svi_pg user='cloud-user' pw="{SAS002}9AA3E9543D60DCE83752A87B4DF92ECF0F0864A4220A534E" schema='pg_catalog';
libname files odbc datasrc=svi_pg user='cloud-user' pw="{SAS002}9AA3E9543D60DCE83752A87B4DF92ECF0F0864A4220A534E" schema='files';

/******QUERY METADADOS DOS ANEXOS******/
proc sql;
create table meta_anexos_ADM as
select distinct 
dh_file.document_type_nm,
datepart(dh_file.uploaded_at_dttm - 60*60*3) format=ddmmyys10. as Data_Criacao_Caso, 
dh_file.document_id as Numero_Caso,
dh_file.type_nm, 
dh_file.name_nm, 
dh_file.size_no,
dh_file.uploaded_by_id
	from fdhdata.dh_file as dh_file  
	inner join Analise.DNA_SAS_CASO_HISTORICO_V5 as hist on  hist.Num_Caso = dh_file.document_id
		where
		datepart(hist.DT_Criacao_Caso) >= &Dt_Inicial.
		and datepart(hist.DT_Criacao_Caso) <= &Dt_Final.
;quit;


proc sql;
create table meta_anexos_JUD as
select distinct 
dh_file.document_type_nm,
datepart(dh_file.uploaded_at_dttm - 60*60*3) format=ddmmyys10. as Data_Criacao_Caso, 
dh_file.document_id as Numero_Caso,
dh_file.type_nm, 
dh_file.name_nm, 
dh_file.size_no,
dh_file.uploaded_by_id
	from fdhdata.dh_file as dh_file  
	inner join Analise.DNA_SAS_CASO_HISTORICO_JUD as hist on  hist.Num_Caso = dh_file.document_id
		where
		datepart(hist.DT_Criacao_Caso) >= &Dt_Inicial.
		and datepart(hist.DT_Criacao_Caso) <= &Dt_Final.;
quit;

/******DATA GUIDE PARA PGADMIN*****/
data _null_;
dt_ini = put(&Dt_Inicial.,yymmdd10.);

dt_txt_ini = trim(cats("'",catx(" ",dt_ini,'00:00:00'),"'"));
call symput("dt_txt_ini",dt_txt_ini);
dt_fim = put(&Dt_Final.,yymmdd10.);

dt_txt_fim = trim(cats("'",catx(" ",dt_fim,'23:59:59'),"'"));
call symput("dt_txt_fim",dt_txt_fim);
run;

%put &dt_txt_ini.;
%put &dt_txt_fim.;


/******QUERY EXPORTAÇÃO DOS ANEXOS SAS GUIDE*****/
proc sql;
connect to odbc(dsn=svi_pg user='cloud-user' password="{SAS002}9AA3E9543D60DCE83752A87B4DF92ECF0F0864A4220A534E");
create table work.teste as
	select *
	from connection to odbc(
	select
		lo_export(file_content.content_data_oid_no, concat('/grao/', dh_file.document_id,'__', dh_file.name_nm))
	from fdhdata.dh_file as dh_file
	inner join files.file_meta as file_meta on (dh_file.file_id = file_meta.file_id)
	inner join files.file_content as file_content on (file_meta.content_id = file_content.content_id)
	inner join (select distinct caso_id, alerta_id
				from(
				select distinct caso_jud_id as caso_id, alerta_id
				from fdhdata.view_caso_judicial_historico
				union
				select distinct caso_id, alert_id as alerta_id
				from fdhdata.view_caso_alerta
				union
				select distinct caso_id, alerta_id
				from fdhdata.view_caso_historico
				)as dp) as dpara on (dh_file.document_id=dpara.caso_id)
	inner join svi_alerts.tdc_alert as alert on(alert.alert_id=dpara.alerta_id)
	where alert.created_dttm >= &dt_txt_ini.
	and alert.created_dttm <= &dt_txt_fim.
	);
disconnect from odbc;
quit;
