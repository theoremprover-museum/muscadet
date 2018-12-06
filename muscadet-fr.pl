%% Copyright 2008 Crip5 Dominique Pastre

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Muscadet version 4.7.6   %%   
%%      03/09/2018            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% muscadet-fr est la version Prolog française de MUSCADET

%% le script linux musca-fr appelle swi-prolog et charge muscadet-fr


%%%%%%%%%%%%%%%%%%
%% declarations %%
%%%%%%%%%%%%%%%%%%

%% (sous-)th N désigne le (sous-)théorème dont le numéro est N
 
%% hyp(N,H,E) : H est une hypothèse du (sous-)th N introduite à l'etape E
:-dynamic hyp/3.
:-dynamic hyp_traite/2.
:-dynamic ou_applique/1.
%% concl(N,C,E) : C est la conclusion du (sous-)th N à l'etape E
:-dynamic concl/3. 
:-dynamic lien/2.
%% sousth(N,N1) : N1 est le numéro d'un sous-th du (sous-)th N
:-dynamic sousth/2. 
%% objet(N,O) : O is an object of (sub-)th N
:-dynamic objet/2.
%% reglactiv(N,LR): LR est la liste des noms des règles actives du (sous-)th N
:-dynamic reglactiv/2. 
:-dynamic regle/2. 
:-dynamic concept/1.
:-dynamic fonction/2.  
:-dynamic type/2.
:-dynamic avecseulile/0.   
:-dynamic definition/2. 
:-dynamic definition/1. 
:-dynamic definition1/2. %1.
:-dynamic lemme/2. 
:-dynamic lemme1/2.
:-dynamic version/1.
:-dynamic ecrireconsreg/0.
:-dynamic tempslimite/1. 
:-dynamic tempspasse/1. 
:-dynamic temps_debut/1. 
:-dynamic conjecture/2.
:-dynamic seulile/1.
:-dynamic include/1. 
:-dynamic fof/3.
:-dynamic fof_traitee/3.
:-multifile fof/3.
:- dynamic probleme/1.
:- dynamic priorite/2.
:- dynamic priorites/1.
:- dynamic etape/1. 
:- dynamic nbhypexi/1. 
:- dynamic lengthmaxpr/1. 
:- dynamic afficher/1. 
:- dynamic lang/1.
:- dynamic chemin/1.
:- dynamic res/1.
:- dynamic theoreme/1.
:- dynamic th/1.
:- dynamic theoreme/2.
:- dynamic theorem/2. 
:- dynamic include/1.


nbhypexi(0).  %% pour compter les hypothèses existentielles 
lengthmaxpr(12000). %% limite pour la longueur des preuves affichées 

%% priorites(sans).   
priorites(avec). 

probleme(pas_encore_de_probleme). 

%% direct | th | tptp | (tptp & casc)
%% version(direct).
%% version(th).
%% version(tptp).
%% version(casc). 

%% temps limite par défaut
tempslimite(20). 
tempspasse(0). 
temps_debut(0).

conjecture(false,false). 
seulile(niouininon).
avecseulile. 
lang(fr).
fr :- affecter(lang(fr)).
en :- affecter(lang(en)).

%% par défaut
% afficher(tr). 
afficher(pr).
%% afficher(szs).


:-op(70,fx,'$$').
:-op(80,fx,'$').
:-op(90,xfx,/).
:-op(100,fx,++).
:-op(100,fx,--).
:-op(100,xf,'!').
:-op(400,xfx,'..').
:-op(400,fy,!).
:-op(400,fx,?).
:-op(400,fx,^).
:-op(400,fx,'!>').
:-op(400,fx,'?*').
:-op(400,fx,'@-').
:-op(400,fx,'@+').
:-op(405,xfx,'=').
:-op(440,xfy,>).
:-op(450,xfx,'<<').
:-op(450,xfy,:).
:-op(450,fx,:=).
:-op(450,fx,'!!').
:-op(450,fx,'??').
:-op(450,fy,~).
:-op(480,yfx,*).
:-op(480,yfx,+).
:-op(501,yfx,@).
%% :-op(502,xfy,'|'). 
     %% pour SWI-Prolog jusqu'à 5.10.1
     %% SWI-Prolog à partir de 5.10.2 affiche Error et Warning, mais n'en tient pas compte et poursuit
:- (system_mode(true),op(502,xfy,'|'),system_mode(false)). 
     %% pour SWI-Prolog à partir de 5.10.2, 
     %% SWI-Prolog ancien affiche un warning, mais n'en tient pas compte et poursuit
     %% les deux lignes peuvent rester
:-op(100,fx,+++).
:-op(502,xfx,'~|').
:-op(503,xfy,&).
:-op(503,xfx,~&).
:-op(504,xfx,=>).
:-op(504,xfx,<=).
:-op(505,xfx,<=>).
:-op(505,xfx,<~>).
:-op(510,xfx,-->).
:-op(550,xfx,:=).
:-op(450,xfy,::). 
:-op(450,fy,..). 
:-op(405,xfx,'~=').
:- op(600,fx,si). 
:- op(610,xfx,alors).
:- op(600,fx,if).
:- op(610,xfx,then). 

c :- consreg.
l(P) :- listing(P).
regle(Nom) :- clause(regle(_,Nom ),Q), ecrire1(Q).


%%%%%%%%%%%%%%%%%%%%%%%%
%% moteur d'inférence %%
%%%%%%%%%%%%%%%%%%%%%%%%

%%   ++++++++++++++++++++ appliregactiv(N) +++++++++++++++++

%% application de toutes les regles actives pour le (sous-)theoreme N
%%            jusqu'à true ou timeout ou plus de  règles à appliquer
%% une ancienne version récurvive a été abandonnée


appliregactiv(N) :- 
        repeat,
        ( concl(N, true, _) -> demontre(N) 
        ; concl(N, _/timeout, _) -> message(aaaaaaaaaaaaaaa),!, nondemontre(N)
        ; reglactiv(N,LR) ->  ( applireg(N,LR)-> fail ;! )  
        ) .           
%% +++

%%   ++++++++++++++++++++ applireg(N,LR_) +++++++++++++++++++

%% application des règles de LR (liste de leurs noms) au (sous-)theoreme N
%% arret si temps depasse
%% si aucune regle n'a ete appliquee avec succes, 
%%               applireg echoue, appliregactiv reussit

applireg(N,_) :- tempsdepasse(N,applireg),!,nondemontre(N),fail. 
applireg(N,[R|RR]) :- 
            (regle(N,R) ->  acrire_tirets(tr,[regle,R])
            ; applireg(N,RR)
            ) .
applireg(N,[]) :- nondemontre(N), fail.
%% +++

%%   ++++++++++++++++++++ tempsdepasse(N,Marqueur) +++++++++++++++

%% interuption + message si le temps limite est dépasse

tempsdepasse(N,Marqueur) :- 
   statistics(cputime,T),!,
   tempspasse(TP),tempslimite(TL), TT is TP+TL , T>TT,
   ( concl(N,C, _) -> nouvconcl(N,C/timeout, _)
   ; true 
   ),
   ME      =('temps limite depasse N='),
    ES     =(' dans '),
     SS    =('\ntheoreme non demontre'),
      SA   =('en'),
       AG  =('secondes (timeout)\n'),
   MESSAGE = [ME,N,ES,Marqueur,SS,SA,T,AG],
   message(MESSAGE),nl,
   (N = -1 -> probleme(P),atom_concat(res_,P,RES),tell(RES)
   ; true),
   acrire1(tr,MESSAGE),nl,
   ! , 
   nondemontre(0),
   break 
                    .

%%   ++++++++++++++++++++ demontre(N) ++++++++++++++++++++++
%%
%% affiche (ou non) le succes quand le (sous-)theoreme N a été demontré,
%% selon la valeur de N (N=0 pour le théorème initial)
%% et l'option (tptp, th, direct, szs, casc,...)
%% si N=0, affiche (selon version) le temps passe 
%% et eventuellement extrait la preuve utile et le temps de cette extraction

demontre(N) :- 
   ( N=0 -> ( version(tptp),conjecture(false,_) -> 
           message('pas de conjecture, probleme montre insatisfaisable')
            ; message('theoreme demontre')
            ),
            ( afficher(tr) -> acrire1(tr,[theoreme,demontre])
            ; version(casc) -> true
            ; ecrire1('theoreme demontre ')
            ),
            probleme(P),
            temps_debut(TD),
            statistics(cputime,Tapresdem),Tdem is Tapresdem-TD, 
            (version(direct) -> true
            ; nomdutheoreme(Nomdutheoreme),
              concat_atom(['(',Nomdutheoreme,')'],Texte)
            ),
            (version(casc) ->true 
            ; Nomdutheoreme=direct -> true
            ; ecrire(Texte)
            ), 
            (version(casc)-> true
            ; messagetemps(Tdem),
              (version(tptp) -> ecrire1([probleme,P,resolu]),
                                ecrire1('== == == == == == == == == == ')
              ; true
              )
            ),
            ligne(szs),
            (afficher(szs) -> ( conjecture(false,_) ->
                                 ecrire1('SZS status Unsatisfiable for ')
                               ; ecrire1('SZS status Theorem for ')
                               ),
                               probleme(P),ecrire(P)
            ; true
            ),
            ( afficher(pr) -> 
                ligne, statistics(cputime,Tavantutile),
                %% recherche et affichage de la trace utile
                tracedemutile,
                ( version(casc) -> true 
                ; statistics(cputime,Tapresutile),
                  Tutile is Tapresutile-Tavantutile,
                 ecrire1('preuve extraite'), 
                 message('preuve extraite'), 
                  messagetemps(Tutile),
                  message('')
                )
            ; true
            ) 
   ; %% N>0
     acrire1(tr,[theoreme,N,demontre]) 
   ) .
%% +++

%%   ++++++++++++++++++++ demontre(N) ++++++++++++++++++++++
%%
%% nondemontre(N) affiche l'echec pour le (sous-)theoreme de numero N
%% si N=0 affiche le temps passe (selon options)

nondemontre(N) :- 
  ( N=0 -> ecrire1etmessage('theoreme non demontre '),
           probleme(P),
           temps_debut(TD),
           statistics(cputime,Tapresdem),Tdem is Tapresdem-TD,
           (version(direct) -> true
           ; nomdutheoreme(Nomdutheoreme),
             concat_atom(['(',Nomdutheoreme,')'],Texte)
           ),
            (version(casc) ->true
            ; Nomdutheoreme=direct -> true
            ; ecrire(Texte), message0(Texte)
            ),
            ( version(casc)-> true
            ; messagetemps(Tdem),
              ( version(tptp) -> ecrire1([probleme,P,non,resolu]),
                                 ecrire1('== == == == == == == == == == ')
              ; true
              )
            ),
            ligne(szs),

           (afficher(szs) ->  nl,nl, write('SZS status GaveUp for '),
                               probleme(P),write(P)
           ; true 
           )
  ; 
    acrire1(tr,[theoreme,N,non,demontre])
  ), 
  !. 


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  fonctions diverses %%
%%%%%%%%%%%%%%%%%%%%%%%%%

varatom(X) :- %% X est une variable ou un atome
   %% Attention [] est une atome ou non selon les versions de Prolog
   (var(X);atom(X)).

vars([X|L]) :- %% L est une liste (eventuellement vide) de variables
    var(X), vars(L).
vars([]).

%% cherche si X peut s'unifier avec un (sous-)élément de E
element(X,E) :- %% X apparait dans E , a n'importe que niveau :
                %%    X est unifiable avec E ou une de ses sous-formules 
                %%    ou avec une (sous-)formule d'une liste de formules
                %%   utilise par lire, avecseuile et ecrireV (X constante)
      (X=E -> true  %% toujours si X est une simple variable 
      ; E=[] -> fail
      ; E=[A|_], X == A -> true
      ; E=[A|_],\+ atom(A),\+ var(A),\+ number(A),element(X,A)
            -> true
      ; E=[_|L] -> element(X,L)
      ; E=..L -> element(X,L)
      ).

%% Pour balayer tous les elements d'une liste, au premier niveau,
%% the predicat predefini member(X,L) est utilisé


%% balaie tous les elements de la sequence (au 1er niveau)
 elt_seq(X,(X,_)). 
 elt_seq(X,(_,S)) :- elt_seq(X,S).
 elt_seq(X,X) :- \+ X=(_,_).

%% seq_der(S,S_X,X) renvoie le dernier element X d'une sequence S
%%                          et S_X la sequence sans X 
seq_der((S1,S2,S3),(S1,SS),X) :- seq_der((S2,S3),SS,X),!.
seq_der((S1,S2),S1,S2):-!.
seq_der(S,S,S) :- message([S, 'n''a qu''un element']).

