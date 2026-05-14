{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      hlsearch = false;
      number = true;
      relativenumber = true;
      mouse = "a";
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      backup = false;
      writebackup = false;
      termguicolors = true;
      winblend = 0;
      pumblend = 0;
      whichwrap = "bs<>[]hl";
      wrap = false;
      linebreak = true;
      list = true;
      listchars = {
        tab = ">>=";
        trail = "-";
        eol = "↵";
      };
      scrolloff = 4;
      sidescrolloff = 8;
      numberwidth = 4;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      cursorline = false;
      splitbelow = true;
      splitright = true;
      swapfile = false;
      smartindent = true;
      showmode = false;
      showtabline = 2;
      backspace = "indent,eol,start";
      pumheight = 10;
      conceallevel = 0;
      fileencoding = "utf-8";
      cmdheight = 1;
      autoindent = true;
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
    };

    extraConfigLuaPre = ''
      vim.opt.shortmess:append("c")
      vim.opt.iskeyword:append("-")
      vim.opt.formatoptions:remove({ "c", "r", "o" })
      vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")
      vim.cmd([[let &t_Cs = "\e[4:3m"]])
      vim.cmd([[let &t_Ce = "\e[4:0m"]])
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
    '';
  };
}
