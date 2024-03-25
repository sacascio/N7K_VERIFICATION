#!/usr/bin/env python3

import re
import sys
import json
import requests
import warnings
import getopt
import os.path
import ipaddress

warnings.filterwarnings("ignore")

def load_commands(file):
    	to_delete = []
    	with open(file) as n7k_commands:
    		cmd_list = n7k_commands.read().splitlines()

    	for element,c in enumerate (cmd_list):
    		if c == '' or bool(re.search('!',c)):
    			to_delete.append(c)
    		else:
    			c = c.lstrip()
    	for d in to_delete:
    		cmd_list.remove(d)
    	cmd_list = " ; ".join(map(str,cmd_list))
    	return cmd_list

def send_to_n7k_api(ip,commands,username,password):
   
    content_type = "json"
    HTTPS_SERVER_PORT = "8080"
    requests.packages.urllib3.disable_warnings()
    
    if commands.endswith(" ; "):
        commands = commands[:-3]
        
    payload = {
        "ins_api": {
            "version": "1.2",
            "type": "cli_conf",
            "chunk": "0",               # do not chunk results
            "sid": "0",
            "input": commands,
            "output_format": "json"
        }
    }
    
    headers={'content-type':'application/%s' % content_type}
    response = requests.post("https://%s:%s/ins" % (ip, HTTPS_SERVER_PORT),
                             auth=(username, password),
                             headers=headers,
                             data=json.dumps(payload),
                             verify=False,                      # disable SSH certificate verification
                             timeout=60)
    
    if response.status_code == 200:
    	allcmds = commands.split(" ; ")
    	# verify result 
    	data = response.json()
    	#print (json.dumps(data))
    	if isinstance(data['ins_api']['outputs']['output'],dict):
    			if int(data['ins_api']['outputs']['output']['code']) != 200:
    				data['ins_api']['outputs']['output']['msg'] = data['ins_api']['outputs']['output']['msg'].rstrip()
    				print ("ERROR: %s, %s.  Command is: %s" % ('msg', data['ins_api']['outputs']['output']['msg'], commands))	
    			else:
    				if 'body' in data['ins_api']['outputs']['output'] and len(data['ins_api']['outputs']['output']['body']) > 0:
                                	print (data['ins_api']['outputs']['output']['body'])	
    	else:
    		for d in data['ins_api']['outputs']['output']:
    			for k in d.keys():
    				if int(d['code']) != 200:
    					cmd_number =  data['ins_api']['outputs']['output'].index(d)
    					if k != 'code':
    						if not isinstance(d[k],dict):
    							d[k] = d[k].rstrip()
    							print ("ERROR: %s, %s.  Command is: %s" % (k, d[k], allcmds[cmd_number]))
    			if 'body' in d and len(d['body']) > 0:
    					print (d['body'])
               	             
    else:
    	msg = "call to %s failed, status code %d (%s).  Command is %s." % (ip,
                                                          response.status_code,
                                                          response.content.decode("utf-8"),
                                                          commands
                                                          )
    	print(msg)


def usage():
    print ("Usage: " +  sys.argv[0] + " -f|--file <excel file name> -c|--config <credentials file>")
    print ("")
    print ("-f|--file:    Pass input file to use for configuration")
    print ("-c|--creds:   Pass credentials file in this format: VDCIP,username,password")
    sys.exit(1)
    

def main(argv):
    errfound = 0
    filename=""
    f_ip = ""
    f_un=""
    f_pw=""

    if len(argv) == 0:
        usage()

    try:
        opts,args = getopt.getopt(argv,"f:c:h",["file=","config=","help"])
    except getopt.GetoptError as err:
        print (str(err))
        sys.exit(2)
    else:
    	for opt,arg in opts:
    		if opt in ("-h","--help"):
    			usage()
    			sys.exit(9)
    		if opt in ("-f","--file"):
                	filename = arg
                	if not os.path.isfile(filename):
                    		print (sys.argv[0] + " input file %s NOT found" % filename)
                    		sys.exit(1)
    		if opt in ("-c","--creds"):
    			creds = arg
    			if not os.path.isfile(creds):
    				print (sys.argv[0] + " credentials file %s NOT found" % creds)
    				sys.exit(1)
    			else:
    				with open (creds) as data:
    					lines = data.read().splitlines()
                    
    					for data in lines:
    						d = data.split(",")
    						f_ip = d[0]
                       
    						try:
    							ipaddress.ip_address(f_ip)
    						except:
    							print ("Invalid IP %s, line %s" % (f_ip,lines.index(data)+1))
    							errfound = 1
                       
    						try:
    							f_un = d[1]
    						except IndexError:
    							print ("No n7k Username defined in n7k file.  Expecting username in the 2nd column, line %s" % (lines.index(data)+1))
    							errfound = 1
                        
    						try:
    							f_pw = d[2]
    						except IndexError:
    							print ("No n7k Password passed in n7k file.  Expecting password in the 3rd column, line %s" % (lines.index(data)+1)) 
    							errfound = 1
                    
    						if errfound:
    							print ("\nPlease correct creds file passed to the -c|--creds option and try again")    
    							sys.exit(9)
    
    if len(filename) == 0:
        print ("Missing -f|--file option")
        sys.exit(9)
    if len(f_ip) == 0:
        print ("No IP address found in credentials file")
        sys.exit(9)
    if len(f_un) == 0:
        print ("No Username found in credentials file")
        sys.exit(9)
    if len(f_pw) == 0:
        print ("No password found in credentials file")
        sys.exit(9)
    
    commands = load_commands(filename)       
    send_to_n7k_api(f_ip,commands,f_un,f_pw)

if __name__ == '__main__':
	main(sys.argv[1:])