%% ajoute _ à la fin d'un atome qui se termine par un chiffre
%%      (pour qu'il ne se termine pas par un chiffre)
denumlast(Atom,Atom1) :- atom(Atom), name(Atom,L),last(L,D),
                         D>47,D<58, !, 
                         append(L,[95],L1),name(Atom1,L1).
denumlast(Atom,Atom).


%% visualise, avec indentation des formules dis/conjonctives horribles
%%    n'est plus utilise, mais pourrait ête utile

arbre(E) :- arbre(E,0).
arbre(E,Indent) :- E=..[Op,A,B],(Op='|';Op='&'),nl,indent(Indent),
                   write(Op),I is Indent+1,arbre(A,I),arbre(B,I),!.
arbre([],_) .
arbre(E,Indent) :- nl,indent(Indent),write(E).
indent(N) :- write('   '),(N>0 -> N1 is N-1, indent(N1);true).


%% crée un nouvel atome X1 à partir de X
%% si l'atome X ne se termine pas par un nombre, ajoute 1
%% sinon ajoute 1 au nombre terminal
%%    (remplace par gensym sauf dans "creer_nom_regle")

suc(X,X1) :- name(X,L),sucliste(L,L1),name(X1,L1).
sucliste(X,X1):-
   last(X,D),
   D>=48,
   D=<56,D1 is D+1,
   append(Y,[D],X),
   append(Y,[D1],X1),!.
sucliste(X,X1) :- last(X,57),append(Y,[57],X),sucliste(Y,Y1),
      append(Y1,[48],X1),!.
sucliste(X,X1):- append(X,[49],X1).


%% ajoufin(L,A,L1) ajoute A a la fin de la liste L

ajoufin([X|L],A,[X|L1]) :- ajoufin(L,A,L1).
ajoufin([],A,[A]).


%% ajoute A à la fin de la sequence S

ajoufinseq(S,A,SA) :- ( S = (X,L) ->  ajoufinseq(L,A,L1), SA = (X,L1)
                      ; S = [] -> SA = A
                      ; SA = (S,A)
                      ).


%% ajoute une condition A, dans une sequence S avant les conditions obj_ct
%% cad : à la fin si c'est une condition obj_ct 
%%                ou s'il n'y a pas encore de conditions obj_ct,
%%       sinon avant les conditions obj-ct
%% SA est la nouvelle sequence

ajouseqavantobjet(S,A,SA) :- 
       ( A = obj_ct(_,_) -> ajoufinseq(S,A,SA) 
       ; S=(obj_ct(_,_),_L) -> SA = (A,S) 
       ; S = (X,L) ->  ajouseqavantobjet(L,A,L1), SA = (X,L1) 
       ; S = [] -> SA = A
       ; S = obj_ct(_,_) -> SA = (A,S) 
       ; SA = (S,A)                     
       ) 
       .


%% renvoie les objets X en commençant par ceux du sous-theoreme N instancie 
%%         puis les objets apparaissant dans les données (N=-1)

obj_ct(N,X) :- 
     objet(N,X) ; objet(-1,X).


%% ajoute une clause P(...) d'arité 0, 1, 2 ou 3 
%%              (à généraliser si nécessaire)
%%        après avoir éventuellement supprimé toute autre clause P(...)

affecter(X) :- 
               X =.. [P,_],Y=..[P,_],retractall(Y),assert(X),!.
affecter(X) :- X =.. [P,_,_],Y=..[P,_,_],retractall(Y),assert(X),!.
affecter(X) :- X =.. [P,A,_,_],Y=..[P,A,_,_],retractall(Y),assert(X),!.


%% incremente le nombre d'hypothèses existentielles (nbhypexi)

incrementer_nbhypexi(N1) :- nbhypexi(N), N1 is N+1, affecter(nbhypexi(N1)).


%% renvoie E1 si E1 est un atome (numéro d'etape),
%% sinon crée une nouvelle etape E1 

etape_action(E1) :- 
          ( var(E1),etape(E0) -> E1 is E0+1,affecter(etape(E1))
          ; true).


%% met une formule à plat 
%% exemple : f(g(a, b), h(c), K) devient f_g_a_b_h_c_var
%% n'est plus utilise (illisible car trop long pour certaines formules)
%% à la place on crée des objets z1, z2, ... (règle concl_seul)
%% pourrait ête utilisé pour de petites formules

plat(E,E1) :- ( (atom(E) ; number(E) ) -> E1 = E
              ; var(E) -> E1=var
              ; E = [X,Y|L] ->  plat(X,X1),plat([Y|L],L1),
                               atom_concat(X1,'_',E2), atom_concat(E2,L1,E1)
              ; E = [X] -> plat(X,E1)
              ; E =..L, plat(L,E1)
              ) .

tartip(X1,X2) :- name(X1,L1),compareg1ter(L1,L2),name(X2,L2).

%% cherche si E est une formule, éventuellement quantifiée, est close
%% sinon, on utilise ground, clos n'est utilisé que dans consreg

clos(E) :- not(var(E)),
           ( E=[] -> true
           ; E=[X|L] -> clos(X),clos(L)
           ; E=(![X|XX]:EX) -> remplacer(EX,X,x,Exx),
                               ( XX=[] -> Ex=Exx
                               ; Ex=(!XX:Exx)
                               ),
                               clos(Ex)
           ; E=(?[X|XX]:EX) -> remplacer(EX,X,x,Exx),
                               ( XX=[] -> Ex=Exx
                               ; Ex=(?XX:Exx)
                               ),
                               clos(Ex)
           ; E=seul(FX::X,PX) -> clos(FX),remplacer(PX,X,x,Px),clos(Px)
           ; E=..[_|L]-> clos(L)
           ; acrire1(tr,clos-E-non)
           ).


%% Depuis la version 5 de swi-prolog, telling ne renvoie plus  
%% le nom du fichier de la sortie courante mais un "stream identifier"  
%% de la forme <stream>(0x81ea8c8) que je ne sais pas récuperer, 
%% J'ai donc défini un prédicat dynamique fichier et des prédicats telll, 
%% toldd, tellling et appendd, pour remplacer (mais non identiques)
%% tell, told, telling et append

:- dynamic fichier/1. 
telll(F) :- tell(F), retractall(fichier(_)), assert(fichier(F)).
toldd :-  retractall(fichier(_)),told.
tellling(F) :- fichier(F),!.
tellling(user).
appendd(F) :- append(F), retractall(fichier(_)), assert(fichier(F)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          super-actions            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ++++++++++++++++++++++++   travail1   ++++++++++++++++++++++++
%% construit les règles à partir des définitions, 
%% après en avoir éliminé les symboles fonctionnels 
%% si on a demandé l'affichage détaillé de la construction (ecrireconsreg), 
%% la trace est dans le fichier traceconsreg[_<nom du problème>]
%% ou dans res[_<nom du problème>] pour les règles locales_

travail1 :-  (probleme(P) -> atom_concat(traceconsreg_,P,Traceconsreg)
             ; Traceconsreg=traceconsreg
             ),  
             (ecrireconsreg -> telll(Traceconsreg);true),
              
              elifondef, 
              consreg, 
              typesdonnees, 
              told.


%% +++++++++++++++++++++++ ecrireconsreg ++++++++++++++++++
%% active l'option d'affichagedétaillé de la constructin des règles

ecrireconsreg :- 
                 afficher(reg).

typesdonnees :- clause(regle(_,Nom),_), \+ type(Nom,_),
                assert(type(Nom,donnee)),fail.
typesdonnees.


%% +++++++++++++++++++++ demontr(Theoreme) +++++++++++++++++++
%% coeur du démonstrateur : initialisations, affichages, 
%%                          activation et applications des règles

demontr(_Theoreme) :- %% arrêt si temps limite dépassé 
     tempsdepasse(0, ['temps depasse avant meme d\'attaquer le theoreme']).

demontr(Theoreme) :- 
     ( version(casc) -> true 
     ; ecrire1('****************************************'),
       ecrire('****************************************'),
       ecrire1(['theoreme a demontrer']), 
       ecrire1([Theoreme]),
       ecrire_tirets('')
     %% nl, write(Theoreme) %% si on veut l'affichage complet 
     ),
     preambule,
     affecter(etape(0)), %% 1ère etape 
     nouvconcl(0, Theoreme, E), %% E=1
     %% première ligne de la trace utile
     traces(0, action(ini), %% nom de l'action 
            [], nouvconcl(0 , Theoreme, E), %% action effectuée 
            E,'theoreme initial',[] %% explication 
           ),
     acrire_tirets(tr,[action,ini]), %% ------------------------------
     \+ tempsdepasse(0, 'temps depasse avant meme d activer les regles'),
     activreg, %% activation des règles 
     \+ tempsdepasse(0, 'temps depasse apres l activation des regles'),
     %% application des règles au théorème initial number 0
     appliregactiv(0),
     !  
     .


%% +++++++++++++++++++++ creersousth(N,N1,A,E) +++++++++++++++++
%% creation de N1, sous-théorème de N, de conclusion A, à l'etape E
%%          les autres item sont ceux de N (copitem)
creersousth(N,N1,A,E) :- 
     assert(sousth(N,N1)),
     ligne(tr),acrire1(tr,[************************************************]),
     acrire(tr,[sous-theoreme, N1,*****]),
     nouvconcl(N1,A,E), copitem(N,N1).


%% demconj(N,C,Econj,Efin), à l'etape Econj, cherche à démontrer
%%  (récursivement) la conclusion C=AetB du (sous)th de numéro N=n1-n2-...-ni 
%%                               ou C=A pour le dernier appel
%% création (nouvelle etape Ecreationsousth) d'un sousth de conclusion A
%%                          et de numéro N1=n1-n2-...-ni-1 puis -2, -3 etc
%% si le theoreme N1 est demontre (concl true) à l'etape Edemsousth
%%    alors A est retiree de la concl de N (etape Eretourth)
%% si c'etait le dernier sousth a demontrer (B=true), on sort en
%%    renvoyant dans Efin le numero de la derniere etape (Eretourth)
%% sinon on appelle demconj pour la concl B de N de l'etape Eretourth
demconj(N,C,Econj, Efin) :-  
 ( C = (A & B) -> true ; (C=A,B=true) ),
 atom_concat(N,-,N0), gensym(N0,N1), %% N1=...-1, ...-2, ...-3, ...
 creersousth(N,N1,A,Ecreationsousth),
 (B=true -> Cond=[],
            Expli=('demonstration du dernier element de la conjonction')
 ; Cond=concl(N, C, Econj),
   Expli=['pour demontrer une conjonction',
          'on demontre successivement tous les elements de la conjonction']
 ),
 traces(N1, %% numero du sous-théorème 
        action(demconj), %% nom de l' action 
        Cond, %% condition
        [creersousth(N,N1,A,Ecreationsousth), %% actions creation N1
           nouvconcl(N1,A,Ecreationsousth)],  %%         conclusion
        (Ecreationsousth), %% etape 
        Expli, %% explication 
        ([Econj]) %% antecedents
       ),
 acrire_tirets(tr,[action,demconj]),
 appliregactiv(N1), %% demonstration (essai) de N1 
 !,  
 concl(N1,true,Edemsousth), %% N1 a été démontré 
 nouvconcl(N,B,Eretourth), %% on retire A qui vient d'être demontre 
 traces(N,
        action(retourdem), 
        concl(N1,true,Edemsousth),
        nouvconcl(N,B,Eretourth),
        (Eretourth),
        ['la conclusion', A, 
         'du (sous-)theoreme', N, 
         'a ete demontree (sous-theoreme', N1,')'
        ],
        ([Econj , Ecreationsousth,Edemsousth])
       ),
 acrire_tirets(tr,[action,retourdem]),
 ( B = true -> Eretourth=Efin ; demconj(N,B,Eretourth,Efin))
 . 

%% ++++++++++++++++++++++ demdij(N,C,N,C,Edij,Efin) +++++++++++++++++++++++
%% demdij(N,C,Edij, Efin),à l'etape Edij, cherche à démontrer (récursivement)
%%       la conclusion C=AouB du (sous)th N
%%                  ou C=A pour le dernier appel
%% création (nouvelle etape Ecreationsousth) d'un sousth N1=N+i de concl A
%% si le sous-theoreme N1 est demontre (concl true) à l'etape Edemsousth
%%    alors N est démontré N (etape Eretourth)
%% sinon et si c'etait le dernier sousth a demontrer (B=true),
%%    on a échoué à démontrer N, donc aussi le théorème initial
%% sinon on appelle demdij pour la disjonction suivante 
demdij(N,C,Edij, Efin) :- 
        message('demdij-C-Edij-Efin'-demdij-C-Edij-Efin),
        ( C = (A | B) | (C = A , B=true)),
        atom_concat(N,+,N0), gensym(N0,N1), %% N1=N+1, N+2, ..., N+i, ...
        creersousth(N,N1,A,Ecreationsousth),
      
        traces(N,action(demdij),(concl(N, C, Edij)),
                 creersousth(N,N1,A,Ecreationsousth),
                 (Ecreationsousth),
                 ['creation du sous-theoreme',
                  N1,
                  'de conclusion',
                  A],
                 ([Edij])),
        acrire_tirets(tr,[action,demdij]),
        appliregactiv(N1), %% demonstration (essai) de N1 
        !,           
        concl(N1,C1,Edemsousth),
      ( C1=true -> %% N1 a été démontré 
        nouvconcl(N,true,Eretourth), %% donc N l'est 
        traces(N, action(retourdemdij), (sousthdem),
               nouvconcl(N,true,Eretourth),
               (Eretourth),
               ['la conclusion',
                 A, 
                'du (sous-)theoreme',
                 N, 
                'a ete demontree'],
               ([Edij , Edemsousth])
               ),
        acrire_tirets(tr,[action,retourdemdij])
      ; B \=true -> acrire_tirets(tr,[action,retourdemdij]), 
                    acrire1(tr,'on essaie la disjonction suivante'),
                    demdij(N,B,Edij,Efin)
      ; acrire1(tr,'la disjonction n\'a pas ete demontree')
      ) 
      .


%% ++++++++++++++++++++++++   copitem(N,M)   +++++++++++++++++++++++++
%% copie les items hyp, hyp_traite, objet et reglactiv du (sous-)theoreme N
%%       vers les sous-theorème M
copitem(N,M) :- hyp(N, H,I), assert(hyp(M,H,I)), fail.
copitem(N,M) :- hyp_traite(N, H), assert(hyp_traite(M,H)), fail.
copitem(N,M) :- objet(N, H), assert(objet(M,H)),fail.
copitem(N,M) :- reglactiv(N, LR), assert(reglactiv(M,LR)), fail.
copitem(_, _) .
%%
%%   ++++++++++++++++  demconclexi(N, C, E, F)   +++++++++++++++++++++++++++
%% cherche à démontrer la conclusion existentielle C du (sous-)théorème N
%% à l'etape E ; en cas de succès, F est le nouveau numéro d'etape
%%
demconclexi(N, ? [X|XX]:C, Eexi, Efin):- 
  %% Ob est un objet qui a déjà été introduit
  obj_ct(N,Ob),
  acrire1(tr,
          ['*** on essaie',Ob,'***']
          ),
  %% le numéro du nouveau sous-theorème sera la chaine N1=N+1 (puis 2, 3, ...)
  %%  sa conclusion C1 et le numéro d'etape Ecreationsousth (en cas de succès)
  atom_concat(N,+,N0), gensym(N0,N1),
  remplacer(C,X,Ob,C0),
  (XX=[] -> C1=C0 ; C1= (?XX:C0)),
  creersousth(N,N1,C1,Ecreationsousth),
  traces(N1, action(demconclexi),
             concl(N, ? [X]:C, Eexi),
             [creersousth(N,N1,C1,Ecreationsousth),
             nouvconcl(N1,C1,Ecreationsousth)],
             Ecreationsousth,
            ['on essaie',Ob,'pour la variable existentielle'],
            [Eexi]

         ),
  acrire_tirets(tr,[action,demconclexi]),
  %% démonstration du sous-théorème N1, en cas de succès, sa conclusion
  %%     est mise à true et l'etape finale est Efin
  appliregactiv(N1),
  (concl(N1, true, E1) -> nouvconcl(N,true,Efin),
    traces(N,
           action(retourdemexi),
           concl(N1, true, E1),
           nouvconcl(N,true, Efin),
           Efin,
           ['la conclusion du (sous-)theoreme',
            N,
            'a ete demontree (sous-theorème',
            N1,
            ')'
           ],
           [Eexi, E1]
          )
  ; acrire1(tr,'on essaie l\'objet suivant'),
    fail
  ).

%%   +++++++++++++++++++++   nouvconcl(N,C,E)   ++++++++++++++++++++++++++++
%%
%% si la conclusion du (sous-)theorème de numéro N n'est pas C (formule close)
%%    la conclusion du (sous)theorème de numéro N, devient C
%%    - à l'étape E si E était déjà instanciée (étape en cours)
%%    - à une nouvelle étape E si E était une variable (étape à créer)
%%   +++++++++++++++++++++
nouvconcl(N,C, E) :- 
     \+ concl(N, C, _),
     etape_action(E), %% nouvelle étape si E variable, inchangée sinon
     %% pour le second ordre, R ayant été instancié
     (C = (..[R, X, Y]) -> C1 =..[R, X, Y] ; C1=C),
     affecter(concl(N,C1,E)), 
     acrire1(tr,[E:N,nouvconcl(C1)]).


%%   +++++++++++++++++++++   ajhyp(N, H, E2) ++++++++++++++++++++++++++++
%%
%% si H est trivialement vérifiée, ne fait rien
%% si H est une conjonction, ajoute tous les éléments de la conjonction
%% si H est une hypothèse universelle, ou une non-existence,
%%    on crée une ou plusieurs règles locales, comme pour les définitions
%% d'autres cas particuliers sont détaillés dans les commentaires ci-après
%% sinon on ajoute simplement l'hypothèse H

ajhyp(N, H, E2) :- 
%% si E2 est instanciée, c'est l'étape courante,
%% sinon on crée une nouvelle étape E2
  etape_action(E2),
  
 (  H = (A & B) ->
    %% appel recursif pour une conjonction
    ajhyp(N, A, E2), ajhyp(N,B, E2)
  ;
    %% H est déjà une hypothèse
    hyp(N, H,_) -> acrire1(tr,[E2:N,H]),
                   acrire1(tr,'est déjà une hypothèse'),
                   true 
  ;
    %% H est une disjonction contenant une hypothese
    hyp_true(N,H,T) -> assert(hyp(N, H,E2)), acrire1(tr,[E2:N,ajhyp(H)]),
                      acrire1(tr,['sans effet car on a deja hyp(',T,')']),
                      ajhyp_traite(N,H)
  ;
    %% H est une égalité triviale
    H = (X = X) -> acrire1(tr,[E2:N,ajhyp(H)]),
                   acrire(tr,'qui est une egalite triviale')
  ;
    H =(X,A) ->
    %% ce type de formule apparait dans le traitement des définitions
    %% de la forme h(X)=f(g(X)) (voir consreg(, elifon and elifondef &&&&&&&& 
    etape(I), I1 is I+1, affecter(etape(I1)),
    assert(hyp(N,H,I1)), 
    creer_objet(N,z,X1), remplacer(A,X,X1,A1), 
    ajhyp(N,A1,I1)
  ;
    %% les égalités sont normalisées : le 1er terme est le plus petit,
    %% lexicographiquement, sauf pour les objets crees z<nombre> où
    %% c'est l'ordre de création (numérique)
    H = (Y=X), atom(X), atom(Y), avant(X,Y), ajhyp(N,(X=Y),E2)
  ;
    %% (pour le pseudo-second ordre) si H est ..[r,X,Y], on ajoute r(X,Y)
    H = (..[R, X, Y])  -> (H1 =..[R, X, Y]), ajhyp(N, H1, E2)
  ;
    H = (..[F, X]::Y)  -> 
    %% (pour le pseudo-second ordre) si H est ..[f,x]::y, on ajoute f(x):y
    (Y1 =..[F, X]), ajhyp(N, Y1:Y, E2),ajhyp(N, Y1::Y, E2)
  ;
    H=seul(A::X,Y)->
    %% (pseudo-second ordre) si H est seul(f(x)::A,p(x,A)) [issu de p(x,f(x))]
    %% ajoute l'hypothèse p(x1) où x1 est un objet 
    %%       soit déjà introduit (hypothèse f(x)::x1)
    %%       soit créé l'hypothèse f(x)::x1 ajoutée
    ( hyp(N,A::X1,_I) -> acrire1(tr,[remplacer,X,par,X1,dans,Y])
    ; creer_objet(N,z,X1),ajhyp(N,A::X1, E2)
    ),
    remplacer(Y,X,X1,Y1),ajhyp(N,Y1,E2)
  ;
    H = (~ seul(FX::Y,P)) ->
    %% si x a été instancié, p(f(x) peut être remplacé par ?x:(f(x)::y & p(y)
    %%   ou !x:(f(x)::y => p(y)), le bon choix dépend de la parité de
    %%   sa profondeur dans la formule, la négation change cette parité, 
    %% seul(f(x)::y,p(x)) provient de p(f(x)) qui a été remplacé par
    %%   ?y(f(x)::y & p(y) mais aurait pu être remplacé par
    %%   !y:(f(x)::y => p(y)) équivalent à ~ ?y (f(x)::y & ~ p(y))
    %% donc ~ seul(f(x)::y,p(x)) peut être remplacé par
    %%  ?y (f(x)::y & ~ p(y)) soit seul(f(x)::y,p(y)  
    ajhyp(N,seul(FX::Y, ~ P ), E2)
          
  ;
    H = (!_: _) -> %% ++++++++++++++++++++++++++++++++++++++++++++++++++ 
    %% création de règles locales de nom r_hyp_univ_<etape> à partir
    %%       des hypothèses universelles et des implications 
   ecrire1(ajhypE2=E2),
    atom_concat(r_hyp_univ_,E2,ReghypE2), 
    atom_concat(ReghypE2,'_',Reghyp),
    acrire1(tr,[E2:N,'traiter l\'hypothèse universelle (non ajoutée)',
                     H]),
    creer_nom_regle(Reghyp,Nom), %% Nom=r_hyp_<etape>_ 
    %% appel de consreg pour l'énoncé H (1er argument)
    %% l'expression N+H comme 4ème argument jouant le rôle de Concept
    consreg(H, _,_,N+H,Nom,[],[E2])

  ; H = (~ (?XX:A)) -> 
    %% ~ ?x:p(x) est traité comme !x:~p(x)
    atom_concat(r_hyp_noexi_,E2,ReghypE2),
    atom_concat(ReghypE2,'_',Reghyp),
    creer_nom_regle(Reghyp,Nom), %% Nom=r_hyp_noexi_<etape>_ 
    consreg( (!XX:(~ A)), _, _Nomfof, N+H, Nom, [],[])

  ; H = (_A =>_B) -> 
    %% creation de règles locales de nom r_hyp_impl_<etape>
    atom_concat(r_hyp_impl_,E2,ReghypE2),
    atom_concat(ReghypE2,'_',Reghyp),
    creer_nom_regle(Reghyp,Nom), %% Nom=r_hyp_impl_<etape>_ 
    consreg( H,_, _Nomfof,N+H,Nom,[],[])

  ; %% dans tous les autres cas on ajoute H comme nouvelle hypothèse
    ( var(E2) -> etape(E0), E2 is E0+1, affecter(etape(E2))
    ; true
    ), 
    assert(hyp(N, H,E2)), acrire1(tr,[E2:N,ajhyp(H)])
  ) .

avant(Z1,Z2) :- 
      ( name(Z1,[122|L1]), name(N1,L1), number(N1),
        name(Z2,[122|L2]), name(N2,L2), number(N2) -> N1<N2
      ; Z1 @< Z2).

ajhyp_traite(N, H) :- assert(hyp_traite(N, H)).
ajhyp_traite(N, H,E) :- ajhyp_traite(N, H),
                        message(z_ajhyp_traite_a_3_arg,N+H+E).

ajobjet(N, X) :- 
   ( objet(N, X) ->  true
   ; assert(objet(N, X)
   ), 
   ( N=(-1)-> true 
   ; etape(E), acrire1(tr,[E:N, 'ajouter objet',X]))
   ) .

ajconcept(P) :- (concept(P) -> true; assert(concept(P))).
ajfonction(F,N) :- (fonction(F,N)-> true;assert(fonction(F,N))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    c o n s t r u c t i o n   d e s   r è g l e s     %%
%%  consreg/0et7   ajoucond   ajoureg   ajoureglocale   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% consreg/7 construit des règles à partir d'un énoncé
%% consreg/0 construit les énoncés à envoyer à consreg/7
%%  à partir des définitions et des lemmes, selon leur forme

%% ++++++++++ consreg ++++++++++

%% suppression d'anciennes règles précedemment construites

consreg :- 
           effacer_regcons,fail.

%% si A a une définition négative ~B, en plus de la construction normale,
%% 2 nouvelles définitions sont ajoutées : nonA définie par B
%%                                    et   A définie par la négation de B
%% (voir manuel-fr.pdf § 6. Définitions et lemmes
consreg :- definition(Nomfof,A<=> ~ B),
    A=..[P|L], vars(L),
    ajconcept(P),  
    atom_concat(non,P,NonP),ajconcept(NonP),
    NonA =.. [NonP|L],
    \+ NonA = B, 
    asserta(definition(Nomfof,A <=> ~ NonA)),
    asserta(definition(Nomfof,NonA <=> B)),
    denumlast(P,P1), 
    creer_nom_regle(P1,Nom),
    assert((regle(_,Nom):- hyp(N,~ A,I), \+ hyp(N,NonA,_),
                           ajhyp(N,NonA,_),
                           traces(N,regle(Nom),
                                  hyp(N,~ A,I), ajhyp(N,NonA,E),E,
                                  ['a cause de',P,et,NonP],
                                  [I]
                                 )
            )),
    assert(type(Nom,P)),
    fail.

%% définitions de symboles fonctionnels (voir manuel-fr.pdf)
consreg :- definition(Nomfof, A<=>B), 
      not(var(A)),
      (ecrireconsreg-> ecrire1('\nconsreg'-definition(Nomfof,A<=>B));true), 
      ( A=(C::_) -> C =..[P|_]   
      ; A=..[_,_,E],not(var(E)),E=..[_|_] -> fail 
      ; A=..[P|_]             
      ),
      (ecrireconsreg-> ecrire1(definitionapres(A<=>B)+'P'=P);true), 
      ajconcept(P), 
      denumlast(P,P1), 
      creer_nom_regle(P1,Nom),
      (A=(X=Y)-> remplacer(B,Y,X,B1),consreg(B1,N,Nomfof,P,Nom,objet(N,X),[])
      
      ; consreg(A=>B,_,Nomfof,P,Nom,[],[]), 
      (B = (_ | _) -> (ecrireconsreg -> 
                       ecrire1('consreg def contraposee de ':(A=>B))
                      ;true),
      consreg(B=>A,_,Nomfof,P,Nom,[],[]);true) 
      ),
      fail.
     


consreg :- definition(Nomfof,A=B), not(B=[_,_]), 
           A =.. [F|_],  ajconcept(F), 
    denumlast(F,F1), 
           creer_nom_regle(F1,Nom),
           elifon4(B::X,B1X), consreg(A::X => B1X,_,Nomfof,F,Nom,[],[]),
           fail.

%% définitions ensemblistes (uniquement version th)
consreg :- definition(Nomfof,A<=>D),        
  (ecrireconsreg -> ecrire1(\nconsreg-def-elt-definition(Nomfof,(A<=D)))
  ;true),
  ( A =..[R,X,E],not(var(E)),E=..[F|_] 
  ) ,
  ajconcept(F), 
  denumlast(F,F1), 
  creer_nom_regle(F1,Nom),
  (atom(E) -> 
    (ecrireconsreg -> ecrire1(consreg-def-elt-apres1:(![X]:(A =>D)));true),
                      consreg((![X]:(A =>D)),_,Nomfof,F,Nom,[],[]) 
    ; XappW =.. [R,X,W],
      (ecrireconsreg -> 
               ecrire1(consreg-def-elt-apres2:((E::W)=>![X]:(XappW <=>D)))
    ;true),
    consreg((E::W)=>![X]:(XappW <=>D),_,Nomfof,F,Nom,[],[])
    ),
    fail.

%% à partir des lemmes
consreg :- lemme(Nomfof,E),atom_concat(Nomfof,'_',Nom0),
       creer_nom_regle(Nom0,Nom1),consreg(E,_,Nomfof,lemme,Nom1,[],[]),fail.

consreg.

%% +++++++++++++ consreg(E,N,Nomfof,Concept,Nom,Cond,Antecedents) ++++++++++
%%
%% construction récursive de règles à partir d'un énoncé E
%% - N est soit une variable non instanciée, si E est (ou provient) d'une
%%   définition ou d'un lemme, soit un numéro de (sous-)théorème si E en
%%   est une hypothèse
%% - Nomfof et Concept sont des mots clefs figurant dans l'énoncé initial
%%   et appraraitront dans le nom des règles construites
%% - Nom sera le préfixe du nom final donné aux règles construites
%% - Cond est la partie conditions, vide au début, construite pas à pas
%% - Antecedents est la liste des etapes des conditions déjà construites

%% pour un affichage détaillé de la construction (option ecrireconsreg)
consreg(E,N,Nomfof,Concept,Nom,Cond,Antecedants):- ecrireconsreg, nl,
       ecrire1([consreg(E,N,Nomfof,Concept,Nom,Cond,Antecedants),
               '\n','Concept'=Concept,
               '\n','Nomfof '=Nomfof,
               '\n','Nom    '=Nom,
               '\n','N      '=N,
               '\n','Cond  '=Cond,
               '\n','Antecedants'=Antecedants,
               '\n','E      '=E]), fail.

%% pour un arrêt si le temps limite est dépassé
consreg(_,_,_,_,_,_,_) :-
    tempsdepasse(_,'temps epuise avant la fin de la construction des regles').
consreg(E,N,Nomfof,Concept,Nom,Cond,Antecedants) :- 
( 
  %% une disjonction est remplacée par une conjonction
  E = ((A|B)=>C) -> 
          consreg((A=>C)&(B=>C),N,Nomfof,Concept,Nom,Cond,Antecedants)
;
  %% remplacements à partir d'une égalité
  E = ((X=Y) => C), (var(X) | var(Y)) -> 
        ( var(X) -> remplacer(Cond,X,Y,Cond1), remplacer(C,X,Y,C1)
        ; var(Y) -> remplacer(Cond,Y,X,Cond1), remplacer(C,Y,X,C1)
        ),
        consreg(C1,N,Nomfof,Concept,Nom,Cond1,Antecedants)

%% si E est une implication A => B, plusieurs cas à envisager
;
  %% si A est une expression négative ~D, on l'ajoute comme condition(s) ,puis
  %% deux appels récursifs pour B d'une part et D|B d'autre part 
  E = (~ D => B) -> ajoucond(N,Cond,Antecedants, ~ D, Cond1,Antecedants1),
                    consreg(B, N, Nomfof,Concept, Nom, Cond1,Antecedants1),
                    creer_nom_regle(Nom, Nom1),
                    consreg(D | B, N, Nomfof,Concept,Nom1,Cond,Antecedants)
; 
  %% idem si A = ~ D & A1=>B, avec appels récursifs pour A1=>B et A1=>D|B
  E = (~ D & A1 =>B) -> ajoucond(N,Cond,Antecedants,~ D,Cond1,Antecedants1),
                    consreg(A1 => B,N,Nomfof,Concept,Nom,Cond1,Antecedants1),
                    creer_nom_regle(Nom, Nom1),
                   consreg(A1 => (D|B),N,Nomfof,Concept,Nom1,Cond,Antecedants)
;
  %% les éléments d'une conjonction seront traités un par un
  E = (A1 & A2 => B) -> 
              consreg(A1 => (A2 => B),N,Nomfof,Concept,Nom,Cond,Antecedants)
;
  %% si A = (!_:_) est une expression universelle
  %% on remplace une conclusion instanciant B par la condition suffisante A
  %% le problème est ainsi remplacé par le suivant :
  %%   si la conclusion est une instance de B (condition concl(B)
  %%   alors montrer A, instancié de la même manière, soit nouvconcl(A)
  %% les règles ainsi construities ne seront pas prioritaires
  %% le nom sera suffixé par _cs pour préciser (pour le lecteur de la trace)
  %%    qu'il s'agit d'une condition suffisante
  E = (A => B), A = (!_:_) -> 
                      ajouseqavantobjet(Cond,concl(N,B,I),Cond1), 
                      ajoufinseq(Cond1,nouvconcl(N,A,I1),CondAct2),
                      atom_concat(Nom, '_cs', Nom_cs),
                      ajoufinseq(CondAct2,
                                 traces(N,regle(Nom_cs),
                                 concl(N,B,I), nouvconcl(N,A,I1), I1,
                                 ['condition suffisante (regle : ',
                                  Nom,'(fof',Nomfof,')'
                                 ], 
                                 [I]),
                                 Regle),
                      ajoureg(N, Concept, Nom_cs, Regle)  ,
                     
          %% deuxième construction de règle(s) : sous certaines conditions
          %% on remplacera une conclusion C par A & (B=>C)
                     creer_nom_regle(Nom, Nom1), 
                     atom_concat(Nom1, cs_endernier, Nom_cs_endernier), 
                     ajouseqavantobjet(Cond, 
                                       (concl(N,C,II),hyp(N,H,I2),
                                        not(atom(C)),functor(C,Q,_),
                                        not(atom(H)),functor(H,Q,_),
                                        clos(A),
                                        nouvconcl(N,A &(B=>C),II1)
                                       ),
                                       CondAct4
                                      ),
                     append(Antecedants,[I2,II],An1),
                     ajoufinseq(CondAct4, 
                                traces(N,regle(Nom_cs_endernier),
                                       Cond+concl(N,C,II)+hyp(N,H,_)+averif,
                                       nouvconcl(N,A & (B=>C),II1),
                                       II1,
                                       'condition suffisante',
                                       An1
                                       ),
                                      Regle2
                               ),
                     ajoureg(N, endernier, Nom_cs_endernier, Regle2)
;
  %% dans les autres cas d'implication, ajout de A à la liste de conditions
  E = (A=>B) -> ajoucond(N,Cond,Antecedants,A,Cond1,Antecedants1),
                consreg(B,N,Nomfof,Concept,Nom,Cond1,Antecedants1)
;  
  %% une equivalence est rempplacée par la conjonction des deux implications
  E = (A<=>B) -> consreg((A=>B)&(B=>A),N,Nomfof,Concept,Nom,Cond,Antecedants)
;
  %% conjonction, autant de paquets de règles que d'éléments de la conjonction
  E = (A & B) -> creer_nom_regle(Nom, Nom1),
                 consreg(A,N,Nomfof,Concept,Nom1,Cond,Antecedants),
                 creer_nom_regle(Nom1, Nom2),
                 consreg(B,N,Nomfof,Concept,Nom2,Cond,Antecedants)
;
  %% propriété universelle 
  E = (![X]:B),(var(X); atom(X)) -> 
              ajoucond(N,Cond,Antecedants,objet(N,X),Cond1,Antecedants1),
              consreg(B,N,Nomfof,Concept,Nom,Cond1,Antecedants1)
; E = (![X|XX]:B),(var(X); atom(X)) -> 
              ajoucond(N,Cond,Antecedants,objet(N,X),Cond1,Antecedants1),
              consreg(!XX:B,N,Nomfof,Concept,Nom,Cond1,Antecedants1)
;
  %% propriété issue d'un symbole fonctionnel p(f(X) devenu 
  %%                                         seul(f(X)::Y,p(Y))
  E = seul(FX::Y, B) ->
        %%  1ere  c o n s t r u c t i o n si on a deja un (des) objet(s) FX::Y
        ajoucond(N,Cond,Antecedants,FX::Y,Cond1,Antecedants1),
        consreg(B,N,Nomfof,Concept,Nom,Cond1,Antecedants1),
        %%  2 è m e  c o n s t r u c t i o n , la règle créera l'objet FX:Y
        ( seulile(oui),seulile(non)->true
        ; seulile(non)-> true
        ; seulile(oui) ->
          atom_concat(Nom, '_crea_seul', Nom2),
          creer_nom_regle(Nom2, Nom1),
          ajouseqavantobjet(Cond, \+ hyp(N,FX::Y,_), Cond3),
          consreg((?[Y]:((FX::Y) & B)),N,Nomfof,Concept,Nom1,Cond3,Antecedants)
        ; true
        )
;
  %% la négation d'une propriété existentielle est remplacée
  %%    par une propriété universelle 
  E = (~ (?[X]:A)) ->
            consreg((![X]:(~ A)),N,Nomfof,Concept,Nom,Cond,Antecedants)
;
  %% supression d'une double négation
  E = (~ ~ A) -> consreg(A,N,Nomfof,Concept,Nom,Cond,Antecedants)
;
  %% ~A est traité comme A => false, sauf dans deux cas
  E = (~ A), \+(A=(!_:_)) , \+ A=(_=_) ->
             ajoucond(N, Cond, Antecedants,A, Cond1,Antecedants1),
             consreg(false,N,Nomfof,Concept,Nom,Cond1,Antecedants1)
;
  %% égalité sans conditions, ajout de l'action "l'ajouter comme nouvelle hyp"
  E = (_=_) -> Cond=Cond0, 
               ajoufinseq(Cond, \+ E, Cond1), 
               ajoufinseq(Cond1, ajhyp(N,E,I1), CondAct2),
               Act=ajhyp(N,E,I1),
               ( Cond0=[] -> SiAlorsAct=Act
               ; ( lang(fr) -> SiAlorsAct = (si Cond0 alors Act)
                 ; lang(en) -> SiAlorsAct = (if Cond0 then Act)
                 ; SiAlorsAct = (si Cond0 alors Act)
                 )
               ),
               copy_term(SiAlorsAct,SiAlorsActCop),
               ( Concept=(_ + HypUnivImp) 
               -> affecter(hypuniv(HypUnivImp)),hypuniv(HypU),
                  Expli1 = ('\nest une regle locale construite'),
                  Expli2 = ('à partir de l\'hypothese universelle'), 
                  Expli = ['la regle',Nom,:,
                           SiAlorsActCop, Expli1,Expli2, HypU]
               ; Concept=lemme
               -> Expli = [regle,SiAlorsActCop,
                           'construite à partir de l\'axiome', 
                           Nom,'(fof',Nomfof,')']
               ; Expli= [regle,SiAlorsActCop,
                         '\nconstruite à partir de la definition de',
                         Concept, '(fof',Nomfof,')']
               ),
               ajoufinseq(CondAct2,
                          traces(N,regle(Nom),
                                 Cond0, ajhyp(N,E,I1),I1,
                                 Expli,
                                 Antecedants 
                                ),
                          Regle),
             ajoureg(N, Concept, Nom, Regle)

;
   %% traitement par défaut et fin des appels récursifs
      \+tempsdepasse(-1,'consreg par defaut'),
      (ecrireconsreg -> ecrire1('suite-de-consreg-Cond'=Cond);true),
   %% suppression des conditions égalitaires (remplacement) dans Cond0
      sup_cond_egal(Cond,Cond0),
   %% ajout de la condition "E n'est pas déjà une hypothèse"
      ajoufinseq(Cond, \+ hyp(N,E,_), Cond1),
   %% ajout de l'action "ajouter l'hypothèse E"
      Act=ajhyp(N,E,I1),
      ajoufinseq(Cond1, Act , CondAct2),
   %% priorité donnée à la règle:1 par défaut, 2 dans deux cas particuliers
      ( E = (?_:_) -> Priorite = 2, atom_concat(Nom, '_exist-prio2_', Nom1)
      ; E = (_ | _) ->  Priorite = 2, atom_concat(Nom, '_ou-prio2_', Nom1)
      ; Nom = Nom1, Priorite = 1
      ), 
   %% nouveau nom pour la règle en construction,
   %%    à partir du nom donné en paramètre
      creer_nom_regle(Nom1,Nom2),
      assert(priorite(Nom2,Priorite)),
   %% texte pour la trace, avec ou sans conditions
      (Cond0=[] -> SiAlorsAct=Act
      ; ( lang(fr) -> SiAlorsAct = (si Cond0 alors Act)
        ; lang(en) -> SiAlorsAct = (if Cond0 then Act)
        ; SiAlorsAct =  (si Cond0 alors Act)
        )
      ),
      copy_term(SiAlorsAct,SiAlorsActCop),
   %% texte d'explication à mettre dans la trace selon que la règle
   %% provient d'une hypothèse universelle, d'un lemme ou autre
     ( Concept=(_ + HypUnivImp) ->
         affecter(hypuniv(HypUnivImp)), hypuniv(HypU),
         Expli1 = ('\nest une regle locale construite'),
         Expli2 = ('à partir de l\'hypothese universelle'),
         Expli = ['la regle',
                  Nom2,:,
                  SiAlorsActCop,
                  Expli1,Expli2, 
                  HypU]
      ; Concept=lemme -> Expli = [regle2-lemme,
                                  SiAlorsActCop,
                                  '\nconstruite à partir de l\'axiome', 
                                  Nomfof]
      ; Expli= [regle2-autre,SiAlorsActCop,
                '\nconstruite à partir de la definition de',
                Concept,
                '(fof',
                Nomfof,
                ')']
      ),
   %% tout le texte de la trace 
      ajoufinseq(CondAct2,
                   traces(N,regle(Nom2),Cond0,ajhyp(N,E,I1),I1,
                          Expli, Antecedants),
                   Regle
                   ),
        \+ tempsdepasse(-1,avant_ajoureg),
   %% mémorisation de la règle 
        ajoureg(N, Concept, Nom2, Regle)
). %% fin de consreg/6 

%% ++++++++ ajoucond(N,C,An,A,CA,AnA) +++ appelée par consreg(...) ++++++++
%% ajoute A ou des conditions issues de A à la partie C déjà construite
%%     et l'etape en cours à la liste An des etapes des conditions
%%   pour donner CA et AnA
ajoucond(N,C,An,A,CA,AnA) :- 
     ( var(A) -> ajoufinseq(C,hyp(N,A,_),CA)
     ; A = (A1 & A2) -> ajoucond(N,C,An,A1,C1,An1),
                        ajoucond(N,C1,An1,A2,CA,AnA)
     ; A = (?_:B) -> ajoucond(N,C,An, B, CA,AnA)
     ; A = seul(FX::Y,B) -> ajoucond(N,C,An,FX::Y,CB,AnB),
                            ajoucond(N,CB,AnB,B,CA,AnA)
     ; A = (B=D), (var(B);var(D)) -> ajoufinseq(C,A,CA), AnA=An
     ; A = (..[F,X]::Y) -> ajouseqavantobjet(C,T=..[F,X],C1), 
                          ajouseqavantobjet(C1,hyp(N,T::Y,_),CA)
     ; A = (..[R,X,Y]) -> ajouseqavantobjet(C,T=..[R,X,Y],C1),
                        ajoucond(N,C1,An,T,CA,AnA)
     ; A = objet(N,X) -> ajoufinseq(C,obj_ct(N,X),CA), AnA=An
     ; A = (!_:_) -> fail 
     ; A = (~ seul(FX::Y,P)) -> ajoucond(N,C,An,seul(FX::Y,~ P),CA,AnA)
     ; %% sinon 
       ajouseqavantobjet(C,hyp(N,A,Etape),CA),
       ajoufin(An,Etape,AnA)
     ) .

%% ++++++++ ajoureg(N, Arg, Nom, Corps) +++ appelée par consreg(...) ++++++++ 

%% mémorise la règle construite par consreg
%% Corps est l'énoncé, construit par consreg, de la regle de nom Nom
%% les conditions égalitaires en sont supprimées/remplacées (Corps0)
%% Arg est un concept, un marqueur ou de la forme N+H si la regle
%%    a été construite à partir de l'hypothèse universelle H 
%% la règle est alors mémorisée sous forme de la clause, executable,
%%       regle(N,Nom) :- Corps0.
%% pour les règles construites à partir d'hypothèses universelles
%%    ceci est fait par un appel à ajoureglocale qui ajoutera aussi
%%    le nom de a règle dans la liste des règles actives

ajoureg(N, Arg, Nom, Corps) :- 
    sup_cond_egal(Corps, Corps0),
    (ecrireconsreg -> nl,ecrire1('ajoureg apres sup_cond_egal'-Corps0);true),
    ( Arg=(Nsth+H) -> etape(E),assert(reglehypuniv(Nom,H,E)),
                      ajoureglocale(Nsth,(regle(N,Nom):-Corps0), Nom)
    ; assert((regle(N,Nom) :- Corps0)), assert(type(Nom,Arg))
    ).


%% ++++++++++++++++ sup_cond_egal(Corps,Corps0) ++++++++++++++++
%%            +++ appelée par consreg et ajoureg +++
%% supprime les conditions X=Y et remplace partout X (ou Y) par Y (ou X)
%% si X (ou Y) est une variable non instanciée
sup_cond_egal(Corps,Corps0) :- 
      ( sup_egal(X=Y,Corps, Corps1) -> 
              ( var(X) -> remplacer(Corps1,X,Y,Corps2)
              ; var(Y) -> remplacer(Corps1,Y,X,Corps2)
              ),
              sup_cond_egal(Corps2,Corps0)
      ; Corps0=Corps
      ).

%% ++++++++++ sup_egal(X=Y,L,L1) +++ appelée par sup_cond_egal ++++++++++
%% suprime les égalités X=Y d'une séquence
sup_egal(X=Y,(X=Y,L),L) :- !. 
sup_egal(X=Y,(L,X=Y),L) :- !.
sup_egal(X,(Y,L),(Y,L1)) :- sup_egal(X,L,L1),!.
sup_egal(X=Y,X=Y,[]) :-  ! . 


%% +++ ajoureglocale(Nth,ClauseR, Nom) +++ appelée par ajoureg et traitegal +++
%% mémorise la règle ClauseR= (regle(_,Nom):- _) et
%% ajoute son Nom dans la liste des règles actives du (sous-)th Nth,
%% à la fin des règles générales (regles_gen), avant les autres règles
ajoureglocale(Nth,ClauseR, Nom) :- 
         reglactiv(Nth,LR), ClauseR= (regle(_,Nom):- _), etape(E),
         assert(ClauseR),
         acrire1(tr,[E:Nth, 'ajouter la regle active locale']),
         ecrire_simpl_R(tr,ClauseR), %% affichage simplifié de la règle
         acrire1(tr,'a la fin des regles générales'),
         ligne(tr),
         assert(type(Nom,Nth)),
         regles_gen(LRG),append(LRG,LRNG,LR),
       NLRNG=[Nom|LRNG] ,
       append(LRG,NLRNG,NLR),
       retract(reglactiv(Nth,LR)), assert(reglactiv(Nth,NLR)),
       !.

%% supprime la regle de nom Nom de la liste de règles LR
desactiver(N,Nom) :- reglactiv(N,LR),member(Nom,LR),oter(Nom,LR,LR1),
                     retract(reglactiv(N,LR)), assert(reglactiv(N,LR1)),
    acrire1(tr,[N,'supprimer la regle active',
                Nom]).
desactiver(_,_). 
%% L1 est la liste L sans la première occurrence de X 
oter(X,[X|L],L) :- !. 
oter(X,[Y|L],[Y|L1]) :- oter(X,L,L1),!.
oter(_,[],[]).

activreg :- 
            acti_lien, acti_univ, 
            acti_enpremier, 
            acti_ro,  acti_et, acti_def1,
            acti_exist, acti_ou, 
            acti_def2,
            acti_concl_exist,
            acti_endernier,
            ! .

acti_lien :- 
             forall(concept(C),assert(lien(0,C))).

acti_univ :- regles_gen(LR), assert(reglactiv(0,LR)).
acti_ro :- priorites(sans),
           reglactiv(0,LR), 
           ecrire1('\nacti_ro sans priorite'),
           ( bagof(R, P^( lien(0,P),type(R,P)),RR)-> true
           ; RR= []   
           ),
           append(LR, RR, LRR1),
           ( bagof(R, ( type(R,lemme)),RR1) -> append(LRR1, RR1, LRR)
           ; LRR = LRR1 
           ) ,
           retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)),
           fail.
acti_ro :- priorites(avec),
           reglactiv(0,LR), 
           ( bagof(R, P^( lien(0,P),type(R,P),\+ priorite(R,2),
                          \+ type(R,enpremier),\+ type(R,endernier)),RR)
             -> true
           ; RR= []   
           ),
           append(LR, RR, LRR1),
           ( bagof(R,(type(R,lemme),\+ priorite(R,2),
                     \+ type(R,enpremier),\+ type(R,endernier)),RR1)
              -> append(LRR1, RR1,LRR2)
           ; LRR2 = LRR1 
           ) ,
           ( bagof(R, P^( lien(0,P),type(R,P),priorite(R,2)),RR2)
             -> append(LRR2,RR2,LRR3)
           ; LRR3 = LRR2
           ),
           ( bagof(R,(type(R,lemme),priorite(R,2)),RR3) -> append(LRR3, RR3,LRR)
           ; LRR = LRR3
           ) ,
           retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)),

           fail.
acti_ro .
acti_enpremier :- reglactiv(0,LR), 
                 ( bagof(R, ( type(R,enpremier)),RR1) -> append(LR,RR1,LRR)
                 ; LRR=LR
                 ) ,
                 retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)),
                 fail.
acti_enpremier.
acti_endernier :- reglactiv(0,LR), 
                 ( bagof(R, ( type(R,endernier)),RR1) -> append(LR,RR1,LRR)
                 ; LRR=LR
                 ) ,
                 retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)),
                 fail.
acti_endernier.


acti_et :-  reglactiv(0,LR), regles_et(RET), append(LR,RET,LRR),
            retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)).
acti_ou :-  reglactiv(0,LR), regles_ou(ROU), append(LR,ROU,LRR),
            retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)).
