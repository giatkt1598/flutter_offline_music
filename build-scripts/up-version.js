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
const tagVersion = `v${newVersion.split('+')[0]}`;

fs.writeFileSync(filePath, lines.join('\n'), 'utf-8');

cp.execSync('git add .', { stdio: 'inherit' });
cp.execSync(`git commit -m "[Build APK] ${newVersion}"`, { stdio: 'inherit' });

try {
  cp.execSync(`git rev-parse -q --verify refs/tags/${tagVersion}`, {
    stdio: 'ignore',
  });
  console.log(`Tag already exists, skip tag: ${tagVersion}`);
} catch {
  cp.execSync(`git tag ${tagVersion}`, { stdio: 'inherit' });
  console.log(`Created tag: ${tagVersion}`);
}

console.log(`Up version: ${newVersion}`);

