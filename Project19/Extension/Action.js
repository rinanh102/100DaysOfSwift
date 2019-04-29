var Action = function(){ };

Action.prototype = {
    
run: function(parameters){
    // send data to our extension: the URL the user was visiting, and the title of the page
    parameters.completionFunction({"URL": document.URL, "title": document.title});
    
},
finalize: function(parameters){
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}
};

var ExtensionPreprocessingJS = new Action 
