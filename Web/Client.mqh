#ifndef WEB_CLIENT_MQH
#define WEB_CLIENT_MQH

//==================================================

#include "JAson.mqh"

#define JSON CJAVal

//==================================================

class Client
{

protected:

    CJAVal *jsonResponse;
    string rawResponse;
    string rawRequest;

    const int timeout;

    string headers;

    int code;
    string responseHeaders;

public:

    Client(const string headers = NULL, const int timeout = 30000):
        headers(headers),
        timeout(timeout),
        code(0), responseHeaders(NULL),
        rawResponse(""),
        rawRequest("")
    {
        this.jsonResponse = new CJAVal();
    }

    ~Client()
    {
        if ( CheckPointer(this.jsonResponse) == POINTER_DYNAMIC ) {
            delete this.jsonResponse;
        }
    }

    int getHttpCode()
    {
        return this.code;
    }

    string getResponseHeaders()
    {
        return this.responseHeaders;
    }

    string getRawResponse()
    {
        return this.rawResponse;
    }

    string getRawRequest()
    {
        return this.rawRequest;
    }

    int requestRaw(const string method, const string url, const char &data[], char &response[])
    {
        this.code = WebRequest(method, url, this.headers, this.timeout, data, response, this.responseHeaders);

        return this.code;
    }

    string request(const string method, const string url, const string data = NULL)
    {
        char body[], response[];

        this.rawRequest = "";
        if (data != NULL) {
            this.rawRequest = data;
            ArrayResize(body, StringToCharArray(data, body, 0, WHOLE_ARRAY, CP_UTF8) - 1);
        }

        this.requestRaw(method, url, body, response);

        this.rawResponse = CharArrayToString(response, 0, WHOLE_ARRAY, CP_UTF8);

        return this.rawResponse;
    }

    string request(const string method, const string url, CJAVal &json)
    {
        return this.request(method, url, json.Serialize());
    }

    CJAVal *requestJson(const string method, const string url, const string data = NULL)
    {
        if ( CheckPointer(this.jsonResponse) != POINTER_DYNAMIC ) {
            this.jsonResponse = new CJAVal();
        }

        if ( !this.jsonResponse.Deserialize(this.request(method, url, data), CP_UTF8) ) {
            return NULL;
        }

        return this.jsonResponse;
    }

    CJAVal *requestJson(const string method, const string url, CJAVal &json)
    {
        return this.requestJson(method, url, json.Serialize());
    }

    string post(const string url, const string data = NULL)
    {
        return this.request("POST", url, data);
    }

    string post(const string url, CJAVal &json)
    {
        return this.request("POST", url, json);
    }

    CJAVal *postJson(const string url, const string data = NULL)
    {
        return this.requestJson("POST", url, data);
    }

    CJAVal *postJson(const string url, CJAVal &json)
    {
        return this.requestJson("POST", url, json);
    }

    string get(const string url)
    {
        return this.request("GET", url);
    }

    CJAVal *getJson(const string url)
    {
        return this.requestJson("GET", url);
    }
};

#endif