return {
  {
    'azratul/live-share.nvim',
    cmd = { 'LiveShareHostStart', 'LiveShareJoin', 'LiveShareServer' },
    opts = {
      username = 'tosshy',
      port = 80,
      transport = 'ws',
    },
  },
}
