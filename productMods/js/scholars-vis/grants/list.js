
/*Coverts an array into a Set (no duplicates)*/
let unique = a => [...new Set(a)];

/*Extracts property and returns list of those properties without duplicates*/
function getProperty(array, property){
	return unique(array.map(d=>d[property]));
}
/*Adds a checkbox for each member of the list*/
function addList(id, array, field){ 
	var anchorDiv = d3.select(id); 
	var labels = anchorDiv.selectAll("div")
	.data(array.sort())
	.enter()
	.append("li");
	
	labels
	.append("input")
	.attr("checked", true)
	.attr("type", "checkbox")
	.attr("class", 'cbox'+field)
	.attr("id", function(d,i) { return i; })
	.attr("for", function(d,i) { return i; })
	.on("change", function(d){
		
		var className = $(this).attr("class");

		if (className==="cboxDepartment"){ 
			var bool = d3.select(this).property("checked");
			if(bool == false){
				currentData = currentData.filter(function(node){
					if(node.dept.name != d){
						return true;
					}
					else{
						filtered.push(node); 
					}
				}); 
			}
			else{
				filtered = filtered.filter(function(node){
					if(node.dept.name == d){
						comeback.push(node);
						return false;
					}
					else{
						return true;
					}
				});	
				currentData = currentData.concat(comeback);
			}
		}

		if (className==="cboxPerson"){ 
			var bool = d3.select(this).property("checked");
			if(bool == false){
				removedNames.push(d);
				currentData = currentData.filter(function(node){
					if(_.intersection(removedNames, node.peopleList).length != node.peopleList.length){
						return true; 
					}
					else{ 
						filtered.push(node); 
						return false; 
					}
				}); 
			}

			else{
				removedNames = removedNames.filter(function(n){
					return n!=d; 
				});
				filtered = filtered.filter(function(node){
					if ((_.intersection(removedNames, node.peopleList).length != node.peopleList.length) && node.peopleList.indexOf(d) > -1){
						comeback.push(node); 
						return false; 
					}
					else{
						return true; 
					}
				});
				currentData = currentData.concat(comeback); 
			}
		}	

		if(className === "cboxFunding Agency"){
			var bool = d3.select(this).property("checked");

			if(bool == false){
				currentData = currentData.filter(function(node){
					if(node.funagen.name != d){
						return true;
					}
					else{
						filtered.push(node); 
					}
				}); 
			}
			else{
				filtered = filtered.filter(function(node){
					if(node.funagen.name == d){
						comeback.push(node);
						return false;
					}
					else{
						return true;
					}
				});	
				currentData = currentData.concat(comeback);
			}			
		}
		update(currentData); //update the viz
		updateChecks(); //update the checks
		comeback = []; //reset comeback
	});
	labels.append("label").attr("class", "label"+field).text(d=>d);
}


function updateChecks() {

	var currentNames = getNameList(currentData);
	var currentDept = _.uniq(getDeptList(currentData));
	var currentAgencies = getFundingAgency(currentData); 

	d3.selectAll('input').property("checked", function(d){

		if(currentNames.indexOf(d) != -1 || currentDept.indexOf(d) != -1||currentAgencies.indexOf(d) != -1){
			return true;
		}
		else{
			return false;
		}
	});
}
