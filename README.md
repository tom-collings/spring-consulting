# spring-consulting
This is a repo to contain bash scripts useful for Spring-like activities.

The spring-footprint.sh bash script will scrape a TAS foundation, and for each application found will determine:

- application name
- org name
- space name
- buildpack used in pushing the application

For apps using the java buildpack, it will also determine
- JDK used to compile the application
- version of Spring Boot found

Notes:
- currently only determines Spring Boot version when application is deployed as a jar
- does not loop over pages if there are more than fifty apps in the foundation
