#ifndef TOML_CONFIG_H
#define TOML_CONFIG_H

#include <unordered_map>
#include "config.h"
#include "toml/comments.hpp"
#include "toml/value.hpp"

class CTomlConfig final : public IConfig {
private:
    toml::basic_value<toml::discard_comments, std::unordered_map, std::vector> data;
    std::string save_filename;
public:
    CTomlConfig() : CTomlConfig("") {}
    explicit CTomlConfig(const std::string& filename);

    bool SaveConfig(const std::string& filename) override;
    bool LoadConfig(const std::string& filename) override;
    bool ReloadConfig() override;

    std::variant<std::monostate, bool, long long, std::string> getValue(const std::string& key) override;
    bool setValue(const std::string& key, std::variant<bool, long long, std::string> value) override;
};

#endif //TOML_CONFIG_H
