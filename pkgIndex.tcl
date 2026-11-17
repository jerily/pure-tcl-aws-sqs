# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

if {![package vsatisfies [package provide Tcl] 9.1-10]} {return}
package ifneeded pure-tcl-aws-sqs 0.1.1 [list source [file join $dir library sqs.tcl]]
package ifneeded awssqs 1.0.19 [list source [file join $dir library sqs.tcl]]
