// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

            console.log("renderer loaded");
            let $ = require('jquery')
            let fs = require('fs')
            const {BrowserWindow} = require('electron').remote
            const ipc = require('electron').ipcRenderer;
function reset() { 
	$('#ldapid').val('').removeClass('valid');
	$('#wrkstn').val('').removeClass('valid');
	$('#date_lim').val('').removeClass('valid');
	$('#inc_no').val('').removeClass('valid');
	//M.updateTextFields();
	$('#ldapid').focus();
	//M.AutoInit();
};  
function init() {
				$('#ldapid').focus();
                // Minimize task
                document.getElementById("min-btn").addEventListener("click", (e) => {
                    var window = BrowserWindow.getFocusedWindow();
                    window.minimize();
                });

                // Close app
                document.getElementById("close-btn").addEventListener("click", (e) => {
                    var window = BrowserWindow.getFocusedWindow();
                    window.close();
                });
                document.getElementById("add-btn").addEventListener("click", (e) => {
                    reset();
                    $('#win-head').text("Add User");
                    $('#win-icon').text("add_box");
                    $('#date_lim').prop("disabled",false);
                    $('.date_lim').removeClass('hide');
                    $('#add_div').addClass('glass');
                    $('#rem_div').removeClass('glass');
                    $('#mod_div').removeClass('glass');
                    $('#logout_div').removeClass('glass');
                    
                });
                document.getElementById("rem-btn").addEventListener("click", (e) => {
                	//M.AutoInit();
                	reset();
                    $('#win-head').text("Remove User");
                    $('#win-icon').text("remove");
                    $('#date_lim').prop("disabled",true);
                    $('.date_lim').addClass('hide');
                    $('#add_div').removeClass('glass');
                    $('#rem_div').addClass('glass');
                    $('#mod_div').removeClass('glass');
                    $('#logout_div').removeClass('glass');
                });
                document.getElementById("mod-btn").addEventListener("click", (e) => {
                    reset();
                    $('#win-head').text("Modify User");
                    $('#win-icon').text("edit");
                    $('#date_lim').prop("disabled",false);
                    $('.date_lim').removeClass('hide');
                    $('#add_div').removeClass('glass');
                    $('#rem_div').removeClass('glass');
                    $('#mod_div').addClass('glass');
                    $('#logout_div').removeClass('glass');
                });


            };
            $('#logout-btn').on('click', () => {
            	console.log("logging out:");
            	var window = BrowserWindow.getFocusedWindow();
            	//var window = BrowserWindow.getAllWindows();
            	console.log(window);
            	//window.webContents.session.clearCache(function(){console.log('cleared all cookies ');});
            	ipc.send('entry-accepted', 'logout');

            });

document.onreadystatechange =  () => {
                if (document.readyState == "complete") {
                    init();
                }
            };