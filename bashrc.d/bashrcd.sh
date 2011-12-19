#!/bin/bash
# (C) Martin Väth <martin@mvath.de>

BashrcdEcho() {
	case "${NOCOLOR}" in
	''|f*|F*|0*|n*|N*)
		printf '\033[1;34m>\033[1;36m>\033[1;35m>\033[0m %s\n' "${@}";;
	*)	printf '>>> %s\n' "${@}";;
	esac
}

BashrcdPhase() {
	local c
	eval "c=\${bashrcd_phases_c_${1}}"
	if [ -n "${c}" ]
	then	c=$(( ${c} + 1 ))
	else	c=0
	fi
	eval "bashrcd_phases_c_${1}=\${c}
	bashrcd_phases_${c}_${1}=\"\${2}\""
}

BashrcdMain() {
	local bashrcd
	for bashrcd in "${CONFIG_ROOT%/}/etc/portage/bashrc.d/"*.sh
	do	case "${bashrcd}" in
		*/bashrcd.sh)	continue;;
		esac
		test -f "${bashrcd}" || continue
		. "${bashrcd}" || die "failed to source ${bashrcd}"
		[ -z "${BASHRCD_DEBUG}" ] || BashrcdEcho "${bashrcd} sourced"
	done
	unset -f BashrcdPhase
BashrcdMain() {
	local bashrcd_phase bashrcd_num bashrcd_max
	[ ${#} -ne 0 ] && EBUILD_PHASE="${1}"
	: ${ED:="${D%/}${EPREFIX%/}/"}
	[ -z "${BASHRCD_DEBUG}" ] || BashrcdEcho \
		"${0}: ${*} (${#} args)" \
		"EBUILD_PHASE=${EBUILD_PHASE}" \
		"PORTDIR=${PORTDIR}" \
		"CATEGORY=${CATEGORY}" \
		"P=${P}" \
		"USER=${USER}" \
		"HOME=${HOME}" \
		"PATH=${PATH}" \
		"ROOT=${ROOT}" \
		"CONFIG_ROOT=${CONFIG_ROOT}" \
		"LD_PRELOAD=${LD_PRELOAD}" \
		"EPREFIX=${EPREFIX}" \
		"D=${D}" \
		"ED=${ED}"
	for bashrcd_phase in all "${EBUILD_PHASE}"
	do	eval "bashrcd_max=\${bashrcd_phases_c_${bashrcd_phase}}"
		[ -z "${bashrcd_max}" ] && continue
		bashrcd_num=0
		while [ ${bashrcd_num} -le ${bashrcd_max} ]
		do	eval "eval \"\\\${bashrcd_phases_${bashrcd_num}_${bashrcd_phase}}\""
			bashrcd_num=$(( ${bashrcd_num} + 1 ))
		done
	done
}
	BashrcdMain "${@}"
}