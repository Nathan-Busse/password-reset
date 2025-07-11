Add-Type -AssemblyName System.Windows.Forms

# Skep die vorm
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows User PIN Reset"
$form.Size = New-Object System.Drawing.Size(440, 220)
$form.StartPosition = "CenterScreen"
$form.Topmost = $true

# Instruksie-etiket
$label = New-Object System.Windows.Forms.Label
$label.Text = "Hierdie aksie verwyder alle gestoor PINs en vereis 'n nuwe opstelling met volgende aanmelding."
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(30, 20)
$form.Controls.Add($label)

# Outeurskap-etiket ("Gemaak deur Nathan-Busse")
$authorLabel = New-Object System.Windows.Forms.Label
$authorLabel.Text = "Gemaak deur Nathan-Busse"
$authorLabel.AutoSize = $true
$authorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$authorLabel.ForeColor = "DarkGray"
$authorLabel.Location = New-Object System.Drawing.Point(30, 45)
$form.Controls.Add($authorLabel)

# Verwyder PIN-knoppie
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Verwyder PIN"
$resetButton.Location = New-Object System.Drawing.Point(60, 100)
$resetButton.Size = New-Object System.Drawing.Size(120, 40)
$form.Controls.Add($resetButton)

# Kanselleer-knoppie
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Kanselleer"
$cancelButton.Location = New-Object System.Drawing.Point(230, 100)
$cancelButton.Size = New-Object System.Drawing.Size(120, 40)
$form.Controls.Add($cancelButton)

# Statusetiket
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(30, 160)
$form.Controls.Add($statusLabel)

# PIN verwyder logika
$resetButton.Add_Click({
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        [System.Windows.Forms.MessageBox]::Show("Voer asseblief hierdie skrif uit as administrateur.", "Toegang Geweier", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $ngcPath = "$env:SystemRoot\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"

    if (-not (Test-Path $ngcPath)) {
        $statusLabel.Text = "PIN is reeds verwyder of nog nie gestel nie."
        return
    }

    try {
        Stop-Service -Name NgcSvc -ErrorAction SilentlyContinue

        takeown /f $ngcPath /r /d Y | Out-Null
        icacls $ngcPath /grant administrators:F /t /c | Out-Null
        Remove-Item $ngcPath -Recurse -Force

        $statusLabel.Text = "✅ PIN suksesvol verwyder. Herbegin nou..."
        Start-Sleep -Seconds 3
        Restart-Computer
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Fout het plaasgevind: $_", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Kanselleer logika
$cancelButton.Add_Click({
    $form.Close()
})

# Wys die GUI
[void]$form.ShowDialog()