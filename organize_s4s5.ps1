# === Kaggle-Learning · Audit + Organize S4/S5 (ASCII-safe) ===
$ErrorActionPreference = 'Stop'
$Apply = $true

if (-not (Test-Path '.git')) { throw 'Not a git repo. Run at the root of kaggle-learning.' }
$remote = git config --get remote.origin.url
Write-Host ("Remote: {0}" -f $remote) -ForegroundColor DarkGray

# Mapping S4 + S5
$map = @{
  'S4E1'  = @{ slug='playground-series-s4e1';  dir='s4e01-bank-churn';            short='bank-churn' }
  'S4E2'  = @{ slug='playground-series-s4e2';  dir='s4e02-obesity-risk';          short='obesity-risk' }
  'S4E3'  = @{ slug='playground-series-s4e3';  dir='s4e03-steel-plate-defect';    short='steel-plate-defect' }
  'S4E4'  = @{ slug='playground-series-s4e4';  dir='s4e04-abalone-regression';    short='abalone-regression' }
  'S4E5'  = @{ slug='playground-series-s4e5';  dir='s4e05-flood-regression';      short='flood-regression' }
  'S4E6'  = @{ slug='playground-series-s4e6';  dir='s4e06-academic-success';      short='academic-success' }
  'S4E7'  = @{ slug='playground-series-s4e7';  dir='s4e07-insurance-cross-sell';  short='insurance-cross-sell' }
  'S4E8'  = @{ slug='playground-series-s4e8';  dir='s4e08-poisonous-mushrooms';   short='poisonous-mushrooms' }
  'S4E9'  = @{ slug='playground-series-s4e9';  dir='s4e09-used-car-prices';       short='used-car-prices' }
  'S4E10' = @{ slug='playground-series-s4e10'; dir='s4e10-loan-approval';         short='loan-approval' }
  'S4E11' = @{ slug='playground-series-s4e11'; dir='s4e11-mental-health';         short='mental-health' }
  'S4E12' = @{ slug='playground-series-s4e12'; dir='s4e12-insurance-regression';  short='insurance-regression' }
  'S5E1'  = @{ slug='playground-series-s5e1';  dir='s5e01-sticker-sales-forecast';   short='sticker-sales-forecast' }
  'S5E2'  = @{ slug='playground-series-s5e2';  dir='s5e02-backpack-prediction';      short='backpack-prediction' }
  'S5E3'  = @{ slug='playground-series-s5e3';  dir='s5e03-rainfall-binary';          short='rainfall-binary' }
  'S5E4'  = @{ slug='playground-series-s5e4';  dir='s5e04-podcast-listening';        short='podcast-listening' }
  'S5E5'  = @{ slug='playground-series-s5e5';  dir='s5e05-calorie-expenditure';      short='calorie-expenditure' }
  'S5E6'  = @{ slug='playground-series-s5e6';  dir='s5e06-optimal-fertilizers';      short='optimal-fertilizers' }
  'S5E7'  = @{ slug='playground-series-s5e7';  dir='s5e07-introverts-vs-extroverts'; short='introverts-vs-extroverts' }
  'S5E8'  = @{ slug='playground-series-s5e8';  dir='s5e08-bank-binary';              short='bank-binary' }
  'S5E9'  = @{ slug='playground-series-s5e9';  dir='s5e09-song-bpm';                 short='song-bpm' }
}

# Dossiers competitions/<dir>/{notebooks,input}
foreach ($kv in $map.GetEnumerator()) {
  New-Item -ItemType Directory -Path ".\competitions\$($kv.Value.dir)\notebooks" -Force | Out-Null
  New-Item -ItemType Directory -Path ".\competitions\$($kv.Value.dir)\input" -Force | Out-Null
}

# Trouver notebooks S4E*/S5E*
$found = Get-ChildItem -Recurse -Include 'S4E*.ipynb','s4e*.ipynb','S5E*.ipynb','s5e*.ipynb' -File

