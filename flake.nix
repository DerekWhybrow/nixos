{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		mwpkgs = {
			url = "github:marcuswhybrow/mwpkgs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

  outputs = inputs: let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
		mwpkgs = inputs.mwpkgs.packages.x86_64-linux;
		lib = inputs.nixpkgs.lib;
	in {
		nixosConfigurations.del-nix = lib.nixosSystem {
			modules = [
        {
          # My additions
          nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
          nix.settings.trusted-users = ["del"];

          # Fonts

          # https://nixos.wiki/wiki/Fonts
          fonts.packages = with pkgs; [
            font-awesome

            (nerdfonts.override {
              fonts = [
                # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/data/fonts/nerdfonts/shas.nix
                "FiraCode"
                "FiraMono"
                "Terminus"
              ];
            })
          ];

          fonts.fontconfig.defaultFonts = {
            monospace = [ "FiraCode Nerd Font Mono" ];
          };
          
          # Set your time zone.
          time.timeZone = "Europe/London";

          # Select internationalisation properties.
          i18n.defaultLocale = "en_GB.UTF-8";

          i18n.extraLocaleSettings = {
            LC_ADDRESS = "en_GB.UTF-8";
            LC_IDENTIFICATION = "en_GB.UTF-8";
            LC_MEASUREMENT = "en_GB.UTF-8";
            LC_MONETARY = "en_GB.UTF-8";
            LC_NAME = "en_GB.UTF-8";
            LC_NUMERIC = "en_GB.UTF-8";
            LC_PAPER = "en_GB.UTF-8";
            LC_TELEPHONE = "en_GB.UTF-8";
            LC_TIME = "en_GB.UTF-8";
          };

          # Configure keymap in X11
          services.xserver = {
            enable = true;
            xkb = { 
              layout = "gb"; 
              variant = ""; 
            };
          };

          # Configure console keymap
          console.keyMap = "uk";

          programs = {
            fish.enable = true;
            hyprland.enable = true;
          };

          # Define a user account. Don't forget to set a password with ‘passwd’.
          users.users.del = {
            isNormalUser = true;
            description = "Derek Whybrow";
            shell = pkgs.fish;
            extraGroups = [
              "networkmanager" 
              "wheel" 
              "video"
              "audio"
            ];
            packages = [
              pkgs.htop # task manager
              pkgs.lsof # needed by htop
              pkgs.firefox 
              pkgs.gh # github cli (command line interface)
              pkgs.krita # photo editor
              pkgs.unzip # for zip files 
              pkgs.vlc # video player
              pkgs.discord # communications app
              mwpkgs.flake-updates # NixOS flake update analyser
              mwpkgs.hyprland # Window Manager 
              mwpkgs.hyprland-fish-auto-login
              mwpkgs.fish # Shell upgrade with better autocomplete
              mwpkgs.alacritty # GUI terminal
              mwpkgs.starship # shell prompt heads up display 
              mwpkgs.waybar # Window manager taskbar with widgets
              mwpkgs.rofi # app launcher
              mwpkgs.dunst # desktop notifications
              mwpkgs.logout # rofi menu for loging out + power off
              mwpkgs.networking # rofi menu for networking 
              mwpkgs.tmux # adds tabs in terminal (alacritty)
              mwpkgs.private # terminal without history
              mwpkgs.alarm # sends desktop notifications after a time
              mwpkgs.volume # helper util to make volume change easy
              mwpkgs.brightness # helper util for brightness
              mwpkgs.neovim # terminal text + code editor
            ];
          };

          # Enable automatic login for the user.
          # services.getty.autologinUser = "del";

          # List packages installed in system profile. To search, run:
          # $ nix search wget
          environment.systemPackages = [
            pkgs.light
            pkgs.direnv
            pkgs.nix-direnv
            pkgs.firefox
          ];
          services.udev.packages = [
            pkgs.light
          ];

          services.openssh.enable = true;

          # DANGER ZONE

          # Bootloader.
          boot.loader.grub.enable = true;
          boot.loader.grub.device = "/dev/sda";
          boot.loader.grub.useOSProber = true;

          networking.hostName = "del-nix";
          networking.wireless.enable = false;

          # Enable networking
          networking.networkmanager.enable = true;


          system.stateVersion = "23.11"; # Did you read the comment?

          boot.initrd.availableKernelModules = [
            "uhci_hcd" 
            "ehci_pci" 
            "ata_piix" 
            "ahci"
            "firewire_ohci"
            "usb_storage"
            "sd_mod"
            "sr_mod"
            "sdhci_pci"
          ];

          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ 
            "kvm-intel" 
          ];
          boot.extraModulePackages = [ ];

          fileSystems."/" = { 
            device = "/dev/disk/by-uuid/387b28dc-62a8-4ca4-8d2b-4537488729a0";
            fsType = "ext4";
          };

          swapDevices = [ 
            { device = "/dev/disk/by-uuid/c7f637b1-4b0d-4185-b705-78ec772b27da"; }
          ];

          networking.useDHCP = lib.mkDefault true;
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.enableRedistributableFirmware = true;
          hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
				}
			];
		};
	};
}
