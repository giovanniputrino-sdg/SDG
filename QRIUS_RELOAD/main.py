from xml_generator import *
xml_generator('gl-km-qdocs-prtcl-frm-md.sql',server='Redshift',parameter_file= 'parameters_redshift.json',env='dev',quantity=100,staging=True)

# from xml_delete import *
# xml_generator('gl-km-qdocs-prtcl-frm-md_delete.sql',server='Redshift',parameter_file= 'parameters_redshift.json',env='dev',quantity=400, staging = False)
