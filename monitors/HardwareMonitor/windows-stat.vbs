' ========================================================
'
' Monitors CPU, Memory, Network and Disks on Windows
'
' version 1.0
'
' ========================================================
Option Explicit

Dim oWsh, oWshSysEnv, objFSO, objWMIService, objRefresher
Dim colItems, objItem, colItems1, objItem1, ColCPU, ColMemPh, ColMem
Dim CPU_IDLE, CPU_BUSY, MEM_TOTAL_MB, MEM_USED_MB, MEM_FREE_MB, MEM_USED_PC, MEM_FREE_PC, NET_PACKETS_IN
Dim NET_PACKETS_OUT, NET_KBYTES_IN, NET_KBYTES_OUT, READS, WRITES, READS_KB, WRITES_KB
Dim TMP_NET_PACKETS1_IN, TMP_NET_PACKETS1_OUT, TMP_NET_BYTES1_IN, TMP_NET_BYTES1_OUT
Dim TMP_NET_PACKETS2_IN, TMP_NET_PACKETS2_OUT, TMP_NET_BYTES2_IN, TMP_NET_BYTES2_OUT
Dim TMP_READS2_KB, TMP_READS1_KB, TMP_WRITES2_KB, TMP_WRITES1_KB
Dim TMP_READS1, TMP_READS2, TMP_WRITES2, TMP_WRITES1
Dim NET_TIME, Bool
Dim TEST_VAL

Set oWsh = WScript.CreateObject("WScript.Shell")
Set oWshSysEnv = oWsh.Environment("PROCESS")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
Set objRefresher = CreateObject("WbemScripting.SWbemRefresher")
Set ColCPU = objRefresher.Add(objWMIService,"Win32_PerfFormattedData_PerfOS_Processor.Name='_Total'").Object
Set ColMemPh = objRefresher.AddEnum(objWMIService,"Win32_ComputerSystem").ObjectSet
Set ColMem = objRefresher.AddEnum(objWMIService,"Win32_PerfFormattedData_PerfOS_Memory").ObjectSet
objRefresher.Refresh

NET_TIME = 60
Bool = 0

Do
'take initial reading, sleep for a minute then find the diff

' NETWORK & DISK Usage 
'Network

      		TMP_NET_PACKETS1_IN = 0
      		TMP_NET_PACKETS1_OUT = 0
      		TMP_NET_BYTES1_IN = 0
      		TMP_NET_BYTES1_OUT = 0
      		TMP_NET_PACKETS2_IN = 0
      		TMP_NET_PACKETS2_OUT = 0
      		TMP_NET_BYTES2_IN = 0
      		TMP_NET_BYTES2_OUT = 0

 Set colItems = GetObject("WinMgmts:root/cimv2").ExecQuery("SELECT * FROM Win32_PerfRawData_Tcpip_NetworkInterface")
' calculate for each network adapter
 For Each objItem1 In colItems
      		TMP_NET_PACKETS1_IN = TMP_NET_PACKETS1_IN + objItem1.PacketsReceivedPersec
      		TMP_NET_PACKETS1_OUT = TMP_NET_PACKETS1_OUT + objItem1.PacketsSentPersec
      		TMP_NET_BYTES1_IN = TMP_NET_BYTES1_IN + objItem1.BytesReceivedPersec
      		TMP_NET_BYTES1_OUT = TMP_NET_BYTES1_OUT + objItem1.BytesSentPersec
 Next

'Disk
 Set colItems = GetObject("WinMgmts:root/cimv2").ExecQuery("SELECT * FROM Win32_PerfRawData_PerfDisk_PhysicalDisk WHERE Name='_Total'")
 For Each objItem In colItems
	TMP_READS1_KB = Round(objItem.DiskReadBytesPersec / 1024)
	TMP_WRITES1_KB = Round(objItem.DiskWriteBytesPersec / 1024)
	TMP_READS1 = Round(objItem.DiskReadsPersec)
	TMP_WRITES1 = Round(objItem.DiskWritesPersec)
 Next

 WScript.Sleep(NET_TIME * 1000)

'Calculate again to find disk and network usage

'Network
 Set colItems = GetObject("WinMgmts:root/cimv2").ExecQuery("SELECT * FROM Win32_PerfRawData_Tcpip_NetworkInterface")
