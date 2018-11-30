import subprocess

def validate_credentials(username, password):
	print ('validate_credentials')
	si = subprocess.STARTUPINFO()
	si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
	command_line = 'powershell -executionpolicy bypass -File Validate-Credential.ps1 sbicza01\\"'+username+'" "'+password+'"'
	p = subprocess.Popen(['powershell.exe', command_line], stdout=subprocess.PIPE, startupinfo=si)
	output_result = str(p.communicate())
	if ('True' in output_result):
		return True
	else:
		return False
def add_user(workstations_string,userids_string,NoOfDays,Incident_No):
	print ('Add user call')
	si = subprocess.STARTUPINFO()
	si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
	print (workstations_string)
	control_command = 'powershell -executionpolicy bypass -Command .\\add_user.ps1 "'+workstations_string+'" "'+userids_string+'" "'+NoOfDays+'" "'+Incident_No+'"'
	print (control_command)
	process = subprocess.Popen(['powershell.exe',control_command],stdin=subprocess.PIPE,stdout=subprocess.PIPE,  startupinfo=si)
	output = process.communicate()[0]
	output.strip()
	return output
def remove_user(workstations_string,userids_string):
	print ('Remove user call')
	si = subprocess.STARTUPINFO()
	si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
	print (workstations_string)
	control_command = 'powershell -executionpolicy bypass -Command .\\RemoveUser.ps1 "'+workstations_string+'" "'+userids_string+'"'
	print (control_command)
	process = subprocess.Popen(['powershell.exe',control_command],stdin=subprocess.PIPE,stdout=subprocess.PIPE,  startupinfo=si)
	output = process.communicate()[0]
	print(output.strip())
	return output