acti_def1 :- reglactiv(0,LR), regles_defconcl1(RR), append(LR,RR,LRR),
             retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)).
acti_def2 :- reglactiv(0,LR), regles_defconcl2(RR), append(LR,RR,LRR),
             retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)).
acti_exist :- reglactiv(0,LR),regles_exist(RILE),append(LR,RILE,LRR),
                 retractall(reglactiv(_,_)),assert(reglactiv(0,LRR)).
acti_concl_exist :- reglactiv(0,LR), regles_concl_exist(RILE), 
                       append(LR,RILE,LRR), retractall(reglactiv(_,_)),
                       assert(reglactiv(0,LRR)).

compareg1ter([I1,I2,X,X,Y,Z|_],[I3,I6,I4,I5,Y,Z]) :- I3 is I1+1, I4 is I2-1,
                                               I5 is I4-1, I6 is I5-1.
traitegal(N,X,Y,Ixy) :- \+ tempsdepasse(N,traitegal),
                         acrire1(tr,traitegal-N-X-Y-Ixy),fail.
traitegal(N, X, Y, Ixy) :- 
  hyp(N, H,I),
  \+ H =(X=Y), 
  remplacer(H,Y,X,H1),\+ H=H1,
  retract(hyp(N,H,_)),
  \+ hyp(N, H1,_), ajhyp(N, H1,I1),
  traces(N,'action(traitegal_hyp)',
         (hyp(N,X=Y,Ixy),hyp(N,H,I)), 
         ajhyp(N, H1,I1),I1,
         ['on remplace',Y,par,X,'dans les hypotheses'],
         [I,Ixy]
         ), 
  acrire1(tr,'-------------------------------- action traitegal_hyp'),
  fail.
