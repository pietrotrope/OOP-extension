Tropeano Pietro 829757

=== oop.pl ===

Object Oriented Prolog è un'estensione "object oriented" di prolog


=== Descrizione ===

Per lavorare con questa implementazione di oop fare riferimento alle
specifiche del progetto.
Per maggiori informazioni circa il funzionamento del codice leggere i paragrafi
seguenti, fino alla fine della sezione Descrizione.

Definizione di una classe:

	L'implementazione Prolog di oop prevede l'utilizzo di assert per
	salvare le classi nella forma:

	class(Class_name, Parents, Slot_values)

	nel predicato class, Class_name identifica la classe,
	Prents la lista delle classi da cui questa eredita,
	Slot_values infine è l'insieme di slot e metodi nella forma:
	
	[key0 = value0, key1= value1, ..., keyN = method([arguments], (code))]
	
	Dove key rappresenta il nome dello slot o metodo, 
	value rappresenta il valore dello slot e il predicato method racchiude
	gli argomenti ed il codice di un metodo.


Creazione di una istanza:

	Le istanze si creano grazie al predicato new, dopo aver verificato che
	esistano gli adeguati slot-name nella classe o nelle sue superclassi.
	
	L'istanza rispetta la forma:
	
	instance(Instance_name, Class_name, Slot_values)
	
	Dove Instance_name è il nome dell'istanza, Class_name è il nome della
	classe e Slot_values è la list di slot dell'istanza.
	
	Per fare riferimento ad una istanza è consigiato utilizzare direttamente il
	nome dell'istanza
	

Estrazione di un campo (o slot) da una classe:
	
	L'estrazione di un campo da una classe avviene grazie all'utilizzo
	del predicato getv.
	
	getv cerca il campo all'interno degli slot dell'istanza, se non
	lo trova lo cerca all'interno degli slot della classe e delle sue 
	superclassi seguendo una politica Depth-First.
	
	Se non viene trovato lo slot, il predicato fallisce.


Estrazione di un campo percorrendo una catena di attributi:
	
	L'estrazione di un campo da una catena di attributi / slot avviene 
	grazie all'utilizzo del predicato getvx.
	
	getvx cerca il primo campo della lista all'interno dell'istanza passata
	e procede a cercare il successivo utilizzando il nome dell'istanza trovata
	per	effettuare la nuova ricerca.
	Una volta raggiunto l'ultimo elemento della lista, esso viene restituito
	con una getv.
	
	Qualora non sia presente uno slot, il predicato fallirà.


Gestione dei metodi:
	
	La gestione dei metodi utilizzata per questa implementazione avviene grazie
	ad i seguenti step:
	
		1) Nel momento della definizione di una classe o di una istanza si
		   verifica che ogni slot sia occupato da un metodo o da un valore di
		   uno slot. Se lo slot contiene un metodo, si procede al punto 2.
		
		2) Per lo slot trovato si procede ad inserire come valore esattamente 
		   quanto inserito dall'utente, in quanto si procederà ad una lettura
		   e applicazione dinamica del metodo nel momento della chiamata.
		
		3) Si utilizza poi il predicato produce_method passando come argomento
		   semplicemente il nome del metodo. 
		   Il predicato produce_method si occupa di creare due predicati:
		   
		   name(Instance).
		   e
		   name(Instance, Args).
		   
		   name è il nome del metodo da creare.
		   Instance è il nome dell'istanza di cui eseguire il codice.
		   Args sono gli argomenti che il codice del metodo deve avere in
		   ingresso.
		   
		   il predicato creato è un "predicato trampolino" perchè si limita
		   a chiamare il predicato ex_code passando i corretti argomenti.
		   ex_code esegue a tutti gli effetti il codice.
		   
		Riassumendo si predispone un predicato con funtore uguale al nome
		del metodo che si desidera creare.
		Il predicato predisposto chiamerà ex_code passando gli argomenti
		del caso.
		Infine sarà il predicato ex_code a occuparsi della esecuzione del
		codice.
		   
	L'esecuzione del codice viene gestita secondo i seguenti passaggi:
		
		1) Viene richiamato dall'utente un metodo nella forma:
		    
			name(Instance, Args).
			
			dove name è il nome del metodo, Instance è il nome dell'istanza
			che deve eseguire il metodo, Args è la lista di argomenti 
			in ingresso.
			Questo predicato chiamerà ex_code passando i dovuti argomenti.
			
		2)	Sarà ex_code ad occuparsi di eseguire il codice, ricavando il
			codice del metodo dal relativo slot nell'istanza e chiamandolo
			sostituendo le occorenze di this con Instance, associando anche
			alla lista di argomenti (variabili) gli argomenti effettivamente
			passati durante la chiamata al metodo.
		
		Riassumendo si chiama un metodo trampolino passando gli argomenti
		necessari e, ogni volta, runtime si ricava il corretto codice da
		eseguire per poi eseguirlo grazie al predicato call.
