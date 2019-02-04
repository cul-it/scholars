# Scholars@Cornell

A "third layer" to add Scholars@Cornell functionality to a VIVO 1.8 distribution.

# Decommission and archive
 
It was decided by Cornell Library Leadership to discontinue the project. The application was decommissioned on Jan 2nd 2019. The data from production instance has been archived and is available (on request) on following links.
 
### Data: Scholars Triple Graphs and SQL Database Dump
__*Location:*__ `s3://scholars-elements-archive/ScholarsGraphsAndDatabase/`

### Data: Documentation of SEA archive
__*Location:*__ `s3://scholars-elements-archive/SEA-DOCUMENTATION`
 
### Data: Elements Publication Data Archive
__*Location:*__ `s3://scholars-elements-archive/SEA`

# How to build a Scholars instance

## Read the instructions
For information on how to install VIVO 1.8, consult the installation instructions for VIVO 1.8, perhaps starting with [A simple installation][simple install], and continuing with [Building VIVO in 3 tiers][3tier install].

This will tell you how to prepare, installing dependencies like MySQL, Tomcat, Ant, etc.

## Get the code repositories

Create a project code directory, and clone the repositories into it:

```
#git clone -b scholars/maint-rel-1.8 git@github.com:cul-it/scholarsVitro.git
#git clone -b maint-rel-1.8 git@github.com:vivo-project/VIVO.git
#git clone git@github.com:cul-it/scholars.git
```

Notes: 

* `scholarsVitro` is a modified version of Vitro 1.8. 
	* It includes code that Brian Lowe wrote, improving the performance of ingest and inferencing.
	* It includes an pre-release version of the Data Distribution API, with several code tweaks to accomodate it.
	* It also contains other tweaks and modifications.
	* At one time, it would have been possible to swap in an unmodified Vitro 1.8, but that would no longer be wise.

* `VIVO` is an unmodified version of VIVO 1.8

* `scholars` is the third layer which contains the Scholars@Cornell functionality

## Follow the instructions

Follow the normal [installation instructions][simple install], with these exceptions.

### Addition to `build.properties`

The `build.properties` file will need an additional property:

```
nihvivo.dir = ../VIVO
```

`nihvivo.dir` points to the clone of the `VIVO` repository, connecting the third
tier to the second tier.

### Addition to `runtime.properties`

To use the Scholars-ORCID connection (SCORconn), you will need a runtime property that tells Scholars
where to find the SCORconn web service.

For example:

```
orcidConnection.baseUrl = http://localhost:8888/scorconn-ws/
```

The comments in `example.runtime.properties` contain more information.

# How to run it

Start Tomcat.



[simple install]: https://wiki.duraspace.org/display/VIVODOC18x/A+simple+installation
[3tier install]: https://wiki.duraspace.org/display/VIVODOC18x/Building+VIVO+in+3+tiers