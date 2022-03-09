import std.array;
import std.json;

import til.nodes;


class JsonDict : Dict
{
    JSONValue values;

    this(JSONValue values)
    {
        this.values = values;
    }
    override Item opIndex(string k)
    {
        JSONValue v;
        try
        {
            v = values[k];
        }
        catch (JSONException)
        {
            throw new Exception("key " ~ k ~ " not found");
        }

        return JsonToItem(v);
    }
}

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
            return new JsonDict(v);
        case JSONType.null_:
            throw new Exception("shit");
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

    return commands;
}
