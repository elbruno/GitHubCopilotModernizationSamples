# .NET brand rules: sources

Everything here was read from dotnet/brand at commit
`91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa`. Quotes are short and attributed;
read the originals before changing a rule.

- Repository: <https://github.com/dotnet/brand/tree/91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa>
- Guide: <https://github.com/dotnet/brand/blob/91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa/dotnet-styleGuide-2024.pdf>
- License: <https://github.com/dotnet/brand/blob/91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa/LICENSE>

## Quotes

| Rule | Source | Quote |
| --- | --- | --- |
| B1 | Guide, PDF p. 22 | "we are currently using a new 3D style" |
| B2 | Guide, PDF p. 22 | "Refrain from over-using the bot in communications, web experiences, or presentations that aren't related to the .NET community or events." |
| B3 | Guide, PDF p. 22 | "Refrain from reusing old 2D bot artwork for any new communications." |
| B4 | Guide, PDF p. 18 | "best used small (up to 200 pixels)" |
| B5 | README, Logo | "The .NET logo purple color is #512bd4." |
| B6 | Guide, PDF p. 12 | "Use Space Grotesk for headlines and Open Sans for secondary headlines and body copy." |
| B7 | README, License | "Illustrations in the brand repo are licensed under the very permissive CC0 1.0 Universal license" and "The .NET brand guidelines and .NET logo are copyright of the .NET authors." |

PDF page numbers are the page positions in the file, not printed folios.

## Fetch an official file

Pin the commit, download, then hash:

```powershell
$commit = '91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa'
$name = 'bot_frontal.png'
Invoke-WebRequest "https://raw.githubusercontent.com/dotnet/brand/$commit/spot-illustrations/$name" -OutFile $name
(Get-FileHash $name -Algorithm SHA256).Hash.ToLower()
```

Do not edit the file. If a different size is needed, pick another official file.

## Provenance record

Save this next to the file as `provenance.json`:

```json
{
  "id": "dotnet-bot-frontal",
  "file": "bot_frontal.png",
  "sha256": "<lowercase sha256>",
  "width": 250,
  "height": 250,
  "source": "https://github.com/dotnet/brand/blob/<commit>/spot-illustrations/bot_frontal.png",
  "repository": "dotnet/brand",
  "commit": "<commit>",
  "license": "CC0 1.0 Universal (illustrations in dotnet/brand)",
  "altText": "Official .NET dotnet-bot illustration from the dotnet/brand repository",
  "usage": "<which slide or page, and why>",
  "generated": false
}
```

A build that embeds the file should fail when the hash does not match.

## Review questions for generated art

Ask these of every generated image in a .NET deck:

1. Could someone mistake the robot for dotnet-bot (round purple helmet head,
   visor with two oval eyes, antenna)? If yes, reject it.
2. Is there any text, logo, watermark or fake UI? If yes, reject it.
3. Is the prompt recorded, and does it contain "no resemblance to any branded
   mascot"?
