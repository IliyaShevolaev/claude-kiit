<?php

declare(strict_types=1);

$raw = file_get_contents('php://stdin');
if ($raw === false || $raw === '') {
    exit(0);
}

$payload = json_decode($raw, true);
if (!is_array($payload)) {
    exit(0);
}

$input = $payload['tool_input'] ?? [];
$path = $input['file_path'] ?? ($input['relative_path'] ?? null);
if (!is_string($path) || $path === '') {
    exit(0);
}

$projectRoot = getenv('CLAUDE_PROJECT_DIR');
if (!is_string($projectRoot) || $projectRoot === '') {
    $projectRoot = getcwd() ?: '.';
}
$projectRoot = rtrim(str_replace('\\', '/', $projectRoot), '/');

$isAbsolute = preg_match('#^([a-zA-Z]:[\\\\/]|/)#', $path) === 1;
$absolute = $isAbsolute ? $path : $projectRoot . '/' . $path;
$absolute = str_replace('\\', '/', $absolute);

if (!is_file($absolute)) {
    exit(0);
}

if (strtolower((string) pathinfo($absolute, PATHINFO_EXTENSION)) !== 'php') {
    exit(0);
}

if (strncmp($absolute, $projectRoot, strlen($projectRoot)) !== 0) {
    exit(0);
}

$lintOutput = [];
$lintCode = 0;
exec('php -l ' . escapeshellarg($absolute) . ' 2>&1', $lintOutput, $lintCode);

if ($lintCode !== 0) {
    fwrite(STDERR, "PHP syntax error in {$absolute}:\n" . implode("\n", $lintOutput) . "\n");
    exit(2);
}

$formatter = null;
$label = '';
foreach (['vendor/bin/pint' => 'pint', 'vendor/bin/phpcbf' => 'phpcbf'] as $bin => $name) {
    if (is_file($projectRoot . '/' . $bin)) {
        $formatter = $projectRoot . '/' . $bin;
        $label = $name;
        break;
    }
}

if ($formatter === null) {
    exit(0);
}

$before = md5_file($absolute);

$fmtOutput = [];
$fmtCode = 0;
exec('php ' . escapeshellarg($formatter) . ' ' . escapeshellarg($absolute) . ' 2>&1', $fmtOutput, $fmtCode);

clearstatcache(true, $absolute);
$after = md5_file($absolute);

if ($before !== $after) {
    $relative = ltrim(substr($absolute, strlen($projectRoot)), '/');
    echo json_encode([
        'systemMessage' => "{$label} auto-formatted: {$relative}",
    ]);
}

exit(0);
