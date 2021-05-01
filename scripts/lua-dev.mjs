import chokidar from 'chokidar'
import MiwosBridge from '@miwos/miwos-bridge'
import { promises as fs } from 'fs'
import { sep, posix } from 'path'

const bridge = new MiwosBridge()

chokidar.watch('./lua/*.lua').on('change', async path => {
  const data = await fs.readFile(path)
  const posixPath = path.split(sep).join(posix.sep)
  await bridge.writeFile(posixPath, data)

  bridge.sendMessage('/lua/execute-file', 'lua/index.lua')
});