import std.array;
import std.json;

import til.nodes;


Item JsonToItem(JSONValue v)
{
    final switch (v.type)
    {
        case JSONType.string:
            return new String(v.get!string);
        case JSONType.integer:
            return new IntegerAtom(v.get!long);
        case JSONType.uinteger:
            return new IntegerAtom(v.get!ulong);
        case JSONType.float_:
            return new FloatAtom(v.get!float);
        case JSONType.true_:
        case JSONType.false_:
            return new BooleanAtom(v.get!bool);
        case JSONType.array:
            return new SimpleList(
                v.array()
                    .map!(x => JsonToItem(x))
                    .array()
            );
        case JSONType.object:
            auto dict = new Dict();
            auto obj = v.object();
            foreach (key; obj.byKey)
            {
                auto value = obj[key];
                dict[key] = JsonToItem(value);
            }
            return dict;
        case JSONType.null_:
            throw new Exception("shit");
    }
}

JSONValue ItemToJson(Item item, bool strict=false)
{
    switch (item.type)
    {
        case ObjectType.Boolean:
            return JSONValue(item.toBool());
        case ObjectType.Integer:
            return JSONValue(item.toInt());
        case ObjectType.Float:
            return JSONValue(item.toFloat());
        case ObjectType.Atom:
        case ObjectType.String:
            return JSONValue(item.toString());
        case ObjectType.SimpleList:
            SimpleList list = cast(SimpleList)item;
            JSONValue[] values = list.items
                    .map!(x => ItemToJson(x, strict))
                    .array;
            return JSONValue(values);
        case ObjectType.Dict:
            Dict dict = cast(Dict)item;
            JSONValue[string] json;
            foreach (key; dict.values.byKey)
            {
                json[key] = ItemToJson(dict[key], strict);
            }
            return JSONValue(json);
        // case ObjectType.Vector:
        // item.typeName = {byte_vector|int_vector|long_vector|...}
        default:
            if (strict)
            {
                throw new Exception("Cannot decode type " ~ to!string(item.type));
            }
            return JSONValue(item.toString());
    }
}


extern (C) CommandsMap getCommands(Escopo escopo)
{
    CommandsMap commands;

    commands["decode"] = new Command((string path, Context context)
    {
        foreach (arg; context.items)
        {
            JSONValue json = parseJSON(arg.toString());
            auto object = JsonToItem(json);
            context.push(object);
        }
        return context;
    });
    commands["encode"] = new Command((string path, Context context)
    {
        foreach (arg; context.items)
        {
            auto json = ItemToJson(arg);
            context.push(json.toString());
        }
        return context;
    });

    return commands;
}
