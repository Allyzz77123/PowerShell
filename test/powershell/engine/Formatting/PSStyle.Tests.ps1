# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe 'Tests for $PSStyle automatic variable' {
    BeforeAll {
        $styleDefaults = @{
            Reset = "`e[0m"
            BlinkOff = "`e[25m"
            Blink = "`e[5m"
            BoldOff = "`e[22m"
            Bold = "`e[1m"
            HiddenOff = "`e[28m"
            Hidden = "`e[8m"
            ReverseOff = "`e[27m"
            Reverse = "`e[7m"
            ItalicOff = "`e[23m"
            Italic = "`e[3m"
            UnderlineOff = "`e[24m"
            Underline = "`e[4m"
            StrikethroughOff = "`e[29m"
            Strikethrough = "`e[9m"
        }

        $formattingDefaults = @{
            FormatAccent = "`e[32;1m"
            TableHeader = "`e[32;1m"
            ErrorAccent = "`e[36;1m"
            Error = "`e[31;1m"
            Debug = "`e[33;1m"
            Verbose = "`e[33;1m"
            Warning = "`e[33;1m"
        }

        $foregroundDefaults = @{
            Black = "`e[30m"
            White = "`e[37m"
            BrightBlack = "`e[90m"
            BrightWhite = "`e[97m"
            Red = "`e[31m"
            BrightRed = "`e[91m"
            Magenta = "`e[35m"
            BrightMagenta = "`e[95m"
            Blue = "`e[34m"
            BrightBlue = "`e[94m"
            Cyan = "`e[36m"
            BrightCyan = "`e[96m"
            Green = "`e[32m"
            BrightGreen = "`e[92m"
            Yellow = "`e[33m"
            BrightYellow = "`e[93m"
        }

        $backgroundDefaults = @{
            Black = "`e[40m"
            White = "`e[47m"
            BrightBlack = "`e[100m"
            BrightWhite = "`e[107m"
            Red = "`e[41m"
            BrightRed = "`e[101m"
            Magenta = "`e[45m"
            BrightMagenta = "`e[105m"
            Blue = "`e[44m"
            BrightBlue = "`e[104m"
            Cyan = "`e[46m"
            BrightCyan = "`e[106m"
            Green = "`e[42m"
            BrightGreen = "`e[102m"
            Yellow = "`e[43m"
            BrightYellow = "`e[103m"
        }

        function Get-TestCases($hashtable) {
            $testcases = [System.Collections.Generic.List[hashtable]]::new()
            foreach ($key in $hashtable.Keys) {
                $testcases.Add(
                    @{ Key = $key; Value = $hashtable[$key] }
                )
            }

            return $testcases
        }
    }

    It '$PSStyle has correct default for OutputRendering' {
        $PSStyle | Should -Not -BeNullOrEmpty
        $PSStyle.OutputRendering | Should -BeExactly 'Host'
    }

    It '$PSStyle has correct defaults for style <key>' -TestCases (Get-TestCases $styleDefaults) {
        param($key, $value)

        $PSStyle.$key | Should -BeExactly $value
    }

    It '$PSStyle.Formatting has correct default for <key>' -TestCases (Get-TestCases $formattingDefaults) {
        param($key, $value)

        $PSStyle.Formatting.$key | Should -BeExactly $value
    }

    It '$PSStyle.Foreground has correct default for <key>' -TestCases (Get-TestCases $foregroundDefaults) {
        param($key, $value)

        $PSStyle.Foreground.$key | Should -BeExactly $value
    }

    It '$PSStyle.Background has correct default for <key>' -TestCases (Get-TestCases $backgroundDefaults) {
        param($key, $value)

        $PSStyle.Background.$key | Should -BeExactly $value
    }

    It '$PSStyle.Foreground.FromRGB(r, g, b) works' {
        $o = $PSStyle.Foreground.FromRGB(11,22,33)
        $o | Should -BeExactly "`e[38;2;11;22;33m" -Because ($o | Format-Hex | Out-String)
    }

    It '$PSStyle.Foreground.FromRGB(rgb) works' {
        $o = $PSStyle.Foreground.FromRGB(0x223344)
        $o | Should -BeExactly "`e[38;2;34;51;68m" -Because ($o | Format-Hex | Out-String)
    }

    It '$PSStyle.Background.FromRGB(r, g, b) works' {
        $o = $PSStyle.Background.FromRGB(33,44,55)
        $o | Should -BeExactly "`e[48;2;33;44;55m" -Because ($o | Format-Hex | Out-String)
    }

    It '$PSStyle.Background.FromRGB(rgb) works' {
        $o = $PSStyle.Background.FromRGB(0x445566)
        $o | Should -BeExactly "`e[48;2;68;85;102m" -Because ($o | Format-Hex | Out-String)
    }

    It '$PSStyle.FormatHyperlink() works' {
        $o = $PSStyle.FormatHyperlink('PSBlog','https://aka.ms/psblog')
        $o | Should -BeExactly "`e]8;;https://aka.ms/psblog`e\PSBlog`e]8;;`e\" -Because ($o | Format-Hex | Out-String)
    }

    It '$PSStyle.Formatting.FormatAccent is applied to Format-List' {
        $old = $PSStyle.Formatting.FormatAccent
        $oldRender = $PSStyle.OutputRendering

        try {
            $PSStyle.OutputRendering = 'Ansi'
            $PSStyle.Formatting.FormatAccent = $PSStyle.Foreground.Yellow + $PSStyle.Background.Red + $PSStyle.Italic
            $out = $PSVersionTable | Format-List | Out-String
            $out | Should -BeLike "*$($PSStyle.Formatting.FormatAccent.Replace('[',"``["))*"
        }
        finally {
            $PSStyle.OutputRendering = $oldRender
            $PSStyle.Formatting.FormatAccent = $old
        }
    }

    It '$PSStyle.Formatting.TableHeader is applied to Format-Table' {
        $old = $PSStyle.Formatting.TableHeader
        $oldRender = $PSStyle.OutputRendering

        try {
            $PSStyle.OutputRendering = 'Ansi'
            $PSStyle.Formatting.TableHeader = $PSStyle.Foreground.Blue + $PSStyle.Background.White + $PSStyle.Bold
            $out = $PSVersionTable | Format-Table | Out-String
            $out | Should -BeLike "*$($PSStyle.Formatting.TableHeader.Replace('[',"``["))*"
        }
        finally {
            $PSStyle.OutputRendering = $oldRender
            $PSStyle.Formatting.TableHeader = $old
        }
    }

    It 'Should fail if setting formatting contains printable characters: <member>.<submember>' -TestCases @(
        @{ Submember = 'Reset' }
        @{ Submember = 'BlinkOff' }
        @{ Submember = 'Blink' }
        @{ Submember = 'BoldOff' }
        @{ Submember = 'Bold' }
        @{ Submember = 'HiddenOff' }
        @{ Submember = 'Hidden' }
        @{ Submember = 'ItalicOff' }
        @{ Submember = 'Italic' }
        @{ Submember = 'UnderlineOff' }
        @{ Submember = 'Underline' }
        @{ Submember = 'StrikethroughOff' }
        @{ Submember = 'Strikethrough' }
        @{ Member = 'Formatting'; Submember = 'FormatAccent' }
        @{ Member = 'Formatting'; Submember = 'TableHeader' }
        @{ Member = 'Formatting'; Submember = 'ErrorAccent' }
        @{ Member = 'Formatting'; Submember = 'Error' }
        @{ Member = 'Formatting'; Submember = 'Warning' }
        @{ Member = 'Formatting'; Submember = 'Verbose' }
        @{ Member = 'Formatting'; Submember = 'Debug' }
        @{ Member = 'Progress'; Submember = 'Style' }
        @{ Member = 'FileInfo'; Submember = 'Directory' }
        @{ Member = 'FileInfo'; Submember = 'SymbolicLink' }
        @{ Member = 'FileInfo'; Submember = 'Executable' }
        @{ Member = 'FileInfo'; Submember = 'Hidden' }
    ) {
        param ($member, $submember)

        if ($null -ne $member) {
            { $PSStyle.$member.$submember = $PSStyle.Foreground.Red + 'hello' } | Should -Throw
        }
        else {
            { $PSStyle.$submember = $PSStyle.Foreground.Red + 'hello' } | Should -Throw
        }
    }

    It 'Should fail adding extension formatting with printable characters' {
        { $PSStyle.FileInfo.Extension.Add('.md', 'hello') } | Should -Throw -ErrorId 'ArgumentException'
    }

    It 'Should add and remove extension' {
        $extension = '.mytest'
        $PSStyle.FileInfo.Extension.Keys | Should -Not -Contain $extension
        $PSStyle.FileInfo.Extension.Add($extension, $PSStyle.Foreground.Blue)

        $PSStyle.FileInfo.Extension[$extension] | Should -Be $PSStyle.Foreground.Blue
        $PSStyle.FileInfo.Extension.Remove($extension)
        $PSStyle.FileInfo.Extension.Keys | Should -Not -Contain $extension
    }

    It 'Should fail to add extension does not start with a period' {
        { $PSStyle.FileInfo.Extension.Add('mytest', $PSStyle.Foreground.Blue) } | Should -Throw -ErrorId 'ArgumentException'
    }

    It 'Should fail to remove extension does not start with a period' {
        { $PSStyle.FileInfo.Extension.Remove('zip') } | Should -Throw -ErrorId 'ArgumentException'
    }

    It 'Should fail if MaxWidth is less than 18' {
        $maxWidth = $PSStyle.Progress.MaxWidth

        # minimum allowed width is 18 as less than that doesn't render correctly
        try {
            { $PSStyle.Progress.MaxWidth = 17 } | Should -Throw -ErrorId 'ExceptionWhenSetting'
        }
        finally {
            $PSStyle.Progress.MaxWidth = $maxWidth
        }
    }

    It "String intput to Out-String should be intact with OutputRendering='<OutputRendering>'" -TestCases @(
        @{ OutputRendering = 'Ansi'; ContainsAnsi = $true }
        @{ OutputRendering = 'Host'; ContainsAnsi = $false }
        @{ OutputRendering = 'PlainText'; ContainsAnsi = $false }
    ) {
        param($OutputRendering, $ContainsAnsi)

        $oldRender = $PSStyle.OutputRendering
        $testStr = "`e[31mABC`e[0m"

        try {
            $PSStyle.OutputRendering = $OutputRendering
            ## For input that actually goes through formatting, Out-String should remove VT sequences
            ## from the formatting output based on the output rendering option that is in effect.
            (Get-Verb -Verb Get | Out-String).Contains("`e[") | Should -Be $ContainsAnsi
            ## For string input, since no formatting is applied, Out-String should keep the string intact.
            ($testStr | Out-String).Trim() | Should -BeExactly $testStr
        }
        finally {
            $PSStyle.OutputRendering = $oldRender
        }
    }

    It "String input to Out-File should be intact with OutputRendering='<OutputRendering>'" -TestCases @(
        @{ OutputRendering = 'Ansi'; }
        @{ OutputRendering = 'Host'; }
        @{ OutputRendering = 'PlainText'; }
    ) {
        param($OutputRendering)

        $oldRender = $PSStyle.OutputRendering
        $content = "Read-Host -Prompt '`e[33mEnter your device code`e[0m'"
        Set-Content -Path $TestDrive\test.ps1 -Value $content -Encoding utf8NoBOM

        try {
            $PSStyle.OutputRendering = $OutputRendering
            Get-Content $TestDrive\test.ps1 > $TestDrive\copy.ps1
            (Get-Content $TestDrive\copy.ps1 -Raw).Trim() | Should -BeExactly $content
        }
        finally {
            $PSStyle.OutputRendering = $oldRender
            Remove-Item $TestDrive\test.ps1 -Force
            Remove-Item $TestDrive\copy.ps1 -Force
        }
    }

    It "Comment based help works with `$PSStyle when OutputRendering='<OutputRendering>'" -TestCases @(
        @{ OutputRendering = 'Ansi'; ContainsAnsi = $true }
        @{ OutputRendering = 'Host'; ContainsAnsi = $false }
        @{ OutputRendering = 'PlainText'; ContainsAnsi = $false }
    ) {
        param($OutputRendering, $ContainsAnsi)

        $oldRender = $PSStyle.OutputRendering

        function Test-PSStyle {
            <#
            .Description
            Get-Function [31mdisplays[0m the name and syntax of all functions in the session.
            #>
        }

        try {
            $PSStyle.OutputRendering = $OutputRendering
            (Get-Help Test-PSStyle | Out-String).Contains("`e[31mdisplays`e[0m") | Should -Be $ContainsAnsi
        }
        finally {
            $PSStyle.OutputRendering = $oldRender
        }
    }
}
