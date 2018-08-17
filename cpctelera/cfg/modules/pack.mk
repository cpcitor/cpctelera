##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine 
##  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##------------------------------------------------------------------------------

###########################################################################
##                  Compression and Packing functions                    ##
##-----------------------------------------------------------------------##
## This file contains functions for creating and managing compressed     ##
## files and packs  												     ##
###########################################################################

#################
# ADD2PACK: Adds a new file to a compressed pack file. It actually adds the file
# given as $(2) to a variable with the name PACK_$(1)
#
# $(1): Compressed pack file name
# $(2): File to be added to the compressed pack file
#
define ADD2PACK
	# First, check that $(1) is non-empty to ensure that the variable to be generated is unique
	$(if $(1),,$(error <<ERROR>> ADD2PACK Requires a non-empty pack name as first parameter))

	# Finally, add the new file to the PACK variable
	$(eval PACK_$(1) := $(PACK_$(1)) $(2))
endef

#################
# PACKZX7B: Creates a compressed file out of all the files previously added with ADD2PACK.
# Updates IMGCFILES and OBJS2CLEAN adding new C files that result from the pack generation.
#
# $(1): Compressed pack file name
# $(2): Output folder for generated files
#
define PACKZX7B
	# First, check that a PACK name has been passed
	$(if $(1),,$(error <<ERROR>> PACKZX7B requires a PACK filename as first parameter))
	# Now, check that $(1) is non-empty to ensure that some files have been previously added to variable
	$(if $(PACK_$(1)),,$(error <<ERROR>> PACK filename '$(1)' does not contain any file to be packed. Is the PACK filename correctly spelled?))
	# Now generate output filename depending on output folder
	$(eval PACK_$(1)_outfile := $(if $(2),$(2:/=)/$(1),$(1)))
	# Construct the build target
	$(eval PACK_$(1)_target := $(PACK_$(1)_outfile).c $(PACK_$(1)_outfile).h)

# Generate target for file compression
.SECONDARY: $(PACK_$(1)_target)
$(PACK_$(1)_target): $(PACK_$(1))
	@$(call PRINT,$(PROJNAME),"Compressing files to generate $(PACK_$(1)_outfile)...")
	$(CPCTPACK) $(PACK_$(1)_outfile) $(PACK_$(1))

# Variables that need to be updated to keep up with generated files and erase them on clean
IMGCFILES   := $(PACK_$(1)_outfile).c $(IMGCFILES)
OBJS2CLEAN  := $(PACK_$(1)_target) $(OBJS2CLEAN)
endef