
// Copyright (C) 2013-2018 University of Amsterdam
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick 									2.8
import QtQuick.Layouts 							1.3
import JASP.Controls 							1.0
import JASP.Widgets 							1.0

Form 
{
	usesJaspResults:							true
	columns:									1

	VariablesForm
	{
		id:										variablesForm

		AvailableVariablesList
		{
			name:								"variablesForm"
		}

		AssignedVariablesList
		{
			id:									variable1
			name:								"diameter"
			title:								qsTr("Diameter")
			singleVariable:						true
			allowedColumns:						["ordinal", "scale"]
		}

		AssignedVariablesList
		{
			id:									variable2
			name:								"subgroups"
			title:								qsTr("Subgroups")
			singleVariable:						true
			allowedColumns:						["nominal", "nominalText"]
		}
	}

	Group
	{
		IntegerField { name: "lowerSpecification";  label: qsTr("Lower Specification Limit")                    }
		IntegerField { name: "upperSpecification";  label: qsTr("Upper Specification Limit")                    }
		IntegerField { name: "targetValue";         label: qsTr("Target value")                                 }
	}

	Section
	{
		title: qsTr("Initial Process Capability Study")

		CheckBox { name: "initialControlchart";			label: qsTr("X-bar Chart")						}
		CheckBox { name: "initialHistogram";			label: qsTr("Histogram")						}
		CheckBox { name: "initialProbabilityPlot";		label: qsTr("Normal Probability Plot")			}
		CheckBox { name: "initialCapabilityAnalysis";	label: qsTr("Process Capability of Diameter")	}
	}

	Section
	{
		title: qsTr("Follow-up Process Capability Study")

		CheckBox { name: "followupControlchart";		label: qsTr("X-bar & Range Control Chart")		}
		CheckBox { name: "followupHistogram";			label: qsTr("Histogram")						}
		CheckBox { name: "followupProbabilityPlot";		label: qsTr("Normal Probability Plot")			}
		CheckBox { name: "followupCapabilityAnalysis";	label: qsTr("Process Capability of Diameter")	}
	}
}