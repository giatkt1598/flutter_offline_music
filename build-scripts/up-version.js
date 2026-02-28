import * as fs from 'fs';
import path from 'path';

const filePath = path.join(import.meta.dirname, '..', 'pubspec.yaml');

const lines = fs.readFileSync(filePath, 'utf-8').split('\n');

const verIndex = lines.findIndex(x => x.startsWith('version: '));
const verNumber = lines[verIndex].split(' ')[1].split('+')[0];
const verNumArr = verNumber.split('.').map(x => +x);
verNumArr[2] = verNumArr[2] + 1;

const newVersion = verNumArr.join('.');
lines[verIndex] = 'version: ' + newVersion;

fs.writeFileSync(filePath, lines.join('\n'), 'utf-8');

console.log(`Up version: ${newVersion}`);