traitegal(N, X, Y,_) :- 
         hyp_traite(N, H), \+ H =(_=_),
         remplacer(H,Y,X,H1),\+ H=H1,
         retract(hyp_traite(N,H)),
         \+ hyp(N, H1, _), 
         acrire1(tr,'et apres'),
         ajhyp_traite(N, H1),
         fail.
traitegal(N,X,Y,Ixy) :- 
     concl(N, X=Y,I), nouvconcl(N, true,I1),
     traces(N,action('traitegal_concl='),
            (hyp(N,X=Y,Ixy),concl(N, X=Y,I)),
            nouvconcl(N, true,I1),I1,
            ['on remplace',Y,par,X,'dans la conclusion'],
            [I,Ixy]
           ),
     acrire1(tr,'-------------------------------- traitegal_concl=').
traitegal(N,X,Y,Ixy) :- 
      concl(N, C, I),  remplacer(C, Y,X,C1), \+ C=C1,
      nouvconcl(N, C1, I1),
      traces(N,action(traitegal_concl),
               (hyp(N,X=Y,Ixy),concl(N, C, I)),
               nouvconcl(N, C1, I1),I1,
               ['on remplace',Y,par,X,'dans la conclusion'],
               [I,Ixy]
               ),
      acrire1(tr, '-------------------------------- traitegal_concl'),
      fail.
traitegal(N,X,Y,I) :- 
        clause(regle(L,Nom),Q), 
        \+ Nom = ! , 
        \+ Nom = concl_seul , 
        reglactiv(N,LR),member(Nom,LR),
        concat_atom(['trop de regles a tester pour le remplacement de ',
                     Y,' par ',X],Message),
        \+ tempsdepasse(N,Message),
        remplacer(Q, Y,X,Q1), \+ Q=Q1,
        sup_cond_triviales(Q1,Q2), 
        creer_nom_regle(Nom,Nom1),
        remplacer(Q2,Nom,Nom1,Q3),
        R = (regle(L,Nom1):-Q3),
        ajoureglocale(N,R,Nom1),
        etape(E),
        traces(N,action(traitegal_regle),
                 regle(Nom),creer_regle(Nom1),E,
                 [Y,'est remplace',X,
                    'dans la regle',Nom,
                    'pour donner la regle',Nom1],
                 [I]
               ),
        desactiver(N,Nom),
        acrire1(tr,'-------------------------------- traitegal_regle'
               ),
        fail.
