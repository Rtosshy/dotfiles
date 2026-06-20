_: {
  home.file = {
    ".claude/skills/design-coach/SKILL.md".source = ../skills/design-coach/SKILL.md;
    ".claude/skills/review-coach/SKILL.md".source = ../skills/review-coach/SKILL.md;
    ".claude/skills/debug-coach/SKILL.md".source = ../skills/debug-coach/SKILL.md;
    ".claude/skills/scope-coach/SKILL.md".source = ../skills/scope-coach/SKILL.md;
    ".claude/skills/growth-L1/SKILL.md".source = ../skills/growth-L1/SKILL.md;
    ".claude/skills/growth-L2/SKILL.md".source = ../skills/growth-L2/SKILL.md;
    ".claude/skills/growth-L3/SKILL.md".source = ../skills/growth-L3/SKILL.md;

    # writing-knowledge は複数ファイル構成(reference/templates/checklists)。
    # ディレクトリごと recursive 配置する(Claude Code は symlink を辿る)。
    ".claude/skills/writing-knowledge" = {
      source = ../skills/writing-knowledge;
      recursive = true;
    };
  };
}
