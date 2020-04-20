%%%% -*- Mode: Prolog -*-
%%%% Tropeano Pietro 829757
%%%% oop.pl --

%%% def_class definisce la struttura di una classe e la memorizza
%%% attraverso una assert, sotto forma di predicato,
%%% dopo aver effettuato i dovuti controlli

def_class(Class_name, Parents, Slot_values):-
    atom(Class_name),
    list_of_atoms(Parents),
    list_of_slots(Slot_values),
    retractall(class(Class_name,_,_)),
    !,
    assert(class(Class_name,Parents, Slot_values)).


%%% crea una nuova istanza di una classe dopo aver effettuato i
%%% dovuti controlli sull'input

new(Instance_name, Class_name):-
    new(Instance_name, Class_name, []).


new(Instance_name, Class_name, Slot_values):-
    class(Class_name,_,_),
    list_of_slots(Slot_values),
    get_slot_names(Slot_values, Names),
    exsist_all(Class_name, Names),
    retractall(instance(Instance_name, _, _)),
    !,
    assert(instance(Instance_name, Class_name, Slot_values)).


%%% getv estrae il valore di un campo da una classe

getv(instance(_, _, Slot_values), Slot_name, Result):-
    get_value_from_name(Slot_name, Slot_values, Result).


getv(instance(_, Class,_), Slot_name, Result):-
    get_slots(Class, Slot_values),
    get_value_from_name(Slot_name, Slot_values, Result).


getv(Instance_name, Slot_name, Result):-
    instance(Instance_name, _, Slot_values),
    get_value_from_name(Slot_name, Slot_values, Result).


getv(Instance_name, Slot_name, Result):-
    instance(Instance_name, Class,_),
    get_slots(Class, Slot_values),
    get_value_from_name(Slot_name, Slot_values, Result).


%%% estrae il valore di una classe percorrendo una catena
%%% di attributi

getvx(instance(In_name, _,_), X, Result):-
    getvx(In_name, X, Result).


getvx(Instance_name, [X | Xs], Result):-
    getv(Instance_name, X, Y),
    length(Xs, L),
    L > 0,
    !,
    getvx(Y, Xs, Result).


getvx(Instance_name, [X | Xs] , Result):-
    getv(Instance_name, X, Result),
    length(Xs, L),
    L = 0.


%%% get_value_from_name recupera il valore di uno slot
%%% a partire dalla chiave slot_name, cercandolo all'interno
%%% della lista passata come secondo parametro

get_value_from_name(_, [], _):-fail.


get_value_from_name(Slot_name, [X | _Xs], Result):-
    arg(1, X, Slot_name),
    arg(2, X, Result).


get_value_from_name(Slot_name, [ _X | Xs], Result):-
    get_value_from_name(Slot_name, Xs, Result).


%%% append appende la prima lista alla seconda, la lista
%%%  ottenuta e' il terzo argomento

append( [], X, X).


append( [X | Y], Z, [X | W]) :-
    append( Y, Z, W).


%%% list_of_atoms verifica che una lista sia composta da atomi

list_of_atoms([X | Xs]):-
    atom(X),
    list_of_atoms(Xs).


list_of_atoms([]).


%%% list_of_slots verifica che una lista sia
%%% composta da slot o metodi

list_of_slots([X | Xs]):-
    compound(X),
    arg(2, X, Val),
    compound(Val),
    functor(Val, method, _),
    arg(1, X, Name),
    produce_method(Name),
    list_of_slots(Xs).


list_of_slots([X | Xs]):-
    compound(X),
    list_of_slots(Xs).


list_of_slots([]).


%%% get_slot_names recupera la chiave di ogni slot in una
%%% lista

get_slot_names([],[]):-!.


get_slot_names([X | Xs], [Y | Slot_names]):-
    arg(1, X, Y),
    get_slot_names(Xs, Slot_names).