' calculate for each network adapter
 For Each objItem1 In colItems
      		TMP_NET_PACKETS2_IN = TMP_NET_PACKETS2_IN + objItem1.PacketsReceivedPersec
      		TMP_NET_PACKETS2_OUT = TMP_NET_PACKETS2_OUT + objItem1.PacketsSentPersec
      		TMP_NET_BYTES2_IN = TMP_NET_BYTES2_IN + objItem1.BytesReceivedPersec
      		TMP_NET_BYTES2_OUT = TMP_NET_BYTES2_OUT + objItem1.BytesSentPersec
 Next

'Disk
 Set colItems = GetObject("WinMgmts:root/cimv2").ExecQuery("SELECT * FROM Win32_PerfRawData_PerfDisk_PhysicalDisk WHERE Name='_Total'")
 For Each objItem In colItems
	TMP_READS2_KB = Round(objItem.DiskReadBytesPersec / 1024)
	TMP_WRITES2_KB = Round(objItem.DiskWriteBytesPersec / 1024)
	TMP_READS2 = Round(objItem.DiskReadsPersec)
	TMP_WRITES2 = Round(objItem.DiskWritesPersec)
 Next

 NET_KBYTES_IN=Round((TMP_NET_BYTES2_IN - TMP_NET_BYTES1_IN)/NET_TIME/1024 )
 NET_PACKETS_IN=Round((TMP_NET_PACKETS2_IN - TMP_NET_PACKETS1_IN)/NET_TIME)

 NET_KBYTES_OUT=Round((TMP_NET_BYTES2_OUT - TMP_NET_BYTES1_OUT)/NET_TIME/1024)
 NET_PACKETS_OUT=Round((TMP_NET_PACKETS2_OUT - TMP_NET_PACKETS1_OUT)/NET_TIME)

 READS_KB = Round((TMP_READS2_KB - TMP_READS1_KB) / NET_TIME)
 WRITES_KB = Round((TMP_WRITES2_KB - TMP_WRITES1_KB) / NET_TIME)

 READS = Round((TMP_READS2 - TMP_READS1) / NET_TIME)
 WRITES = Round((TMP_WRITES2 - TMP_WRITES1) / NET_TIME)

 objRefresher.Refresh

' CPU Usage
 CPU_BUSY = ColCPU.PercentProcessorTime
 CPU_IDLE = 100 - CPU_BUSY

' Memory
 For Each objItem In ColMemPh
	MEM_TOTAL_MB = Round(objItem.TotalPhysicalMemory / (1024 * 1024))
 Next

 For Each objItem In ColMem   
	MEM_FREE_MB = objItem.AvailableMbytes
 Next

 MEM_USED_MB = MEM_TOTAL_MB - MEM_FREE_MB

 If MEM_USED_MB <> 0 Then 
	MEM_USED_PC = Round((MEM_USED_MB * 100) / MEM_TOTAL_MB)
 End If 

 MEM_FREE_PC = 100 - MEM_USED_PC

' Output area
' The first output isn't showed
 If Bool Then
 	WScript.Echo "name=Hardware Resources|CPU|%Idle,value=" & CPU_IDLE
	WScript.Echo "name=Hardware Resources|CPU|%Busy,value=" & CPU_BUSY
	WScript.Echo "name=Hardware Resources|Memory|Total (MB),value=" & MEM_TOTAL_MB
	WScript.Echo "name=Hardware Resources|Memory|Used (MB),value=" & MEM_USED_MB
	WScript.Echo "name=Hardware Resources|Memory|Free (MB),value=" & MEM_FREE_MB
	WScript.Echo "name=Hardware Resources|Memory|Used %,value=" & MEM_USED_PC
	WScript.Echo "name=Hardware Resources|Memory|Free %,value=" & MEM_FREE_PC
	WScript.Echo "name=Hardware Resources|Network|Incoming packets/sec,value=" & NET_PACKETS_IN
	WScript.Echo "name=Hardware Resources|Network|Outgoing packets/sec,value=" & NET_PACKETS_OUT
	Wscript.Echo "name=Hardware Resources|Network|Incoming KB/sec,value=" & NET_KBYTES_IN
	WScript.Echo "name=Hardware Resources|Network|Outgoing KB/sec,value=" & NET_KBYTES_OUT
	WScript.Echo "name=Hardware Resources|Disks|Reads/sec,value=" & READS
	WScript.Echo "name=Hardware Resources|Disks|Writes/sec,value=" & WRITES
	WScript.Echo "name=Hardware Resources|Disks|KB read/sec,value=" & READS_KB
	WScript.Echo "name=Hardware Resources|Disks|KB written/sec,value=" & WRITES_KB
 End If 
 Bool = 1
Loop
WScript.Quit 