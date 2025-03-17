import fs from 'fs';
import path from 'path';

const getAppVersion = () => {
    const filePath = path.join(import.meta.dirname, '..', 'pubspec.yaml');
    const lines = fs.readFileSync(filePath, 'utf-8').split('\n');
    const verIndex = lines.findIndex(x => x.startsWith('version: '));
    let verNumber = lines[verIndex].split(' ')[1];
    return verNumber.trim();
}

const apkDir = path.join(import.meta.dirname, '..', 'build/app/outputs/flutter-apk');
const apkOldPath = path.join(apkDir, 'app-release.apk');
const apkNewPath = path.join(apkDir, `music_player_${getAppVersion()}.apk`);

if (fs.existsSync(apkOldPath)) {
    fs.renameSync(apkOldPath, apkNewPath);
    console.log(`Output Folder: ${apkDir}`);
    console.log(`Output Apk: ${apkNewPath}`);
} else {
    console.error(`Not found ${apkOldPath}`);
}