traitegal(N,X,Y,_) :- 
       retract(hyp(N,X=Y,_)), 
       acrire1(tr,['supprimer hypothese', X=Y]),
       retract(objet(N,Y)),
       acrire1(tr,['supprimer objet',Y]).
traitegal(_,_,_,_). 
sup_cond_triviales( (hyp(_,X=X,_)),[]) :- 
                                          !.
sup_cond_triviales( (hyp(_,X=X,_),Q),Q1) :- sup_cond_triviales(Q,Q1),!.
sup_cond_triviales( (Q,hyp(_,X=X,_)),Q) :- 
                                     !.
sup_cond_triviales((X,Q),(X,Q1)) :- sup_cond_triviales(Q,Q1),!.
sup_cond_triviales(Q,Q).

%% +++++++ elifondef + elifondef1 + elifondef2 + elifondef3 + elifondef4 +++++++

elifondef :- %% definition !_:(A=B)
             definition(Nomfof,D), D=(!_:(A=B)), 
             assert(definition1(Nomfof,A=B )),
             retract(definition(Nomfof,D)),
             fail.

elifondef :- definition(Nomfof,D), D=(!_:(~(A=B))), 
             assert(definition1(Nomfof,~(A=B))), retract(definition(Nomfof,D)),
             fail.

elifondef :- %% definition(A<=>B),
             definition(Nomfof,D), D=(!_:(A<=>B)), 
             A=..[P|_],
             ( B=..[P|_] -> true
             ; B=(~B2), B2=..[P|_]-> true
             ; true
             ),
             elifon(B,B1), 
             assert(definition1(Nomfof,A<=>B1)),
             (ecrireconsreg->ecrire1(elifondef-ancienne-def-definition(Nomfof,D)-
                                     nouvelle-definition1(A<=>B1))
             ;true),
             retract(definition(Nomfof,D)),
             fail.
elifondef :- definition1(Nomfof,D),
             retract(definition1(Nomfof,D)),assert(definition(Nomfof,D)),fail.

elifondef :- lemme(Nom,B),elifon(B,B1),
             retract(lemme(Nom,B)),assert(lemme1(Nom,B1)),
             (avecseulile -> 
                (element(_H=>seul(_FXY,_C),B1),\+ (seulile(oui))
                                                       -> assert(seulile(oui))
                ; B1 = seul(_FXY,_C),\+ (seulile(oui)) -> assert(seulile(oui))
                ; element(_H=>_C1 & seul(_FXY,_C),B1),\+ (seulile(oui))
                                                       -> assert(seulile(oui))
                ; element(_H=>seul(_FXY,_C) & _C1,B1),\+ (seulile(oui))
                                                       -> assert(seulile(oui))
                ; element(_H<=>seul(_FXY,_C),B1),\+ (seulile(non))
                                                       -> assert(seulile(non))
                )
              ; true  
             ),
             fail.

elifondef :- lemme1(Nom,B), retract(lemme1(Nom,B)),assert(lemme(Nom,B)), fail.

elifondef :- definition(Nomfof,D),D=(!_:De),
             retract(definition(Nomfof,D)), assert(definition(Nomfof,De)),
             fail.

elifondef.

elifon(E, E1) :- 
         ( (var(E);E=false;objet(_,E)) -> E1=E   
         ; (atom(E);number(E)) -> ajobjet(-1,E), E1 =E 
         ; E =..[P,A,B], (P= => ; P = (&) ; P= <=>  )
           -> elifon(A,A1),elifon(B,B1),E1 =..[P,A1,B1]
         ; E=(A|B) -> elifon(A,A1),elifon(B,B1),E1 = (A1|B1)
         ; E=[A,B,C]
           -> elifon(A,A1),elifon(B,B1),elifon(C,C1),E1 = [A1,B1,C1]
         ; E=[A,B]
           -> elifon(A,A1),elifon(B,B1),E1 = [A1,B1]
         ; E = (..L) -> elifon(L, L1), E1 = (..L1)
         ; E =(!XX:P) -> elifon(P,P1), E1 = (!XX:P1)
         ; E =(?XX:P) -> elifon(P,P1), E1 = (?XX:P1)
         ; E =seul(_,_) -> elifon2(E,E1)
         ; E =(_::_) -> E=E1
         ; E  = (~ A) -> elifon(A, A1), E1 = (~ A1)
         ; E = (A=B), varatom(A), \+ varatom(B) -> elifon3((B::A),E1)
         ; E = (A=B), varatom(B), \+ varatom(A) -> elifon3((A::B),E1)
         ; E =..[_P|_] -> elifon1(E,E1)
         ; message(z_elifonpasprevu,E)
         ),
         ! .

elifon2(E,E5) :- 
                 E = seul(FX::Y,E1), FX =.. [F|Args], 
                 length(Args,N), ajfonction(F,N), 
                 member(Arg,Args), 
                 \+var(Arg), \+objet(_,Arg),
                 ( (atom(Arg);number(Arg)) -> ajobjet(-1,Arg),fail
                 ;
                 remplacer(Args,Arg,Z,Args1), 
                 FX1 =.. [F|Args1], elifon2(seul(FX1::Y,E1),E3),
                 E4=seul(Arg::Z,E3),elifon2(E4,E5)
                 ),
                 !.
elifon2(E,E). 

elifon1(E,E4) :- 
                 (E=(_::_) -> E4=E;true), 
                 E =.. [P|Args], \+ P = seul, member(Arg,Args),
                 \+var(Arg), \+ objet(_,Arg),
                 ( (atom(Arg);number(Arg)) -> ajobjet(-1,Arg),fail
                 ;
                 remplacer(Args,Arg,Y,Args1), 
                 E1 =.. [P|Args1],
                 elifon(E1,E2),elifon1(E2,E22),E3=seul(Arg::Y,E22),
                 elifon2(E3,E4) 
                 ),
                 !.
elifon1(E,E).

elifon4(FY::X,(Z,E1 & E2)) :- 
                         FY =.. [F|Args], member(Arg,Args),
                         \+ atom(Arg), \+var(Arg), \+number(Arg),
                         remplacer(Args,Arg,Z,Args1), FY1 =.. [F|Args1],
                         elifon4(FY1::X, E1),
                         elifon4(Arg::Z,E2),
                         !.
elifon4(E,E).

elifon3(FX::Y,E) :- 
                    FX =.. [F|Args], member(Arg,Args),
                    \+var(Arg), \+ objet(_,Arg),
                    ( (atom(Arg);number(Arg)) -> ajobjet(-1,Arg),fail
                    ;
                    remplacer(Args,Arg,Z,Args1), FY1 =.. [F|Args1],
                    elifon3(FY1::Y,FY1Y),
                    elifon2(seul(Arg::Z,FY1Y),E)
                    ),
                    !.
elifon3(E,E).

%% ++++++++++++++++++++ traiter +++++++++++++++++++++

traiter(N,(?[X|XX]:P),I1) :-        
     ( var(X) ; atom(X)), !,
     ( P = (Q & R & S) -> \+ (hyp(N, Q1,_), eg(Q,Q1), 
                            hyp(N, R1,_), eg( R,R1), hyp(N, S1,_), eg(S,S1))
     ; P = (Q & R) ->  \+ (hyp(N, Q1,_), eg(Q,Q1), hyp(N, R1,_), eg( R,R1))
     ; \+ (hyp(N, P1,_), eg(P,P1))
     ) ,
     creer_objet(N,z,X1), ajobjet(N,X1), remplacer(P,X,X1,P1), 
     traces(N,action(traiter_exi),      
            (?[X|XX]:P),traiter(N,P1,I1),I1,
            traiter_exi,
            []
            ),
     ( XX=[] -> traiter(N, P1, _I,I1) 
     ;  traiter(N,(? XX:P1),I1)
     )  . 
traiter(N,H,_I,I1) :- ajhyp(N, H,I1).
eg(P,P1) :- ( P = P1
            ; P1 = (F1::Y) , P = (F::Y), F1=..L,F = (..L),
              message([eg,oui,ce,cas,se,produit]),read(_)   
            ) .


%% efface ce qui concerne le dernier theoreme qui vient d'être étudié
%% n'efface pas les definitions ni les regles construites
%% peut être appelé sous Prolog
%% utilisé dans version th si plusieurs théorèmes à démontrer, 
effacerth :- 
      effacer([sousth(_,_),
               theoreme(_),
               chemin(_),
               hyp(_,_,_), hyp_traite(_,_), ou_applique(_),
               concl(_,_,_),
               lien(_,_),
               objet(_,_),
               fonction(_,_),
               reglactiv(_,_),
               tracedem(_,_,_,_,_,_,_),
               conjecture(_,_), fof(_,_,_), include(_),
               priorite(_,_),
               fichier(_),
               reglehypuniv(_,_,_),
               etape(_),
               fof_traitee(_,_,_),
               res(_),
               seulile(_)
              ]),
       assert(conjecture(false, false)),
       assert(seulile(niouininon)),
       affecter(probleme(pas_encore_de_probleme)),
       affecter(nbhypexi(0)),
       reset_gensym,
       told.
%% efface tout ce qui concerne le dernier theoreme étudié
%% y compris les définitions et les règles construites
%% peut être appelé sous Prolog
effacertout :- 
      effacerth,
      effacer([version(_),
               include(_),
               definition(_),definition(_Nomfof,_), lemme(_,_),
               priorite(_,_), 
               concept(_),
               etape(_),
               fof_traitee(_,_,_),
               seulile(_)
              ]),
       assert(seulile(niouininon)), 
       effacer_regcons,
       told.
effacer([Item|Items]) :- effacer(Item), effacer(Items),!.
effacer([]) :- !. 
effacer(Item) :- retractall(Item).

%% efface toutes les regles construites
effacer_regcons :- type(R,C), 
                   \+ C=donnee,  
                   retract((regle(_,R):- _)),retract(type(R,_)),fail.
effacer_regcons :- effacer(type(_,_)).

%% affiche les faits hyp(..), concl(..), objet(..)
listeth :- liste([hyp, concl, objet]).
%% affiche tous les faits que vous voulez
listetout :- liste([hyp, hyp_traite, concl, 
                    conjecture,
                    fof 
                    ]),
             (lang(fr) -> liste([reglactiv])
             ;lang(en) -> liste([rulactiv])
             ; true 
             ).
