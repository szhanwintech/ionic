package com.hanwintech.ca;

import android.app.Activity;

import com.google.gson.Gson;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.org.bjca.signet.component.core.activity.SignetCoreApi;
import cn.org.bjca.signet.component.core.activity.SignetToolApi;
import cn.org.bjca.signet.component.core.bean.results.FindBackUserResult;
import cn.org.bjca.signet.component.core.bean.results.GetUserListResult;
import cn.org.bjca.signet.component.core.bean.results.LoginResult;
import cn.org.bjca.signet.component.core.callback.FindBackUserCallBack;
import cn.org.bjca.signet.component.core.callback.LoginCallBack;
import cn.org.bjca.signet.component.core.enums.FindBackType;
import cn.org.bjca.signet.component.core.enums.IdCardType;

public class WGCA extends CordovaPlugin {

    private Activity activity;
    private CallbackContext callbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        activity = cordova.getActivity();
    }

    @Override
    public boolean execute(String action, String rawArgs, CallbackContext callbackContext) throws JSONException {
        return super.execute(action, rawArgs, callbackContext);
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        return super.execute(action, args, callbackContext);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("findBackUser")) {
            findBackUser(args.getString(0), args.getString(1), args.getInt(2));
            return true;
        } else if (action.equals("findBackUserBySignet")) {
            findBackUserBySignet();
            return true;
        } else if (action.equals("userLogin")) {
            login(args.getString(0), args.getString(1));
            return true;
        } else if (action.equals("getUserList")) {
            getUserList();
            return true;
        }
        return false;
    }

    /**
     * 找回用户
     *
     * @param name
     * @param cardNumber
     * @param cardType
     */
    private void findBackUser(String name, String cardNumber, int cardType) {
        try {
            IdCardType idCardType = IdCardType.GA;
            for (IdCardType type : IdCardType.values()) {
                if (type.hashCode() == cardType) {
                    idCardType = type;
                    break;
                }
            }
            SignetCoreApi.useCoreFunc(new FindBackUserCallBack(activity, name, cardNumber, idCardType) {
                @Override
                public void onFindBackResult(FindBackUserResult findBackUserResult) {
                    try {
                        if (findBackUserResult.getErrCode() == "0x00000000") {
                            Gson gson = new Gson();
                            String jsonStr = gson.toJson(findBackUserResult);
                            JSONObject jsonObject = new JSONObject(jsonStr);
                            callbackContext.success(jsonObject);
                        } else {
                            callbackContext.error(findBackUserResult.getErrMsg());
                        }
                    } catch (Exception e) {
                        callbackContext.error(e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    /**
     * 使用输入信息方式找回用户
     */
    private void findBackUserBySignet() {
        try {
            SignetCoreApi.useCoreFunc(new FindBackUserCallBack(activity, FindBackType.FINDBACK_USER) {
                @Override
                public void onFindBackResult(FindBackUserResult result) {
                    try {
                        if (result.getErrCode() == "0x00000000") {
                            Gson gson = new Gson();
                            String jsonStr = gson.toJson(result);
                            JSONObject jsonObject = new JSONObject(jsonStr);
                            callbackContext.success(jsonObject);
                        } else {
                            callbackContext.error(result.getErrMsg());
                        }
                    } catch (Exception e) {
                        callbackContext.error(e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    /**
     * 登录
     *
     * @param signId
     * @param msspId
     */
    private void login(String msspId, String signId) {
        try {
            SignetCoreApi.useCoreFunc(new LoginCallBack(activity, msspId, signId) {
                @Override
                public void onLoginResult(LoginResult loginResult) {
                    try {
                        if (loginResult.getErrCode() == "0x00000000") {
                            Gson gson = new Gson();
                            String jsonStr = gson.toJson(loginResult);
                            JSONObject jsonObject = new JSONObject(jsonStr);
                            callbackContext.success(jsonObject);
                        } else {
                            callbackContext.error(loginResult.getErrMsg());
                        }
                    } catch (Exception e) {
                        callbackContext.error(e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

    /**
     * 获取用户列表
     */
    private void getUserList() {
        try {
            GetUserListResult userListResult = SignetToolApi.getUserList(activity);
            if (userListResult.getErrCode() == "0x00000000") {
                Gson gson = new Gson();
                String jsonStr = gson.toJson(userListResult);
                JSONObject jsonObject = new JSONObject(jsonStr);
                callbackContext.success(jsonObject);
            } else {
                callbackContext.error(userListResult.getErrMsg());
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }
}