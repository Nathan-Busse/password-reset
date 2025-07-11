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
    $form.Text = if ($lang -eq "en") { "Windows PIN Sign-In Toggle" } else { "Windows PIN Inskrywing Wissel" }
    $form.Size = New-Object System.Drawing.Size(460, 300)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = if ($lang -eq "en") {
        "Use the buttons below to disable or enable PIN logon."
    } else {
        "Gebruik die knoppies hieronder om PIN inskrywing af of aan te skakel."
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

    # Disable PIN button
    $disableButton = New-Object System.Windows.Forms.Button
    $disableButton.Text = if ($lang -eq "en") { "Disable PIN" } else { "Skakel PIN Af" }
    $disableButton.Location = New-Object System.Drawing.Point(50, 100)
    $disableButton.Size = New-Object System.Drawing.Size(140, 40)
    $form.Controls.Add($disableButton)

    # Enable PIN button
    $enableButton = New-Object System.Windows.Forms.Button
    $enableButton.Text = if ($lang -eq "en") { "Enable PIN" } else { "Skakel PIN Aan" }
    $enableButton.Location = New-Object System.Drawing.Point(230, 100)
    $enableButton.Size = New-Object System.Drawing.Size(140, 40)
    $form.Controls.Add($enableButton)

    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = if ($lang -eq "en") { "Cancel" } else { "Kanselleer" }
    $cancelButton.Location = New-Object System.Drawing.Point(150, 160)
    $cancelButton.Size = New-Object System.Drawing.Size(140, 40)
    $form.Controls.Add($cancelButton)

    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = ""
    $statusLabel.AutoSize = $true
    $statusLabel.Location = New-Object System.Drawing.Point(30, 220)
    $form.Controls.Add($statusLabel)

    # GUID of the PIN Credential Provider
    $credProvGuid = "{D6886603-9D2F-4EB2-B667-1971041FA96B}"
    $regKeyPath    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\$credProvGuid"

    # Shared admin-check
    function Ensure-Admin {
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
            ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            $msg = if ($lang -eq "en") {
                "Please run this script as Administrator."
            } else {
                "Voer asseblief hierdie skrif uit as administrateur."
            }
            [System.Windows.Forms.MessageBox]::Show(
                $msg,
                if ($lang -eq "en") { "Admin Required" } else { "Administrateur Vereis" },
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return $false
        }
        return $true
    }

    # Disable PIN handler
    $disableButton.Add_Click({
        if (-not (Ensure-Admin)) { return }

        try {
            # Delete the credential provider key
            if (Test-Path $regKeyPath) {
                Remove-Item $regKeyPath -Recurse -Force
            }
            $statusLabel.Text = if ($lang -eq "en") {
                "✅ PIN logon disabled. Restarting..."
            } else {
                "✅ PIN inskrywing uitgeskakel. Herbegin nou..."
            }
            Start-Sleep -Seconds 3
            Restart-Computer
        } catch {
            $err = $_.Exception.Message
            [System.Windows.Forms.MessageBox]::Show(
                $err,
                if ($lang -eq "en") { "Error" } else { "Fout" },
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })

    # Enable PIN handler
    $enableButton.Add_Click({
        if (-not (Ensure-Admin)) { return }

        try {
            # Re-create the credential provider key
            if (-not (Test-Path $regKeyPath)) {
                New-Item -Path $regKeyPath -Force | Out-Null
            }
            $statusLabel.Text = if ($lang -eq "en") {
                "✅ PIN logon enabled. Restarting..."
            } else {
                "✅ PIN inskrywing ingeskakel. Herbegin nou..."
            }
            Start-Sleep -Seconds 3
            Restart-Computer
        } catch {
            $err = $_.Exception.Message
            [System.Windows.Forms.MessageBox]::Show(
                $err,
                if ($lang -eq "en") { "Error" } else { "Fout" },
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })

    # Cancel handler
    $cancelButton.Add_Click({ $form.Close() })

    [void]$form.ShowDialog()
}

# Kick things off
$selectedLang = Show-LanguageSelector
if (-not $selectedLang) { exit }
Show-GUI -lang $selectedLang