liste([Item|Items]) :- listing(Item), liste(Items).
liste([]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  actions elementaires  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

creer_objet(N,X,XX) :- 
   gensym(X,XX),  
   ajobjet(N,XX).

creer_objets_et_remplacer(N,[X|XX],CX,C1,OO) :- 
           creer_objets_et_remplacer(N,[X|XX],CX,C1,[],OO). 
creer_objets_et_remplacer(N,[X|XX],CX,C1,OO1,OO2) :-
       gensym(z, Z), ajobjet(N, Z), ligne(tr),tab(3), 
       remplacer(CX,X,Z,CZ),
       creer_objets_et_remplacer(N,XX, CZ,C1,[Z|OO1],OO2).
creer_objets_et_remplacer(_N,[],C,C,OO,OO).

creer_nom_regle(R,RR) :- 
                        ( type(R,_) -> suc(R,R1),creer_nom_regle(R1,RR)
                         ; RR = R).

remplacer(E, X, Y, E1) :-
    ( E == X -> E1 = Y
    ; (var(E) ; atom(E)) -> E1 = E
    ; E = [] -> E1 = []
    ; E = [A|L] -> remplacer(A, X, Y, A1), remplacer(L, X, Y, L1), 
                   E1 = [A1|L1]
    ; E =..[F|A] -> remplacer(A, X, Y, A1), E1 =..[F|A1]
    ).


hypou(A | B => C, (A => C) & BC) :- hypou(B => C, BC),!.
hypou(T,T).

%% +++++++++++++++++++++++ hyp_true(N,H,T) +++++++++++++++++_
%% si H est une disjonction dont un des elements est une hypothese,
%%    renvoie cette hypothese T
hyp_true(N,A|B,T) :- hyp(N,A,_),T=A;hyp_true(N,B,T).
hyp_true(N,A,A) :- hyp(N,A,_).

ou_et(_,_) :- tempsdepasse(_,ou_et). 
ou_et(A & B,C) :- ou_et(A,A1), ou_et(B,B1),assoc(A1 & B1,C),!.
ou_et(A | (B & C),F) :- ou_et((A | B) & (A | C),F),!.
ou_et((A & B) | C, F) :- ou_et((A | C) & (B | C),F),!.
ou_et(A | B,F):- ou_et(A,A1),ou_et(B,B1),not((A=A1,B=B1)),
                  ou_et(A1 | B1, F),!.
ou_et(A,A).
assoc(_,_) :- tempsdepasse(_,assoc).
assoc((A & B) & C,F) :- assoc(A & B & C,F),!.
assoc(A & B,A1 & B1) :- assoc(A,A1), assoc(B,B1),!.
assoc((A | B) | C,F) :- assoc(A | B | C,F),!.
assoc(A | B,A1 | B1) :- assoc(A,A1), assoc(B,B1),!.
assoc(A, A).

ou_non(A | ~ B, A, B) :- ! .
ou_non(A | ~ B|C, A|C, B) :- ! .
ou_non(~ B | A , A, B) :- ! .
ou_non(A | B, A | Aplus, Amoins) :- ou_non(B, Aplus,Amoins). 

elt_ou(A,A | _) :- !.
elt_ou(A,_ | A) :- !. 
elt_ou(X, _ | B) :- elt_ou(X,B),!.
elt_ou_bis(N, A | _) :- elt_ou_bis(N, A),!. 
elt_ou_bis(N, A) :- A = seul(FX::Y,P), hyp(N,FX::Y,_), hyp(N,P,_),
                    acrire1(tr,elt_ou_bis-'FX::Y'/(FX::Y)-'P'/P), !.
elt_ou_bis(N, A) :- 
                 A = seul(FX::Y,Z=T), hyp(N,FX::Y,_), Y=Z, Y=T, 
                 acrire1(tr,elt_ou_bis-'FX::Y'/(FX::Y)-'Y'/Y-'Z'/Z-'T'/T), !.
elt_ou_bis(N, _ | B) :- elt_ou_bis(N, B), acrire1(tr,elt_ou_bis_), !.
 
%%%%%%%%%%%%%%%%%%%%%
%%    écritures    %%
%%%%%%%%%%%%%%%%%%%%% 

ecrire1(L):- ligne, ecrire(L). 
ecrire1etmessage(M) :- message(M),ecrire1(M).
acrire_tirets(Option,E) :- (afficher(Option) -> ecrire_tirets(E);true).
ecrire_tirets(E) :- ligne,
       ecrire([-------------------------------------------------------]),
       ecrire(E).  

acrire(Option,E) :- (afficher(Option) -> ecrire(E);true).
acrire1(Option,E) :- (afficher(Option) -> ecrire1(E);true).
ecrire(E) :- var(E) , write('_'). 

ecrire(fr(FR)/en(EN)):- message('il reste un'=fr(FR)/en(EN)). 
ecrire(fr(FR)/en(EN)+_ ):-
  (lang(fr) -> (lang(en) -> ecrire(FR/EN) ; ecrire(FR))
               ;lang(en) -> ecrire(EN)
               ), !.
ecrire(E) :- (var(E) -> write(E)
             ;E = [X|L] -> ecrire(X), tab(1), ecrire(L)
             ;E=[] -> true
             ;ecrireAA(E)    
             ).
ecrireAA(T) :- 
              numbervars(T,0,_,[singletons(true)]), 
               write_term(T,[numbervars(true),max_depth(29)]),
               fail.
ecrireAA(_).            
ecrireV(E) :- (var(E) -> write(E)
         ; (element(!,E);element(?,E);element(seul,E))
                      -> writeV(E)
         ; E=(_ :- _) -> writeV(E) 
         ; write(E)
         ).
writeV(E) :- assert(-(E)),listing(-),retract(-(E)).

ligne :- nl.
ligne(Option) :- (afficher(Option) -> nl;true).

message(M) :- 
              ( version(casc) -> true
              ; version(direct) -> true
              ; tellling(F),toldd,ecrire1(M),appendd(F)
              ).
message0(M) :- 
              ( version(casc) -> true
              ; version(direct) -> true
              ; tellling(F),toldd,ecrire(M),appendd(F)
              ).
message(Fich,M) :- tellling(F), appendd(Fich), probleme(Probleme),
                   ecrire1(Probleme),ecrire1(M),appendd(F).

%% ++++++++++++++ traces(N,Nom,Cond,Act,E,Expli,Antecedants) ++++++++++++++

%% affiche (si option tr) et mémorise dans tracedem l'action Act, à l'etape N,
%% de la règle ou action Nom, avec ses Conditions, ses Antecedants 
%% et une Explication

traces(N,Nom,Cond,Act,E,Expli,Antecedants) :- 
       (Cond=[] -> true
       ;acrire1(tr,['car']), acriretracecond(tr,Cond)
       ),
       acrire1(tr,'etape(s) des antecedants'),
       acrire(tr,'':Antecedants),       
       acrire(tr,' etape de l\'action'),
       acrire(tr,'':E),
       acrire1(tr,'expl : '), acrire(tr,Expli),
       assert(tracedem(N,Nom,Cond,Act,E,Expli,Antecedants))
       .

  

limitertemps(TL) :- 
           affecter(tempslimite(TL)).

tptp :- ( lang(fr) -> shell('cat tptp-commandes')
        ; lang(en) -> shell('cat tptp-commands')
        ; nl,write('definir un langage/define a language')
        ).

m :- ['muscadet-perso'].
t :- testtr. 
testtr :- tptp('SET002+4.p',+tr). 
test :- tptp('SET002+4.p'). 
t27 :- tptp('SET027+4.p'). 
t12 :- tptp('SET012+4.p').
testth :- th('exemples/exemple1').
p :- demontrer(p).           
petp :- demontrer(p & p).   
pimpp :- demontrer(p => p).  

casc(FICH) :- 
              affecter(lengthmaxpr(100000)),
              affecter(version(casc)),
              tptp([FICH,+pr,-tr,+szs,100000]).

%% +++++++++++++++++++ préambule ++++++++++++++++++++++

preambule :- (afficher(pr)|afficher(tr)|version(casc) ->
     ecrire1('----------------------------------------'),
     ecrire1('dans ce qui suit'), 
     ecrire1('N est le numéro d''un (sous-)théorème'),
     ecrire1('E est un numéro d''etape'),
     ecrire1('E:N <action> désigne une action effectuée à l''etape E'),
     ecrire1('un sous-théorème N-i ou N+i est un sous-théorème du (sous-)théorème N'),
     ecrire1('N est démontré si tous les N-i ont été démontrés (noeud-et(&))'),
     ecrire1('            ou si un N+i a été demontré (noeud-ou(|))'),
     ecrire1('\nle theoreme initial a pour numero 0')
     ;true
     ).
      
         




%% ++++++++++++++++++++ tptp([Pb|Options]) ++++++++++++++++++++

%% démontration d'un problème Pb de TPTP, 
%% le 1er argument est le nom d'un problème ou un chemin vers un problème
%%    (chaine de caractères, entre quotes si nécessaire)
%% les autres arguments, facultatifs, sont, dans n'importe quel ordre
%%      un temps limite (nombre ou produit de 2 nombres)
%%      +Option pour options d'affichage :
%%              +tr (trace complète)
%%              +pr (etapes utiles)
%%              +szs (résultat selon l'ontologie SZS)
%%              +reg (affichage détaillé de la construction des règles)
%%      -Option pour supprimer l'option : -tr, ...
%%       options par défaut : voir lignes "^afficher(...)"... (modifiables)  
tptp([A|AA]) :-
   ( atom(A),exists_file(A) -> file_base_name(A,NomPb),
                       affecter(chemin(A)),affecter(probleme(NomPb)),
                       tptp(AA)
   ; atom(A),sub_atom(A,0,3,_,DOM), getenv('TPTP',TPTPdir),
     concat_atom([TPTPdir,'/Problems/',DOM,'/',A],CHEMIN),
     exists_file(CHEMIN) -> affecter(chemin(CHEMIN)),affecter(probleme(A)),
                             tptp(AA)
   ; number(A) -> limitertemps(A), tptp(AA)
   ; A=(B*C) -> BC is B*C, BC1 is max(10,BC),
           limitertemps(BC1), tptp(AA)
   ; A=(+B) -> ( afficher(B) -> true ; assert(afficher(B))), tptp(AA)
   ; A=(-B) -> retractall(afficher(B)), tptp(AA)
   ; (A=fr|A=en) ->  affecter(lang(A)),  tptp(AA) 
   ; ecrire1(['donnee incorrecte',A]),nl
   ),!. 
tptp([]) :-
   (version(casc) -> assert(version(tptp));affecter(version(tptp))),
   statistics(cputime,Tdebut),
   affecter(temps_debut(Tdebut)),
   (chemin(Ch) ->
     ( version(casc) -> RES=user, REG=res
     ; write('---------------------------------------------------'),
       acrire1(tr,chemin=Ch),
       probleme(NomPb), acrire1(tr,probleme=NomPb),
       atom_concat(res_,NomPb,RES), 
       (lang(en) -> atom_concat(rul_,NomPb,REG);atom_concat(reg_,NomPb,REG))
       ),
       affecter(res(RES)), affecter(reg(REG)),
       lire(Ch),
       charger_axioms,
       \+ tempsdepasse(-1,apres_charger_axioms),
       travail1,
       \+ tempsdepasse(-1, 'apres travail1'),
       ( afficher(tr) -> tell(REG),  listing(regle), l(type),
                         l(priorite),l(definition),l(lemme), told
       ; true
       ),
       conjecture(NomConj,TH),
       (NomConj=false->affecter(nomdutheoreme(contradiction))
       ;affecter(nomdutheoreme(NomConj))
       ), 
       telll(RES), 
       acrire1(tr,Ch), acrire1(tr,NomConj),
       demontr(TH),
       ( version(casc) -> true
       ; statistics(cputime,Tfintptp), affecter(tempspasse(Tfintptp))
       ),
       nl,toldd, 
       ( afficher(tr) -> tell(REG), listing(regle), l(type),
                         l(priorite),l(definition),l(lemme), told
       ; true
       ),

       ! 
   ; ecrire1('pas de fichier ni chemin ni probleme')
   ). 
%% +++

%% raccourcis 
tptp(A) :- atom(A), tptp([A]).
tptp(A,B) :- tptp([A,B]).
tptp(A,B,C) :- tptp([A,B,C]).
tptp(A,B,C,D) :- tptp([A,B,C,D]).
tptp(A,B,C,D,E) :- tptp([A,B,C,D,E]).
tptp(A,B,C,D,E,F) :- tptp([A,B,C,D,E,F]).

tptptest :- tptp([-name, 'SET002+4.p', -print, tr+pr+szs]).

messagetemps(Tdem) :- 
       Format = '~2f sec',
       Texte=(' en '),
       ecrire(Texte), message0(Texte),
       format(Format, Tdem),
       (version(direct) -> true;format(user, Format, Tdem)),
       ecrire1(========================================),
       ecrire(========================================),
       message('---------------------------------------------------').
messagetemps(Option, Tdem) :- 
      (version(casc) -> true 
      ; Format = '~2f sec',
       Texte=(' en '),
       acrire(Option,Texte), message0(Texte),
       format(Format, Tdem), format(user, Format, Tdem),
       acrire1(Option,++++++++++++++++++++++++++++++++++++++++),
       acrire(Option,++++++++++++++++++++++++++++++++++++++++),
       message('---------------------------------------------------')
      ).

trad(E,E1) :- 
              ( varatom(E) -> E1=E
              ; E=[] -> E1=E 
              ; number(E) -> E=E1
              ; E = (A=B), var(A) -> trad(B,B1),E1=(A=B1)
              ; E = ( A!=B) -> E1 = (~(A=B)) 
              ; E = ( A <= B ) -> E1=(B => A) 
              ; E = ( A <~> B ) -> E1=(~(B <=> A))
              ; E = ( A ~& B ) -> E1=(~(B & A))
              ; E = [L|LL] -> trad(L,L1),trad(LL,LL1), E1=[L1|LL1]
              ; E=..L -> trad(L,L1), E1=..L1
              ; E=E1
              ).

lire(FICH) :- 
 op(450,xfy,:), 
 consult(FICH),
	fof(Nomfof,Nature,FormuleTPTP), trad(FormuleTPTP,Formule),
	\+ tempsdepasse(-1,lire),
       concat_atom([Nature,':',Nomfof], Nature_Nomfof), 

 (Nature = conjecture ->                                    
                          effacer([conjecture(_,_)]),
                          assert(conjecture(Nature_Nomfof,Formule))

 ;(Nature=axiom;Nature=hypothesis;Nature=lemma
               ;(Nature=definition , \+ afficher(sansdef))
               ; Nature=assumption) ->



     (Formule=(! _ :(A=B)) -> 
        assert(lemme(Nature_Nomfof,member(X,A <=> member(X,B)))),
        ( \+ var(A), A=..[P|L],vars(L), \+ element(P,B)
                  -> 
                     assert(definition(Nature_Nomfof,Formule))
        ; true 
        )

     ; Formule=(! _ :(A=B <=>!XX:C)),var(A), \+ var(B) -> 
             remplacer(C,A,B,C1),
             assert(definition(Nature_Nomfof,!XX:C1))
     ; true
     ),

     (Formule=(!_:(_=>(! XX :(A=B)))) -> 
             assert(lemme(Nature_Nomfof,member(X,A) <=> member(X,B))),
             assert(definition(Nature_Nomfof,!XX:A=B))
     ; true
     ),


     ( Formule=(!_:FT), FT=(A<=>B),A=..[_,X|_],var(X)

       -> 
          (A=..[P|_], B=(~B1), B1=..[P|_] -> 
                      assert(lemme(Nature_Nomfof,Formule))
          ; 
            assert(definition(Nature_Nomfof,Formule)) 
          )
     ; Formule=(!_:FT), FT=(ApplyR<=>_), ApplyR=..[Apply,R,_,_],
         atom(Apply),atom(R) 
         -> 
            assert(lemme(Nature_Nomfof,Formule)),
            assert(definition(Nature_Nomfof,FT))
     ; assert(lemme(Nature_Nomfof,Formule)) 
     ),

     ( Formule=(!_:FT), FT=(A =>_),A=..[P,X|_],var(X)-> ajconcept(P)
     ; true
     )

 ; ecrire1(['type de fof ', Nature ,' non connu dans la formule ', FormuleTPTP])
 
 ),
 retract(fof(Nomfof,Nature,FormuleTPTP)),           
 assert(fof_traitee(Nomfof,Nature,FormuleTPTP)), 
 fail. 

lire(_). 

lire0(FICH) :- 
 op(450,xfy,:), 
 consult(FICH),
	fof(Nomfof,Nature,FormuleTPTP), trad(FormuleTPTP,Formule),
	\+ tempsdepasse(-1,lire0),

 (Nature = conjecture ->                                    
                          effacer([conjecture(_,_)]),
                          assert(conjecture(Nomfof,Formule))

 ;(Nature=axiom;Nature=hypothesis;Nature=lemma
               ; Nature=assumption) ->



     (Formule=(! _ :(A=B)) -> 
        assert(lemme(Nomfof,member(X,A <=> member(X,B)))),
        ( \+ var(A), A=..[P|L],vars(L), \+ element(P,B)
                  -> 
                     assert(definition(Nomfof,Formule))
        ; true 
        )

     ; Formule=(! _ :(A=B <=>!XX:C)),var(A), \+ var(B) -> 
             remplacer(C,A,B,C1),
             assert(definition(Nomfof,!XX:C1))
     ; true
     ),

     (Formule=(!_:(_=>(! XX :(A=B)))) -> 
             assert(lemme(Nomfof,member(X,A) <=> member(X,B))),
             assert(definition(Nomfof,!XX:A=B))
     ; true
     ),


     ( Formule=(!_:FT), FT=(A<=>B),A=..[_,X|_],var(X)

       -> 
          (A=..[P|_], B=(~B1), B1=..[P|_] -> 
                      assert(lemme(Nomfof,Formule))
          ; 
            assert(definition(Nomfof,Formule)) 
          )
     ; Formule=(!_:FT), FT=(ApplyR<=>_), ApplyR=..[Apply,R,_,_],
       ecrire('Formule'=Formule), atom(Apply),atom(R) 
         -> 
            assert(lemme(Nomfof,Formule)),
            assert(definition(Nomfof,FT))
     ; assert(lemme(Nomfof,Formule)) 
     ),

     ( Formule=(!_:FT), FT=(A =>_),A=..[P,X|_],var(X)-> ajconcept(P)
     ; true
     )

 ; true 
 ),
 retract(fof(Nomfof,Nature,FormuleTPTP)),           
 assert(fof_traitee(Nomfof,Nature,FormuleTPTP)), 
 fail. 

lire0(_). 

charger_axioms :- include(Axioms),
                  \+ tempsdepasse(-1,charger_axioms),
                  (getenv('TPTP',TPTPDirectory) ->
                          atom_concat(TPTPDirectory,'/',Directory),
                          atom_concat(Directory,Axioms,Axioms1),
                          exists_file(Axioms1), lire(Axioms1),
                          fail
                  ; ecrire1('variable d''environnement TPTP non definie')
                  ).
charger_axioms.
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% appel th (donnees et theoremes) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

th :- ( lang(fr) -> shell('cat th-commandes')
        ; lang(en) -> shell('cat th-commands')
        ; nl,write('definir un langage/define a language')
        ).
th([A|AA]) :- 
   ( atom(A), exists_file(A) -> affecter(chemin(A)),th(AA)
   ; number(A) -> limitertemps(A), th(AA)
   ; A=(+B) -> ( afficher(B) -> true ; assert(afficher(B))), th(AA)
   ; A=(-B) -> retractall(afficher(B)), th(AA)
   ; (A=fr|A=en) ->  affecter(lang(A)),  th(AA)
   ; ecrire1(['donnee incorrecte',A,
          '(ni fichier, ni option)']),
     nl
   ),!.
th([]) :- affecter(version(th)),
   chemin(Ch), [Ch],
   file_base_name(Ch,FichCh),atom_concat(reg_,FichCh,REG),
   forall( include(Donnees),[Donnees]),
     ( (theoreme(_,_);theorem(_,_)) ->
        travail1th,
        ( afficher(tr) -> tell(REG), listing(regle),told;true),
        forall( (theoreme(Nom,T);theorem(Nom,T)),
           (  effacerth,
             affecter(probleme(Nom)),assert(theoreme(T)),
             affecter(nomdutheoreme(Nom)),
             probleme(P),message(['theoreme a demontrer (',P,')','\n',T]),
             atom_concat(res_,Nom,RES), affecter(res(RES)), telll(RES),
             demontrerth(T),
             told 
            )
          ), 
       nl 
   ; ecrire1('pas de theoreme a demontrer, on lit juste des definitions')
   ) .
th(A) :- th([A]).
th(A,B) :- th([A,B]).
th(A,B,C) :- th([A,B,C]).
th(A,B,C,D) :- th([A,B,C,D]).
th(A,B,C,D,E) :- th([A,B,C,D,E]).
th(A,B,C,D,E,F) :- th([A,B,C,D,E,F]).
th2 :- th(exemple2).
th21 :- th(exemple21).
th22 :- th(exemple22).
travail1th :- %% traitement des definitions 
   %% définitions ensemblistes A = {X | ...}
   forall((definition(Y=A), \+ var(A), functor(Y,P,_), A=[X,PX],
   +++(APP), XappY =.. [APP,X,Y]), 
   assert(definition(P, XappY <=> PX))),
   %% definitions par equivalence A <=> B (variables libres)
   forall((definition(A<=>B), functor(A,P,_)), assert(definition(P,A<=>B))),
   %% definitions par equivalence (formules closes)
   forall((definition(!_:(A<=>B)),functor(A,P,_)), assert(definition(P,A<=>B))),
   elifondef, consreg.

%% ++++++++++++++++++++ demontrerth(Th) ++++++++++++++++++++
demontrerth(Th) :- res(RES), telll(RES), 
                   demontr(Th)
          .
%% uniquement pour demonstration directe
%% ++++++++++++++++++++ demontrerth(Th) ++++++++++++++++++++
demontrer(Th) :- 
        affecter(version(direct)),
        travail1th,
        affecter(theoreme(Th)), affecter(theoreme('',Th)),affecter(res(user)),
        affecter(probleme(probleme)), 
        affecter(nomdutheoreme('')),
        demontrerth(Th).

def(Def) :- assert(definition(Def)).

test_def_part :- assert(definition(parties(E)=[X,inc(X,E)])).
tdp :- test_def_part.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        règles         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% règle(s) traitant les conjonctions
regles_et([concl_et]).
%% règles générales, c'est-à-dire non liées
%%    à un concept ou une hypothèse universelle
regles_gen( [!, 
              elifon,
              concl_exi_all,
              stop_hyp_concl, 
              stop1a, stop_hyp_false, stop_hyp_false2,
              concl_ou_stop3, concl_ou_stop3bis,
              hyp_contradiction,
              egal, egaldef,
              hyp_ou1, hyp_ou23, hyp_ou4, hyp_ou5,
              concl_nonnon, concl_non, hypnon, hypnonnon, hypnonimp, hypimp, 
              concl_non_ou, concl_ou_non,
              hypequ, hypnonequ, concl_ou_et,
              =>,<=>, concl_seul, .. , ..1 ,
              concl_exi1, concl_exi2, concl_exi3,concl_exi4, concl_exi5,
              concl_exi1a,concl_exi1b, concl_exi_seul,
              concl_et_trivial_1, concl_et_trivial_2,
              concl_stop_trivial,concl_stop_trivial_ou,
              concl2pts
             ] ) .
regles_defconcl1([def_concl_pred,defconcl1a,defconcl1b,defconcl1bb]). 
regles_defconcl2([defconcl2,defconcl2app,defconcl_rel,
                  defconcl2a,defconcl2b,defconcl3]).
regles_exist([hyp_exi]).
regles_ou([hyp_ou_cte, hyp_ou]). 
regles_concl_exist([concl_exi,concl_exi_et_non,creer_un_objet_image]). 

regle(N, elifon) :- 
          concl(N, C, I), elifon( C, C1), nouvconcl(N, C1,I1),!,
          traces(N,elifon, 
                 concl(N, C, I), nouvconcl(N, C1, I1),
                 I1,
                 ['elimination des symboles fonctionnels dans la conclusion',
              '\npar exemple, p(f(X)) est remplace par seul(f(X)::Y, p(Y))'],
                 [I]).
regle(N,stop_hyp_concl ):- 
      concl(N,C,Etape1), ground(C), hyp(N,C,Etape2),
      nouvconcl(N,true,NouvelleEtape),
      traces(N, regle(stop_hyp_concl),
               (hyp(N,C,Etape2),concl(N,C,Etape1)),
               nouvconcl(N,true,NouvelleEtape),
               (NouvelleEtape),
               ['la conclusion',C,'a demontrer est une hypothese'],
               ([Etape1,Etape2])
            ).

regle(N,stop1a):- concl(N,C,IC), 
                  ( C=(?_:_);C=(!_:_);C=(_ | _);C=(_<=>_)
                                   ;C=seul(_::_,_)   
                  ),
                  hyp(N,H,I), H =@= C, 
                  nouvconcl(N,true,I1),
        traces(N,regle(stop1a),
               (concl(N,C,IC),hyp(N,H,I)), nouvconcl(N,true,I1),
               I1,
               ['la conclusion',C,'a demontrer est une hypothese'],
               [IC,I]
               ).
regle(N,stop_hyp_false):- hyp(N,false,I), nouvconcl(N,true,I1),
                 traces(N,regle(stop_hyp_false),
                        hyp(N,false,I),nouvconcl(N,true,I1),
                        I1,
                        'on a trouve une contradiction',
                        [I]).
regle(N,stop_hyp_false2) :-hyp(N,~(X=X),I), atom(X),nouvconcl(N,true,I1),
                 traces(N,regle(stop_hyp_false2),
                        hyp(N,~(X=X),I),nouvconcl(N,true,I1),
                        I1,
                        'on a trouve une contradiction (hypothese trivialement fausse)',
                        [I]), ecrire1(stop_hyp_false2-X).

regle(N,concl_ou_stop3) :- 
     concl(N,A | B,I), hyp(N,H,II),elt_ou(H,A | B),
     nouvconcl(N,true,I1),
     traces(N,regle(concl_ou_stop3),
            (concl(N,A | B,I),hyp(N,H,II)),
           nouvconcl(N,true,I1),I1,
          'un des elements de la conclusion disjonctive est une hypothese',
          [I,II]
          ).
regle(N,concl_ou_stop3bis) :- 
               concl(N,A | B,I), elt_ou_bis(N,A | B),
                            nouvconcl(N,true,I1),    
                 traces(N,regle(concl_ou_stop3bis),
                        concl(N,A | B,I), nouvconcl(N,true,I1),I1,
                        concl_ou_stop3bis,
                        [I]).
regle(N,hyp_contradiction):- hyp(N,A,I), hyp(N,~ A,II), nouvconcl(N,true,I1),
                    traces(N,regle(hyp_contradiction),
                           (hyp(N,A,I), hyp(N,~ A,II)),
                           nouvconcl(N,true,I1),I1,
                           'on a une contradiction',
                           [I,II]
                          ).
regle(N, egal) :- 
                  hyp(N, X=Y,I),
                  A=X, B=Y, 
                  acrire1(tr,[remplacer,B,par,A,'propager et supprimer',B]),
                  \+ tempsdepasse(N,regle_egal_avant_traitegal),
                  traitegal(N,A,B,I),
                  \+ tempsdepasse(N,regle_egal_apres_traitegal)
                  .
regle(N, egaldef) :- 
                     hyp(N,E::X,I), atom(X), 
                     hyp(N,E::Y,J), atom(Y), 
                     \+ X == Y, ajhyp(N, X = Y, I1),
                     traces(N,regle(egadef),
                            (hyp(N,E::X,I), hyp(N,E::Y,J), J),
                            ajhyp(N, X=Y, I1),I1,
                          [X,et,Y,'ont la meme definition'],
                             [I,J] 
                           ).

                    
regle(N, hyp_ou1) :- 
                 hyp(N,A | A,I), \+ hyp_traite(N, A | A),
                 ajhyp(N,A,E),assert(hyp_traite(N, A | A)),
                 traces(N,regle(hyp_ou1),hyp(N,A | A,I), ajhyp(N,A,E),E,
                        'E|E = E',[I]).
regle(N, hyp_ou23) :- 
                 hyp(N,A | B,_), \+ hyp_traite(N, A | B), 
                 elt_ou(X=X, A | B), assert(hyp_traite(N, A | B))
                 .
regle(N, hyp_ou4) :- 
                 hyp(N,A | B,_), \+ hyp_traite(N, A | B),hyp(N,A,_),
                 assert(hyp_traite(N, A | B)).
regle(N, hyp_ou5) :- 
                 hyp(N,A | B,_), \+ hyp_traite(N, A | B),hyp(N,B,_),
                 assert(hyp_traite(N, A | B)).
regle(N, concl_nonnon) :- 
               concl(N,~ ~ A,I), ajhyp(N,~ A,I1), nouvconcl(N,A,I1),
               traces(N,regle(concl_nonnon),
                      concl(N,~ ~ A,I),
                      (nouvconcl(N,A,I1)),I1,
                      'suppession de la double negation dans le conclusion',
                      [I]
                     ).
regle(N, concl_non) :- 
               concl(N,~ A,I), ajhyp(N,A,I1), 
               nouvconcl(N,false,I1),
               traces(N,regle(concl_non),
                      concl(N,~ A,I),
                      (ajhyp(N,A,I1), nouvconcl(N,false,I1)),I1,
                      ['on suppose',A,'et on cherche une contradiction'],
                      [I]
                     ).
regle(N, hypnonnon) :- 
                       hyp(N,~ ~ A,I), ajhyp(N, A, J),
                       traces(N, regle(hypnonnon),
                              hyp(N,~ ~ A,I), ajhyp(N, A, J),J,
                              '\n*** car ~ ~ a = a',
                              [I,J]
                             ).
regle(N, hypnonimp) :- 
                       hyp(N,~(A=>B),I),\+ hyp(N,A ,_),     
                       ajhyp(N,(A & ~ B),J),
                       traces(N,regle(hypnonimp),
                              hyp(N,~(A=>B),I), ajhyp(N,(A & ~ B),J), J,
                              '\n*** car ~(a=>b) = (a&~b)',
                              [I]
                             ).
regle(N, hypnonequ) :- 
                       hyp(N,~(A<=>B),_),
                       \+ hyp(N,(A & ~ B) | (~ A & B),_),
                       ajhyp(N,(A & ~ B) | (~ A & B),_).  
regle(N, hypequ) :- hyp(N,A <=> B,_),\+ hyp(N,(A & B) | (~ B & ~ A),_),
                    ajhyp(N, (A & B) | (~ B & ~ A),_).    
regle(N, hypnon) :- 
                    hyp(N,~ A,I), concl(N,false,IC), 
                    \+ hyp_traite(N,~A),
                    nouvconcl(N,A,I1),
                    ajhyp_traite(N,~A),
                    traces(N,regle(hypnon),
                           (hyp(N,~ A,I), concl(N,false,IC)),
                           nouvconcl(N,A,I1),I1,
                        ['on suppose',A,'et on cherche une contradiction'],
                           [I,IC]
                          ).
regle(N, concl_non_ou) :- 
                         concl(N,~ A | B,I),ajhyp(N,A,I1),nouvconcl(N,B,I1),
                         traces(N,regle(concl_non_ou),
                                concl(N,~ A | B,I),(ajhyp(N,A,I1),
                                nouvconcl(N,B,I1)),I1,
                                ['on suppose',A,'et on doit montrer',B],
                                [I]
                               ).
regle(N, concl_ou_non) :- 
   concl(N,A | B,I), ou_non(A | B,Aplus,Amoins), 
   ajhyp(N,Amoins,I1), nouvconcl(N,Aplus,I1),
   traces(N,regle(concl_ou_non),
          concl(N,A | B,I),
          (ajhyp(N,Amoins,I1), nouvconcl(N,Aplus),I1),
          I1,
          ['on suppose',Amoins, 'on retire',~ Amoins,'de la conclusion'],
          [I]
         ).
regle(N,concl_ou_et) :- 
                        concl(N,A | B,I),ou_et(A | B,C),nouvconcl(N,C,I1),
                        traces(N,regle(concl_ou_et),
                               concl(N,A | B,I),nouvconcl(N,C,I1),I1,
                               'distributivite de | par rapport a &',
                               [I]
                              ).
regle(N, =>) :- 
      concl(N, A => B, Etape),
      ajhyp(N, A, NouvelleEtape),
      nouvconcl(N,B,NouvelleEtape),
      traces(N, regle(=>), (concl(N, A => B, Etape)),
             [ajhyp(N, A, NouvelleEtape), nouvconcl(N,B,NouvelleEtape)],
             (NouvelleEtape),
             'pour demontrer H=>C, on suppose H et on doit demontrer C',
             ([Etape])
            ).
regle(N,<=>) :- concl(N , A <=> B, E1), nouvconcl(N,(A => B) & (B => A), E2),
     traces(N,regle(<=>),
              concl(N, A <=> B, E1), nouvconcl(N,(A => B) & (B => A)), 
              E2,
              'on remplace A<=>B par (A=>B)&(B=>A)',
              [E1]).

regle(N, !) :-
   concl(N,(! XX : C), Etape),
   etape_action(NouvelleEtape),
   creer_objets_et_remplacer(N,XX,C,C1,Objets), 
   nouvconcl(N, C1,NouvelleEtape),
   traces(N, regle(!), concl(0,(! XX : C), Etape),
          [creer_objets(Objets), nouvconcl(N, C1,NouvelleEtape)],
          (NouvelleEtape),
       'on instancie la(les) variable(s) universelle(s) de la conclusion',
           [Etape]
           ).

regle(N, concl_seul) :- 
               concl(N,seul(A::X,B),I),
               ( hyp(N,A::X1,II) -> 
                 acrire1(tr,[remplacer,X,par,X1]),
                 remplacer(B,X,X1,B1), nouvconcl(N,B1,I1),
                 traces(N,regle(concl_seul),
                        (concl(N,seul(A::X,B),I), hyp(N,A::X1,II)),
                        nouvconcl(N,B1,I1),
                        I1,
                        [X,'est remplace par',X1,dans,B],
                        [I,II])
               ; var(X) -> 
                 creer_objet(N,z,X1), 
                 ajobjet(N, X1),ajhyp(N,A::X1,I1),
                 remplacer(B,X,X1,B1), nouvconcl(N,B1,I1),
                 traces(N,regle(concl_seul),
                        concl(N,seul(A::X,B),I),
                        [ajhyp(N,A::X1,I1),nouvconcl(N,B1,I1)],
                        I1,
                        ['creation de l\'objet',X1,'et de sa definition'],
                        [I])
               ; acrire1(tr,[regle,seul,cas, non,prevu])
               ). 
regle(N, ..) :- concl(N, ..[R, X, Y], I), C=..[R, X, Y], nouvconcl(N, C, I1),
                traces(N,regle(..),
                       concl(N, ..[R, X, Y], I),  nouvconcl(N, C, I1),I1,
                       '\n*** car ..[r,a,b] = r(a,b)',
                       [I]
                      ).
regle(N, ..1) :- concl(N, ..[F, X]::Y,I), Z=..[F, X], nouvconcl(N, Z::Y,I1),
      traces(N,regle(..1),
             concl(N, ..[F, X]::Y,I), nouvconcl(N, Z::Y,I1),I1,
             '\n*** car ..[f,x] = f(x)',
             [I]
            ).
regle(N,concl_exi_all) :- concl(N,(?[X]:(![Y]:(A=>C))),E),
                    ajhyp(N,(![X]:(?[Y]:(A&(~C)))),E1), nouvconcl(N,false,E1),
                    message(concl_exi_all),
                    traces(N,regle(concl_exi_all),
                           concl(N,(?[X]:(![Y]:(A=>C))),E),
                           (ajhyp(N,(![X]:(?[Y]:(A&(~C)))),E1),
                            nouvconcl(N,false,E1)),E1,
                            'raisonnement par l\'absurde',
                            [E]
                           ).
regle(N, concl_exi1) :- concl(N,(?[X]:C),I),
                         (atom(X);var(X)),hyp(N,C,II), ground(C),
                         nouvconcl(N, true, I1),
                        remplacer((?[X]: C),X,_XX,CC),
                traces(N,regle(concl_exi1),
                       (concl(N, CC,I), hyp(N,C,II)),
                        nouvconcl(N, true, I1),I1,
                        ['l\'objet',X,'verifie la conclusion'],
                        [I,II]
                        ).
regle(N, concl_exi2) :- concl(N, (?[X]: (B & C)),I),(atom(X);var(X)),
                         hyp(N,B,II),ground(B), hyp(N,C,III), ground(C), 
                         nouvconcl(N,true,I1),
                        remplacer((?[X]:(B & C)),X,_XX,CC),
       traces(N, regle(concl_exi2),
              ( concl(N, CC,I),hyp(N,B,II), hyp(N,C,III)),
              nouvconcl(N,true,I1),
              I1,
              ['l\'objet',X,'verifie la conclusion'],
              [I,II,III]
              ).
regle(N, concl_exi3) :- concl(N, (?[X]: (B | C)),I),(atom(X);var(X)),
                         ( hyp(N,B,II),ground(B) -> BouC=B 
                         ; hyp(N,C,II),ground(C) -> BouC=C), 
                         nouvconcl(N,true,I1),
                         remplacer((?[X]: B | C),X,_XX,CC),
                      traces(N,regle(concl_exi3),
                             (concl(N,CC,I),hyp(N,BouC,II)),
                             nouvconcl(N,true,I1),
                             I1,
                    ['on a un element qui verifie la conclusion'],
                             [I,II]
                             ).

regle(N, concl_exi4) :- concl(N, (?[X]: (B => C)),I),(atom(X);var(X)),
                         ( hyp(N,~ B,II),ground(B)-> NBouC=(~ B)
                         ; hyp(N,C,II),ground(C)-> NBouC=C),
                         nouvconcl(N, true, I1),
                         remplacer((?[X]: B => C),X,_XX,CC),
               traces(N, regle(concl_exi4),
                      (concl(N, CC,I),hyp(N,NBouC,II)),
                      nouvconcl(N, true, I1),I1,
                      ['on a un element qui verifie la conclusion'],
                      [I,II]
                      ).
regle(N, concl_exi5) :- concl(N, (?XX: (~ C)),I),
                         nouvconcl(N,false,I1),ajhyp(N, (!XX:C),I1),
                          traces(N,regle(concl_exi5),
                                 concl(N, (?XX:( ~ C)),I),
                                (nouvconcl(N,false,I1),ajhyp(N,(!XX:C),I1)),
                                I1,
                         ['pour demontrer ?[..]: ~A,', 'on suppose A et on cherche une contradiction'],
                                [I]
                                ).
regle(N,concl_exi) :- 
                      concl(N, ? XX:C, Eexi),
                      demconclexi(N,? XX:C, Eexi,_EEE).



regle(N, creer_un_objet_image) :- 
   objet(N,X), fonction(F,1), FX =.. [F,X], 
   \+ hyp(N,_::X,_),
   \+ hyp(N,(?[Y]:(FX::Y)),_), ajhyp(N,(?[Y]:(FX::Y)),I1),
   traces(N,regle(creer_un_objet_image),
          [objet(N,X), fonction(F,1)],
          ajhyp(N,(?[Y]:(FX::Y)),I1),I1,
          'creer un objet image',
          []
         ).
regle(N,concl_et_trivial_1):- 
   concl(N, A & B, I), hyp(N, A, II), 
   acrire1(tr,[A, est, true]),nouvconcl(N, B, I1),
   traces(N,regle(concl_et_trivial_1),
         (concl(N, A & B, I),hyp(N, A, II)),
         nouvconcl(N, B, I1),I1,
         'un des elements de la conclusion conjonctive est une hypothese', [I,II]
     ).
regle(N, concl_et_trivial_2) :- 
   concl(N, A & B,I), hyp(N, B, II),
   acrire1(tr,[B, est, true]),nouvconcl(N, A, I1),
   traces(N,regle(concl_et_trivial_2),
          (concl(N, A & B,I), hyp(N, B, II)),
         nouvconcl(N, A, I1), I1,
        'un des elements de la conclusion conjonctive est une hypothese',
      [I,II]
     ).
regle(N, concl_stop_trivial) :- concl(N, A = A, I), nouvconcl(N,true, I1),
                                traces(N,regle(concl_stop_trivial),
                                       concl(N, A = A, I), 
                                       nouvconcl(N,true, I1),I1,
                                       'conclusion triviale',
                                       [I]
                                      ).
regle(N, concl_stop_trivial_ou) :- 
                                   concl(N, A | B, I), elt_ou(X=X,A | B),
                                   nouvconcl(N,true, I1),
                                   traces(N,regle(concl_stop_trivial_ou),
                                         concl(N, A | B, I),
                                         nouvconcl(N,true, I1),I1,
              'un des elements de la conclusion disjonctive est triviale',
                                         [I]
                                         ).
regle(N, concl_et) :- 
      concl(N, A & B, E ), 
      demconj(N, A & B, E, _Efin)
      .
regle(N, concl_ou ) :- 
      concl(N, A | B, Eavant), 
      demdij(N, A | B, Eavant, _Eapres)
      .
 
regle(N, def_concl_pred) :- concl(N, C, Etape),  definition(Nomfof,C <=> D),
   acrire1(tr,[N, 'definition_de_la_conclusion']),
                       nouvconcl(N, D, NouvelleEtape),
      traces(N, regle(def_concl_pred),
             concl(N, C, Etape), nouvconcl(N, D, NouvelleEtape),
             NouvelleEtape,
       ['on remplace la conclusion ',C,' par sa definition(fof',Nomfof,')'],
             [Etape]
            ).
regle(N, defconcl1a) :- concl(N, C | A, I),  definition(Nomfof,C <=> D),
                        acrire1(tr,[N, 'definition de la conclusion']),
                        nouvconcl(N, D | A, I1),
                        traces(N,regle(defconcl1a),
                               concl(N, A | C, I),
                               nouvconcl(N, A | D, I1),I1,
                               [definition,Nomfof], 
                               [I]
                               ).
regle(N, defconcl1b) :- concl(N, A | C, I),  definition(Nomfof,C <=> D),
                        acrire1(tr,[N, 'definition de la conclusion']),
                        nouvconcl(N, A | D, I1),
                        traces(N,regle(defconcl1b),
                               concl(N, A | C, I),
                               nouvconcl(N, A | D, I1),I1,
                               [definition,Nomfof],  
                               [I]).
regle(N, defconcl1bb) :- concl(N, A | seul(Y::X,seul(Z::T,C)), I), 
                         definition(Nomfof,C <=> ~ D),
                         acrire1(tr,[N, 'definition de la conclusion']),
                         nouvconcl(N, A | ~ seul(Y::X,seul(Z::T,D)), I1),
             traces(N,regle(defconcl1bb),
                    concl(N, A | seul(Y::X,seul(Z::T,C)), I),
                    nouvconcl(N, A | ~ seul(Y::X,seul(Z::T,D)), I1),I1,
                    [definition,Nomfof],  
                    [I]
                    ).
regle(N, concl2pts) :- 
                       concl(N, FX::Y, I), nouvconcl(N, seul(FX::Z, Z=Y), I1),
                       traces(N,regle(concl2pts),
                               concl(N, FX::Y, I),
                               nouvconcl(N, seul(FX::Z, Z=Y), I1),I1,
                               ' FX::Y est reecrit seul only(FX::Z, Z=Y)',
                               [I]
                              ) .
regle(N, defconcl_rel) :- concl(N, C, I), C =.. [R, A, B], hyp(N, D::B, II),
                          definition(Nomfof,XappD <=> P),
               XappD =.. [R,X,D1],\+ var(D1), D=D1
               ,
               remplacer(P, X, A, P1),
               acrire1(tr,[N, 'definition de la conclusion']),
               nouvconcl(N, P1, I1),
               traces(N,regle(defconcl_rel),
                      (concl(N, C, I), hyp(N, D::B, II)),
                      nouvconcl(N, P1, I1),I1,
                      [definition,Nomfof], 
                      [I,II]
                     ) .

regle(N, hyp_exi) :- hyp(N, (?XX:P),I),
   \+ hyp_traite(N, (?XX:P)),
   ( P = (Q & R & S) -> \+ (hyp(N, Q1,_), eg(Q,Q1),
                            hyp(N, R1,_), eg( R,R1), hyp(N, S1,_), eg(S,S1))
   ; P = (Q & R) ->  \+ (hyp(N, Q1,_), eg(Q,Q1), hyp(N, R1,_), eg( R,R1))
   ; \+ (hyp(N, P1,_), eg(P,P1))
   ) ,   
   etape(E), I1 is E+1, affecter(etape(I1)),
   creer_objets_et_remplacer(N,XX,P,P1,Objets),
   ajhyp(N,P1,I1),
   ajhyp_traite(N,(?XX:P)),
   incrementer_nbhypexi(NBhypexi),
   traces(N,regle(hyp_exi),
          hyp(N,(?XX:P),I),
          [creer_objets(Objets),
          ajhyp(N,P1,I1)],
          I1,
          'traitement de l\'hypothese existentielle',
          [I]
         ), 
   ( NBhypexi > 300 -> 
        acrire1(tr,['on a traite',NBhypexi,'hypotheses existentielles']),
        acrire1(tr,'on desactive la regle hyp_exi'),
        desactiver(N,hyp_exi)
   ;true
   )
   .
regle(N, hyp_ou) :- 
   hyp(N, (A | B),I), \+ hyp_traite(N, (A | B)),
   \+ (ou_applique(N)), 
   concl(N, C, II),
   acrire1(tr,[N,'traitement de l''hypothese disjonctive',(A | B)]),
   hypou(A | B => C, T), nouvconcl(N,T, I1), 
   traces(N,regle(hyp_ou),
          (hyp(N, A | B,I),concl(N, C, II)),
          nouvconcl(N,T, I1),
          I1,
          ['on doit montrer la conclusion dans les deux cas'],
          [I,II]
          ),
   ajhyp_traite(N, (A | B)),
   assert(ou_applique(N))
   .
regle(N, hyp_ou_cte) :- 
   hyp(N, A | B,I), \+ hyp_traite(N, A | B),
   \+ (ou_applique(N)), 
   A=(A1=A2), B=(B1=B2), atom(A1), atom(A2), atom(B1), atom(B2),
   concl(N, C, II),
   acrire1(tr,[N,'traitement de l''hypothese disjonctive',(A | B)]),
   hypou(A | B => C, T), nouvconcl(N,T, I1), 
   traces(N,regle(hyp_ou_cte),
          (hyp(N, A | B,I),concl(N, C, II)),
          nouvconcl(N,T, I1),I1,
          ['on doit montrer la conclusion dans les deux cas'],
          [I,II]
         ) ,
   ajhyp_traite(N, A | B),
   assert(ou_applique(N))
   .

orphelin(L) :- tracedem(_,_,_,_,_,_,L),var(L),!. 
orphelin(E) :- tracedem(_,_,_,_,_,_,L),member(E,L),
               (var(E)-> acrire(tr,'il reste une variable dans tracedem'-L)
               ; E =\= 1),
               \+ tracedem(_,_,_,_,E,_,[_|_]).

%% ++++++++++++++++++++ tracedemutile +++++++++++++++++++++

%% à la dernière etape (End), extrait la liste LU des etapes utiles
%% de la liste des etapes mémorisées dans tracedem
%% si la longueur de LU est inférieure au maximum accepté (paramétrable
%% dans lengthmaxpr) et selon les options, appelle tracedemutile(LU)
%% qui affiche les etapes selon un format facilement lisible 

tracedemutile :- 
 ( concl(0,true,End) ->
   bagof(B-A,C^D^E^F^G^tracedem(C,D,E,F,B,G,A),L1),
   etape(End),
   ( reachable(End,L1,L11), sort(L11,LU) ->
     length(LU, LengthLU),
     lengthmaxpr(Lmax),
     ( LengthLU>Lmax  -> 
       acrire1(pr,['trace trop longue (',LengthLU,'etapes utiles)'])
     ; 
       (version(casc)-> true
        ;acrire1(tr,'orphelins : '),
         forall(orphelin(Orph),acrire(tr,['',Orph])),
         acrire1(pr,['\n*************************************\n*',
                    'etapes utiles de la demonstration',
                    '*\n*************************************\n'
                   ])
       ),
       probleme(P),
       ( afficher(szs),afficher(pr)->
             ecrire1('SZS output start Proof for '), write(P)
           ; true
           ),
       acrire1(pr,'\n* * * * * * * * * * * * * * * * * * * * * * * *'),
       
       acrire1(pr,'* * * theoreme a demontrer (numero 0)'), 
       ( version(tptp),conjecture(_,TH) -> acrire1(pr,TH)
       ; theoreme(TAD), acrire1(pr,TAD)
       ),
       acrire1(pr,'\n* * * demonstration :'),
       acrire1(pr,'\n* * * * * * theoreme initial 0 * * * * * *'),
       tracedemutile(LU),
       acrire1(pr,'le theoreme initial'),
       (version(direct) -> true
       ; nomdutheoreme(Nom), 
         concat_atom([' (',Nom,')'],Texte),acrire(pr,Texte)
       ),
       acrire(pr,' est donc demontre'),
       ( version(tptp),conjecture(false,_) -> 
            acrire(pr,' (pas de conjecture)')
       ; true
       ),
       acrire1(pr,'* * * * * * * * * * * * * * * * * * * * * * * *\n'),
       ( afficher(szs) -> ecrire1('SZS output end Proof for '), write(P)
       ; true
       )
     ) 
   ; acrire1(tr,['on ne peut pas atteindre la racine de la trace,',
                 'il doit manquer une etape dans tracedem']),
     acrire1(tr,'mais le theoreme initial est bien demontre\n')
   ) 
 ; acrire1(tr,'theoreme initial non demontre')
 ). 


%% ++++++++++++++++++++ tracedemutile(LU) +++++++++++++++++++++

%% affiche les etapes de la trace utile LU selon un format facilement lisible
tracedemutile([U|LU]) :- 
     tracedem(_N,Nom,Cond,Act,(U),Expli,_Antecedants),
     ecriretraceact(Act), %% action
     ( Cond=[] -> true ;
       acrire1(pr,['******* car']),
       acriretracecond(pr,Cond) %% conditions
     ),
     acrire1(pr,['***','explication :']),
     acrire(pr,Expli),
     ( Nom=regle(R) -> Nom_a_ecrire=[regle,R]
     ; Nom=action(A) -> Nom_a_ecrire=[action,A]
     ; Nom_a_ecrire=Nom
     ),
     acrire_tirets(pr,Nom_a_ecrire),
     tracedemutile(LU).
tracedemutile([]).

%% ++++++++++++++++++++ acriretracecond(Option,Conditions) ++++++++++++++++++++

%% affiche une liste de conditions selon un format facilement lisible

acriretracecond(Option,(Cond,CC)) :-  acriretracecond(Option,Cond),
                                      acriretracecond(Option,CC),!.
acriretracecond(Option,hyp(N,H,E)) :- acrire(Option,[hyp,H]), acrire(Option,'['),
    acrire(Option,E),acrire(Option,':'), acrire(Option,N),acrire(Option,'] \n            '),!.
acriretracecond(Option,concl(N,C,E)) :- acrire(Option,[concl,C]), acrire(Option,'['),
    acrire(Option,E),acrire(Option,':'), acrire(Option,N),acrire(Option,'] \n            '),!.
acriretracecond(Option,obj_ct(N,Ob)) :- acrire(Option,[obj_ct,Ob]), acrire(Option,'['),
    acrire(Option,N),acrire(Option,'] \n            '),!.
acriretracecond(Option,C) :- acrire(Option,C).


%% ++++++++++++++++++++ ecriretraceact(Actions) ++++++++++++++++++++

%% affiche une liste d'actions selon un format facilement lisible

ecriretraceact([Act|AA]) :- ecriretraceact(Act), ecriretraceact(AA),!.

ecriretraceact([]).

ecriretraceact(ajhyp(N,A & B,E)) :- ecriretraceact(ajhyp(N,A,E)), tab(1),
                                    ecriretraceact(ajhyp(N,B,E)),!.

ecriretraceact(ajhyp(N,..R,E)) :- H=..R, 
                                  ecriretraceact(ajhyp(N,H,E)).

ecriretraceact(ajhyp(N,seul(FX::Y,A),E)) :-
   hyp(N,FX::Obj,Eobj), 
   remplacer(A,Y,Obj,A1),
   (E=Eobj -> acrire1(pr,['*** creer objet',Obj]),
              ecriretraceact(ajhyp(N,FX::Obj,E)),nl,tab(5) ; true),
              ecriretraceact(ajhyp(N,A1,E)),!.

ecriretraceact(ajhyp(N,~seul(FX::Y,A),E)) :-
   hyp(N,FX::Obj,Eobj), 
   remplacer(A,Y,Obj,A1),
   (E=Eobj -> acrire1(pr,['*** creer objet',Obj]), 
                                             
              ecriretraceact(ajhyp(N,FX::Obj,E)),nl,tab(5) ; true),
              ecriretraceact(ajhyp(N,~A1,E)),!.

ecriretraceact(nouvconcl(N,..R,E)) :- C=..R, ecriretraceact(nouvconcl(N,C,E)).

ecriretraceact(creersousth(N,N1,_A,_E)) :- 
   acrire1(pr,['\n* * * * * * creation * * * * * * sous-theoreme',
              N1,'* * * * *'
              ]),
   acrire1(pr,['toutes les hypotheses du (sous-)theoreme',
               N,
               'sont hypotheses du sous-theoreme',
               N1]).

ecriretraceact(creer_objets(OO)) :- 
   acrire1(pr,['creer objet(s)',OO]).

ecriretraceact(ajhyp(N,H,E)) :- 
   ecrire1([E:N,'***','ajouter,hypothèse',H]).

ecriretraceact(nouvconcl(N,C,E)) :-
   ecrire1([E:N,'***',nouvelle, conclusion, C]).

ecriretraceact(E) :- acrire1(pr,['****',E]).

%% ++++++++++++++ ecrire_simpl_R(Option,(regle(_,Nom):- Q)) +++++++++++++

%% affiche une règle selon un format facilement lisible

ecrire_simpl_R(Option,(regle(_,Nom):- Q)) :- seq_der(Q,_Qmoinstraces,Traces),
       Traces=traces(_,_,Cond,Act,_,_R,_Ex),
       ( lang(fr) -> acrire1(Option,['+++',regle,Nom,:,(si Cond alors Act)])
       ; lang(en) -> acrire1(Option,['+++',rule,Nom,:,(if Cond then Act)])
       ; acrire1(Option,'+++')
       ).

th_tous :- th('exemples/exemple1_thI03'),
           th('exemples/exemple1bis_thI03'),
           th('exemples/exemple2_thI03_thI21'),
           th('exemples/exemple2bis_thI03_thI21'),
           th('exemples/exemple2ter_thI21'),
           th('exemples/exemple2_definitions'),
           th('exemples/exemple2bis_definitions'),
           th('exemples/exemple3_pre_ordre_variante_set807+4.p'),
           th('exemples/exemple3_en_pre_order_variant_set807+4.p'),
           th('exemples/exemple4_transitivite').
