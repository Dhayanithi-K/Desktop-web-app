
            console.log("signin loaded");
            let $ = require('jquery')
            let fs = require('fs')
            let filename = 'authorities'
            let cfname = 'Certificate.pem'
            const {app,BrowserWindow} = require('electron').remote
            const ipc = require('electron').ipcRenderer;
            //ldap
            let txtUser=$('#ldapid').val();
            let txtPwd=$('#pwdtxt').val();
            var username = txtUser
            //var password = txtPwd
            var http = require("http");
            var options = {
                            "method": "POST",
                            "hostname": [
                            "10",
                            "95",
                            "226",
                            "32"
                            ],
                            "port": "8080",
                            "path": [
                            "cardgame"
                            ],
                            "headers": {
                            "Content-Type": "application/json",
                            "cache-control": "no-cache"
                            }
            };
                        

             
            $('#ldapid').focus();            

            function init() {
                // Minimize task
                document.getElementById("min-btn").addEventListener("click", (e) => {
                    var window = BrowserWindow.getFocusedWindow();
                    window.minimize();
                });

                // Close app
                document.getElementById("close-btn").addEventListener("click", (e) => {
                    //var window = BrowserWindow.getFocusedWindow();
                    //window.close();
                    app.quit();
                });
            };

            function get_request(res) {
                    var chunks = [];

                    res.on("data", function (chunk) {
                             chunks.push(chunk);
                    });

                    res.on("end", function () {
                        var body = Buffer.concat(chunks);
                        var out=body.toString()
                        console.log(out);

                        M.toast({html: out})
                    });
            };

            document.onreadystatechange =  () => {
                if (document.readyState == "complete") {
                    init();
                }
            };


            //on click of login button
            $('#login-btn').on('click', () => {
                console.log("login clicked");
                //var req = http.request(options, get_request(res))
                var req = http.request(options, function (res) {
                            var chunks = [];

                            res.on("data", function (chunk) {
                            chunks.push(chunk);
                            });

                            res.on("end", function () {
                            var body = Buffer.concat(chunks);
                            console.log(body.toString());
                            });
                            });
                req.write(JSON.stringify({ userid: txtUser }));
                req.end();                

                    if(txtUser==usr && txtPwd==pass){
                        $('.progress').removeClass("hide");
                        window.setTimeout(function(){
                         // do whatever you want to do
                         ipc.sendSync('entry-accepted', 'ping')     
                          }, 600);
                    }
                    else if (txtUser.length==0 || txtPwd.length==0){
                        //$('#lbl').text('username or password is incorrect')
                        M.toast({html: '<i class="material-icons">sentiment_very_dissatisfied</i>Username/password is missing', classes: 'rounded',displayLength:1500})
                        if(txtUser.length==0){
                            $('#ldapid').focus();
                        }
                        else{
                            $('#pwdtxt').focus();
                        }
                    }
                    else{
                        //$('#lbl').text('username or password is incorrect')                        
                        $('#pwdtxt').val('').removeClass('valid');
                        $('#ldapid').val('').removeClass('valid');
                        //M.updateTextFields();
                        $('#ldapid').focus();
                        M.toast({html: '<i class="material-icons">fingerprint</i>Incorrect username/password', classes: 'rounded',displayLength:1500})
                    }
                    
               

            });



            //on click of login button
/*            $('#login-btn').on('click', () => {
                console.log("login clicked");
             
            // to be changed as routing to python code to authenticate  
                if(fs.existsSync(filename)) {
                let data = fs.readFileSync(filename, 'utf8').split('\n')
                

                data.forEach((authorities, index) => {
                    let [ user, password ] = authorities.split(',')
                    console.log(user)
                    console.log(password)
                    let [name1,usr]=user.split(':')
                    let [name2,pass]=password.split(':')

                    

                    if(txtUser==usr && txtPwd==pass){
                        $('.progress').removeClass("hide");
                        window.setTimeout(function(){
                         // do whatever you want to do
                         ipc.sendSync('entry-accepted', 'ping')     
                          }, 600);
                    }
                    else if (txtUser.length==0 || txtPwd.length==0){
                        //$('#lbl').text('username or password is incorrect')
                        M.toast({html: '<i class="material-icons">sentiment_very_dissatisfied</i>Username/password is missing', classes: 'rounded',displayLength:1500})
                        if(txtUser.length==0){
                            $('#ldapid').focus();
                        }
                        else{
                            $('#pwdtxt').focus();
                        }
                    }
                    else{
                        //$('#lbl').text('username or password is incorrect')                        
                        $('#pwdtxt').val('').removeClass('valid');
                        $('#ldapid').val('').removeClass('valid');
                        //M.updateTextFields();
                        $('#ldapid').focus();
                        M.toast({html: '<i class="material-icons">fingerprint</i>Incorrect username/password', classes: 'rounded',displayLength:1500})
                    }
                    
                    })
                }

            });

*/