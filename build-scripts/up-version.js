import * as fs from 'fs';
import path from 'path';
import cp from 'child_process';

const filePath = path.join(import.meta.dirname, '..', 'pubspec.yaml');

const lines = fs.readFileSync(filePath, 'utf-8').split('\n');

const verIndex = lines.findIndex(x => x.startsWith('version: '));
const verNumber = lines[verIndex].split(' ')[1];
const verNumArr = verNumber.split('.');
const lastNumbers = verNumArr[2].split('+');
verNumArr.pop();
verNumArr.push((+lastNumbers[0] + 1) + '+' + lastNumbers[1]);

const newVersion = verNumArr.join('.');
lines[verIndex] = 'version: ' + newVersion;

fs.writeFileSync(filePath, lines.join('\n'), 'utf-8');

cp.execSync(`git add . && git commit -m "[Build APK] ${newVersion}"`);

console.log(`Up version: ${newVersion}`);


