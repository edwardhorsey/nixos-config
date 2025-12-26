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
      localip = "ip -4 addr show | awk '/inet / {print $2}' | cut -d/ -f1";
      publicip = "curl ifconfig.co/json";
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
