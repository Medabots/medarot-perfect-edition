export LC_CTYPE=C
export PYTHONIOENCODING=utf-8

VERSIONS := kabuto
PREFIX_OUTPUT := medarot_
PREFIX_BASE := baserom_

# Toolchain
CC := nasm
CC_ARGS :=
LD := nasm
LD_ARGS :=

# File extensions
EXT_GAME := ws
EXT_SOURCE := nasm
EXT_BIN := bin

# Directories
## It's important these remain relative
DIR_BASE := .
DIR_GAME := $(DIR_BASE)/game
DIR_BUILD := $(DIR_BASE)/build
DIR_SOURCE := $(DIR_GAME)/src
DIR_COMMON_SOURCE := $(DIR_SOURCE)/common

# Source modules (directories in SRC)
MODULES := \
core

# Source dependencies (e.g. core_init_ADDITIONAL for a dependency on core/init.nasm or core_ADDITIONAL for all of core)

##

# Helper functions
TOUPPER = $(shell echo '$1' | tr '[:lower:]' '[:upper:]')
FILTER = $(strip $(foreach v,$(2),$(if $(findstring $(1),$(v)),$(v),)))
FILTER_OUT = $(strip $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v))))
ESCAPE = $(subst ','\'',$(1))
# Necessary for patsubst expansion
pc := %

# Evaluate variables
ROMS_BASE := $(foreach VERSION,$(VERSIONS),$(DIR_BASE)/$(PREFIX_BASE)$(VERSION).$(EXT_GAME))
ROMS_OUTPUT := $(foreach VERSION,$(VERSIONS),$(DIR_BASE)/$(PREFIX_OUTPUT)$(VERSION).$(EXT_GAME))

OBJECT_NAMES := $(foreach MODULE,$(MODULES),$(addprefix $(MODULE)., $(addsuffix .$(EXT_BIN), $(notdir $(basename $(wildcard $(DIR_SOURCE)/$(MODULE)/*.$(EXT_SOURCE)))))))
SOURCES_COMMON := $(wildcard $(DIR_COMMON_SOURCE)/*.$(SOURCE_TYPE))

# Intermediates for common sources (not in version folder)
## We explicitly rely on second expansion to handle version-specific files in the version specific objects
OBJECTS := $(foreach OBJECT,$(OBJECT_NAMES), $(addprefix $(DIR_BUILD)/,$(OBJECT)))

# Rules
.PHONY: all clean default kabuto kuwagata
default: kabuto
all: $(VERSIONS)

clean:
	rm -r $(DIR_BUILD) $(ROMS_OUTPUT) || exit 0

# Support building specific versions
# Unfortunately make has no real good way to do this dynamically from VERSIONS so we just manually set CURVERSION here to propagate to the rgbasm call
kabuto: CURVERSION:=kabuto
kuwagata: CURVERSION:=kuwagata

$(VERSIONS): %: $(PREFIX_OUTPUT)%.$(EXT_GAME)


.SECONDEXPANSION:
$(DIR_BASE)/$(PREFIX_OUTPUT)%.$(EXT_GAME): $(OBJECTS) $(DIR_SOURCE)/main.%.nasm | $(DIR_BASE)/$(PREFIX_BASE)%.$(EXT_GAME)
	$(LD) $(LD_ARGS) -f bin -o $@ $(DIR_SOURCE)/main.$*.nasm
	cmp -l $| $@

# Build objects
.SECONDEXPANSION:
.SECONDARY: # Don't delete intermediate files
$(DIR_BUILD)/%.$(EXT_BIN): $(DIR_SOURCE)/$$(firstword $$(subst ., ,$$*))/$$(lastword $$(subst ., ,$$*)).$(EXT_SOURCE) $(SOURCES_COMMON) $$(wildcard $(DIR_SOURCE)/$$(firstword $$(subst ., ,$$*))/include/*.$(EXT_SOURCE)) $$($$(firstword $$(subst ., ,$$*))_ADDITIONAL) $$($$(firstword $$(subst ., ,$$*))_$$(lastword $$(subst ., ,$$*))_ADDITIONAL) $$(subst PLACEHOLDER_VERSION,$$(lastword $$(subst /, ,$$(firstword $$(subst ., ,$$*)))),$$($$(firstword $$(subst /, ,$$*))_$$(lastword $$(subst ., ,$$*))_ADDITIONAL)) | $$(patsubst $$(pc)/,$$(pc),$$(dir $$@))
	$(CC) $(CC_ARGS) -DGAMEVERSION=$(CURVERSION) -f bin -o $@ $<

#Make directories if necessary
$(DIR_BUILD):
	mkdir -p $@