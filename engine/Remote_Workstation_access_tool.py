from flask import Flask,request,jsonify
from Workstation_access_tool_services import validate_credentials,add_user,remove_user
import traceback
import sys

app = Flask(__name__)

# workstations_string = '10.144.129.169'
# userids_string = 'c812105'
# NoOfDays = '10'

@app.route('/login',methods=['POST'])
def login():
	username = 'c737960'
	password = 'nov@1967'
	if validate_credentials(username, password):
		return 'Valid User!'
	else:
		return 'Invalid User!'

@app.route('/addUser',methods=['POST'])
def adduser():
	try:
		add_result = {}
		print (request.is_json)
		req_obj = request.get_json()
		print(req_obj)
		add = add_user(req_obj['workstations_string'],req_obj['userids_string'],req_obj['NoOfDays'],req_obj['Incident_No'])
		print (add.decode('utf-8'))
		add_result.update({'add_msg': add.decode('utf-8')})
		return jsonify(add_result)
	except:
		err_dict = {}
		msg = 'Module Name      : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][0]) + '\nLine Number      : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][1]) + '\nLine Details     : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][3])
		msg1 = str(sys.exc_info()[0])[str(sys.exc_info()[0]).find("'") + 1:str(sys.exc_info()[0]).rfind("'")]
		msg2 = str(sys.exc_info()[1])
		err_msg = msg + '\nException Type   : ' + msg1 + '\nException Detail : ' + msg2 + '\n \nError! Please contact Auto-IT team.'
		err_dict.update({'err_dict':err_msg.decode('utf-8')})
		return jsonify(err_dict)

@app.route('/removeUser',methods=['POST'])
def removeUser():
	try:
		remove_result = {}
		req_obj = request.get_json()
		remove = remove_user(req_obj['workstations_string'],req_obj['userids_string'])
		remove_result.update({'add_msg': remove.decode('utf-8')})
		return jsonify(remove_result)
	except:
		err_dict = {}
		msg = 'Module Name      : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][0]) + '\nLine Number      : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][1]) + '\nLine Details     : ' + str(traceback.extract_tb(sys.exc_info()[2])[0][3])
		msg1 = str(sys.exc_info()[0])[str(sys.exc_info()[0]).find("'") + 1:str(sys.exc_info()[0]).rfind("'")]
		msg2 = str(sys.exc_info()[1])
		err_msg = msg + '\nException Type   : ' + msg1 + '\nException Detail : ' + msg2 + '\n \nError! Please contact Auto-IT team.'
		err_dict.update({'err_dict':err_msg.decode('utf-8')})
		return jsonify(err_dict)
