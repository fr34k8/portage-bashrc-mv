#!/bin/bash
# (C) Martin V\"ath <martin@mvath.de>

# Portage explicitly unsets all CCACHE_* variables in each phase.
# Therefore, we save them to BASHRCD_CCACHE_* in the setup phase;
# in all later phases, we restore CCACHE_* from these variables
CcacheSetup() {
	local i
	: ${CCACHE_BASEDIR="${PORTAGE_TMPDIR:-/var/tmp}/portage"}
	: ${CCACHE_SLOPPINESS='file_macro,time_macros,include_file_mtime'}
	: ${CCACHE_COMPRESS=true}
	BashrcdTrue "${USE_NONGNU}" && : ${CCACHE_CPP2=true}
	for i in ${!CCACHE_*}
	do	if eval "BashrcdTrue \"\${${i}}\""
		then	eval BASHRCD_${i}=\${${i}}
			export ${i}
		else	unset ${i}
		fi
	done
CcacheRestore() {
	local i j
	unset ${!CCACHE_*}
	for i in ${!BASHRCD_CCACHE_*}
	do	j=${i##BASHRCD_}
		eval ${j}=\${${i}}
		export ${j}
	done
}
}

CcacheRestore() {
:
}

# Register CcacheRestore before CcacheSetup to save time in setup phase
BashrcdPhase all CcacheRestore
BashrcdPhase setup CcacheSetup