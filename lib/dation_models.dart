

class Student {
  int id;
  String name;
  int courseId;

  Student(this.id, this.name);

  String toString() {
    return "${super.toString()} (id: $id, name: '$name')";
  }
}

class AgendaEvent {}

class AgendaBlock extends AgendaEvent {
  DateTime start;
  DateTime end;

  AgendaBlock({
    this.start,
    this.end,
  });

  @override
  String toString() {
    return "${super.toString()} ($start - $end)";
  }
}

class Appointment extends AgendaEvent {
  DateTime start;
  DateTime end;
  ItemType itemType;
  List<Student> students = List();
  String remark = '';
  int id;

  Appointment({
    this.id,
    this.start,
    this.end,
    this.itemType,
    this.students,
    this.remark,
  });

  @override
  String toString() {
    return "${super.toString()} ($itemType, $start - $end)";
  }
}

class Instructor {
  int id;

  Instructor(this.id);
}

class User {
  String name;
  int id;

  User(this.id, this.name);
}

class Tenant {
  int id;
  String handle;

  Tenant(this.id, this.handle);
}

class ItemType {
  int id;
  String name;

  ItemType({this.id, this.name});
}