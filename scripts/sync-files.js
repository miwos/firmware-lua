import LuaOnArduino from 'lua-on-arduino'

(async () => {
  const loa = new LuaOnArduino()
  await loa.connect()
  loa.syncFiles('./lua/**/*', { watch: true })
})()
