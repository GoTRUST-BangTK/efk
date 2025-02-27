function extract_id(json_str)
    local pattern = '%[.*]%s'
    local id = json_str:match(pattern)
    return id
end
function remove_id(json_str)
    local pattern = '%[.*]%s'
    json_str = json_str:gsub(pattern, '')
    return json_str
end
function transform_log(tag, timestamp, record)
    -- local log_str = record["log"]
    -- local log_record = json_decode(log_str)
    -- local id = extract_id(log_record["@mt"])
    local id = extract_id(record["@mt"])

    record["Id"] = id
    record["Timestamp"] = record["@t"]
    record["Message"] = remove_id(record["@mt"])
    if record["@l"] and record["@l"] ~= "" then
        record["Level"] = record["@l"]
    else
        record["Level"] = "Info"
    end
    
    record["@t"] = nil
    record["@mt"] = nil
    record["@ml"] = nil

    return 1, timestamp, record
end