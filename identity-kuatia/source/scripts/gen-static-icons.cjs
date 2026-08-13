const sharp = require('sharp')
const fs = require('fs')
const path = require('path')

async function main() {
  const appDir = path.join(__dirname, '..', 'src', 'app')
  fs.copyFileSync(
    path.join(__dirname, '..', 'public', 'kuatia-mark-og.png'),
    path.join(appDir, 'opengraph-image.png'),
  )

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
  <text x="16" y="24" text-anchor="middle" font-family="Arial, Helvetica, sans-serif" font-size="26" font-weight="800" fill="#00a89d">K</text>
</svg>`
  await sharp(Buffer.from(svg)).png().toFile(path.join(appDir, 'icon.png'))

  console.log('ok', {
    og: fs.statSync(path.join(appDir, 'opengraph-image.png')).size,
    icon: fs.statSync(path.join(appDir, 'icon.png')).size,
  })
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
