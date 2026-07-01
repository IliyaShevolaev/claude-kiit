'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { spawnSync } = require('child_process');

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  raw += chunk;
});
process.stdin.on('end', () => {
  try {
    main(raw);
  } catch {
    process.exit(0);
  }
});

function main(raw) {
  if (!raw) process.exit(0);

  let payload;
  try {
    payload = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const input = (payload && payload.tool_input) || {};
  const target = input.file_path || input.relative_path;
  if (typeof target !== 'string' || target === '') process.exit(0);

  let projectRoot = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  projectRoot = path.resolve(projectRoot);

  const isAbsolute = /^([a-zA-Z]:[\\/]|\/)/.test(target);
  let absolute = isAbsolute ? target : path.join(projectRoot, target);
  absolute = path.resolve(absolute);

  if (!fs.existsSync(absolute) || !fs.statSync(absolute).isFile())
    process.exit(0);

  const normRoot = projectRoot.replace(/\\/g, '/').toLowerCase();
  const normFile = absolute.replace(/\\/g, '/').toLowerCase();
  if (!normFile.startsWith(normRoot + '/')) process.exit(0);

  const ext = path.extname(absolute).toLowerCase();
  const prettierExts = ['.vue', '.js', '.ts', '.jsx', '.tsx', '.scss', '.css', '.json'];
  const eslintExts = ['.vue', '.js', '.ts', '.jsx', '.tsx'];

  if (!prettierExts.includes(ext)) process.exit(0);

  const rel = (p) => p.replace(/\\/g, '/').slice(normRoot.length + 1);

  const md5 = (file) =>
    crypto.createHash('md5').update(fs.readFileSync(file)).digest('hex');

  const prettierBin = path.join(
    projectRoot,
    'node_modules',
    'prettier',
    'bin',
    'prettier.cjs'
  );
  const eslintBin = path.join(
    projectRoot,
    'node_modules',
    'eslint',
    'bin',
    'eslint.js'
  );

  if (!fs.existsSync(prettierBin)) process.exit(0);

  const before = md5(absolute);

  const pretty = spawnSync(process.execPath, [prettierBin, '--write', absolute], {
    cwd: projectRoot,
    encoding: 'utf8',
  });

  if (pretty.status !== 0) {
    process.stderr.write(
      `prettier could not format ${rel(absolute)}:\n${(pretty.stderr || '').trim()}\n`
    );
    process.exit(0);
  }

  if (eslintExts.includes(ext) && fs.existsSync(eslintBin)) {
    spawnSync(process.execPath, [eslintBin, '--fix', absolute], {
      cwd: projectRoot,
      encoding: 'utf8',
    });
  }

  const after = md5(absolute);

  if (before !== after) {
    process.stdout.write(
      JSON.stringify({ systemMessage: `frontend autofix: ${rel(absolute)}` })
    );
  }

  process.exit(0);
}
