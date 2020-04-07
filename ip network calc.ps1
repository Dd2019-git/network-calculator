<# ip cals
# example https://shootnick.ru/ip_calc/156.166.176.186/27
1. IPv4 - 94.177.233.87 / 13
2. Найти родительскую сеть адреса.
3. Разделить так, чтобы уместилось 57 подсетей.
4. Написать идентификатор подсети номер 39.. #>

# $SrcIp = "94.177.233.87"
# $SrcMask = "13"
# $SplitTo = 57 

# $SrcIp = "156.166.176.186"
# $SrcMask = "19"
# $SplitTo = 139 

$SrcIp = "192.168.1.25"
$SrcMask = "24"
$SplitTo = 4 



function IpStringToBinarySplit{
param([string]$F_IP)

While ($F_IP.Length -lt 32)
{$F_IP = "0" + $F_IP
}


$ChunkSize = 8
$F_IpBinarySplit=@()

# for ($i1 = 0; $i1 -lt ($SrcIpBinary.Length) ; $i1++ ){
# не, ну можно и регулярочкой $arr = $str -split "(\w{8})"
for ($i1 = 0; $i1 -lt ($F_IP.Length )  ){
    $F_IpBinarySplit += $F_IP.Substring($i1, $ChunkSize)
    # $i1
    # $SrcIpBinary.Substring($i1, $ChunkSize)
    $i1 = $i1 + $ChunkSize
    
}
return $F_IpBinarySplit

}

function MaskToBinary{
param([string]$F_Mask)

for ($i1 = 1; $i1 -le ($F_Mask) ; $i1++ )
{$F_Maskbit = "1" + $F_Maskbit}

While ($F_Maskbit.Length -lt 32)
{$F_Maskbit = $F_Maskbit + "0" 
}


# $F_Maskbit
return $F_Maskbit
}

# https://topic.alibabacloud.com/a/powershell-the-method-of-converting-ip-address-into-binary-_powershell_8_8_20111739.html
# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/converting-binary-data-to-ip-address-and-vice-versa

# $ipV4 = '255.255.255.255'
$SrcIpBinary = [Convert]::toString(([IPAddress][String]([IPAddress]$SrcIp).Address).Address,2)
# $SrcIpBinaryTrue 
While ($SrcIpBinary.Length -lt 32)
{$SrcIpBinary = "0" + $SrcIpBinary}


$SrcIpBinarySplit = IpStringToBinarySplit($SrcIpBinary)
$NetAddressBin = ""
$MaskBinary = MaskToBinary($SrcMask)  # пересчитали 13 маску в битовую


# начинаем считать адрес сети. нам надо ехать вдоль слева направо
for ($i1 = 0; $i1 -lt ($MaskBinary.Length ); $i1++) {
    if ($MaskBinary[$i1]  -eq "1") {$NetAddressBin = $NetAddressBin + $SrcIpBinary[$i1]}
  else {$NetAddressBin = $NetAddressBin + "0"}

  # Write-Host $i1 "  ||  " $NetAddressBin " || " $NetAddressBin.Length
}

# $NetAddressSplitted = $NetAddress -split "(\w{8})"
# $IPBinary = '01000000101010000000110000100001'
$NetAddressIP =  ([System.Net.IPAddress]"$([System.Convert]::ToInt64($NetAddressBin,2))").IPAddressToString

# Result 
Write-host "SrcIp    = " $SrcIp " Bin " ($SrcIpBinary -split "(\w{8})")
Write-host "SrcMaskS = " ([System.Net.IPAddress]"$([System.Convert]::ToInt64($MaskBinary,2))").IPAddressToString " Bin " ($MaskBinary -split "(\w{8})")
Write-host "NetAddrB = "  $NetAddressIP " Bin" ($NetAddressBin -split "(\w{8})")
Write-host "SrcMaskO = " $SrcMask # " Bin " ($MaskBinary -split "(\w{8})")

# http://ciscotips.ru/subnetting-equal
$SplitToNetCorrect = 0
for ($i1 = 0; $i1 -lt 32; $i1++) {
    $Tmp2 = [math]::Pow(2,$i1)
    if ($SplitTo -gt $Tmp2) {}
    else {$SplitToNetCorrect = $Tmp2 
        $MaskAddon = $i1
        $i1 = 32}
}
$ResultMask = ([System.Convert]::ToInt32($SrcMask) + $MaskAddon) 
Write-host "Для получения " $SplitTo " подсетей нужно фактически" $SplitToNetCorrect "сети и увеличить маску на" $MaskAddon " с " $SrcMask " до " $ResultMask
Write-host "В двоичном виде это будет " ((MaskToBinary($ResultMask)) -split "(\w{8})")
Write-host "то есть мы можем менять биты с первого слева после старой маски - "(1 + $SrcMask )" до первого слева в новой - " (1+$ResultMask) 
Write-host "стартовая последовательность в этих байтах будет 000*, конечная 111*"
Write-host "Мы знаем увеличение размера маски. Фактически это некое двоичное число - в нашем случае 2 в " $MaskAddon "или" $SplitToNetCorrect "или пересчет" ([math]::Pow(2,$MaskAddon))
for ($i1 = 0; $i1 -lt $SplitToNetCorrect; $i1++) {

    $CurrentNetAddressBin = $NetAddressBin.Substring(0,$SrcMask) # неизменяемые $SrcMask биты и это строка. 
    $CurrentNetAddon = [Convert]::ToString($i1,2) #то, что будет прибавлено в битах. 
        While ($CurrentNetAddon.Length -lt $MaskAddon) # пока длина маски меньше чем сколько-нам-надо-добавить - досыпаем ноли слева
        {$CurrentNetAddon = "0" + $CurrentNetAddon}
    $CurrentNetAddressBin = $CurrentNetAddressBin + $CurrentNetAddon # прибавили к неизменяемой маске - измененный кусок. 
        While ($CurrentNetAddressBin.Length -lt 32) # досыпаем ноли справа - то, где мы менять и не собирались. 
        {$CurrentNetAddressBin = $CurrentNetAddressBin + "0"}

    Write-Host "N " $i1 " bin-edited " $CurrentNetAddon "result " ([System.Net.IPAddress]"$([System.Convert]::ToInt64($CurrentNetAddressBin,2))").IPAddressToString

}