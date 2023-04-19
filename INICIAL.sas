/***** PRIMEIRA ACAO - ENTRADA DAS VARIAVEIS *****/
%PUT &DIR_TRIGGER.;
%PUT &DIRETORIO.;
%PUT &DT_INI.;
%PUT &DT_FIM.;
%PUT &VALIDA.;
data _null_;
	Dt_Inicial="&DT_INI."d;
	Dt_Final ="&DT_FIM."d;  
call symput('Dt_Inicial',Dt_Inicial);
call symput('Dt_Final',Dt_Final);
run;

%PUT &Dt_Inicial.;
%PUT &Dt_Final.;

%let ANO = %sysfunc(year(&Dt_Inicial.));
%put &ANO.;


%let Num_Caso_Adm = ;
%let Num_Caso_Jud = ;

/***** SEGUNDA ACAO - VERIFICA SE EXISTE CASO ABERTO NO PERIODO SELECIONADO *****/
%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/VALIDACAO_Lucas.sas';

/* Chama "VALIDACAO.sas" para retorna quantas alertas estao abertos */
%if &valida. = 'Nao' and &em_aberto. > 0 %then %do;
    %put 'Listar casos em aberto';
	PROC SQL;
	create table work.VALIDACAO_ALERTA_ABERTO as
		select distinct
			'ADM' as operacao,
			hist.Num_Caso,
			datepart(hist.DT_Criacao_Caso) format=ddmmyys10. as Data_Criacao_Caso2
		from Analise.DNA_SAS_CASO_HISTORICO_V5 hist
		where
			datepart(hist.DT_Criacao_Caso) >= &Dt_Inicial.
			and datepart(hist.DT_Criacao_Caso) <= &Dt_Final.
			&Num_Caso_Adm.
		group by hist.Num_Caso
		having max(hist.Row_Number) = hist.Row_Number and Aberto_Fechado = ''
		union
		select distinct
			'JUD' as operacao,
			hist.Num_Caso,
			datepart(hist.DT_Criacao_Caso) format=ddmmyys10. as Data_Criacao_Caso2
		from Analise.DNA_SAS_CASO_HISTORICO_JUD hist
		where
			datepart(hist.DT_Criacao_Caso) >= &Dt_Inicial.
			and datepart(hist.DT_Criacao_Caso) <= &Dt_Final.
			&Num_Caso_Jud.
		group by hist.Num_Caso
		having max(hist.Row_Number) = hist.Row_Number and Aberto_Fechado = ''
	;QUIT;
	proc export 
	data=work.VALIDACAO_ALERTA_ABERTO  
	outfile="&DIRETORIO./Casos_em_aberto.csv"
	dbms=csv replace; 
	run;
	%end;
/* Caso contrario é que nao possui alertas abertos e a exportacao sera iniciada */
%else %do;
%put 'rodar rotina';
/* Chama "ETL_ADM_CASO.sas" para carregar as tabelas do ADMINISTRATIVO */
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/ETL_ADM_CASO_Lucas.sas';
/* Chama "ETL_JUD_CASO.sas" para carregar as tabelas do JUDICIAL */	
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/ETL_JUD_CASO_Lucas.sas';
/*Chama EXPORT_ANEXOS.sas para inciar o processo de gerar e extrair os Anexos*/
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/EXPORT_ANEXOS_Lucas.sas';
/*Chama EXPORT_CSV.sas para inciar o processo de gerar e extrair os csvs*/
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/EXPORT_CSV_Lucas.sas';
/*Chama TRIGGER_ADM.sas para inciar o processo de gerar e extrair os csvs*/
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/TRIGGER_ADM_Lucas.sas';
/*Chama TRIGGER_JUD.sas para inciar o processo de gerar e extrair os csvs*/
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/TRIGGER_JUD_Lucas.sas';
/*Chama EXPORT_TRIGGER_Lucas.sas para inciar o processo de gerar e extrair os csvs*/
	%include 'G:/sasdata/projetos/antifraude/solucao/Grao/Programs/OLD/V2/EXPORT_TRIGGER_Lucas.sas';
%end;
	


