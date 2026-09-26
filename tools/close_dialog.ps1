$code = @'
using System;
using System.Runtime.InteropServices;
public class WinUtil {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
}
'@
Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
$hwnd = [WinUtil]::FindWindow($null, "Legacy Compiled Data")
Write-Host "Found hwnd: $hwnd"
if ($hwnd -ne [IntPtr]::Zero) {
    [WinUtil]::SendMessage($hwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
    Write-Host "Closed Legacy Compiled Data dialog!"
}
