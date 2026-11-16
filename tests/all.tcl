# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

set here [file dirname [file normalize [info script]]]
if {[catch {exec python3 [file join $here requests_server.py] --library [file join $here .. pkgIndex.tcl] --tclsh [info nameofexecutable] >@stdout 2>@stderr} message]} {puts stderr $message; exit 1}
if {[catch {exec python3 [file join $here extra_server.py] [info nameofexecutable] >@stdout 2>@stderr} message]} {puts stderr $message; exit 1}
