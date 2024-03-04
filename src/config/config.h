#ifndef CONFIG_H
#define CONFIG_H

#include <variant>
#include <string>
#include <vector>

class IConfig {
public:
    virtual bool SaveConfig(const std::string& filename) = 0;
    virtual bool LoadConfig(const std::string& filename) = 0;
    virtual bool ReloadConfig() = 0;

    virtual std::variant<std::monostate, bool, long long, std::string> getValue(const std::string& key) = 0;
    virtual bool setValue(const std::string& key, std::variant<bool, long long, std::string> value) = 0;

    virtual ~IConfig() = 0;
};

#endif //CONFIG_H
