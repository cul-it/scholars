function getNameList(array){
	var nameList = [];
	array.forEach(function(d){
		var people = d.people; 

		var grantPeople = people.map(function(person){
			nameList.push(person.name);
			return person.name; 
		});
	});
	nameList = _.uniq(nameList);
	return nameList;
}

function getDeptList(array){
	return array.map(function(d){
		return d.dept.name;
	}); 
}

function getFundingAgency(array){
	return array.map(function(d){
		return d.funagen.name;
	}); 
}

function uncheckAll(){
	currentData = [];
	filtered = grants; 

	update(currentData);
	updateChecks();
}

function checkAll(){
	currentData = grants; 
	removedNames = [];
	filtered = []; 
	update(currentData); 
	updateChecks();
}

 

