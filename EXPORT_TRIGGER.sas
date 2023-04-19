/*LEITURA DO DATA/SET NOVO (ADM+JUD)*/
data nova_base;
set work.trigger_adm work.trigger_jud;
run;

%let DIR_TRIGGER = G:/sasdata/projetos/antifraude/solucao/Grao/Export_Trigger;
%put &DIR_TRIGGER.;

/*DELETAR A VARIÁVEL*/
%symdel ult_arq;
%symdel sequencial;

/*IDENTIFICA O ÚLTIMO ARQUIVO MODIFICADO*/
data ListaArquivos (keep=fname modified);
length fref $8;
if filename(fref,"&DIR_TRIGGER.") = 0
then do;
did = dopen(fref);
if did ne 0
then do;
dnum = dnum(did);
do i = 1 to dnum;
fname = dread(did, i);
fid = mopen(did, fname);
if fid ne 0
then do;
modified = input(finfo(fid,'Last Modified'),DATETIME.);  
output;
fid = dclose(fid);
end;
end;
did = dclose(did);
end;
rc = filename(fref);
end;
run;
proc sort data=ListaArquivos; by descending modified descending fname; run;


data ListaArquivos;
	set ListaArquivos (obs=1);
	if find(fname, "_seq");
	sequencial = substr(fname,12,4);
	call symput('ult_arq',fname);
	call symput('sequencial',sequencial);
run;
%put &ult_arq.;
%put &sequencial.;
%let arq = &DIR_TRIGGER./&ult_arq.;

/*IF PARA VERIFICAR SE HÁ ALGUM ARQUIVO TRIGGER OU DEVE-SE INICIAR DO "ZERO"*/
%macro check_file;
%if %symexist(ult_arq) %then %do;
	%put 'EXISTE ÚLTIMO ARQUIVO DO TRIGGER';

	/*IMPORTA ÚLTIMO AQUIVO IDENTIFICADO*/
	proc import datafile="&arq." out=ult_bse_trigger dbms=csv replace; delimiter=','; run;

	/*IDENTIFICAR A QUANTIDADE DE LINHAS NO ARQUIVO LOCALIZADO E CALACULAR A DIFERENÇA (QTDE LINHAS QUE FALTA INCLUIR)*/
	proc sql;
		select 1000-count(*) into: _num_linhas from ult_bse_trigger;
	quit;
	%put &_num_linhas.;

	/*JUNTAR O DATA/SET ANTERIOR (ult_bse_trigger) COM O NOVO DATA/SET --- SEM LIMITE DE LINHAS*/
	data juncao_base_trigger;
		set ult_bse_trigger nova_base;
	run;

%end;
%else %do;
	%put 'NÃO EXISTE ÚLTIMO ARQUIVO DO TRIGGER';

	/*JUNTAR O DATA/SET ANTERIOR (ult_bse_trigger) COM O NOVO DATA/SET --- SEM LIMITE DE LINHAS*/
	data juncao_base_trigger;
		set nova_base;
	run;
	%global sequencial;
	%let sequencial =0001;
%end;
%mend;
%check_file;

/*A PARTIR DESTE PONTO A ROTINA É IGUAL PARA CASO EXISTA O ÚLTIMO ARQ TRIGGER OU NÃO*/

/*ROTINA EXPORT TRIGGER 1000 EM 1000*/

/*1 - DESCOBRIR QUANTAS INTERAÇÕES O LOOP TERÁ*/
proc sql;
	select count(*), int(count(*)/1000), mod(count(*),1000) into: _num_linhas_total, :_num_interacoes, :_linhas_sobra from juncao_base_trigger;
quit;
%put &_num_linhas_total.;
%put &_num_interacoes.;
%put &_linhas_sobra.;

%macro check_resto;
%if &_linhas_sobra.>0 %then %do; %let _num_interacoes = %EVAL(&_num_interacoes. + 1); %end;
%put &_num_interacoes.;
%mend;
%check_resto;

/*LOOPING E EXPORTAÇÃO 1000 EM 1000*/
%macro exportTriggerFile;
	%do i = 1 %to &_num_interacoes.;
		%if &i. = 1 %then %let _obs_ini = 1; %else %let _obs_ini = %eval(&_obs_ini.+1000);
		%let _obs_fim = &_obs_ini. + 1000;
		%put &_obs_ini.;
		%put &_obs_fim.;
		data base_export_temp;
			set juncao_base_trigger /*(firstobs=&_obs_ini. obs=1000)*/;
			if _N_ >= &_obs_ini. and _N_ < &_obs_fim.;
		run;
		%let sequencial = %sysfunc(putn(&sequencial.,z4));
		%let filepathExport = %sysfunc(trim(&DIR_TRIGGER/SAS_&ANO._seq&sequencial.));
		%put %filepathExport.;
		proc export data=base_export_temp outfile="&filepathExport..csv" dbms=csv replace;run;
		%let sequencial = %eval(&sequencial+1);
	%end;
%mend;
%exportTriggerFile;
