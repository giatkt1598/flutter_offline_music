import fs from 'fs';
import path from 'path';
import cp from 'child_process';

const getAppVersion = () => {
    const filePath = path.join(import.meta.dirname, '..', 'pubspec.yaml');
    const lines = fs.readFileSync(filePath, 'utf-8').split('\n');
    const verIndex = lines.findIndex(x => x.startsWith('version: '));
    let verNumber = lines[verIndex].split(' ')[1];
    return verNumber.trim();
}

const apkDir = path.join(import.meta.dirname, '..', 'build/app/outputs/flutter-apk');
const apkOldPath = path.join(apkDir, 'app-release.apk');
const apkNewName = `music_player_${getAppVersion()}.apk`;
const apkNewPath = path.join(apkDir, apkNewName);

if (fs.existsSync(apkOldPath)) {
    fs.renameSync(apkOldPath, apkNewPath);
    console.log(`app-release.apk is renamed to ${apkNewName}`);
    cp.execSync(`start ${apkDir}`);
} else {
    console.error(`Not found ${apkOldPath}`);
}



