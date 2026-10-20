Add-Type -AssemblyName System.Drawing
$out=(Resolve-Path 'images\jelly_sprites').Path
for($id=40;$id -lt 50;$id++){
  $file=Join-Path $out ('jelly_{0:D2}.png' -f $id)
  $source=[Drawing.Image]::FromFile($file); $w=$source.Width; $h=$source.Height
  $bitmap=[Drawing.Bitmap]::new($w,$h,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics=[Drawing.Graphics]::FromImage($bitmap); $graphics.DrawImage($source,0,0,$w,$h); $graphics.Dispose(); $source.Dispose()
  $seen=New-Object 'bool[,]' $w,$h; $queue=[Collections.Generic.Queue[Drawing.Point]]::new()
  for($x=0;$x -lt $w;$x++){ $queue.Enqueue([Drawing.Point]::new($x,0)); $queue.Enqueue([Drawing.Point]::new($x,$h-1)) }
  for($y=1;$y -lt ($h-1);$y++){ $queue.Enqueue([Drawing.Point]::new(0,$y)); $queue.Enqueue([Drawing.Point]::new($w-1,$y)) }
  while($queue.Count -gt 0){
    $point=$queue.Dequeue(); $x=$point.X; $y=$point.Y
    if($x -lt 0 -or $y -lt 0 -or $x -ge $w -or $y -ge $h -or $seen[$x,$y]){ continue }
    $seen[$x,$y]=$true; $pixel=$bitmap.GetPixel($x,$y)
    $background=($pixel.A -eq 0) -or ($pixel.R -le 65 -and $pixel.G -le 75 -and $pixel.B -le 80)
    if(-not $background){ continue }
    if($pixel.A -ne 0){ $bitmap.SetPixel($x,$y,[Drawing.Color]::FromArgb(0,0,0,0)) }
    $queue.Enqueue([Drawing.Point]::new($x-1,$y)); $queue.Enqueue([Drawing.Point]::new($x+1,$y)); $queue.Enqueue([Drawing.Point]::new($x,$y-1)); $queue.Enqueue([Drawing.Point]::new($x,$y+1))
  }
  $tmp="$file.tmp.png"; $bitmap.Save($tmp,[Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose(); Move-Item -LiteralPath $tmp -Destination $file -Force
}




