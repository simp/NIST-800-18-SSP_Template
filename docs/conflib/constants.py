# A list of constants used throughout the code and for testing

import sys
import os
import configparser

def __validate_fips_199_level(level):
    valid_levels = ['Low', 'Moderate', 'High']

    if level.lower() not in map(lambda x: x.lower(), valid_levels):
        sys.exit("Error: 'Config.FIPS_199_Level' must be one of '" +
                 ", '".join(valid_levels) +
                 "' got '" +
                 level + "'")

def __validate_operational_status(operational_status):
    valid_statuses = ['Operational', 'Under Development', 'Major Modification']

    if operational_status.lower() not in map(lambda x: x.lower(), valid_statuses):
        sys.exit("Error: 'Config.Operational_Status' must be one of '" +
                 ", '".join(valid_statuses) +
                 "' got '" +
                 operational_status + "'")

def __validate_system_type(system_type):
    valid_system_types = ['Major Application', 'General Support System']

    if system_type.lower() not in map(lambda x: x.lower(), valid_system_types):
        sys.exit("Error: 'Config.System_Type' must be one of '" +
                 ", '".join(valid_system_types) +
                 "' got '" +
                 system_type + "'")

def __process_project_config(local_config_path):
    _project_config = configparser.ConfigParser()
    _project_config['ABOUT'] = {
        'Version': u'0.0.1-0',
        'Name': u'System Security Plan',
        'Author': u'My Team'
    }
    _project_config['CONFIG'] = {
        'Show_Todo': u'True',
        'FIPS_199_Level': u'Low',
        'System_Type': u'General Support System',
        'Operational_Status': u'Under Development'
    }

    if os.path.isfile(local_config_path):
        local_config = configparser.ConfigParser()
        local_config.read(local_config_path)
        _project_config.update(local_config)

    if _project_config['CONFIG']['Show_Todo'] not in ['True', 'False', 'yes', 'no']:
        sys.stderr.write("CONFIG.Show_Todo must be either 'yes' or 'no'")

    if _project_config['CONFIG']['Show_Todo'] == 'yes':
        _project_config['CONFIG']['Show_Todo'] = 'True'

    if _project_config['CONFIG']['Show_Todo'] == 'no':
        _project_config['CONFIG']['Show_Todo'] = 'False'

    return _project_config

# Root directory of the local git repo to which this file belongs
ROOTDIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

# Directory containing *.rst files
DOCSDIR = os.path.join(ROOTDIR, 'docs')

# Whether this project is being built by ReadTheDocs
ON_RTD = os.environ.get('READTHEDOCS') == 'True'

project_config = __process_project_config(os.path.join(ROOTDIR, 'project_config.ini'))

__validate_fips_199_level(project_config['CONFIG']['FIPS_199_Level'])
__validate_operational_status(project_config['CONFIG']['Operational_Status'])
__validate_system_type(project_config['CONFIG']['System_Type'])
