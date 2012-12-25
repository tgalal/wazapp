#ifndef WAPROVIDERPLUGINPROCESS_H
#define WAPROVIDERPLUGINPROCESS_H

#include <AccountSetup/ProviderPluginProcess>
#include <accounts-qt/Accounts/Account>

class WAProviderPluginProcess
{
public:
    WAProviderPluginProcess();

    bool isUniqueInstance;
    int initType;

    Accounts::Account *account;

    std::string accountValueAsString(std::string name);

    int accountId;


};

#endif // WAPROVIDERPLUGINPROCESS_H
