import LuaOnArduino from 'lua-on-arduino'

(async () => {
  const loa = new LuaOnArduino()
  await loa.connect('COM6')
  loa.syncFiles('./lua/**/*', { watch: true })
})()
