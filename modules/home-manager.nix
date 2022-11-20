{ self, ... }@inputs:
{ options, config, lib, pkgs, ... }:
let
  cfg = config.programs.doom-emacs;

  inherit (lib)
    literalExample mkEnableOption mkIf mkMerge mkOption mkOptionType optional
    types optionalString concatStringsSep mapAttrsToList;
  inherit (builtins) elem;

  overlayType = lib.mkOptionType {
    name = "overlay";
    description = "Emacs packages overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };

  mkFlagsOption = example:
    mkOption {
      inherit example;
      type = with types; listOf (enum example);
      default = [ ];
      description = "Enabled flags.";
    };

  mkModuleOption = exampleEnable: exampleFlags: {
    enable = mkEnableOption exampleEnable;
    flags = mkFlagsOption exampleFlags;
  };

  writeConfigLine = name: value:
    optionalString value.enable
    "(${name} ${(concatStringsSep " " value.flags)})";

  writeConfigSection = set:
    concatStringsSep "\n" (mapAttrsToList writeConfigLine set);

in {
  options.programs.doom-emacs = {

    enable = mkEnableOption "Doom Emacs configuration";

    doomPrivateDir = mkOption {
      description = ''
        Path to your `.doom.d` directory.

        The specified directory should  contain yoour `init.el`, `config.el` and
        `packages.el` files.
      '';
      default = ".";
      apply = path:
        if lib.isStorePath path then path else builtins.path { inherit path; };
    };

    doomPackageDir = mkOption {
      description = ''
        A Doom configuration directory from which to build the Emacs package environment.

        Can be used, for instance, to prevent rebuilding the Emacs environment
        each time the `config.el` changes.

        Can be provided as a directory or derivation. If not given, package
        environment is built against `doomPrivateDir`.
      '';
      default = cfg.doomPrivateDir;
      apply = path:
        if lib.isStorePath path then path else builtins.path { inherit path; };
      example = literalExample ''
        doomPackageDir = pkgs.linkFarm "my-doom-packages" [
           # straight needs a (possibly empty) `config.el` file to build
           { name = "config.el"; path = pkgs.emptyFile; }
           { name = "init.el"; path = ./doom.d/init.el; }
           { name = "packages.el"; path = pkgs.writeText "(package! inheritenv)"; }
           { name = "modules"; path = ./my-doom-module; }
         ];
      '';
    };

    # Declarative Config
    doomInit = {
      enable = mkEnableOption "Enable declarative configuration";

      input = {
        chinese = mkModuleOption "Chinese support" [ ];
        japanese = mkModuleOption "Japanese support" [ ];
        layout =
          mkModuleOption "Different layouts support" [ "+azerty" "+bepo" ];
      };

      completion = {
        company = mkModuleOption "Company support" [ "+childframe" "+tng" ];
        helm =
          mkModuleOption "Helm support" [ "+fuzzy" "+childframe" "+icons" ];
        ido = mkModuleOption "Ido support" [ ];
        ivy = mkModuleOption "Ivy support" [
          "+fuzzy"
          "+prescient"
          "+childframe"
          "+icons"
        ];
        vertico = mkModuleOption "Vertico support" [ "+icons" ];
      };

      ui = {
        deft = mkModuleOption "Deft support" [ ];
        doom-dashboard = mkModuleOption "Doom-Dashboard support" [ ];
        doom-quit = mkModuleOption "Doom-Quit support" [ ];
        doom = mkModuleOption "Doom support" [ ];
        emoji = mkModuleOption "Emoji support" [ ];
        hl-todo = mkModuleOption "Hl-Todo support" [ ];
        hydra = mkModuleOption "Hydra support" [ ];
        indent-guides = mkModuleOption "Indent-Guides support" [ ];
        ligatures = mkModuleOption "Ligatures support" [
          "+extra"
          "+fira"
          "+hasklig"
          "+iosevka"
          "+pragmata-pro"
        ];
        minimap = mkModuleOption "Minimap support" [ ];
        modeline = mkModuleOption "Modeline support" [ "+light" ];
        nav-flash = mkModuleOption "Nav-Flash support" [ ];
        neotree = mkModuleOption "Neotree support" [ ];
        ophints = mkModuleOption "Ophints support" [ ];
        popup = mkModuleOption "Popup support" [ "+all" "+defaults" ];
        tabs = mkModuleOption "Tabs support" [ ];
        treemacs = mkModuleOption "Treemacs support" [ "+lsp" ];
        unicode = mkModuleOption "Unicode support" [ ];
        vc-gutter = mkModuleOption "Vc-Gutter support" [ ];
        vi-tilde-fringe = mkModuleOption "Vi-Tilde-Fringe support" [ ];
        window-select = mkModuleOption "Window-Select support" [
          "+switch-window"
          "+numbers"
        ];
        workspaces = mkModuleOption "Workspaces support" [ ];
        zen = mkModuleOption "Zen support" [ ];

      };

      editor = {
        evil = mkModuleOption "Evil support" [ "+everywhere" ];
        file-templates = mkModuleOption "File-Templates support" [ ];
        fold = mkModuleOption "Fold support" [ ];
        format = mkModuleOption "Format support" [ "+onsave" ];
        god = mkModuleOption "God support" [ ];
        lispy = mkModuleOption "Lispy support" [ ];
        multiple-cursors = mkModuleOption "Multiple-Cursors support" [ ];
        objed = mkModuleOption "Objed support" [ ];
        parinfer = mkModuleOption "Parinfer support" [ ];
        rotate-text = mkModuleOption "Rotate-Text support" [ ];
        snippets = mkModuleOption "Snippets support" [ ];
        word-wrap = mkModuleOption "Word-Wrap support" [ ];
      };

      emacs = {
        dired = mkModuleOption "Dired support" [ "+ranger" "+icons" ];
        electric = mkModuleOption "Electric support" [ ];
        ibuffer = mkModuleOption "Ibuffer support" [ "+icons" ];
        undo = mkModuleOption "Undo support" [ "+tree" ];
        vc = mkModuleOption "Vc support" [ ];
      };

      term = {
        eshell = mkModuleOption "Eshell support" [ ];
        shell = mkModuleOption "Shell support" [ ];
        term = mkModuleOption "Term support" [ ];
        vterm = mkModuleOption "Vterm support" [ ];
      };

      checkers = {
        grammar = mkModuleOption "Grammar support" [ ];
        spell = mkModuleOption "Spell support" [
          "+flyspell"
          "+aspell"
          "+hunspell"
          "+enchant"
          "+everywhere"
        ];
        syntax = mkModuleOption "Syntax support" [ "+childframe" ];
      };

      tools = {
        ansible = mkModuleOption "Ansible support" [ ];
        biblio = mkModuleOption "Biblio support" [ ];
        debugger = mkModuleOption "Debugger support" [ ];
        direnv = mkModuleOption "Direnv support" [ ];
        docker = mkModuleOption "Docker support" [ "+lsp" ];
        editorconfig = mkModuleOption "Editorconfig support" [ ];
        ein = mkModuleOption "Ein support" [ ];
        eval = mkModuleOption "Eval support" [ "+overlay" ];
        gist = mkModuleOption "Gist support" [ ];
        lookup = mkModuleOption "Lookup support" [
          "+dictionary"
          "+offline"
          "+docsets"
        ];
        lsp = mkModuleOption "Lsp support" [ "+peek" "+eglot" ];
        magit = mkModuleOption "Magit support" [ "+forge" ];
        make = mkModuleOption "Make support" [ ];
        pass = mkModuleOption "Pass support" [ "+auth" ];
        pdf = mkModuleOption "Pdf support" [ ];
        prodigy = mkModuleOption "Prodigy support" [ ];
        rgb = mkModuleOption "Rgb support" [ ];
        taskrunner = mkModuleOption "Taskrunner support" [ ];
        terraform = mkModuleOption "Terraform support" [ ];
        tmux = mkModuleOption "Tmux support" [ ];
        upload = mkModuleOption "Upload support" [ ];
      };

      os = {
        macos = mkModuleOption "Macos support" [ ];
        tty = mkModuleOption "Tty support" [ "+osc" ];
      };

      lang = {
        agda = mkModuleOption "Agda support" [ ];
        beancount = mkModuleOption "Beancount support" [ "+lsp" ];
        cc = mkModuleOption "C/C++ support" [ "+lsp" ];
        clojure = mkModuleOption "Clojure support" [ "+lsp" ];
        common-lisp = mkModuleOption "Common-Lisp support" [ ];
        coq = mkModuleOption "Coq support" [ ];
        crystal = mkModuleOption "Crystal support" [ ];
        csharp = mkModuleOption "C# support" [ "+lsp" "+unity" "+dotnet" ];
        dart = mkModuleOption "Dart support" [ "+lsp" "+flutter" ];
        data = mkModuleOption "Data support" [ ];
        dhall = mkModuleOption "Dhall support" [ ];
        elixir = mkModuleOption "Elixir support" [ "+lsp" ];
        elm = mkModuleOption "Elm support" [ ];
        emacs-lisp = mkModuleOption "Emacs-lisp support" [ ];
        erlang = mkModuleOption "Erlang support" [ "+lsp" ];
        ess = mkModuleOption "Ess support" [ "+lsp" ];
        factor = mkModuleOption "Factor support" [ ];
        faust = mkModuleOption "Faust support" [ ];
        fortran = mkModuleOption "Fortran support" [ "+lsp" ];
        fsharp = mkModuleOption "F# support" [ "+lsp" ];
        fstar = mkModuleOption "Fstar support" [ ];
        gdscript = mkModuleOption "GDScript support" [ "+lsp" ];
        go = mkModuleOption "Go support" [ "+lsp" ];
        haskell = mkModuleOption "Haskell support" [ "+lsp" ];
        hy = mkModuleOption "Hy support" [ ];
        idris = mkModuleOption "Idris support" [ ];
        java = mkModuleOption "Java support" [ "+lsp" "+meghanada" ];
        javascript = mkModuleOption "Javascript support" [ "+lsp" ];
        json = mkModuleOption "Json support" [ "+lsp" ];
        julia = mkModuleOption "Julia support" [ "+lsp" ];
        kotlin = mkModuleOption "Kotlin support" [ "+lsp" ];
        latex = mkModuleOption "LaTeX support" [
          "+latexmk"
          "+cdlatex"
          "+lsp"
          "+fold"
        ];
        lean = mkModuleOption "Lean support" [ ];
        ledger = mkModuleOption "Ledger support" [ ];
        lua = mkModuleOption "Lua support" [ "+moonscript" "+fennel" "+lsp" ];
        markdown = mkModuleOption "Markdown support" [ "+grip" ];
        nim = mkModuleOption "Nim support" [ ];
        nix = mkModuleOption "Nix support" [ "+tree-sitter" ];
        ocaml = mkModuleOption "Ocaml support" [ ];
        org = mkModuleOption "Org support" [
          "+brain"
          "+dragndrop"
          "+gnuplot"
          "+hugo"
          "+journal"
          "+jupiter"
          "+noter"
          "+pandoc"
          "+pomodoro"
          "+present"
          "+pretty"
          "+roam"
          "+roam2"
        ];
        php = mkModuleOption "Php support" [ "+hack" "+lsp" ];
        plantum = mkModuleOption "Plantum support" [ ];
        purescript = mkModuleOption "Purescript support" [ ];
        python = mkModuleOption "Python support" [
          "+lsp"
          "+pyright"
          "+pyenv"
          "+conda"
          "+poetry"
          "+cython"
        ];
        qt = mkModuleOption "Qt support" [ ];
        racket = mkModuleOption "Racket support" [ "+lsp" "+xp" ];
        raku = mkModuleOption "Raku support" [ ];
        rest = mkModuleOption "Rest support" [ ];
        rst = mkModuleOption "Rst support" [ ];
        ruby = mkModuleOption "Ruby support" [
          "+lsp"
          "+rvm"
          "+rbenv"
          "+chruby"
          "+rails"
        ];
        rust = mkModuleOption "Rust support" [ "+lsp" ];
        scala = mkModuleOption "Scala support" [ "+lsp" "+tree-sitter" ];
        scheme = mkModuleOption "Scheme support" [
          "+chez"
          "+chibi"
          "+chicken"
          "+gambit"
          "+gauche"
          "+guile"
          "+kawa"
          "+mit"
          "+racket"
        ];
        sh = mkModuleOption "Sh support" [
          "+lsp"
          "+fish"
          "+powershell"
          "+tree-sitter"
        ];
        sml = mkModuleOption "Sml support" [ ];
        solidity = mkModuleOption "Solidity support" [ ];
        swift = mkModuleOption "Swift support" [ "+lsp" "+tree-sitter" ];
        terra = mkModuleOption "Terra support" [ ];
        web = mkModuleOption "Web support" [ "+lsp" "+tree-sitter" ];
        yaml = mkModuleOption "Yaml support" [ "+lsp" ];
        zig = mkModuleOption "Zig support" [ "+lsp" "+tree-sitter" ];
      };

      email = {
        mu4e = mkModuleOption "Mu4e support" [ "+gmail" "+org" ];
        notmuch = mkModuleOption "Notmuch support" [ "+org" "+afew" ];
        wanderlust = mkModuleOption "Wanderlust support" [ ];
      };

      app = {
        calendar = mkModuleOption "Calendar support" [ ];
        emms = mkModuleOption "Emms support" [ ];
        everywhere = mkModuleOption "Everywhere support" [ ];
        irc = mkModuleOption "Irc support" [ ];
        rss = mkModuleOption "Rss support" [ "+org" ];
        twitter = mkModuleOption "Twitter support" [ ];
      };

      config = {
        default =
          mkModuleOption "Default support" [ "+bindings" "+smartparens" ];
        literate = mkModuleOption "Literate support" [ ];
      };
    };

    doomConfig = mkOption {
      description = ''
        Use this option to populate your config.el. This will not let you use your own config.el file.
        This option requires cfg.doomInit.enable = true in order to do something.
      '';
      type = with types; lines;
      default = "";
      example = literalExample ''
        (setq! user-full-name "MyBeautifulName")
      '';
    };

    doomPackages = mkOption {
      description = ''
        Use this option to populate your packages.el. This will not let you use your own packages.el file.
        This option requires cfg.doomInit.enable = true in order to do something.
      '';
      type = with types; lines;
      default = "";
      example = literalExample ''
        (package! org-super-agenda)
      '';
    };

    extraConfig = mkOption {
      description = ''
        Extra configuration options to pass to doom-emacs.

        Elisp code set here will be appended at the end of `config.el`. This
        option is useful for refering `nixpkgs` derivation in Emacs without the
        need to install them globally.
      '';
      type = with types; lines;
      default = "";
      example = literalExample ''
        (setq mu4e-mu-binary = "''${pkgs.mu}/bin/mu")
      '';
    };

    extraPackages = mkOption {
      description = ''
        Extra packages to install.

        List addition non-emacs packages here that ship elisp emacs bindings.
      '';
      type = with types; listOf package;
      default = [ ];
      example = literalExample "[ pkgs.mu ]";
    };

    emacsPackage = mkOption {
      description = ''
        Emacs package to use.

        Override this if you want to use a custom emacs derivation to base
        `doom-emacs` on.
      '';
      type = with types; package;
      default = pkgs.emacs;
      example = literalExample "pkgs.emacs";
    };

    emacsPackagesOverlay = mkOption {
      description = ''
        Overlay to customize emacs (elisp) dependencies.

        As inputs are gathered dynamically, this is the only way to hook into
        package customization.
      '';
      type = with types; overlayType;
      default = final: prev: { };
      defaultText = "final: prev: { }";
      example = literalExample ''
        final: prev: {
          magit-delta = super.magit-delta.overrideAttrs (esuper: {
            buildInputs = esuper.buildInputs ++ [ pkgs.git ];
          });
        };
      '';
    };

    package = mkOption { internal = true; };
  };

  config = mkIf cfg.enable (let
    doomInitTxt = ''
      (doom! :input
             ${writeConfigSection cfg.doomInit.input}

             :completion
             ${writeConfigSection cfg.doomInit.completion}

             :ui
             ${writeConfigSection cfg.doomInit.ui}

             :editor
             ${writeConfigSection cfg.doomInit.editor}

             :emacs
             ${writeConfigSection cfg.doomInit.emacs}

             :term
             ${writeConfigSection cfg.doomInit.term}

             :checkers
             ${writeConfigSection cfg.doomInit.checkers}

             :tools
             ${writeConfigSection cfg.doomInit.tools}

             :os
             ${writeConfigSection cfg.doomInit.os}

             :lang
             ${writeConfigSection cfg.doomInit.lang}

             :email
             ${writeConfigSection cfg.doomInit.email}

             :app
             ${writeConfigSection cfg.doomInit.app}

             :config
             ${writeConfigSection cfg.doomInit.config}
      )
    '';
    doomInitFile = pkgs.writeTextDir "doom/init.el" doomInitTxt;
    doomConfFile = pkgs.writeTextDir "doom/config.el" cfg.doomConfig;
    doomPkgsFile = pkgs.writeTextDir "doom/packages.el" cfg.doomPackages;
    doomDir = pkgs.runCommand "doom-emacs-dir" { } ''
      mkdir -p $out
      cp ${doomInitFile}/doom/init.el $out/init.el
      cp ${doomConfFile}/doom/config.el $out/config.el
      cp ${doomPkgsFile}/doom/packages.el $out/packages.el
    '';
    emacs = pkgs.callPackage self {
      extraPackages = (epkgs: cfg.extraPackages);
      emacsPackages = pkgs.emacsPackagesFor cfg.emacsPackage;
      doomPrivateDir =
        if cfg.doomInit.enable then doomDir else cfg.doomPrivateDir;
      doomPackageDir =
        if cfg.doomInit.enable then doomDir else cfg.doomPackageDir;
      inherit (cfg) extraConfig emacsPackagesOverlay;
      dependencyOverrides = inputs;
    };
  in mkMerge ([

    # MAIN PART
    {
      # TODO: remove once Emacs 29+ is released and commonly available
      home.file.".emacs.d/init.el".text = ''
        (load "default.el")
      '';

      home.packages = with pkgs; [ emacs-all-the-icons-fonts ];
      programs.emacs.package = emacs;
      programs.emacs.enable = true;
      programs.doom-emacs.package = emacs;
    }

    # WARNINGS
    (mkIf
      (cfg.doomInit.enable && cfg.doomConfig == "" && cfg.extraConfig == "") {
        warnings = [''
          Warning:
          - cfg.doomInit.enable is set to true.
          - cfg.doomConfig is an empty string.
          - cfg.extraConfig is an empty string.
          > This will create an empty config.el file.
        ''];
      })
    (mkIf
      (cfg.doomInit.enable && cfg.doomConfig == "" && cfg.extraConfig != "") {
        warnings = [''
          Warning:
          - cfg.doomInit.enable is set to true.
          - cfg.doomConfig is an empty string.
          > Only the content inside cfg.extraConfig will be used to create the config.el file.
        ''];
      })
    (mkIf (cfg.doomInit.enable && cfg.doomPackages == "") {
      warnings = [''
        Warning:
        - cfg.doomInit.enable is set to true.
        - cfg.doomPackages is an empty string.
          > This will create an empty packages.el file.
      ''];
    })
    (mkIf (!cfg.doomInit.enable && cfg.doomPrivateDir == "."
      && cfg.doomPackageDir == ".") {
        warnings = [''
          Warning:
          - cfg.doomInit.enable is set to false.
          - cfg.doomPrivateDir is set to the default value.
          - cfg.doomPrivateDir is set to the default value.
          > This will probably produce unwanted behaviour.
        ''];
      })

    ### DEPENDENCIES

    #########
    #       #
    # INPUT #
    #       #
    #########

    ## CHINESE
    ###

    ## JAPANESE
    ###

    ## LAYOUT
    ###

    ##############
    #            #
    # COMPLETION #
    #            #
    ##############

    ## COMPANY
    ###

    ## HELM
    ###

    ## IDO
    ###

    ## IVY
    ###

    ## VERTICO
    ###

    #########
    # TERMS #
    #########

    ## ESHELL
    ###

    ## SHELL
    ###

    ## TERM
    ###

    ## VTERM
    (mkIf (cfg.doomInit.term.vterm.enable) {
      programs.emacs.extraPackages = epkgs: [ epkgs.vterm ];
      home.packages = with pkgs; [ libvterm gcc gnumake cmake libtool ];
    })
    ###

    #########
    # LANGS #
    #########

    ## CC
    (mkIf (cfg.doomInit.lang.cc.enable) {
      home.packages = with pkgs; [ ccls cmake gcc glslang ];
    })
    ###

    ## CSHARP
    (mkIf (cfg.doomInit.lang.csharp.enable) {
      home.packages = with pkgs; [ omnisharp-roslyn mono ];
    })
    ###

    ## EMACS-LISP
    (mkIf (cfg.doomInit.lang.emacs-lisp.enable) { })
    ###

    ## GDSCRIPT
    (mkIf (cfg.doomInit.lang.gdscript.enable) {
      home.packages = with pkgs; [ godot python3Packages.gdtoolkit ];
    })
    ###

    ## GO
    (mkIf (cfg.doomInit.lang.go.enable) {
      home.packages = with pkgs; [
        go
        gopls
        gocode
        # godoc
        # gorename
        gore
        # guru
        # goimports
        gotests
        gomodfytags
      ];
    })
    ###

    ## HASKELL
    (mkIf (cfg.doomInit.lang.haskell.enable) {
      home.packages = with pkgs; [
        ghc
        haskellPackages.hls
        stack
        haskellPackages.hoogle
        hlint
        ormolu
      ];
    })
    ###

    ## JAVA
    (mkIf (cfg.doomInit.lang.java.enable) {
      home.packages = with pkgs; [ jdk ];
    })
    ###

    ## JAVASCRIPT
    (mkIf (cfg.doomInit.lang.javascript.enable) {
      home.packages = with pkgs; [
        nodejs
        yarn
        nodePackages.typescript-language-server # maybe?
      ];
    })
    ###

    ## JSON
    (mkIf (cfg.doomInit.lang.json.enable) { })
    ###

    ## JULIA
    (mkIf (cfg.doomInit.lang.julia.enable) {
      home.packages = with pkgs; [ julia ];
    })
    ###

    ## KOTLIN
    (mkIf (cfg.doomInit.lang.kotlin.enable) {
      home.packages = with pkgs; [ kotlin ];
    })
    ###

    ## LATEX
    (mkIf (cfg.doomInit.lang.latex.enable) {
      home.packages = with pkgs; [ texlive.combined.scheme-full ];
    })
    ###

    ## MARKDOWN
    (mkIf (cfg.doomInit.lang.markdown.enable) {
      home.packages = with pkgs; [ mdl pandoc ];
    })
    ###

    ## LUA
    (mkIf (cfg.doomInit.lang.lua.enable) {
      home.packages = with pkgs; [ lua sumneko-lua-language-server ];
    })
    ###

    ## NIX
    (mkIf (cfg.doomInit.lang.nix.enable) {
      home.packages = with pkgs;
        let checkFlag = flag: elem flag cfg.doomInit.lang.nix.flags;
        in [
          (mkIf (cfg.doomInit.editor.format.enable) nixfmt)
          # (mkIf (cfg.doomInit.editor.format.enable) nixpkgs-fmt)
        ];
    })

    ## OCAML
    (mkIf (cfg.doomInit.lang.ocaml.enable) {
      home.packages = with pkgs; [
        ocaml
        opam
        ocamlPackages.merlin
        ocamlPackages.utop
        ocamlPackages.ocp-indent
        dune_2
        ocamlformat
      ];
    })
    ###

    ## ORG
    (mkIf (cfg.doomInit.lang.org.enable) {
      home.packages = with pkgs; [
        texlive.combined.scheme-medium # Should it be full?
        (mkIf (elem "+gnuplot" cfg.doomInit.lang.org.flags) gnuplot)
        (mkIf ((elem "+roam2" cfg.doomInit.lang.org.flags)
          || (elem "+roam" cfg.doomInit.lang.org.flags) sqlite))
        (mkIf (elem "+jupiter" cfg.doomInit.lang.org.flags) python3.withPackages
          (ps: with ps; [ jupyter ]))
      ];
    })
    ###

    ## PYTHON
    (mkIf (cfg.doomInit.lang.python.enable) {
      home.packages = with pkgs; [
        python3Full
        python3Packages.pytest
        python3Packages.nose
        python3Packages.black
        python3Packages.flakes
        python3Packages.isort
        conda
        poetry
        pipenv
        python39Packages.cython
        nodePackages.pyright
        python3Packages.setuptools
      ];
    })
    ###

    ## RACKET
    (mkIf (cfg.doomInit.lang.racket.enable) {
      home.packages = with pkgs; [ racket ];
    })
    ###

    ## RUBY
    (mkIf (cfg.doomInit.lang.ruby.enable) {
      home.packages = with pkgs; [ ruby rubocop ];
    })
    ###

    ## RUST
    (mkIf (cfg.doomInit.lang.rust.enable) {
      home.packages = with pkgs;
        let checkFlag = flag: elem flag cfg.doomInit.lang.rust.flags;
        in [
          rustc
          cargo
          rustracer
          (mkIf (checkFlag "+lsp") rust-analyzer)
          (mkIf cfg.doomInit.editor.format.enable rustfmt)
          # carco-check
          # rustup component add clippy-preview
        ];
    })

    ## SCALA
    (mkIf (cfg.doomInit.lang.scala.enable) {
      home.packages = with pkgs;
        let checkFlag = flag: elem flag cfg.doomInit.lang.scala.flags;
        in [ scala sbt (mkIf (checkflag "+lsp") metals) ];
    })

    ## SCHEME
    (mkIf (cfg.doomInit.lang.scheme.enable) {
      home.packages = with pkgs;
        let checkFlag = flag: elem flag cfg.doomInit.lang.scheme.flags;
        in [
          (mkIf (checkflag "+chez") chez)
          (mkIf (checkflag "+chibi") chibi)
          (mkIf (checkflag "+chicken") chicken)
          (mkIf (checkflag "+gambit") gambit)
          (mkIf (checkflag "+gauche") gauche)
          (mkIf (checkflag "+guile") guile)
          (mkIf (checkflag "+mit") mitscheme)
        ];
    })
    (mkIf (cfg.doomInit.lang.scheme.enable
      && (elem "+racket" cfg.doomInit.lang.scheme.flags)) {
        programs.doom-emacs.doomInit.lang.racket.enable = true;
      })

    ## SH
    (mkIf (cfg.doomInit.lang.sh.enable) {
      home.packages = with pkgs; [
        shellcheck
        (mkIf (elem "+lsp" cfg.doomInit.lang.sh.flags)
          nodePackages.bash-language-server)
        (mkIf (cfg.doomInit.tools.debugger.enable) bashdb)
        # zshdb
      ];
    })

    ## SML
    (mkIf (cfg.doomInit.lang.sml.enable) {
      home.packages = with pkgs; [ mosml mlton ];
    })

    ## SOLIDITY
    (mkIf (cfg.doomInit.lang.solidity.enable) {
      home.packages = with pkgs; [ solc ];
    })

    ## SWIFT
    (mkIf (cfg.doomInit.lang.swift.enable) {
      home.packages = with pkgs; [ swift ];
    })

    ## TERRA
    (mkIf (cfg.doomInit.lang.terra.enable) {
      home.packages = with pkgs; [ terra ];
    })

    ## WEB
    (mkIf (cfg.doomInit.lang.web.enable) { })

    ## YAML
    (mkIf (cfg.doomInit.lang.yaml.enable) {
      home.packages = with pkgs;
        [
          (mkIf (elem "+lsp" cfg.doomInit.lang.yaml.flags)
            nodePackages.yaml-language-server)
        ];
    })

    ## ZIG
    (mkIf (cfg.doomInit.lang.zig.enable) {
      home.packages = with pkgs; [
        zig
        (mkIf (elem "+lsp" cfg.doomInit.lang.zig.flags) zls)
      ];
    })

    #########
    # EMAIL #
    #########

    ## MU4E
    (mkIf (cfg.doomInit.email.mu4e.enable) {
      programs.mu.enable = true;
      services.mbsync.enable = true;
    })

    ## NOTMUCH
    (mkIf (cfg.doomInit.email.notmuch.enable) {
      home.packages = with pkgs; [ notmuch ];
      programs.lieer.enable = true;
      # Notmuch can be installed using accounts.email.accounts.<name>.notmuch.enable. Can/Should we use it?
    })
    (mkIf (cfg.doomInit.email.notmuch.enable
      && (elem "+afew" cfg.doomInit.email.notmuch.flags)) {
        programs.afew.enable = true;
      })

    ## WANDERLUST
    (mkIf (cfg.doomInit.email.wanderlust.enable) { })

    #########
    # TOOLS #
    #########

    ## DIRENV
    (mkIf (cfg.doomInit.tools.direnv.enable) { programs.direnv.enable = true; })
  ]
  # this option is not available on darwin platform.
    ++ optional (options.services ? emacs) {
      # Set the service's package but don't enable. Leave that up to the user
      services.emacs.package = emacs;
    }));
}
