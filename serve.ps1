$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:7788/')
$listener.Start()
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath.TrimStart('/')
    if ($path -eq '' -or $path -eq '/') { $path = 'dither-point.html' }
    $file = Join-Path $PSScriptRoot $path
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [System.IO.Path]::GetExtension($file).ToLower()
        $mime = switch ($ext) { '.html' {'text/html'} '.js' {'text/javascript'} '.css' {'text/css'} default {'application/octet-stream'} }
        $res.ContentType = $mime
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.OutputStream.Close()
}
