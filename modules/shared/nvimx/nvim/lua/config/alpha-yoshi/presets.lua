local paths = require('config.paths')

---@type AlphaYoshiPreset[]
return {
  {
    weight = 1,
    frame_dir = paths.asset('frames/yoshi-walk-rainbow'),
    frame_prefix = 'yoshi-walk-rainbow-',
    frame_count = 14,
    frame_delay_ms = 100,
    image_cols = 34,
    image_rows = 16,
    colors = {
      '#ff5fa2',
      '#d050d8',
      '#9a3fd6',
      '#3a3ad6',
      '#3a8af0',
      '#3fd0d8',
      '#1fb39a',
      '#2fc44a',
      '#7ad84a',
      '#e0d83a',
      '#f0c83a',
      '#f0a830',
      '#f07a20',
      '#e83a2a',
    },
  },
  {
    weight = 9,
    frame_dir = paths.asset('frames/yoshi-walk-normal'),
    frame_prefix = 'yoshi-walk-normal-',
    frame_count = 8,
    frame_delay_ms = 120,
    image_cols = 40,
    image_rows = 14,
    colors = {
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
      '#7ad84a',
    },
  },
}
