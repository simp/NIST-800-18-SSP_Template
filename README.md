[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

# System Security Plan Template

This repository holds a reusable SSP Template based around the principals
outlined in [NIST 800-18]()

This is **NOT** an official repository of any kind, simply a way to organize
things in a consistent manner.

# Setup

Next, you'll need to have a copy of Ruby installed and run `bundler install` to
install the approprate gems.

(Run `gem install bunder` if you don't have it yet)

You will also need a copy of `java` and `saxon.jar` installed in your path for
the XSL transforms that happen during the build process.

Finally, you will need a copy of Python `sphinx` version 2.2 or higher.

# Usage

Full `rake` task help can be found by running `rake -D` at the command line but
most people will wish to do the following:

1. Update the `project_config.ini` file to satisfy the requirements of your
   organization.
2. Run `rake generate_controls` to generate the appropriate FIPS 199 control
   templates that you selected in `project_config.ini`
3. Remove any controls from `docs/security_controls` that you do not need to
   follow

     * Don't forget to update `docs/security_controls/index.rst` if you remove
       entire control families.

4. Generate the documentation using `rake docs:html`
5. Check for any `todo` items that you have outstanding, fix them, and re-run
   `rake docs:html` until satisfied.

[NIST 800-18]: http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-18r1.pdf
