#include "Upwingo.mqh"

/*
    (!!!)
    To use the WebRequest() function, add the addresses of the required servers (https://api.upwingo.com)
    in the list of allowed URLs in the "Expert Advisors" tab of the "Options" window.
    Server port is automatically selected on the basis of the specified protocol - 80 for "http://"
    and 443 for "https://".

    https://www.mql5.com/en/docs/common/webrequest
*/

void OnStart()
{
    Upwingo *upwingo = new Upwingo("XXX");

    string currency = "FREE";

    JSON balances = upwingo.getBalance();
    if ( upwingo.getLastError() != NULL ) {
        Print(upwingo.getLastError());
    } else {
        Print("balance: ", balances["data"]["FREE"][currency].ToDbl());
    }

    JSON order;
    order["table_id"]   = "bina--btc_usdt--10--micro--single:FREE--pvp";
    order["amount"]     = 10.0;
    order["currency"]   = currency;
    order["type"]       = -1;

    JSON r = upwingo.orderCreate(order);
    if ( upwingo.getLastError() != NULL ) {
        Print(upwingo.getLastError());
    } else {
        Print("order: ", r["data"]["order_id"].ToStr(), " balance: ", r["balance"]["FREE"][currency].ToDbl());
    }

    delete upwingo;
}