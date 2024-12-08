# jmeter-load-tests
Jmeter scripts for repo load tests

## python

1. create python repository with name `py-1`
2. add dependencies to [requirements.txt](python/requirements.txt)
3. run `rm -rf output && mkdir -p output/report && jmeter -n -t pip-install-testplan.jmx -l output/results.jtl -j output/jmeter.log -q pip-testplan.properties -e -o output/report`
4. inspect report in `output/report` folder
