{ lib, ... }:
let
  installSkill = name: src: ''
    $DRY_RUN_CMD rm -f $HOME/.codex/skills/${name}/SKILL.md
    $DRY_RUN_CMD install -Dm644 ${src} $HOME/.codex/skills/${name}/SKILL.md
  '';
in
{
  # Codex CLI 0.128.0 does not follow symlinks during skill discovery,
  # so we materialize SKILL.md as real files via activation instead of
  # using home.file (which would create symlinks to /nix/store).
  home.activation.materializeCodexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings [
      (installSkill "design-coach" ../skills/design-coach/SKILL.md)
      (installSkill "review-coach" ../skills/review-coach/SKILL.md)
      (installSkill "debug-coach" ../skills/debug-coach/SKILL.md)
      (installSkill "scope-coach" ../skills/scope-coach/SKILL.md)
      (installSkill "growth-L1" ../skills/growth-L1/SKILL.md)
      (installSkill "growth-L2" ../skills/growth-L2/SKILL.md)
      (installSkill "growth-L3" ../skills/growth-L3/SKILL.md)
    ]
  );
}
