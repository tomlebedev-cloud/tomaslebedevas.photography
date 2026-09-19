<#
  sitemap.ps1
  Paskirtis:  sugeneruoja sitemap.xml is puslapiu turinio - ir pacius
              puslapius, ir kiekviena juose rodoma nuotrauka (Google Images).
  Paleidimas: powershell -ExecutionPolicy Bypass -File tools\sitemap.ps1
  Kada:       po kiekvieno paruosti-nuotraukas.ps1 arba pakeitus puslapius.

  Nuotrauku adresai imami is figure data-full - t.y. pilno dydzio (2000 px)
  versijos. Miniatiuros i zemelapi nededamos: Google indeksuotu maza kadra.
#>

$ErrorActionPreference = 'Stop'
$saknis = Split-Path -Parent $PSScriptRoot
$baze   = 'https://tomaslebedevas.photography/'

# Failas -> adresas ir prioritetas. Titulinis rodomas be index.html.
$puslapiai = @(
    @{ Failas = 'index.html';     Adresas = '';               Prio = '1.0' },
    @{ Failas = 'tanzania.html';  Adresas = 'tanzania.html';  Prio = '0.8' },
    @{ Failas = 'morocco.html';   Adresas = 'morocco.html';   Prio = '0.8' },
    @{ Failas = 'elsewhere.html'; Adresas = 'elsewhere.html'; Prio = '0.8' }
)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"')
[void]$sb.AppendLine('        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">')

$visoNuotrauku = 0

foreach ($p in $puslapiai) {
    $kelias = Join-Path $saknis $p.Failas
    if (-not (Test-Path -LiteralPath $kelias)) { throw "Nerastas puslapis $($p.Failas)" }

    $h = [System.IO.File]::ReadAllText($kelias)
    $data = (Get-Item -LiteralPath $kelias).LastWriteTime.ToString('yyyy-MM-dd')

    # Pilno dydzio kadrai. Tvarka tokia pati kaip puslapyje, dublikatu nededam.
    $nuotraukos = New-Object System.Collections.Generic.List[string]
    if ($p.Failas -eq 'index.html') { [void]$nuotraukos.Add('photos/hero/harbour-2000.jpg') }
    foreach ($m in [regex]::Matches($h, 'data-full="([^"]+)"')) {
        $v = $m.Groups[1].Value
        if (-not $nuotraukos.Contains($v)) { [void]$nuotraukos.Add($v) }
    }

    [void]$sb.AppendLine('  <url>')
    [void]$sb.AppendLine('    <loc>' + $baze + $p.Adresas + '</loc>')
    [void]$sb.AppendLine('    <lastmod>' + $data + '</lastmod>')
    [void]$sb.AppendLine('    <priority>' + $p.Prio + '</priority>')
    foreach ($n in $nuotraukos) {
        [void]$sb.AppendLine('    <image:image><image:loc>' + $baze + $n + '</image:loc></image:image>')
    }
    [void]$sb.AppendLine('  </url>')

    $visoNuotrauku += $nuotraukos.Count
    Write-Host ("{0,-16} {1,3} nuotraukos" -f $p.Failas, $nuotraukos.Count)
}

[void]$sb.AppendLine('</urlset>')

$isvestis = Join-Path $saknis 'sitemap.xml'
[System.IO.File]::WriteAllText($isvestis, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host ("sitemap.xml: {0} puslapiai, {1} nuotrauku irasai" -f $puslapiai.Count, $visoNuotrauku)
