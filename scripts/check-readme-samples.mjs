#!/usr/bin/env node
// Checks that every Swift sample in README.md matches the compiled copy in the example app.
//
// A README sample is a ```swift block right after a `<!-- sample: <name> -->` line. The source
// is the text between `// readme:begin <name>` and `// readme:end` in
// Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift, with its common indentation
// removed. Exit code 1 lists every sample that differs or is missing.
//
// Usage: node scripts/check-readme-samples.mjs
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const sourcePath = join(root, 'Examples/SystemDesignLab/SystemDesignLab/ReadmeSamples.swift');
const readmePath = join(root, 'README.md');

function dedent(lines) {
  const indents = lines.filter((line) => line.trim() !== '').map((line) => line.match(/^ */)[0].length);
  const common = indents.length ? Math.min(...indents) : 0;
  return lines.map((line) => line.slice(common)).join('\n').trim();
}

function sourceSamples(text) {
  const samples = new Map();
  let name = null;
  let lines = [];
  for (const line of text.split('\n')) {
    const begin = line.match(/^\s*\/\/ readme:begin (\S+)\s*$/);
    if (begin) {
      name = begin[1];
      lines = [];
    } else if (/^\s*\/\/ readme:end\s*$/.test(line)) {
      if (name) samples.set(name, dedent(lines));
      name = null;
    } else if (name) {
      lines.push(line);
    }
  }
  return samples;
}

function readmeSamples(text) {
  const samples = new Map();
  const pattern = /<!-- sample: (\S+) -->\s*\n```swift\n([\s\S]*?)\n```/g;
  for (const match of text.matchAll(pattern)) samples.set(match[1], match[2].trim());
  return samples;
}

const source = sourceSamples(readFileSync(sourcePath, 'utf8'));
const readme = readmeSamples(readFileSync(readmePath, 'utf8'));
const problems = [];

for (const [name, code] of readme) {
  if (!source.has(name)) problems.push(`README sample "${name}" has no source in ReadmeSamples.swift`);
  else if (source.get(name) !== code) problems.push(`README sample "${name}" differs from ReadmeSamples.swift`);
}
for (const name of source.keys()) {
  if (!readme.has(name)) problems.push(`ReadmeSamples.swift sample "${name}" is not in the README`);
}

if (problems.length) {
  for (const problem of problems) console.error(problem);
  process.exit(1);
}
console.log(`${readme.size} README samples match ReadmeSamples.swift`);
