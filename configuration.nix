{ lib, pkgs, config, modulesPath, ... }:

{
  imports = [
    ./nix.nix
    ./cachix.nix
    "${modulesPath}/profiles/minimal.nix"
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    nativeSystemd = true;
    defaultUser = "haneta";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "23.11";
  #nix.settings.system-features = [ "benchmark" "big-parallel" "kvm" "nixos-test" "gccarch-tigerlake" ];
  #nixpkgs.localSystem = {
  #  gcc.arch = "tigerlake";
  #  gcc.tune = "tigerlake";
  #  system = "x86_64-linux";
  #};

  networking.hostName = "waltraute";
  environment.noXlibs = false;
  environment.shells = with pkgs; [ bash zsh ];
  environment.systemPackages = with pkgs; [
    cachix
    bash
    nodePackages.bash-language-server
    file
    vim
    wget
    socat
    samba
    gcc
    rustc
    cargo
    rust-analyzer
    rustfmt
    ghc
    cabal-install
    haskell-language-server
    dotnet-runtime
    dotnet-sdk
    fsautocomplete
    (python3.withPackages(ps: with ps; [ epc orjson sexpdata six paramiko rapidfuzz ]))
  ];
  environment.sessionVariables = {
    LSP_USE_PLISTS = "true";
    SSH_AUTH_SOCK = ''$XDG_RUNTIME_DIR/ssh-agent.sock'';
    DOTNET_ROOT = "${pkgs.dotnet-sdk}";
  };
  programs.zsh = {
    enable = true;
  };
  users.users.haneta = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  home-manager.users.haneta = {
    home.stateVersion = "23.11";
    home.sessionPath = [
      "$HOME/.local/bin"
    ];
    home.packages = [
      pkgs.source-han-code-jp
      pkgs.fzf
      pkgs.zsh
      pkgs.zsh-completions
      pkgs.zsh-fzf-tab
      pkgs.zsh-fzf-history-search
      pkgs.deer
      pkgs.zsh-fast-syntax-highlighting
    ];
    programs.zsh = {
      enable = true;
      defaultKeymap = "emacs";
      enableCompletion = true;
      enableAutosuggestions = true;
      enableVteIntegration = false;
      syntaxHighlighting.enable = false;
      historySubstringSearch.enable = true;
      autocd = true;
      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
        {
          name = "zsh-fzf-history-search";
          src = "${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search";
        }
        {
          name = "deer";
          src = "${pkgs.deer}/share/zsh/site-functions";
        }
        {
          name = "fast-syntax-highlighting";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
      ];
      initExtra = ''
      functiom em() {
        emacs "$@" 1>/dev/null 2>&1 &
      }

      autoload -U deer
      zle -N deer
      bindkey '\ek' deer
      export WINDOWSHOST=$(ip route | grep 'default via' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
      ss -a | grep -q $SSH_AUTH_SOCK
      if [ $? -ne 0 ]; then
      rm -f $SSH_AUTH_SOCK
      ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
      fi
      '';
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$username$hostname$directory$git_branch$git_status$fill\n$os$shell$character[>](bold cyan) ";
        right_format = "$cmd_duration";
        continuation_prompt = "[>>](bold cyan)";
        fill = {
          symbol = "-";
          style = "bold green";
        };
        character = {
          success_symbol = "\\[[O](bold green)\\]";
          error_symbol = "\\[[x](bold red)\\]";
          vimcmd_symbol = "\\[[V](bold green)\\]";
        };
        directory = {
          format = "\\[[$path]($style)[$read_only]($read_only_style)\\] ";
        };
        cmd_duration = {
          min_time = 500;
          format = "[$duration](bold yellow)";
        };
        username = {
          style_user = "green bold";
          style_root = "black bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = true;
        };
      
        hostname = {
          ssh_only = false;
          format = "[$ssh_symbol](bold blue) @ [$hostname](bold red) ";
          trim_at = ".companyname.com";
          disabled = false;
        };
      
        os = {
          format = "[($type )]($style)";
          style = "bold blue";
          disabled = false;
        };
        shell = {
          zsh_indicator = "zsh";
          bash_indicator = "bash";
          powershell_indicator = "pwsh";
          unknown_indicator = "mystery shell";
          style = "cyan bold";
          disabled = false;
        };
      };
    };
    programs.git = {
      enable = true;
      userName = "Shota Arakaki";
      userEmail = "syotaa1@gmail.com";
    };
    programs.emacs = {
      enable = true;
      package = (pkgs.emacsWithPackagesFromUsePackage {
        package = pkgs.emacs-pgtk;
        config = ./init.el;
        extraEmacsPackages = epkgs: with epkgs; [
          use-package
          leaf
          treesit-grammars.with-all-grammars
        ];
      });
    };
    programs.home-manager.enable = true;
  };
}
