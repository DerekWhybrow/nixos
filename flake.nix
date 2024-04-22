{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		mwpkgs = {
			url = "github:marcuswhybrow/mwpkgs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
	outputs = inputs: let
		pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
		lib = inputs.nixpkgs.lib;
	in {
		nixosConfigurations.del-nix = lib.nixosSystem {
			modules = [
				{
					  # My additions
					  nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
					  nix.settings.trusted-users = ["del"];
					  
					  # Bootloader.
					  boot.loader.grub.enable = true;
					  boot.loader.grub.device = "/dev/sda";
					  boot.loader.grub.useOSProber = true;

					  networking.hostName = "del-nix";
					  networking.wireless.enable = false;

					  # Enable networking
					  networking.networkmanager.enable = true;

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
					    displayManager.gdm.enable = true;
					    desktopManager.gnome.enable = true;
					    autorun = true;

					    xkb = {
						layout = "gb";
					    	variant = "";
						};
					  };

					  #Configure Hyprland for login not by command line
					  #services.xserver = {
					    #enable = true;
					    #displayManager.sddm.enable = true;
					    #displayManager.sddm.wayland.enable = true;
					    #displayManager.sddm.theme = "where_is_my_sddm_theme";
#
					  #};

					  # Configure console keymap
					  console.keyMap = "uk";

					  # Define a user account. Don't forget to set a password with ‘passwd’.
					  users.users.del = {
					    isNormalUser = true;
					    description = "Derek Whybrow";
					    extraGroups = [ "networkmanager" "wheel" ];
					    packages = with pkgs; [];
					  };

					  # Enable automatic login for the user.
					  # services.getty.autologinUser = "del";

					  # Allow unfree packages
					  nixpkgs.config.allowUnfree = true;

					  # List packages installed in system profile. To search, run:
					  # $ nix search wget
					  environment.systemPackages = with pkgs; [
						  pkgs.firefox
					  ];

					  services.openssh.enable = true;


					  # DANGER ZONE

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
