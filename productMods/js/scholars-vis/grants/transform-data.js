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
	var merged = bindings.map(transformBinding).reduce(mergeDuplicates, []);
	console.log("Merged? " + merged.length);
	return merged;

	function transformBinding(binding) {
		return {
			"group" : figureGrantGroup(),
			"person" : getPeopleDetails(),
			"P-I-Id" : "55226-3713", // BOGUS
			"grant" : getGrantDetails(),
			"dept" : getDepartmentDetails(),
			"funagen" : getFundingAgencyDetails(),
			"Cost" : parseInt(binding.amount.value),
			"End" : figureYear(binding.enddt),
			"Start" : figureYear(binding.startdt),
			"id" : getUniqueId()
		// BOGUS? -- for grant (where is the data?)
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
				"type" : figureGrantType()
			};

			function figureGrantType() {
				if (binding.type == undefined) {
					return "UNKNOWN";
				} else if (binding.type.value == "http://vivoweb.org/ontology/core#Grant") {
					return "GRANT";
				} else if (binding.type.value == "http://vivoweb.org/ontology/core#Contract") {
					return "CONTRACT";
				} else if (binding.type.value == "http://vivoweb.org/ontology/core#CooperativeAgreement") {
					return "CO-OP";
				} else {
					return "UNKNOWN";
				}
			}
		}

		function getPeopleDetails() {
			return [ getPersonDetails() ]
			function getPersonDetails() {
				if (binding.person == undefined
						|| binding.personName == undefined
						|| binding.personNetid == undefined) {
					return {
						"uri" : "'",
						"name" : "not found",
						"netid" : "zzz",
						"role" : ""
					};
				} else {
					return {
						"uri" : toDisplayPageUrl(binding.person.value),
						"name" : binding.personName.value,
						"netid" : binding.personNetid.value,
						"role" : figureRole()
					};
				}

				function figureRole() {
					if (binding.role == undefined) {
						return "";
					} else if (binding.role.value == "http://vivoweb.org/ontology/core#PrincipalInvestigatorRole") {
						return "PI";
					} else if (binding.role.value == "http://vivoweb.org/ontology/core#CoPrincipalInvestigatorRole") {
						return "CO";
					} else {
						return "";
					}
				}
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

		function figureYear(date) {
			if (date == undefined) {
				return "9999";
			} else {
				return date.value.substring(0, 4);
			}
		}

		function getUniqueId() {
			return uniqueId++;
		}
	}

	function mergeDuplicates(bindingsSoFar, currentBinding) {
		var matchingValue = bindingsSoFar.find(matchUris);
		if (matchingValue == undefined) {
			return bindingsSoFar.concat(currentBinding);
		} else {
			matchingValue.person = matchingValue.person
					.concat(currentBinding.person);
			return bindingsSoFar;
		}

		function matchUris(aBinding) {
			return aBinding.grant.uri == currentBinding.grant.uri
		}
	}
}
