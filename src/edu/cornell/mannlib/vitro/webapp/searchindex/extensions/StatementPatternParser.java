/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.searchindex.extensions;

import static com.hp.hpl.jena.rdf.model.ResourceFactory.*;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.hp.hpl.jena.datatypes.TypeMapper;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.Selector;
import com.hp.hpl.jena.rdf.model.SimpleSelector;
import com.hp.hpl.jena.vocabulary.RDF;

/**
 * Parse the matcher string and create a Selector from it.
 */
class StatementPatternParser {
    private static final Pattern MATCHER_SPLITTER = Pattern.compile("\\s+");
    private static final Pattern URI_PATTERN = Pattern.compile("<([^<>]+)>");
    private static final Pattern PLAIN_LITERAL_PATTERN = Pattern
            .compile("\"([^\"]+)\"");
    private static final Pattern LANGUAGE_LITERAL_PATTERN = Pattern
            .compile("\"([^\"]+)\"@([^@]+)");
    private static final Pattern TYPED_LITERAL_PATTERN = Pattern.compile("" //
            + "\"" // a quote
            + "([^\"]+)" // some non-quote characters
            + "\"" // a quote
            + "\\^\\^" // two carets
            + "<" // an opening bracket
            + "([^<>]+)" // some non-bracket characters
            + ">" // a closing bracket
    );

    private final Selector selector;

    StatementPatternParser(String pattern) {
        if (pattern == null) {
            throw new PatternException("pattern may not be null");
        }
        if (pattern.isEmpty()) {
            throw new PatternException("pattern may not be empty");
        }
        try {
            String[] parts = MATCHER_SPLITTER.split(pattern, 3);
            if (parts.length == 3) {
                selector = new SimpleSelector(parseMatcherSubject(parts[0]),
                        parseMatcherPredicate(parts[1]),
                        parseMatcherObject(parts[2]));
            } else {
                throw new IllegalArgumentException(
                        "Matcher string must be in three parts, not "
                                + parts.length);
            }
        } catch (Exception e) {
            throw new PatternException("Matcher is invalid: '" + pattern + "'",
                    e);
        }
    }

    /**
     * Subject may be variable or URI.
     */
    private Resource parseMatcherSubject(String string) {
        if (string.startsWith("?")) {
            return null;
        }
        Matcher m = URI_PATTERN.matcher(string);
        if (m.matches()) {
            return createResource(m.group(1));
        }
        throw new PatternException("Subject must be a URI or a variable");
    }

    /**
     * Predicate may be "a" or a variable or a URI.
     */
    private Property parseMatcherPredicate(String string) {
        if (string.equals("a")) {
            return RDF.type;
        }
        if (string.startsWith("?")) {
            return null;
        }
        Matcher m = URI_PATTERN.matcher(string);
        if (m.matches()) {
            return createProperty(m.group(1));
        }
        throw new PatternException(
                "Predicate must be \"a\" or a URI or a variable");
    }

    /**
     * Object may be URI or Literal or variable.
     */
    private RDFNode parseMatcherObject(String string) {
        if (string.startsWith("?")) {
            return null;
        }
        Matcher m = URI_PATTERN.matcher(string);
        if (m.matches()) {
            return createResource(m.group(1));
        }
        m = PLAIN_LITERAL_PATTERN.matcher(string);
        if (m.matches()) {
            return createPlainLiteral(m.group(1));
        }
        m = LANGUAGE_LITERAL_PATTERN.matcher(string);
        if (m.matches()) {
            return createLangLiteral(m.group(1), m.group(2));
        }
        m = TYPED_LITERAL_PATTERN.matcher(string);
        if (m.matches()) {
            return createTypedLiteral(m.group(1),
                    TypeMapper.getInstance().getTypeByName(m.group(2)));
        }
        throw new PatternException(
                "Object must be a URI or a Literal or a variable");
    }

    Selector selector() {
        return selector;
    }

    static class PatternException extends RuntimeException {
        public PatternException(String message) {
            super(message);
        }

        public PatternException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
