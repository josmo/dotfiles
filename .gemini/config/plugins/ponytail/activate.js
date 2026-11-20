const os = require('os');
const path = require('path');

const root = path.join(os.homedir(), '.apm/apm_modules/dietrichgebert/ponytail');
try {
  const { getDefaultMode } = require(path.join(root, 'hooks/ponytail-config'));
  const { getPonytailInstructions } = require(path.join(root, 'hooks/ponytail-instructions'));
  const mode = getDefaultMode();
  if (mode !== 'off') {
    process.stdout.write(JSON.stringify({
      injectSteps: [{ systemMessage: { systemMessage: getPonytailInstructions(mode) } }],
    }));
  } else {
    process.stdout.write('{}');
  }
} catch {
  process.stdout.write('{}');
}
