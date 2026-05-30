# ============================================================================
# trust-cert.ps1 - END-USER helper to trust the BlueMap publisher.
#
# Run this ONCE on a user machine after installing BlueMap to silence the
# Windows SmartScreen "Unknown publisher" warning. After it runs, the
# BlueMap installer (and any future signed update) will be recognized as
# coming from a trusted source on this machine.
#
# What this script does (transparent):
#   1. Locates BlueMap-CodeSigning.cer next to this script.
#   2. Imports it into TWO Windows certificate stores:
#        - CurrentUser\Root          (Trusted Root CA)
#        - CurrentUser\TrustedPublisher
#      Both are under the user profile - NO admin rights needed.
#   3. Verifies the certificate thumbprint after import.
#
# To revoke: delete the cert from `certmgr.msc` under those two stores.
#
# Run interactively:
#   powershell -ExecutionPolicy Bypass -File .\trust-cert.ps1
#
# Or right-click -> "Run with PowerShell"
# ============================================================================

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$cerPath = Join-Path $here 'BlueMap-CodeSigning.cer'

Write-Host ""
Write-Host "--- BlueMap publisher-trust installer -------------------------"
Write-Host ""

if (-not (Test-Path $cerPath)) {
    Write-Host "[FAIL] Certificate file not found:" -ForegroundColor Red
    Write-Host "       $cerPath"
    Write-Host ""
    Write-Host "  This script must be run from the folder that contains"
    Write-Host "  BlueMap-CodeSigning.cer (typically the BlueMap install folder's"
    Write-Host "  resources\app\certificates\ directory, or anywhere you copied"
    Write-Host "  both files together)."
    exit 1
}

# Show what we are about to trust.
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cerPath
Write-Host "About to trust this certificate:"
Write-Host "  Subject    : $($cert.Subject)"
Write-Host "  Issuer     : $($cert.Issuer)"
Write-Host "  Valid from : $($cert.NotBefore)"
Write-Host "  Valid until: $($cert.NotAfter)"
Write-Host "  Thumbprint : $($cert.Thumbprint)"
Write-Host ""

# Refuse to trust an expired cert.
if ($cert.NotAfter -lt (Get-Date)) {
    Write-Error "This certificate has expired. Get an updated .cer from the BlueMap publisher."
    exit 2
}

# Confirm before mutating user cert stores.
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -notmatch '^[yY]') {
    Write-Host "Aborted. No changes made." -ForegroundColor Cyan
    exit 0
}

# Import to TrustedPublisher (this is what silences SmartScreen for signed
# exe's signed by this cert).
try {
    Import-Certificate -FilePath $cerPath -CertStoreLocation 'Cert:\CurrentUser\TrustedPublisher' | Out-Null
    Write-Host "[OK] Imported into CurrentUser\TrustedPublisher" -ForegroundColor Green
} catch {
    Write-Error "Failed to import into TrustedPublisher: $_"
    exit 3
}

# Import to Root (so the chain validates - required for self-signed certs
# because there is no real CA above them).
try {
    Import-Certificate -FilePath $cerPath -CertStoreLocation 'Cert:\CurrentUser\Root' | Out-Null
    Write-Host "[OK] Imported into CurrentUser\Root" -ForegroundColor Green
} catch {
    Write-Warning "Could not import into Root store: $_"
    Write-Warning "Authenticode chain may not validate; signed-installer warnings may persist."
}

# Verify the import landed.
$found = Get-ChildItem 'Cert:\CurrentUser\TrustedPublisher' |
         Where-Object { $_.Thumbprint -eq $cert.Thumbprint }
if ($found) {
    Write-Host ""
    Write-Host "[OK] BlueMap publisher is now trusted on this machine." -ForegroundColor Green
    Write-Host "     Future BlueMap installers signed with this cert will install"
    Write-Host "     without 'Unknown publisher' SmartScreen warnings."
    Write-Host ""
    Write-Host "To undo: open certmgr.msc -> CurrentUser -> Trusted Publishers"
    Write-Host "         (and Trusted Root CAs) -> delete the entry with thumbprint"
    Write-Host "         $($cert.Thumbprint)"
} else {
    Write-Error "Import seemed to succeed but the certificate is not visible in the store. Re-run as the target user (NOT as admin via 'Run as administrator', which uses a different cert store)."
    exit 4
}
Write-Host ""
