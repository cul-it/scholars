var RDF, RDFS, BIBO, FOAF, VCARD, VIVO;

function standardPrefixes() {
    RDF = $rdf.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
    RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");
    BIBO = $rdf.Namespace("http://purl.org/ontology/bibo/");
    FOAF = $rdf.Namespace("http://xmlns.com/foaf/0.1/");
    VCARD = $rdf.Namespace("http://www.w3.org/2006/vcard/ns#");
    VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
}

/*
 * Use RDFlib to create a graph structure from a string of RDF in Turtle format.
 */
function populateGraph(turtleRdf) {
    var graph = $rdf.graph();
    $rdf.parse(turtleRdf, graph, "http://graph.name", "text/turtle");
    return graph;
}

/*
 * Add a field to a structure, with a supplied key and a value from a function.
 */
function addRequiredField(structure, fieldName, finderFunction) {
    structure[fieldName] = finderFunction();
}

/*
 * Add a field to a structure, with a supplied key and a value from a function.
 * If the function throws an exception, or if the function returns a null 
 * value, just do nothing.
 */
function addOptionalField(structure, fieldName, finderFunction) {
    try {
        var value = finderFunction();
        if ((typeof value != "undefined") && (value != null)) {
            structure[fieldName] = value;
        }
    } catch (err) {
        // Problems? Skip this field.
    }
}

/*
 * Starting with a node in the graph, follow a list of predicates looking for
 * a literal value at the end of the chain. If the chain breaks, or leads to 
 * a URI instead, return null.
 * 
 * Call it like a varargs function: 
 *     getAnyValue(graph, startingNode, VIVO('relates'), RDFS('label'))
 */
function getAnyValue(graph, baseNode, predicates) {
    var currentNode = baseNode;
    predicates = [].slice.call(arguments, 2);
    predicates.forEach(followPath);
    
    if (currentNode && currentNode.value) {
        return currentNode.value;
    } else {
        return null;
    }

    function followPath(predicate) {
        if (currentNode && currentNode.uri) {
            currentNode = graph.any(currentNode, predicate);
        } else {
            currentNode = null;
        }
    }
}

