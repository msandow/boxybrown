var exec = require('child_process').exec;
var pkg = require('./package.json');
var async = require("async");
var fs = require("fs");
var path = require("path");
var build = (process.env.BUILD_TAG || "")
var ENVSTR = (function(){
  if(!build || /develop/.test(build)){
    return "develop";
  }
  return "master";
}()),
regexpEscape = function(str){
  return (str+'').replace(/[.?*+^$[\]\\(){}|-]/g, "\\$&").replace(/\s/g, "\\s")
};

if(!/v(6|14)/i.test(process.version)){
  if(!pkg.postInstallJSON){
    pkg.postInstallJSON = {};
  }
  pkg.postInstallJSON["node-sass"] = "=4.7.2";
}

if(!pkg.postInstallJSON && !pkg.postInstallClone && !pkg.postInstallJSONVersion){
  process.exit(0);
}


var series = [];


if(pkg.postInstallJSON || pkg.postInstallJSONVersion){

  var deps = [];

  if(pkg.postInstallJSON){
    for(var kk in pkg.postInstallJSON){
      if(pkg.postInstallJSON.hasOwnProperty(kk)){

        deps.push(/\.git/i.test(pkg.postInstallJSON[kk]) ? pkg.postInstallJSON[kk] + "#" + ENVSTR : kk + "@" + pkg.postInstallJSON[kk]);

      }
    }

    console.log("Installing", Object.keys(pkg.postInstallJSON).length, "dependencies", ENVSTR);
  }

  if(pkg.postInstallJSONVersion){

    for(var kk in pkg.postInstallJSONVersion){
      if(pkg.postInstallJSONVersion.hasOwnProperty(kk) && new RegExp(regexpEscape(kk), "i").test(process.version)){

        for(var kk2 in pkg.postInstallJSONVersion[kk]){
          if(pkg.postInstallJSONVersion[kk].hasOwnProperty(kk2)){

            deps.push(/\.git/i.test(pkg.postInstallJSONVersion[kk][kk2]) ? pkg.postInstallJSONVersion[kk][kk2] + "#" + ENVSTR : kk2 + "@" + pkg.postInstallJSONVersion[kk][kk2]);

          }
        }

        console.log("Installing", Object.keys(pkg.postInstallJSONVersion[kk]).length, kk + " dependencies");

      }
    }
  }

  if(deps.length){

    series.push(function(acb){
      var script = exec('npm install --no-save ' + deps.join(" "), function(err){
        if (err) {
          console.error('exec error: ', err);
        }else{
          console.info(deps.join(" "), " installed");
        }

        acb();
      });

      script.stdout.setEncoding('utf8');
      script.stderr.setEncoding('utf8');

      script.stdout.on('data', function(data){
        console.log(data.trim()); 
      });

      script.stderr.on('data', function(data){
        console.error(data.trim());
      });
    });

  }

}


if(pkg.postInstallClone){

  for(var kk in pkg.postInstallClone){
    if(pkg.postInstallClone.hasOwnProperty(kk)){

      (function(i){

        var f = i.split("/"),
        f = f[ f.length - 1 ].replace(/\.git.*/gi, ''),
        outputFolder = __dirname + '/node_modules/' + f;

        series.push(function(acb){
          exec('rm -rf ' + outputFolder + '/', function(){
            acb();
          });
        });

        series.push(function(acb){

          var script = exec('git clone ' + i + ' -b ' + ENVSTR + ' --depth 1 -q ' + outputFolder, function(err){
            if (err) {
              console.error('exec error: ', error);
            }
            
            fs.stat(outputFolder, function(err, stats){
              if(err || !stats.isDirectory()){
                console.log("Error creating folder", outputFolder);
              }else{
                console.log("Folder", outputFolder, "created");
              }
              acb();
            });
          })

          script.stdout.setEncoding('utf8');
          script.stderr.setEncoding('utf8');

          script.stdout.on('data', function(data){
              console.log(data.trim()); 
          });

          script.stderr.on('data', function(data){
              console.error(data.trim());
          });

        });

        series.push(function(acb){
          exec('rm -rf ' + outputFolder + '/.git/', function(){
            acb();
          });
        });

      })(pkg.postInstallClone[kk]);

    }
  }

  console.log("Cloning", Object.keys(pkg.postInstallClone).length, "dependencies", ENVSTR);

}

async.series(series, function(){
  process.exit(0);
});