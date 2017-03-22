class TriggleCond(object):
    def __init__(self, table_id, import_type):
        self.table_id = table_id
        self.import_type = import_type

    def __eq__(self, other):
        return self.table_id == other.table_id and self.import_type == other.import_type

    def __ne__(self, other):
        return not self.__eq__(other)

    def __hash__(self):
        return hash((self.table_id, self.import_type))