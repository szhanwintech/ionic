var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'WGCA', 'coolMethod', [arg0]);
};
exports.findbackUserBySignet = function (success, error) {
    exec(success, error, 'WGCA', 'findBackUserBySignet');
}
exports.getUserList = function (success, error) {
    exec(success, error, "WGCA", "getUserList");
}
exports.userLogin = function (msspID, signJobID, success, error) {
    exec(success, error, "WGCA", "userLogin", [msspID, signJobID]);
}