# Plan de deplacement/rename
$plan = @()
foreach ($f in $found) {
  $base = $f.BaseName
  if ($base -match '(?i)S([45])E(\d{1,2})') {
    $ep = ('S{0}E{1}' -f $matches[1], $matches[2].PadLeft(2,'0')).ToUpper()
    if ($map.ContainsKey($ep)) {
      $m = $map[$ep]
      $safeBase = ($base -replace '[^\w\-]+','-').ToLower()
      $newName  = ('{0}_{1}_{2}.ipynb' -f $ep.ToLower(), $m.short, $safeBase)
      $dest     = Join-Path ".\competitions\$($m.dir)\notebooks" $newName
      $plan += [pscustomobject]@{ From=$f.FullName; To=$dest; Episode=$ep }
    } else {
      $plan += [pscustomobject]@{ From=$f.FullName; To=$null; Episode='(no-map)' }
    }
  }
}

# Ecrire l'audit
$auditPath = '.\AUDIT_SUMMARY.md'
$lines = @()
$lines += ('# Audit - ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
$lines += ('Remote: ' + $remote)
$lines += ''
$lines += '## Notebooks detectes (S4/S5)'
if ($plan.Count -gt 0) {
  foreach ($p in ($plan | Sort-Object Episode, From)) {
    $relFrom = $p.From.Replace((Get-Location).Path + '\','')
    $relTo   = if ($p.To) { $p.To.Replace((Get-Location).Path + '\','') } else { '(no-map)' }
    $lines  += ('- `{0}` -> `{1}`' -f $relFrom, $relTo)
  }
} else {
  $lines += '- Aucun S4E*/S5E* trouve.'
}
$lines | Set-Content -Encoding UTF8 $auditPath
Write-Host ('Resume ecrit dans {0}' -f $auditPath) -ForegroundColor Cyan

# Appliquer deplacements/renames
foreach ($p in $plan) {
  if ($p.To) {
    Move-Item -Path $p.From -Destination $p.To -Force
    Write-Host ('Moved: {0}' -f $p.To) -ForegroundColor Green
  } else {
    Write-Host ('(i) No mapping for: {0}' -f $p.From) -ForegroundColor Yellow
  }
}

# README par competition
foreach ($kv in $map.GetEnumerator()) {
  $key = $kv.Key; $m = $kv.Value
  $root = ".\competitions\$($m.dir)"
  $rp = "$root\README.md"
  if (-not (Test-Path $rp)) {
    $content = @(
      '# ' + $key + ' - ' + ($m.short -replace '-', ' '),
      '',
      '**Kaggle page:** https://www.kaggle.com/competitions/' + $m.slug,
      '',
      '- Put EDA/baseline/modeling notebooks in `notebooks/`.',
      '- Download data into `input/` with Kaggle CLI:',
      '  py -m kaggle competitions download -c ' + $m.slug + ' -p "' + $root + '\input"'
    )
    $content | Set-Content -Encoding UTF8 $rp
  }
}

# Fichiers de base du repo
if (-not (Test-Path '.\requirements.txt')) {
  'jupyter','numpy','pandas','scikit-learn','matplotlib','xgboost','lightgbm' | Set-Content -Encoding UTF8 .\requirements.txt
}
if (-not (Test-Path '.\.gitignore')) {
  '.venv/','__pycache__/','.ipynb_checkpoints/','.kaggle/','competitions/*/input/','competitions/*/working/' | Set-Content -Encoding UTF8 .\.gitignore
}
if (-not (Test-Path '.\LICENSE')) {
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/mit.txt' -OutFile .\LICENSE
}

# Commit + push
$pending = git status --porcelain
if ($pending) {
  git add -A
  git commit -m 'chore: audit & organize S4/S5 notebooks by competition; add readmes/reqs/gitignore/license'
  git push
} else {
  Write-Host '(i) Aucun changement a committer.' -ForegroundColor Yellow
}

# Release v0.1 si absente
try {
  $repo = (git config --get remote.origin.url) -replace 'https://github.com/','' -replace '\.git$',''
  gh release view v0.1 -R $repo | Out-Null
} catch {
  try {
    gh release create v0.1 -R $repo -n 'Initial public release: S4/S5 structure, per-competition readmes, reqs/gitignore/license.'
  } catch { Write-Host '(i) Impossible de creer la release.' }
}
Write-Host 'Termine. Ouvre AUDIT_SUMMARY.md.' -ForegroundColor Green
