/*
 * Take the data as it comes from the server, and convert it for the bubble-chart.
 * 
 * This is a limited version, in that it assumes that all values are present, 
 * and that each grant is represented only once. In the future, we will need to 
 * check for both of those.
 */
function transformGrantsData(resultSet) {
	console.log(window.location.href);
	var uniqueId = 1;
	var bindings = resultSet.results.bindings;
	console.log("How many? " + bindings.length);
	return bindings.map(transformBinding)

	function transformBinding(binding) {
		return {
			"group" : figureGrantGroup(),
			"person" : getPersonDetails(),
			"P-I-Id" : "55226-3713", // BOGUS
			"grant" : getGrantDetails(),
			"dept" : getDepartmentDetails(),
			"funagen" : getFundingAgencyDetails(),
			"Cost" : parseInt(binding.amount.value),
			"Role" : "CO", // BOGUS - which role? pi, co-pi?
			"End" : binding.endYear.value,
			"Start" : binding.startYear.value,
			"id": getUniqueId() // BOGUS? -- for grant (where is the data?)
		};

		function figureGrantGroup() {
			var rawAmount = binding.amount
			if (rawAmount == null) {
				return "unknown";
			}
			var amount = parseInt(rawAmount.value);
			if (amount == 0) {
				return "unknown";
			} else if (amount <= 100000) {
				return "low";
			} else if (amount > 1000000) {
				return "high";
			} else {
				return "medium";
			}
		}

		function getGrantDetails() {
			return {
				"uri" : toDisplayPageUrl(binding.grant.value),
				"title" : binding.grantTitle.value,
				"type" : binding.grantType.value
			};
		}

		function getPersonDetails() {
			if (binding.person == undefined || binding.personName == undefined
					|| binding.personNetid == undefined) {
				return {
					"uri" : "'",
					"name" : "not found",
					"netid" : "zzz"
				};
			} else {
				return {
					"uri" : toDisplayPageUrl(binding.person.value),
					"name" : binding.personName.value,
					"netid" : binding.personNetid.value
				};
			}
		}

		function getDepartmentDetails() {
			if (binding.dept == undefined || binding.deptName == undefined) {
				return {
					"code" : "",
					"name" : "not found",
					"uri" : "."
				};
			} else {
				return {
					"code" : "CBE", // BOGUS
					"name" : binding.deptName.value,
					"uri" : toDisplayPageUrl(binding.dept.value)
				};
			}
		}

		function getFundingAgencyDetails() {
			if (binding.fundingOrg == undefined
					|| binding.fundingOrgName == undefined) {
				return {
					"name" : "not found",
					"uri" : "."
				};
			} else {
				return {
					"name" : binding.fundingOrgName.value,
					"uri" : toDisplayPageUrl(binding.fundingOrg.value)
				}
			}
		}

		function getUniqueId() {
			return uniqueId++;
		}
	}
}
