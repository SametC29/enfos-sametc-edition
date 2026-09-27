# SteamCMD uploads content; this official Steamworks API helper supplies the Dota
# Custom Game tag. Probe is read-only; -Apply changes only this project's saved ID.
param([switch]$Apply, [switch]$MakePublic)
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$taskVdf = Get-Content (Join-Path $taskRoot 'release/workshop/workshop.vdf') -Raw
if ($taskVdf -notmatch '"publishedfileid"\s+"(\d+)"') { throw 'Missing publication ID' }
$taskId = [uint64]$Matches[1]
$taskConfig = Get-Content (Join-Path $taskRoot 'workshop/release.json') -Raw | ConvertFrom-Json
if ($taskId -ne [uint64]$taskConfig.publishedfileid -or $taskConfig.appid -ne '570') { throw 'VDF does not match saved project Workshop ID' }
if ($Apply -and ($taskId -eq 0 -or $taskId -eq 3591082091)) { throw 'Invalid project publication ID' }
if ($MakePublic -and -not $Apply) { throw 'MakePublic requires Apply' }
$taskDll = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta/game/bin/win64/steam_api64.dll'
$taskCode = @'
using System;
using System.Runtime.InteropServices;
public static class EnfosWorkshopApi {
 const string Dll = "__DLL__";
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_InitSafe();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern void SteamAPI_Shutdown();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern void SteamAPI_RunCallbacks();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern IntPtr SteamAPI_SteamUGC_v021();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern IntPtr SteamAPI_SteamUtils_v010();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern IntPtr SteamAPI_SteamUser_v023();
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_ISteamUser_BLoggedOn(IntPtr instance);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern uint SteamAPI_ISteamUtils_GetAppID(IntPtr instance);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern ulong SteamAPI_ISteamUGC_StartItemUpdate(IntPtr instance, uint app, ulong id);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_ISteamUGC_SetItemVisibility(IntPtr instance, ulong update, int visibility);
 [StructLayout(LayoutKind.Sequential, Pack=8)] public struct Tags { public IntPtr Strings; public int Count; }
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_ISteamUGC_SetItemTags(IntPtr instance, ulong update, ref Tags tags, [MarshalAs(UnmanagedType.I1)] bool allowAdmin);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] public static extern ulong SteamAPI_ISteamUGC_SubmitItemUpdate(IntPtr instance, ulong update, [MarshalAs(UnmanagedType.LPUTF8Str)] string note);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_ISteamUtils_IsAPICallCompleted(IntPtr instance, ulong call, [MarshalAs(UnmanagedType.I1)] out bool failed);
 [DllImport(Dll, CallingConvention=CallingConvention.Cdecl)] [return:MarshalAs(UnmanagedType.I1)] public static extern bool SteamAPI_ISteamUtils_GetAPICallResult(IntPtr instance, ulong call, IntPtr result, int bytes, int callback, [MarshalAs(UnmanagedType.I1)] out bool failed);
 public static string Apply(IntPtr ugc, IntPtr utils, ulong id, bool makePublic) {
   ulong update=SteamAPI_ISteamUGC_StartItemUpdate(ugc,570,id);
   if(update==0 || update==ulong.MaxValue) throw new Exception("Invalid update handle");
   if(makePublic && !SteamAPI_ISteamUGC_SetItemVisibility(ugc,update,0)) throw new Exception("Public visibility rejected");
   IntPtr text=Marshal.StringToCoTaskMemUTF8("Custom Game");
   IntPtr array=Marshal.AllocHGlobal(IntPtr.Size);
   try {
     Marshal.WriteIntPtr(array,text);
     Tags tags=new Tags { Strings=array, Count=1 };
     if(!SteamAPI_ISteamUGC_SetItemTags(ugc,update,ref tags,false)) throw new Exception("SetItemTags rejected");
   } finally { Marshal.FreeHGlobal(array); Marshal.FreeCoTaskMem(text); }
   ulong call=SteamAPI_ISteamUGC_SubmitItemUpdate(ugc,update,"Classify addon as Dota 2 Custom Game.");
   if(call==0) throw new Exception("Invalid submit handle");
   DateTime deadline=DateTime.UtcNow.AddSeconds(45);
   bool failed=false;
   while(!SteamAPI_ISteamUtils_IsAPICallCompleted(utils,call,out failed)) {
     if(DateTime.UtcNow>deadline) throw new Exception("Tag update timed out; verify remote result before retrying");
     SteamAPI_RunCallbacks(); System.Threading.Thread.Sleep(200);
   }
   if(failed) throw new Exception("Steam tag update transport failed");
   IntPtr result=Marshal.AllocHGlobal(16);
   try {
     if(!SteamAPI_ISteamUtils_GetAPICallResult(utils,call,result,16,3404,out failed)||failed) throw new Exception("No valid tag callback");
     int status=Marshal.ReadInt32(result);
     bool legal=Marshal.ReadByte(result,4)!=0;
     ulong returned=(ulong)Marshal.ReadInt64(result,8);
     if(status!=1||returned!=id) throw new Exception("Tag update failed; EResult="+status);
     return "Custom Game tag applied; Workshop ID="+id+"; public requested="+makePublic+"; legal agreement action="+legal;
   } finally { Marshal.FreeHGlobal(result); }
 }
}
'@
Add-Type -TypeDefinition $taskCode.Replace('__DLL__', $taskDll)
$taskOldApp = $env:SteamAppId
$taskOldGame = $env:SteamGameId
try {
    $env:SteamAppId = '570'
    $env:SteamGameId = '570'
    if (-not [EnfosWorkshopApi]::SteamAPI_InitSafe()) { throw 'Steam API unavailable; Steam desktop must be logged in' }
    try {
        $taskUtils = [EnfosWorkshopApi]::SteamAPI_SteamUtils_v010()
        $taskUgc = [EnfosWorkshopApi]::SteamAPI_SteamUGC_v021()
        if ($taskUtils -eq [IntPtr]::Zero -or $taskUgc -eq [IntPtr]::Zero) { throw 'Steam UGC interface unavailable' }
        if ([EnfosWorkshopApi]::SteamAPI_ISteamUtils_GetAppID($taskUtils) -ne 570) { throw 'Wrong Steam app context' }
        $taskUser = [EnfosWorkshopApi]::SteamAPI_SteamUser_v023()
        if ($taskUser -eq [IntPtr]::Zero) { throw 'Steam user interface unavailable' }
        $taskDeadline = [DateTime]::UtcNow.AddSeconds(25)
        while (-not [EnfosWorkshopApi]::SteamAPI_ISteamUser_BLoggedOn($taskUser)) {
            if ([DateTime]::UtcNow -gt $taskDeadline) { throw 'Steam desktop is not connected; reconnect Steam before applying the tag' }
            [EnfosWorkshopApi]::SteamAPI_RunCallbacks()
            Start-Sleep -Milliseconds 250
        }
        if ($Apply) { [EnfosWorkshopApi]::Apply($taskUgc, $taskUtils, $taskId, [bool]$MakePublic) }
        else { 'Steam UGC API available for Dota 2; probe did not upload or modify anything.' }
    } finally { [EnfosWorkshopApi]::SteamAPI_Shutdown() }
} finally {
    $env:SteamAppId = $taskOldApp
    $env:SteamGameId = $taskOldGame
}
