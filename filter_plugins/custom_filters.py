def flatten_dict(d, parent_key="", sep="."):
    """
    Recursively flattens a nested dictionary into dot-notation keys.
    """
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else str(k)
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


class FilterModule(object):
    def filters(self):
        return {"flatten_dict": flatten_dict}
