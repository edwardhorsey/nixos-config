{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      ll = "ls -la";
      localip = "ip -o addr show scope global | awk '{split($4, a, \"/\"); printf \"%-14s %s\\n\", $2, a[1]}'";
      publicip = "echo -n 'v4: '; curl -4 -s ifconfig.co; echo -n 'v6: '; curl -6 -s ifconfig.co || echo unavailable";
      gp = "git pull";
      gs = "git status";
    };
    promptInit = ''
      PROMPT="%F{blue}%n%f@%F{blue}%m%f %F{cyan}%~%f "
      PROMPT+="%(?.%(!.%F{white}❯%F{yellow}❯%F{red}.%F{blue}❯%F{cyan}❯%F{green})❯.%F{red}❯❯❯)%f "
      RPROMPT=""
    '';
    shellInit = ''
      # Disable zsh's newuser startup script that prompts you to create
      # a ~/.z* file if missing
      zsh-newuser-install() { :; }
    '';
  };

  users.defaultUserShell = pkgs.zsh;
}