%%% get_slots cerca di recuperare uno slot a partire da una classe
%%% se non riesce utilizza get_slots_p sui parents della classe

get_slots(Class, Y):-
    class(Class, Parents, Slots),
    get_slots_p(Parents, X),
    append(Slots, X, Y),!.


get_slots(_Class, []).


get_slots([],[]):-!.


%%% get_slots_p cerca di recuperare uno slot a partire da una
%%% lista di classi richiamando get_slots

get_slots_p([X | Xs], Z):-
    get_slots(X, Y),
    get_slots_p(Xs, Slots),
    append(Slots, Y, Z).


get_slots_p([],[]).


%%% exsist verifica che uno slot esista in una classe

exsist(Class, Slot):-
    class(Class,_,X),
    get_slot_names(X, Y),
    member(Slot, Y).


exsist(Class, Slot):-
    class(Class, Parents, _),
    exsist_in_parents(Parents, Slot).


%%% exsist_in_parents verifica che uno slot esista in una
%%% lista di classi, chiamando exsist su ognuna di esse

exsist_in_parents([X | _Xs], Slot):-
    exsist(X, Slot),
    !.

exsist_in_parents([_X | Xs], Slot):-
    exsist_in_parents(Xs, Slot),
    !.


%%% exsist_all verifica che ogni slot sia presemte nella classe

exsist_all(Class, [X | Xs]):-
    exsist(Class, X),
    exsist_all(Class, Xs).


exsist_all(_Class, []).


%%% produce_method produce un metodo trampolino
%%% che una volta chiamato utilizza ex_code

produce_method(Name):-
    term_string(Name, X),
    string_concat(X, "(Instance):-!,",Par1),
    string_concat(X, "(Instance, Args):-!,ex_code(Instance, ",Para1),
    string_concat(Par1,X, Par2),
    string_concat(Para1, X, Para2),
    string_concat(Para2, ", Args).", Para3),
    string_concat(Par2, "(Instance, []).",Par3),
    term_string(M1, Para3),
    term_string(M2, Par3),
    retractall(M1),
    retractall(M2),
    assert(M1),
    assert(M2).


%%% ex_code esegue il codice contenuto nello slot Slot_name
%%% della istanza Instance, utilizzando gli argomenti Args

ex_code(Instance, Slot_name, Args):-
    getv(Instance, Slot_name, X),
    arg(1, X, Arguments),
    assoc(Arguments, Args),
    arg(2, X, Codice),
    list_from_con(Li, Codice),
    rep_something(Li, this, Instance, Out),
    list_from_con(Out, CodiceOk),
    call(CodiceOk).


%%% assoc verifica che due liste siano uguali

assoc([X | Xs], [X | Ys]):-
    assoc( Xs, Ys).


assoc([],[]).


%%% list_from_con consente di ricavare una lista di predicati
%%% da una congiunzione di predicati (e viceversa)

list_from_con([Ter | Res], ','(Ter, Co)) :-
    list_from_con(Res, Co).


list_from_con([Ter], Ter) :- !.


%%% rep_something sostituisce le occorrenze di Old con New, Old
%%% deve essere un atomo.
%%% si sostituisce ad ogni livello di profondità sulla lista di
%%% predicati passata in input

rep_something([],_,_,[]).


rep_something([X | Xs], Old, New, [X | Out]):-
    var(X),
    !,
    rep_something(Xs, Old, New, Out).


rep_something([X | Xs], Old, New, [Ok | Out]):-
    compound(X),
    !,
    X =.. [H | T],
    rep_something(T, Old, New, T2),
    Ok =.. [H | T2],
    rep_something(Xs, Old, New, Out).


rep_something([X | Xs], X, New, [New | Out]):-
    atom(X),
    !,
    rep_something(Xs, X, New, Out).


rep_something([Ok | Xs], X, New, [Ok | Out]):-
    !,
    rep_something(Xs, X, New, Out).


%%%% end of file -- oop.pl
