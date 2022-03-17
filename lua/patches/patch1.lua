return {
  instances = {
    [1] = { Module = 'Input', props = { device = 4 }, xy = { 100, 100 } },
    [2] = { Module = 'PatternListen', props = {}, xy = { 200, 200 } },
  },
  connections = {
    { 1, 1, 2, 1 },
  },
  encoders = { {}, {}, {} },
}
