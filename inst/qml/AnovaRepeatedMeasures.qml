//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick			2.12
import JASP.Controls	1.0
import JASP.Widgets		1.0
import JASP				1.0
import "./common" as Common
import "./common/classical" as Classical

Form
{
	id: form
	property int analysis:	Common.Type.Analysis.RMANOVA
	property int framework:	Common.Type.Framework.Classical

	Classical.InvisiblePlotSizes{}

	VariablesForm
	{
		preferredHeight: 520 * preferencesModel.uiScale
		AvailableVariablesList			{ name: "allVariablesList" }
		FactorLevelList					{ name: "repeatedMeasuresFactors";	title: qsTr("Repeated Measures Factors");	height: 180 * preferencesModel.uiScale;	factorName: qsTr("RM Factor")	}
		AssignedRepeatedMeasuresCells	{ name: "repeatedMeasuresCells";	title: qsTr("Repeated Measures Cells");		source: "repeatedMeasuresFactors"										}
		AssignedVariablesList			{ name: "betweenSubjectFactors";	title: qsTr("Between Subject Factors");		suggestedColumns: ["ordinal", "nominal"];	itemType: "fixedFactors"	}
		AssignedVariablesList			{ name: "covariates";				title: qsTr("Covariates");					suggestedColumns: ["scale"]												}
	}

	Classical.Display
	{
		analysis: form.analysis
	}

	Section
	{
		title: qsTr("Model")

		VariablesForm
		{
			preferredHeight: 150 * preferencesModel.uiScale
			AvailableVariablesList	{ name: "withinComponents"; title: qsTr("Repeated Measures Components"); source: ["repeatedMeasuresFactors"] }
			AssignedVariablesList	{ name: "withinModelTerms"; title: qsTr("Model Terms");	listViewType: JASP.Interaction	}
		}

		VariablesForm
		{
			preferredHeight: 150 * preferencesModel.uiScale
			AvailableVariablesList	{ name: "betweenComponents"; title: qsTr("Between Subjects Components"); source: ["betweenSubjectFactors", "covariates"] }
			AssignedVariablesList	{ name: "betweenModelTerms"; title: qsTr("Model terms"); listViewType: JASP.Interaction }
		}

		Classical.SumOfSquares{}

		CheckBox { name: "multivariateModelFollowup";	label: qsTr("Use multivariate model for follow-up tests");	checked: false }
	}

	Section
	{
		title: qsTr("Assumption Checks")

		Group
		{
			CheckBox { name: "sphericityTests";	label: qsTr("Sphericity tests") }
			Group
			{
				title: qsTr("Sphericity corrections")
				columns: 3
				CheckBox { name: "sphericityCorrectionNone";				label: qsTr("None");				checked: true }
				CheckBox { name: "sphericityCorrectionGreenhouseGeisser";	label: qsTr("Greenhouse-Geisser");	checked: false }
				CheckBox { name: "sphericityCorrectionHuynhFeldt";			label: qsTr("Huynh-Feldt");			checked: false }
			}
			CheckBox { name: "homogeneityTests"; label: qsTr("Homogeneity tests") }
		}
	}

	Classical.Contrasts
	{
		analysis:	form.analysis
		source:		["withinModelTerms", { name: "betweenModelTerms", discard: "covariates", combineWithOtherModels: true }]
	}

	Classical.OrderRestrictions
	{
		analysis:	form.analysis
		source:		[{ name: "betweenModelTerms", discard: "covariates" }, { name: "withinModelTerms" }]
	}
	
	Section
	{
		title: qsTr("Post Hoc Tests")
		columns: 1

		VariablesForm
		{
			preferredHeight: 150 * preferencesModel.uiScale
			AvailableVariablesList { name: "postHocAvailableTerms"; source: ["withinModelTerms", { name: "betweenModelTerms", discard: "covariates", combineWithOtherModels: true }] }
			AssignedVariablesList {  name: "postHocTerms" }
		}

		Group
		{
			columns: 2
			CheckBox { name: "postHocEffectSize";	label: qsTr("Effect size")						}
			CheckBox { name: "postHocPooledError";	label: qsTr("Pool error term for RM factors");			checked: true	}
		}

		Group
		{
			title: qsTr("Correction")
			CheckBox { name: "postHocCorrectionHolm";			label: qsTr("Holm"); 		checked: true	}
			CheckBox { name: "postHocCorrectionBonferroni";		label: qsTr("Bonferroni")			}
			CheckBox { name: "postHocCorrectionTukey";			label: qsTr("Tukey")				}
			CheckBox { name: "postHocCorrectionScheffe";		label: qsTr("Scheffé")				}
		}

		Classical.PostHocDisplay{}
	}

	Classical.DescriptivePlots
	{
		source: ["repeatedMeasuresFactors", "betweenSubjectFactors"]
		TextField	{ name: "descriptivePlotYAxisLabel";		label: qsTr("Label y-axis"); fieldWidth: 200	}
		CheckBox	{ name: "descriptivePlotErrorBarPooled";	label: qsTr("Average across unused RM factors")	}
	}

	Common.RainCloudPlots
	{
		source:				["repeatedMeasuresFactors", "betweenSubjectFactors"]
		enableHorizontal:	false
		enableYAxisLabel:	true
	}

	Classical.MarginalMeans
	{
		source: ["withinModelTerms", { name: "betweenModelTerms", discard: "covariates" }]
	}

	Classical.SimpleMainEffects
	{
		source: ["repeatedMeasuresFactors", "betweenSubjectFactors"]
		CheckBox { name: "poolErrorTermSimpleEffects";	label: qsTr("Pool error terms") }
	}

	Section
	{
		title: qsTr("Nonparametrics")

		VariablesForm
		{
			preferredHeight: 150 * preferencesModel.uiScale
			AvailableVariablesList	{ name: "kruskalVariablesAvailable";	title: qsTr("Factors"); source: ["repeatedMeasuresFactors", "betweenSubjectFactors"]	}
			AssignedVariablesList	{ name: "friedmanWithinFactor";			title: qsTr("RM Factor")																}
			AssignedVariablesList	{ name: "friedmanBetweenFactor";		title: qsTr("Optional Grouping Factor"); singleVariable: true							}
		}

		CheckBox { name: "conoverTest"; label: qsTr("Conover's post hoc tests") }
	}

}
