{ lib
, runCommandNoCC
, fetchFromGitLab
}:

let
  pinenote-firmware = fetchFromGitLab {
    owner = "calebccff";
    repo = "firmware-pine64-pinenote";
    rev = "6676e4cabf5f68062da86ef528ac033507f02529";
    hash = "sha256-Kza3buPUyLUeVjcJnTYlaZTJm523dToFhi5dWTGtuCE=";
  };
in

# The minimum set of firmware files required for the device.
runCommandNoCC "pine64-pinenote-firmware" {} ''
  (PS4=" $ "; set -x
  install -Dm644 ${pinenote-firmware}/waveform.bin "$out"/lib/firmware/rockchip/ebc.wbf
  install -Dm644 ${pinenote-firmware}/brcm/BCM4345C0_cy.hcd "$out"/lib/firmware/brcm/BCM4345C0_cy.hcd
  install -Dm644 ${pinenote-firmware}/brcm/BCM4345C0.hcd "$out"/lib/firmware/brcm/BCM4345C0.hcd
  install -Dm644 ${pinenote-firmware}/brcm/fw_bcm43455c0_ag_cy.bin "$out"/lib/firmware/brcm/brcmfmac43455-sdio.pine64,pinenote-v1.2.bin
  install -Dm644 ${pinenote-firmware}/brcm/nvram_ap6255_cy.txt "$out"/lib/firmware/brcm/brcmfmac43455-sdio.txt
  )
''
