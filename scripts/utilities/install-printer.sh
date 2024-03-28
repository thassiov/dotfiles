# Install the HP printer
# [https://unix.stackexchange.com/a/392629/10333]
# "hp-scan is the 'HPLIP Scan Utility'. If you need that tool, you will need to install `python-pillow`."
# [https://wiki.archlinux.org/index.php/SANE/Scanner-specific_problems#HP]

# install needed utilities
yay -S cups hplip python-pillow system-config-printer

sudo systemctl start org.cups.cupsd
sudo systemctl enable org.cups.cupsd

sudo hp-setup -i
