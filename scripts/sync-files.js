import LuaOnArduino from 'lua-on-arduino'

;(async () => {
  const loa = new LuaOnArduino()
  await loa.connect('COM4')

  // console.log((await loa.readFile('lua/Miwos.lua')).toString())
  // console.log((await loa.readFile('lua/init.lua')).toString())
  // console.log((await loa.readFile('lua/patches/patch1.lua')).toString())

  // await loa.updateFile('lua/init.lua');

  await loa.syncFiles('lua/**/*', { watch: true, override: true })
})()
