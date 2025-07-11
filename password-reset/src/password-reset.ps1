Add-Type -AssemblyName System.Windows.Forms

function Show-LanguageSelector {
    $langForm = New-Object System.Windows.Forms.Form
    $langForm.Text = "Select Language / Kies Taal"
    $langForm.Size = New-Object System.Drawing.Size(320, 160)
    $langForm.StartPosition = "CenterScreen"
    $langForm.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Please select your language / Kies jou taal:"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(40, 20)
    $langForm.Controls.Add($label)

    $btnEnglish = New-Object System.Windows.Forms.Button
    $btnEnglish.Text = "English"
    $btnEnglish.Location = New-Object System.Drawing.Point(40, 60)
    $btnEnglish.Size = New-Object System.Drawing.Size(100, 35)
    $langForm.Controls.Add($btnEnglish)

    $btnAfrikaans = New-Object System.Windows.Forms.Button
    $btnAfrikaans.Text = "Afrikaans"
    $btnAfrikaans.Location = New-Object System.Drawing.Point(160, 60)
    $btnAfrikaans.Size = New-Object System.Drawing.Size(100, 35)
    $langForm.Controls.Add($btnAfrikaans)

    $language = $null
    $btnEnglish.Add_Click({ $script:language = "en"; $langForm.Close() })
    $btnAfrikaans.Add_Click({ $script:language = "af"; $langForm.Close() })

    [void]$langForm.ShowDialog()
    return $script:language
}

function Show-GUI ($lang) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = if ($lang -eq "en") { "Windows User PIN Reset" } else { "Windows Gebruiker PIN Herstel" }
    $form.Size = New-Object System.Drawing.Size(440, 240)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = if ($lang -eq "en") {
        "This removes the saved PIN for the current user only."
    } else {
        "Hierdie aksie verwyder die PIN vir slegs die huidige gebruiker."
    }
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(30, 20)
    $form.Controls.Add($label)

    $authorLabel = New-Object System.Windows.Forms.Label
    $authorLabel.Text = if ($lang -eq "en") { "Created by Nathan-Busse" } else { "Gemaak deur Nathan-Busse" }
    $authorLabel.AutoSize = $true
    $authorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $authorLabel.ForeColor = "DarkGray"
    $authorLabel.Location = New-Object System.Drawing.Point(30, 45)
    $form.Controls.Add($authorLabel)

    $resetButton = New-Object System.Windows.Forms.Button
    $resetButton.Text = if ($lang -eq "en") { "Reset PIN" } else { "Verwyder PIN" }
    $resetButton.Location = New-Object System.Drawing.Point(60, 100)
    $resetButton.Size = New-Object System.Drawing.Size(120, 40)
    $form.Controls.Add($resetButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = if ($lang -eq "en") { "Cancel" } else { "Kanselleer" }
    $cancelButton.Location = New-Object System.Drawing.Point(230, 100)
    $cancelButton.Size = New-Object System.Drawing.Size(120, 40)
    $form.Controls.Add($cancelButton)

    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = ""
    $statusLabel.AutoSize = $true
    $statusLabel.Location = New-Object System.Drawing.Point(30, 160)
    $form.Controls.Add($statusLabel)

    $resetButton.Add_Click({
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
            ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            $msg = if ($lang -eq "en") { "Please run this script as Administrator." } else { "Voer asseblief hierdie skrif uit as administrateur." }
            [System.Windows.Forms.MessageBox]::Show($msg, "Admin Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        $basePath = "$env:SystemRoot\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"
        $userPinPath = Join-Path $basePath $sid
        $pinExists = $false

        if (Test-Path $userPinPath) {
            $pinExists = Get-ChildItem $userPinPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 0 }
        }

        if (-not $pinExists) {
            $statusLabel.Text = if ($lang -eq "en") { "No PIN found for this user." } else { "Geen PIN gevind vir hierdie gebruiker nie." }
            return
        }

        try {
            Stop-Service -Name NgcSvc -ErrorAction SilentlyContinue
            takeown /f $userPinPath /r /d Y | Out-Null
            icacls $userPinPath /grant administrators:F /t /c | Out-Null
            Remove-Item $userPinPath -Recurse -Force

            $statusLabel.Text = if ($lang -eq "en") { "✅ User's PIN removed. Restarting..." } else { "✅ PIN verwyder. Herbegin nou..." }
            Start-Sleep -Seconds 3
            Restart-Computer
        } catch {
            $errorMsg = if ($lang -eq "en") { "An error occurred: $_" } else { "Fout het plaasgevind: $_" }
            [System.Windows.Forms.MessageBox]::Show($errorMsg, "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $cancelButton.Add_Click({ $form.Close() })
    [void]$form.ShowDialog()
}

# 🌍 Launch GUI
$selectedLang = Show-LanguageSelector
if (-not $selectedLang) { exit }
Show-GUI -lang $selectedLang