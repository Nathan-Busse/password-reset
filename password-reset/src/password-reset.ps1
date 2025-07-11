# after you define $regKey = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\$guid"

$enableButton = New-Object System.Windows.Forms.Button
$enableButton.Text = if ($lang -eq "en") { "Enable PIN" } else { "Skakel PIN Aan" }
$enableButton.Location = New-Object System.Drawing.Point(60,150)
$enableButton.Size = New-Object System.Drawing.Size(120,40)
$form.Controls.Add($enableButton)

$enableButton.Add_Click({
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $msg = if ($lang -eq "en") { "Run as Administrator, please." } else { "Voer asseblief as administrateur uit." }
        [System.Windows.Forms.MessageBox]::Show($msg, "Admin Required", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        # Re-create the credential provider key
        if (-not (Test-Path "HKLM:\$regKey")) {
            New-Item -Path "HKLM:\$regKey" -Force | Out-Null
        }

        $statusLabel.Text = if ($lang -eq "en") { "✅ PIN enabled. Restarting..." } else { "✅ PIN ingeskakel. Herbegin nou..." }
        Start-Sleep -Seconds 3
        Restart-Computer
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
