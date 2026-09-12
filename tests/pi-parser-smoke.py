#!/usr/bin/env python3
"""Optional actual Pi parser parity check; never changes the Pi checkout."""
from pathlib import Path
import subprocess
import sys

project, pack = (Path(arg).resolve() for arg in sys.argv[1:])
module = project / "packages/pi-dev-team-package/src/model-defaults.mjs"
subprocess.run(["node", "--input-type=module", "-e", r'''
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const {parseProjectRoleModels} = await import(pathToFileURL(process.argv[1]));
const text = fs.readFileSync(process.argv[2], 'utf8');
const legacy = text.split('\n').map(line => line.startsWith('|')
  ? line.split('|').slice(0, 10).join('|') + '|' : line).join('\n');
const actual = parseProjectRoleModels(text);
assert.deepEqual(actual, parseProjectRoleModels(legacy));
assert.equal(actual.architect.model, 'luna');
assert.equal(actual.architect.effort, 'xhigh');
assert.equal(actual.executor.model, 'terra');
assert.equal(actual.executor.effort, 'medium');
console.log('Actual Pi parser legacy parity passed; v2 enforcement not tested.');
''', str(module), str(pack / ".agents/models.md")], check=True, cwd=pack)
