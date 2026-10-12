# GB-Link Team cards for the Switch

The GB-Link Team's Wonder Cards from
[gblink-wondercards](https://github.com/GB-Link/gblink-wondercards), made for the Nintendo
Switch release of FireRed and LeafGreen in English, French, German, Italian and Spanish.
The web page sends them to the Switch over Mystery Gift.

Most cards carry a small program that works with the game's own code, so each card is made
separately for every game and language. A card only runs in the game it was made for; in
any other game, the deliveryman says the gift doesn't work with it.

## The European games

The French, German, Italian and Spanish cards are made from the English Switch games and
the European Game Boy Advance games, and checked against the European Switch games
themselves. Before the page sends one of these cards, or backs up or restores a save, it
makes sure the game on the Switch is the one the card was made for. If it isn't, nothing is
sent and the game is left as it was.

The Japanese games are not supported.

## Rebuilding

After changing a card, rebuild them all with `node cards/build.mjs`. It needs Node.js and
the arm-none-eabi tools.

## Differences from gblink-wondercards

- Only FireRed and LeafGreen for the Switch; no Emerald cards.
- The card texts are in English in every language, as in gblink-wondercards.

The sources are GPL-3.0, like gblink-wondercards.
