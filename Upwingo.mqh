#ifndef UPWINGO_MQH
#define UPWINGO_MQH

//==================================================

#include "Web/Client.mqh"

/*
    (!!!)
    To use the WebRequest() function, add the addresses of the required servers (https://api.upwingo.com)
    in the list of allowed URLs in the "Expert Advisors" tab of the "Options" window.
    Server port is automatically selected on the basis of the specified protocol - 80 for "http://"
    and 443 for "https://".

    https://www.mql5.com/en/docs/common/webrequest
*/

//==================================================

#define DEFAULT_HOST "https://api.upwingo.com"

class Upwingo
{

protected:

    const string host;

    Client *client;

    string lastError;


    virtual JSON *request(const string method, const string url, const string data = NULL)
    {
        this.lastError = NULL;

        JSON *res = this.client.requestJson(method, this.host + url, data);
        if ( this.client.getHttpCode() != 200 || res == NULL ) {
            this.lastError = "code " + IntegerToString(this.client.getHttpCode()) + ": " + this.client.getRawResponse();
        } else if ( res["code"].ToInt() != 200 ) {
            this.lastError = "code " + res["code"].ToStr() + ": " + this.client.getRawResponse();
        }

        return res;
    }

    virtual JSON *request(const string method, const string url, JSON &params)
    {
        return this.request(method, url, params.Serialize());
    }

public:

    Upwingo(const string apiKey, const string host = DEFAULT_HOST):
        host(host),
        lastError(NULL)
    {
        this.client = new Client("Authorization: Bearer " + apiKey + "\r\n");
    }

    ~Upwingo()
    {
        delete this.client;
    }

    virtual string getLastError()
    {
        return this.lastError;
    }

    virtual JSON *getTablesList()
    {
        return this.request("GET", "/v1/binary/tables");
    }

    virtual JSON *getNextRoundInfo(JSON &params)
    {
        return this.request("GET", "/v1/binary/round", params);
    }

    virtual JSON *getHistory(JSON &params)
    {
        return this.request("GET", "/v1/binary/history", params);
    }

    virtual JSON *orderCreate(JSON &params)
    {
        return this.request("POST", "/v1/binary/order", params);
    }

    virtual JSON *orderCancel(string orderId)
    {
        return this.request("POST", "/v1/binary/order/" + orderId + "/cancel");
    }

    virtual JSON *getBalance()
    {
        return this.request("GET", "/v1/balance");
    }
};

#endif