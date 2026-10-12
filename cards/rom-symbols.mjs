#!/usr/bin/env node
// Writes roms.mjs, the addresses the cards use in the Switch's FireRed and
// LeafGreen (the Nintendo Switch release, revision 10), from the symbol tables
// of pret's pokefirered builds (`make firered_switch leafgreen_switch`, which
// match the Switch's ROMs byte for byte).
//
//   node cards/rom-symbols.mjs <pokefirered dir>
//
// Needs arm-none-eabi-nm on PATH. Routines get the Thumb bit.

import { writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { cardSymbols, symbolTable } from './symbols.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));

// Keyed like the page's romId(): game code, then 1. and the header's revision.
const ROMS = {
  'BPRE 1.10': { family: 'frlg', game: 'R', revision: 10, elf: 'pokefirered_switch.elf' },
  'BPGE 1.10': { family: 'frlg', game: 'G', revision: 10, elf: 'pokeleafgreen_switch.elf' },
};

const [decompDir] = process.argv.slice(2);
if (!decompDir) {
  console.error('usage: rom-symbols.mjs <pokefirered dir>');
  process.exit(1);
}

const out = {};
for (const [id, rom] of Object.entries(ROMS)) {
  const symbols = cardSymbols(symbolTable(join(decompDir, rom.elf)), rom.family);
  symbols.EMERALD = rom.family === 'emerald' ? 1 : 0;
  out[id] = { family: rom.family, game: rom.game, revision: rom.revision, symbols };
}

const hex = (value) => `0x${value.toString(16).padStart(8, '0')}`;
const body = Object.entries(out).map(([id, rom]) => {
  const symbols = Object.entries(rom.symbols).map(([name, value]) => `      ${name}: ${hex(value)},`).join('\n');
  return `  '${id}': {\n    family: '${rom.family}', game: '${rom.game}', revision: ${rom.revision},\n    symbols: {\n${symbols}\n    },\n  },`;
}).join('\n');
writeFileSync(join(HERE, 'roms.mjs'), `// Written by rom-symbols.mjs from pret's pokefirered Switch builds.
// Addresses the cards use in each ROM; routines carry the Thumb bit.

export const ROMS = {
${body}
};
`);
