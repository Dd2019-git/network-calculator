<# ip cals
# example https://shootnick.ru/ip_calc/156.166.176.186/27
1. IPv4 - 94.177.233.87 / 13
2. Найти родительскую сеть адреса.
3. Разделить так, чтобы уместилось 57 подсетей.
4. Написать идентификатор подсети номер 39.. 

UPD v2
добавить адрес сетей и бродкаст
Добавить последний адрес в данном (исходном) сегменте. Бродкаст то есть. 
#>

# $SrcIp = "94.177.233.87"
# $SrcMask = "13"
# $SplitTo = 57 

# $SrcIp = "156.166.176.186"
# $SrcMask = "19"
# $SplitTo = 139 

$SrcIp = "80.220.31.117" # исходный адрес
$SrcMask = "18" # исходная маска
$SplitTo = 46 # на сколько сетей делим. 



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
return $F_IpBinarySplit  # отдали массив бит группами по 8. Это не всегда правильно конечно. 

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
$SrcIpBinary = [Convert]::toString(([IPAddress][String]([IPAddress]$SrcIp).Address).Address,2)  # перевели адрес в бинарник. 
# $SrcIpBinaryTrue 
While ($SrcIpBinary.Length -lt 32)
{$SrcIpBinary = "0" + $SrcIpBinary} # нам нужен бинарник 1)строкой 2) с нолями в начале, чтобы считать четко по 32. 


# $SrcIpBinarySplit = IpStringToBinarySplit($SrcIpBinary) # отдали массив бит 4-мя группами по 8. Это не всегда правильно конечно. 
# и вообще не используется, для вывода на экран это не н 

$NetAddressBin = ""
$NetAddressBCastBin = ""
$MaskBinary = MaskToBinary($SrcMask)  # пересчитали исходную маску в битовую , строкой в единицы и ноли. 


# начинаем считать адрес сети. нам надо ехать вдоль слева направо
# ну и заодно broadcast
for ($i1 = 0; $i1 -lt ($MaskBinary.Length ); $i1++) {
    if ($MaskBinary[$i1]  -eq "1") {
        $NetAddressBin = $NetAddressBin + $SrcIpBinary[$i1]
        $NetAddressBCastBin = $NetAddressBCastBin + $SrcIpBinary[$i1]
        
        }
  else {
    $NetAddressBin = $NetAddressBin + "0"
    $NetAddressBCastBin = $NetAddressBCastBin + "1"}

  # Write-Host $i1 "  ||  " $NetAddressBin " || " $NetAddressBin.Length
}

# $NetAddressSplitted = $NetAddress -split "(\w{8})"
# $IPBinary = '01000000101010000000110000100001'
$NetAddressIP =  ([System.Net.IPAddress]"$([System.Convert]::ToInt64($NetAddressBin,2))").IPAddressToString  # получили адрес сети. 
$NetAddressBCast = ([System.Net.IPAddress]"$([System.Convert]::ToInt64($NetAddressBCastBin,2))").IPAddressToString  # получили адрес broadcast.


# Result 
Write-host "SrcMaskO = " $SrcMask # " Bin " ($MaskBinary -split "(\w{8})")
Write-host "SrcIp    = " $SrcIp " Bin " ($SrcIpBinary -split "(\w{8})")
Write-host "SrcMaskS = " ([System.Net.IPAddress]"$([System.Convert]::ToInt64($MaskBinary,2))").IPAddressToString " Bin " ($MaskBinary -split "(\w{8})")
Write-host "NetAddrB = "  $NetAddressIP " Bin" ($NetAddressBin -split "(\w{8})")
Write-host "NetAddrBcast = " $NetAddressBCast " Bin" ($NetAddressBCastBin -split "(\w{8})")
Write-host
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
Write-host "то есть мы можем менять биты с первого слева после старой маски от бита - "(1 + $SrcMask )" до первого слева в новой - бит " (1+$ResultMask) 
Write-host "стартовая последовательность в этих байтах будет 000*, конечная 111* - на нужное число бит"
Write-host "точнее: "

Write-host ""
Write-host "Мы знаем увеличение размера маски. Фактически это некое двоичное число - в нашем случае 2 в степени " $MaskAddon " или " $SplitToNetCorrect " или пересчет" ([math]::Pow(2,$MaskAddon))
for ($i1 = 0; $i1 -lt $SplitToNetCorrect; $i1++) {  # начинаем размазывать сеть на $SplitToNetCorrect подсетей. 
    $CurrentNetAddressBcastBin = ""
    $CurrentNetAddressBin = $NetAddressBin.Substring(0,$SrcMask) # неизменяемые $SrcMask биты и это строка. $SrcMask - фактически длина в штуках бит. например 18.
    $CurrentNetAddon = [Convert]::ToString($i1,2) #то, что будет прибавлено в битах. 
        While ($CurrentNetAddon.Length -lt $MaskAddon) # пока длина маски меньше чем сколько-нам-надо-добавить - досыпаем ноли слева
        <# пояснение. У нас есть неизменная часть маски сети и мы ее не трогаем, и есть изменяемый кусок длиной например 5. 
        Значение изменяемой части длиной 5 будет меняться от 00000 до 11111. Но мы пересчитываем число слева, 
        и нам надо добить полученный кусок нолями "еще левее от значения", то есть получить из 11 = 00011
        
        #> 
        {$CurrentNetAddon = "0" + $CurrentNetAddon}
        $CurrentNetAddressBin = $CurrentNetAddressBin + $CurrentNetAddon # прибавили к неизменяемой маске - измененный кусок. 
        $CurrentNetAddressBcastBin = $CurrentNetAddressBin # эта часть адреса и бродкаста у нас совпадает, только справа будут все 1111    
        While ($CurrentNetAddressBin.Length -lt 32) # досыпаем ноли справа - то, где мы менять и не собирались. 
        {$CurrentNetAddressBin = $CurrentNetAddressBin + "0"
        $CurrentNetAddressBcastBin = $CurrentNetAddressBcastBin + "1"
        }

    Write-Host "N " $i1 " bin-edited Net add " $CurrentNetAddon "result " ([System.Net.IPAddress]"$([System.Convert]::ToInt64($CurrentNetAddressBin,2))").IPAddressToString "BCast" ([System.Net.IPAddress]"$([System.Convert]::ToInt64($CurrentNetAddressBcastBin,2))").IPAddressToString

}

Write-host "Final point" 