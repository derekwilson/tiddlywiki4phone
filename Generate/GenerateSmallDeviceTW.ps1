
param($source, $dest)

if (($source -eq $null) -or ($dest -eq $null))
{
"`r`nUsage: .\GenerateSmallDeviceTW.ps1 -source <source blank TiddlyWiki filename> -dest <output filename>"
"`r`n       eg. .\GenerateSmallDeviceTW.ps1 -source `"..\3rd Party\TiddyWiki\blank files\empty.2.6.2.html`" -dest `"new.html`""
"`r`n"
exit
}

#$lineSeparator = [environment]::newline
$lineSeparator = "`n"


function ReadFileContents([string] $filename)
{ 
	return [string]::join($lineSeparator, (get-content -path $filename))
}

function ReplaceFromFile([string] $sourceText, [string] $replaceRegex, [string] $replaceFile)
{
	$replaceText = ReadFileContents $replaceFile
	
	return [regex]::Replace($sourceText, $replaceRegex, "`$1$lineSeparator$replaceText$lineSeparator`$2", [Text.RegularExpressions.RegExOptions]::Singleline)
}


$preHeadFile = ".\PreHead-iTW.txt"
$storeAreaFile = ".\StoreArea-iTW.txt"
$tableFormatFile = ".\TableFormat.txt"

$preHeadRegex = "(<!--PRE-HEAD-START-->.*?<!--\{\{\{-->).*(<!--\}\}\}-->.*?<!--PRE-HEAD-END-->)"
$storeAreaRegex = "(<!--POST-SHADOWAREA-->.*?<div\sid=`"storeArea`">)(.*</div>.*?<!--POST-STOREAREA-->)"
$tableFormatRegex = "(name:\s`"table`",).*(\srowTypes:)"

# Read sourceFile
$sourceContents = ReadFileContents $source


# Replace pre-head
$newContents = ReplaceFromFile $sourceContents $preHeadRegex $preHeadFile

# Replace storearea
$newContents = ReplaceFromFile $newContents $storeAreaRegex $storeAreaFile

# Replace table format (so we can use ¦ on devices that don't have a | on the keyboard - ie. Android)
$newContents = ReplaceFromFile $newContents $tableFormatRegex $tableFormatFile

# Replace "iphone" with "small screen devices"
$newContents = [regex]::Replace($newContents, "iphone", "small screen devices", [Text.RegularExpressions.RegExOptions]::IgnoreCase)


# Need to use UTF8 to ensure ¦ saved correctly
set-content -path $dest -encoding UTF8 -value $newContents

