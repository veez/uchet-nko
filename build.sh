#!/usr/bin/env bash
# Сборка сайта для хостинга.
# Исходник: site/index.html (его же публикует Claude для предпросмотра).
# Результат: папка docs/ — ее публикует GitHub Pages (или загружают на любой хостинг).
set -euo pipefail
cd "$(dirname "$0")"

SRC=site/index.html
OUT=docs

rm -rf "$OUT"
mkdir -p "$OUT"
cp -r site/img site/fonts site/favicon.svg "$OUT"/

# Строки до <style>: title и описание. Служебные строки предпросмотра и Google Fonts выкидываем.
HEAD_META=$(sed -n '1,/<style>/p' "$SRC" | grep -v '<style>' | grep -v -e 'claude:' -e 'preconnect' -e 'fonts.googleapis')
# Блок стилей целиком.
STYLE=$(sed -n '/<style>/,/<\/style>/p' "$SRC")
# Все, что после </style>, — содержимое страницы.
BODY=$(sed '1,/<\/style>/d' "$SRC")

DESC=$(printf '%s\n' "$HEAD_META" | sed -n 's/.*name="description" content="\([^"]*\)".*/\1/p')
TITLE=$(printf '%s\n' "$HEAD_META" | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p')

{
  cat <<EOF
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
$HEAD_META
<meta property="og:type" content="website">
<meta property="og:locale" content="ru_RU">
<meta property="og:title" content="$TITLE">
<meta property="og:description" content="$DESC">
<link rel="icon" href="favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="fonts/fonts.css">
<style>
/* Базовые правила, которые в предпросмотре Claude добавляются автоматически */
:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
body{margin:0}
img{max-width:100%}
[hidden]{display:none!important}
html{scroll-behavior:smooth}
</style>
$STYLE
</head>
<body>
$BODY
</body>
</html>
EOF
} > "$OUT/index.html"

touch "$OUT/.nojekyll"
# Свой домен для GitHub Pages. Сборка стирает docs/, поэтому файл создается здесь.
echo "nkoplan.ru" > "$OUT/CNAME"
echo "Готово: $OUT/index.html"
du -sh "$OUT"
