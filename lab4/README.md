# Pràctica 4 - forums-app

Aquestes instruccions comencen un cop ja s'ha extret el contingut de `lab4.zip`.

## Requisits

- GHC i Cabal instal·lats i disponibles al `PATH`.
- `sqlite3` instal·lat i disponible al `PATH`.

El paquet ja inclou el codi local de `datfw-core` dins `libs/datfw-core-0.2.0.0`, de manera que no cal copiar res d'altres pràctiques.

## Crear la base de dades

Obre PowerShell o una terminal dins la carpeta extreta i executa:

```powershell
Remove-Item forums.db -ErrorAction SilentlyContinue
sqlite3 forums.db ".read sqlite/schema.sql"
sqlite3 forums.db ".read sqlite/users-data.sql"
sqlite3 forums.db ".read sqlite/forums-data.sql"
```

## Compilar i executar

Des de la mateixa carpeta:

```powershell
cabal run forums-app -- 4099
```

Després obre el navegador a:

```text
http://127.0.0.1:4099/
```

Si el port `4099` ja s'està utilitzant, es pot canviar per un altre, per exemple:

```powershell
cabal run forums-app -- 4100
```

## Usuaris de prova

```text
usuari1 / 1234
usuari2 / 1234
```

## Prova ràpida

1. Sense iniciar sessió, comprova que es poden veure la pàgina principal, el fòrum inicial i el topic inicial.
2. Inicia sessió com `usuari1`.
3. Crea un fòrum nou des de la pàgina principal.
4. Entra al fòrum nou i crea una pregunta.
5. Entra a la pregunta i publica una resposta.
6. Torna a les pàgines anteriors i comprova que els comptadors de topics i posts s'han actualitzat.
7. Com a moderador del fòrum, comprova que pots editar el fòrum i eliminar topics o posts.
8. Tanca sessió, entra com `usuari2` i comprova que pots escriure, però no editar ni eliminar el fòrum creat per `usuari1`.

Per reiniciar les dades de prova, atura el servidor amb `Ctrl+C` i torna a executar les tres comandes de `sqlite3`.
