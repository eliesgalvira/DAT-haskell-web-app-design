# DAT Practica 3

Aquestes instruccions comencen despres d'extreure el fitxer `lab3.zip`.

Obriu una terminal PowerShell dins el directori extret. Ha de ser el directori
on hi ha els fitxers `README.md` i `stack.yaml`.

## Requisits

Cal tenir instal.lat Stack per a Haskell:

```powershell
stack --version
```

Si aquesta comanda no funciona, instal.leu Stack abans de continuar.

## Compilar

Des del directori extret:

```powershell
stack build
```

La primera compilacio pot trigar perque Stack pot descarregar el compilador i
les dependencies.

## Executar el joc

```powershell
stack run game
```

Obriu el navegador a:

```text
http://localhost:4050
```

Si el port `4050` esta ocupat, atureu el servidor amb `Ctrl+C` i executeu:

```powershell
$env:PORT = "4051"
stack run game
```

Llavors obriu:

```text
http://localhost:4051
```

## Prova rapida

En una sessio nova, la pagina ha de mostrar:

```text
Game state: (False,0)
```

Introduiu aquesta cadena al formulari:

```text
*+-++*--*+
```

Despres d'enviar-la, el resultat esperat es:

```text
Game state: (True,3)
```

Per reiniciar l'estat, esborreu la cookie de `localhost` al navegador o obriu
una finestra privada.

## Altres executables

L'exemple `hello-2` tambe es pot executar amb:

```powershell
stack run hello-2
```

Atureu qualsevol servidor amb `Ctrl+C`.
