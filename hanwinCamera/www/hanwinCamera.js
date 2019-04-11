var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'hanwinCamera', 'coolMethod', [arg0]);
};
exports.getCamera = function (imgUrl, success, error) {
    exec(success, error, 'hanwinCamera', 'getCamera', [imgUrl]);
}