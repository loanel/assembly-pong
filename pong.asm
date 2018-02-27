; segment danych
dane segment
	koniec		db	"***** Koniec gry *****",10,13,"$"
	paletka		dw	?	; zmienna przechowujaca polozenie paletki - wiersz, kolumny sa stale
	pilka_x		dw	? 	; zmienna przechowujaca wspolrzedna x polozenia pilki
	pilka_y		dw	?	; zmienna przechowujaca wspolrzedna y polozenia pilki
	wektor_x	dw	?	; wektor przesuniecia pilki, wyznacza tor jej ruchu
	wektor_y	dw	?	
	temp		dw 	? 	; zmienna pomocnicza
	kolor		db	? 	; zmienna przechowujaca kolor
dane ends

; segment stosu
stos1 segment STACK
	db 200 dup(?)
	top	db ? 
stos1 ends

; glowny segment kodu
code segment
	assume cs:code, ds:dane
	; --- glowny program ---
	start:
		; Ustawiam segment stosu
		mov ax,seg top
		mov ss,ax
		mov sp,offset top
		; Ustawiam segment danych
		mov ax,seg dane
		mov ds,ax
		; Inicjalizacja zmiennych
	
		mov word ptr ds:[paletka],150
		mov word ptr ds:[pilka_x],1
		mov word ptr ds:[pilka_y],1
		mov word ptr ds:[wektor_x],1
		mov word ptr ds:[wektor_y],1
		
		
		call trybGraficzny ; przechodzimy do trybu graficznego
		call rysujPaletke ; rysujemy paletke i pileczke
		call rysujPilke
		
		glowna:
			call sleep
			call klawisze
			pileczka:
				call przesunPilke
				call wyczysc
				call rysujPaletke
				call rysujPilke
			jmp glowna
		jmp koniecProgramu
	
; --- procedury ---

	; procedura sprawdzajaca, jaki wcisnieto klawisz, i podejmujaca zgodnie z tym dzialanie
	klawisze:
		xor ax,ax
		mov ah,01h
		int 16h
		jz pileczka
		xor ax,ax
		int 16h ; w buforze jest znak, ktory pobieramy
		cmp ah,01h ; czy to escape?
		je koniecProgramu
		cmp ah,4bh; czy to strzalka w lewo?
		je przesunWLewo
		cmp ah,4dh ; czy to strzalka w prawo?
		je przesunWPrawo
		jmp pileczka
	; procedura przelaczajaca program do trybu graficznego 320x200
	trybGraficzny:
		mov	ax,13h
		int 10h
		mov ax,0a000h
		mov es,ax
		ret
		
	; procedura przelaczajaca program na tryb tekstowy
	trybTekstowy:
		mov ax,03h
		int 10h
		ret
		
	; procedura wypisujaca napis "Koniec gry"
	koniecGry:
		mov dx,offset koniec
		mov ah,9
		int 21h
		ret
		
	; procedura konczaca program
	koniecProgramu:
		call trybTekstowy
		call koniecGry
		mov ax,04c00h
		int 21h
	; procedury przesuwajace paletke zgodnie z wcisnietym klawiszem
	przesunWPrawo:
		mov ax,word ptr ds:[paletka]
		add ax,8
		cmp ax,320 ; sprawdzam, czy paletka dotarla do konca ekranu
		jae prawaGranica
		mov word ptr ds:[paletka],ax ; jesli nie, zapisujemy nowe polozenie
		jmp pileczka
		prawaGranica:
			mov word ptr ds:[paletka],320 ; zapisujemy nowe polozenie paletki
			jmp pileczka
	
	przesunWLewo:
		mov ax,word ptr ds:[paletka]
		sub ax,8
		cmp ax,30 ; sprawdzam, czy paletka dotarla do konca ekranu
		jbe lewaGranica
		mov word ptr ds:[paletka],ax ; jesli nie, zapisujemy nowe polozenie
		jmp pileczka
		lewaGranica:
			mov word ptr ds:[paletka],30 ; zapisujemy nowe polozenie paletki
			jmp pileczka
	
	; procedura przesuwajaca pileczke, zmieniajaca jej zwrot lub wylaczajaca program
	przesunPilke:
		mov ax,word ptr ds:[pilka_x]	;zajmuje sie wierszami, czyli polozeniem w pionie
		add ax,word ptr ds:[wektor_x]
		mov word ptr ds:[pilka_x],ax
		cmp ax,0					;Czy nie odbijam sie od gornej krawedzi
		ja wierszPowyzejZero
		mov word ptr ds:[wektor_x],1
		wierszPowyzejZero:
		cmp ax,198					;Czy nie odbijam sie od dolnej krawedzi
		jae koniecProgramu
		cmp ax,195  ; czy nie odbijam sie od rakiety
		jb bezPaletki
		mov ax,word ptr ds:[pilka_y]
			add ax,2
			cmp ax,word ptr ds:[paletka]
			ja bezPaletki
			mov ax,word ptr ds:[paletka]
			sub ax,29
			cmp ax,word ptr ds:[pilka_y]
			ja bezPaletki
			mov word ptr ds:[wektor_x],-1
				
			bezPaletki:
				mov ax,word ptr ds:[pilka_y]
				add ax,word ptr ds:[wektor_y]
				mov word ptr ds:[pilka_y],ax
				cmp ax,0					;Czy nie odbijam sie od lewej krawedzi?
				ja kolumnyPowyzejZero
				mov word ptr ds:[wektor_y],1
				kolumnyPowyzejZero:
				cmp ax,318	; Czy nie odbijam sie od prawej krawedzi? 
				jb przeliczone
				mov word ptr ds:[wektor_y],-1
				
			przeliczone:
				ret
		
	
			

		
	; procedura spowalniajaca, w rodzaju sleep()
	sleep:
		xor cx,cx
		mov ah,86h
		mov dx,11000
		int 15h
	
	; procedura rysujaca paletke w polozeniu z paletka
	rysujPaletke:
		mov ax,196
		mov byte ptr ds:[kolor],40
		call ustawRejestry
		add di,word ptr ds:[paletka]
		
		mov cx,3 ; dlugosc paletki
		rysuj1:
			add di,290
			push cx ; zachowujemy wartosc cx na stosie
			mov cx,30 ; szerokosc paletki
			call rysujLinie
			pop cx
			loop rysuj1
		ret
	
	; procedura rysuje pileczke w polozeniu o podanych wspolrzednych
	rysujPilke:
		mov ax,word ptr ds:[pilka_x]
		mov byte ptr ds:[kolor],15
		call ustawRejestry
		add di,word ptr ds:[pilka_y]
		mov cx,3
		call rysujLinie
		mov cx,3
		add di,317
		call rysujLinie
		mov cx,3
		add di,317
		call rysujLinie
		ret
	
	; procedura rysuje linie
	rysujLinie:
		mov byte ptr es:[di],al
		inc di
		loop rysujLinie
		ret
	
	; procedura ustawia rejestry
	ustawRejestry:
		
		mov cx,320
		mul cx
		mov di,ax
		mov al,byte ptr ds:[kolor]	;kolor
		ret
	
	; procedura czyszczaca ekran	
	wyczysc:
		xor cx,cx ; lewy gorny rog
		xor bx,bx
		mov dx,63999 ; prawy dolny rog
		mov ah,06h	; przewijanie
		mov al,0	; czyszczenie
		int 10h
		ret


code ends
end start
		
		