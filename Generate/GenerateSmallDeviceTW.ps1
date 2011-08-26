
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

function ReplaceFromString([string] $sourceText, [string] $replaceRegex, [string] $replaceText)
{
	return [regex]::Replace($sourceText, $replaceRegex, "`$1$lineSeparator$replaceText$lineSeparator`$2", [Text.RegularExpressions.RegExOptions]::Singleline)
}

function ReplaceFromFile([string] $sourceText, [string] $replaceRegex, [string] $replaceFile)
{
	#return ReplaceFromString $sourceText, $replaceRegex, (ReadFileContents $replaceFile)

	$replaceText = ReadFileContents $replaceFile
	return [regex]::Replace($sourceText, $replaceRegex, "`$1$lineSeparator$replaceText$lineSeparator`$2", [Text.RegularExpressions.RegExOptions]::Singleline)
}


$iTWpreHeadFile = ".\PreHead-iTW.txt"
$iTWstoreAreaFile = ".\StoreArea-iTW.txt"
$tableFormatFile = ".\TableFormat.txt"
# TODO this should be some kind of collection of files
$AdditionalStoreAreaFile1 = ".\SaveMessageAutoDismissPlugin.txt"

$preHeadRegex = "(<!--PRE-HEAD-START-->.*?<!--\{\{\{-->).*(<!--\}\}\}-->.*?<!--PRE-HEAD-END-->)"
$storeAreaRegex = "(<!--POST-SHADOWAREA-->.*?<div\sid=`"storeArea`">)(.*</div>.*?<!--POST-STOREAREA-->)"
$tableFormatRegex = "(name:\s`"table`",).*(\srowTypes:)"

# Read sourceFile
$sourceContents = ReadFileContents $source

# Replace pre-head
$newContents = ReplaceFromFile $sourceContents $preHeadRegex $iTWpreHeadFile

# Replace storearea
$storeAreaContents = ReadFileContents $iTWstoreAreaFile
$storeAreaContents += ReadFileContents $AdditionalStoreAreaFile1
$newContents = ReplaceFromString $newContents $storeAreaRegex $storeAreaContents

# Replace table format (so we can use ¦ on devices that don't have a | on the keyboard - ie. Android)
$newContents = ReplaceFromFile $newContents $tableFormatRegex $tableFormatFile

# Replace "iphone" with "small screen devices"
$newContents = [regex]::Replace($newContents, "iphone", "small screen devices", [Text.RegularExpressions.RegExOptions]::IgnoreCase)


# Need to use UTF8 to ensure ¦ saved correctly
set-content -path $dest -encoding UTF8 -value $newContents

