# version 0.0.1.0
export PRJ_VERSION = 0x000000100

export GIT_BYPASS = 1
export REMOVE_UNUSED_CODE = 0
export GEN_XSA_IMAGE = 1

export TOP_DIR = $(abspath $(PWD)/../..)

target : prom

export PRJ_PART = xc7z007sclg400-1

include ../../submodules/ruckus/system_vivado.mk

.PHONY : sdt
sdt : target
	$(PROJ_DIR)/build-sdt.sh

clean-sdt :
	rm -rf $(PROJ_DIR)/sdt
