#include "toml_config.h"
#include <toml.hpp>
#include <fstream>

CTomlConfig::CTomlConfig(const std::string& filename) {
    data = nullptr;
    save_filename = filename;
}

bool CTomlConfig::SaveConfig(const std::string& filename) {
    if(data.is_uninitialized())
        return true;
    auto serial = toml::format(data);

    std::ofstream file;
    file.open(filename);

    if(!file.good())
        return true;

    file << serial;
    file.close();

    save_filename = filename;

    return false;
}

bool CTomlConfig::LoadConfig(const std::string& filename) {
    data = toml::parse(filename);
    if(data.is_uninitialized())
        return true;
    save_filename = filename;
    return false;
}

bool CTomlConfig::ReloadConfig() {
    if(save_filename.empty())
        return true;
    LoadConfig(save_filename);
    return false;
}

std::variant<std::monostate, bool, long long, std::string> CTomlConfig::getValue(const std::string &key) {
    if(data.is_uninitialized())
        return std::monostate();

    toml::value value = find(data, key);

    switch (value.type()) {
        case toml::value_t::string:
            return value.as_string();
        case toml::value_t::boolean:
            return value.as_boolean();
        case toml::value_t::integer:
            return value.as_integer();
        default:
            return std::monostate();
    }
}

bool CTomlConfig::setValue(const std::string &key, std::variant<bool, long long, std::string> value) {
    if(data.is_uninitialized())
        return true;

    if(!data.contains(key))
        return true;

    if(std::holds_alternative<bool>(value))
        data[key] = get<bool>(value);
    else if(std::holds_alternative<long long>(value))
        data[key] = get<long long>(value);
    else if(std::holds_alternative<std::string>(value))
        data[key] = get<std::string>(value);

    return false;
}

