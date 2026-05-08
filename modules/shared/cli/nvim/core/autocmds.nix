{
  programs.nixvim.autoCmd = [
    {
      event = "InsertLeave";
      pattern = "*";
      command = "set nopaste";
    }
    {
      event = "FileType";
      pattern = [
        "json"
        "jsonc"
        "jsonl"
      ];
      callback.__raw = ''
        function()
          vim.wo.spell = false
          vim.wo.conceallevel = 0
        end
      '';
    }
    {
      event = "FileType";
      pattern = [
        "c"
        "cpp"
      ];
      callback.__raw = ''
        function()
          vim.bo.shiftwidth = 2
          vim.bo.tabstop = 2
          vim.bo.softtabstop = 2
        end
      '';
    }
  ];
}
