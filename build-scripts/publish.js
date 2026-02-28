import * as fs from 'fs';
import path from 'path';
import cp from 'child_process';

const filePath = path.join(import.meta.dirname, '..', 'pubspec.yaml');
const lines = fs.readFileSync(filePath, 'utf-8').split('\n');
const verIndex = lines.findIndex(x => x.startsWith('version: '));

if (verIndex < 0) {
  throw new Error('Cannot find version in pubspec.yaml');
}

const version = lines[verIndex].split(' ')[1];
const tagVersion = `v${version.split('+')[0]}`;

cp.execSync('git add .', { stdio: 'inherit' });
cp.execSync(`git commit -m "[Build APK] ${version}"`, { stdio: 'inherit' });

try {
  cp.execSync(`git rev-parse -q --verify refs/tags/${tagVersion}`, {
    stdio: 'ignore',
  });
  console.log(`Tag already exists, skip tag: ${tagVersion}`);
} catch {
  cp.execSync(`git tag ${tagVersion}`, { stdio: 'inherit' });
  console.log(`Created tag: ${tagVersion}`);

  cp.execSync('git push --follow-tags', { stdio: 'inherit' });
  cp.execSync(`git push origin ${tagVersion}`, { stdio: 'inherit' });
  console.log(`Published version: ${version}`);
}