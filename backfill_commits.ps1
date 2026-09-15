Set-Location "D:\Projects\gym_fitness_nepal\mobile_app"
$env:GIT_AUTHOR_NAME = 'Sandesh'
$env:GIT_AUTHOR_EMAIL = 'sangm3138@gmail.com'
$env:GIT_COMMITTER_NAME = 'Sandesh'
$env:GIT_COMMITTER_EMAIL = 'sangm3138@gmail.com'
$dates = @(
    '2026-05-01',
    '2026-05-02',
    '2026-05-03',
    '2026-05-04',
    '2026-05-05',
    '2026-05-06',
    '2026-05-07',
    '2026-05-08',
    '2026-05-09',
    '2026-05-10',
    '2026-05-11',
    '2026-05-12',
    '2026-05-13',
    '2026-05-14',
    '2026-05-15',
    '2026-05-16',
    '2026-05-17',
    '2026-05-18',
    '2026-05-19',
    '2026-05-20',
    '2026-05-21',
    '2026-05-22',
    '2026-05-23',
    '2026-05-24',
    '2026-05-25',
    '2026-05-26',
    '2026-05-27',
    '2026-05-28',
    '2026-05-29',
    '2026-05-30',
    '2026-05-31'
)
foreach ($d in $dates) {
    $dt = "$d`T12:00:00+0545"
    git commit --allow-empty --author='Sandesh <sangm3138@gmail.com>' --date=$dt -m "Backfill commit for $d"
}
git push origin main



Set-Location "E:\practice_projects\gym_fitness_nepal\mobile_app"
$env:GIT_AUTHOR_NAME = 'Sandesh'
$env:GIT_AUTHOR_EMAIL = 'sangm3138@gmail.com'
$env:GIT_COMMITTER_NAME = 'Sandesh'
$env:GIT_COMMITTER_EMAIL = 'sangm3138@gmail.com'
$dates = @(
    '2026-09-10',
    '2026-09-12',
    '2026-09-14'
)
foreach ($d in $dates) {
    $dt = "$d`T12:00:00+0545"
    git commit --allow-empty --author='Sandesh <sangm3138@gmail.com>' --date=$dt -m "Backfill commit for $d"
}
git push origin main