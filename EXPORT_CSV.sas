/******EXPORT CSV*********/

/******INICIO DELETE ARQUIVOS************/
options nosource nonotes;
data have;
rc=filename('xx','G:/sasdata/projetos/antifraude/solucao/Grao/Export/');
did=dopen('xx');
do i=1 to dnum(did);
fname=dread(did,i);
output;
end;
rc=dclose(did);
run;
%macro dfile(fname=);
data _null_;
rc=filename('temp',"G:/sasdata/projetos/antifraude/solucao/Grao/Export/&fname.");
if rc=0 and fexist('temp') then rc=fdelete('temp');
rc=filename('temp');
put _all_;
run;
%mend;
data _null_;
 set have;
 call execute(cats('%dfile(fname=',fname,')'));
run;
options source notes;
/******FIM DELETE ARQUIVOS************/

%macro export(Numero_Caso, base);

data basetemp;
set &base.;
where Numero_Caso ="&Numero_Caso.";
run;

proc export data=basetemp  
  outfile="&DIRETORIO./&base._&Numero_Caso..csv"
  dbms=csv replace; 
run;

%mend;

/****Export SAS_ADM_Dados****/
proc sort data=work.SAS_ADM_Dados out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_ADM_Dados';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_ADM_Alertas****/
proc sort data=work.SAS_ADM_Alertas out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_ADM_Alertas';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_ADM_Historico****/
proc sort data=work.SAS_ADM_Historico out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_ADM_Historico';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_ADM_Recebedor****/
proc sort data=work.SAS_ADM_Recebedor out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_ADM_Recebedor';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_ADM_Representante****/
proc sort data=work.SAS_ADM_Representante out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_ADM_Representante';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;

/***************************************************************************************************/
/****Export SAS_JUD_Dados****/
proc sort data=work.SAS_JUD_Dados out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_Dados';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_JUD_Historico****/
proc sort data=work.SAS_JUD_Historico out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_Historico';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_JUD_Alertas*****/
proc sort data=work.SAS_JUD_Alertas out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_Alertas';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_JUD_PastaJud*****/
proc sort data=work.SAS_JUD_PastaJud out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_PastaJud';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_JUD_PessoaJud*****/
proc sort data=work.SAS_JUD_PessoaJud out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_PessoaJud';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


/****Export SAS_JUD_VeiculoJud*****/
proc sort data=work.SAS_JUD_VeiculoJud out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='SAS_JUD_VeiculoJud';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;

/****Export Anexos_Metadados*****/
proc sort data=meta_anexos_ADM out=loop nodupkey;
  by Numero_Caso;
run;

data _null_;
  set loop;
  base='meta_anexos_ADM';
  call execute(cats('%nrstr(%export(',Numero_Caso,',',base,'));'));
run;


