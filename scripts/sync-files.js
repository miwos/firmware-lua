import LuaOnArduino from 'lua-on-arduino'
import { AsyncOsc } from 'async-osc'
import NodeSerialTransport from 'async-osc/dist/NodeSerialTransport.js'
import chokidar from 'chokidar'
import { promises as fs } from 'fs'

const loa = new LuaOnArduino(new AsyncOsc(new NodeSerialTransport()))

export const delay = (duration) =>
  new Promise(resolve => setTimeout(resolve, duration))

  const pathToPosix = (path) => path.replace(/\\/g, '/')

const syncFiles = async (
  pattern,
  { watch = false, override = true, initial = false } = {}
) => {
  // this.logger.info(`sync files ${pattern}`)
  const dir = await loa.readDirectory('lua')

  const syncFile = async (path, update = true) => {
    const posixPath = pathToPosix(path)

    // As `updateFile()` also logs a success message we can omit the
    // `writeFile()` success.
    const logSuccess = !update

    // For some reasons, reading the file inside a chokidar callback sometimes
    // returns an empty string, at least on windows. Maybe the file is locked?
    // As a (dirty) workaround we just wait a bit...
    await delay(10)

    loa.writeFile(posixPath, await fs.readFile(path), logSuccess)
    update && loa.updateFile(posixPath)
  }

  const handleInitialAdd = (path) => {
    const relativePath = path.substring(4) // omit the leading `lua/`
    if (override || !dirIncludes(dir, relativePath)) syncFile(path, false)
  }

  return new Promise(resolve => {
    const watcher = chokidar.watch(pattern)
    initial && watcher.on('add', handleInitialAdd)
    watcher.on('ready', async () => {
      watcher.off('add', handleInitialAdd)
      watcher.on('change', syncFile)
      if (!watch) {
        watcher.close()
        resolve(watcher)
      }
    })
  })
}

loa
  .connect({ path: 'COM4' })
  .then(() =>
    syncFiles("lua/**/*", { watch: true, override: true, initial: false })
  );
