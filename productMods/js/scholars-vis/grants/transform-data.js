function closeGrantsVis(target) {
	$(target).children("svg").remove();
	$('div#gates_tooltip').remove();
}

/*
 * Take the data as it comes from the server, and convert it for the bubble-chart.
 * 
 * This is a limited version, in that it assumes that all values are present, 
 * and that each grant is represented only once. In the future, we will need to 
 * check for both of those.
 */
function transformGrantsData(resultSet) {
	var dummyPersonDetails = {
		"uri" : "'",
		"name" : "not found",
		"netid" : "zzz",
		"role" : ""
	};
	var dummyFundingOrg = {
		"name" : "not found",
		"uri" : "."
	};
	var dummyDept = {
		"code" : "",
		"name" : "not found",
		"uri" : "."
	};

	var bindings = resultSet.results.bindings;
	var merged = bindings.filter(matchDepartment).map(transformBinding).reduce(
			mergeDuplicates, []);
	return merged;

	function matchDepartment(binding) {
		return typeof grantsDataDepartmentUri == 'undefined'
				|| grantsDataDepartmentUri == undefined
				|| grantsDataDepartmentUri == ""
				|| (binding.dept != undefined && grantsDataDepartmentUri == binding.dept.value);
	}

	function transformBinding(binding) {
		return {
			"group" : figureGrantGroup(),
			"people" : getPeopleDetails(),
			"P-I-Id" : "55226-3713", // BOGUS
			"grant" : getGrantDetails(),
			"dept" : getDepartmentDetails(),
			"funagen" : getFundingAgencyDetails(),
			"Cost" : parseInt(binding.amount.value),
			"End" : figureYear(binding.enddt),
			"Start" : figureYear(binding.startdt),
			"id" : binding.grantId.value
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
				} else if (binding.type.value == "http://scholars.cornell.edu/ontology/ospcu.owl#CooperativeAgreement") {
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
					return dummyPersonDetails;
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
				return dummyDept;
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
				return dummyFundingOrg;
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
	}

	function mergeDuplicates(bindingsSoFar, current) {
		var matching = bindingsSoFar.find(matchUris);
		if (matching == undefined) {
			return bindingsSoFar.concat(current);
		} else {
			matching.people = mergePeople();
			matching.funagen = mergeFunders();
			matching.dept = mergeDepartments();
			return bindingsSoFar;
		}

		function matchUris(aBinding) {
			return aBinding.grant.uri == current.grant.uri
		}

		function mergePeople() {
			var people = matching.people.concat(current.people);
			var filtered = people.filter(notDummyPerson);
			return filtered.length == 0 ? [ dummyPersonDetails ] : filtered;

			function notDummyPerson(person) {
				return person != dummyPersonDetails;
			}
		}

		function mergeFunders() {
			if (matching.funagen == dummyFundingOrg) {
				return current.funagen;
			} else {
				return matching.funagen;
			}
		}

		function mergeDepartments() {
			if (matching.dept == dummyDept) {
				return current.dept;
			} else {
				return matching.dept;
			}
		}
	}
}
