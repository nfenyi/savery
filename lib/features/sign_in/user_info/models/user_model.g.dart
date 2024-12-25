// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      uid: fields[0] as String,
      accounts: (fields[1] as HiveList?)?.castHiveList(),
      displayName: fields[2] as String?,
      phoneNumber: fields[3] as String?,
      photoUrl: fields[5] as String?,
      email: fields[4] as String?,
      notifications: (fields[6] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.accounts)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.photoUrl)
      ..writeByte(6)
      ..write(obj.notifications);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      name: fields[0] as String,
      expenses: fields[2] as double,
      transactions: (fields[3] as HiveList?)?.castHiveList(),
      income: fields[1] as double,
      budgets: (fields[4] as HiveList?)?.castHiveList(),
      currency: fields[5] as String?,
      balance: fields[7] as double,
      savingsBucket: fields[8] as double,
      goals: (fields[6] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.income)
      ..writeByte(2)
      ..write(obj.expenses)
      ..writeByte(3)
      ..write(obj.transactions)
      ..writeByte(4)
      ..write(obj.budgets)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.goals)
      ..writeByte(7)
      ..write(obj.balance)
      ..writeByte(8)
      ..write(obj.savingsBucket);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      category: fields[0] as TransactionCategory?,
      amount: fields[1] as double,
      type: BudgetType.values[fields[2] as int],
      duration: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionAdapter extends TypeAdapter<AccountTransaction> {
  @override
  final int typeId = 5;

  @override
  AccountTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountTransaction(
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      description: fields[3] as String,
      type: fields[0] as String,
      category: fields[4] as TransactionCategory?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountTransaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 6;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      fund: fields[0] as double,
      name: fields[3] as String,
      estimatedDate: fields[1] as DateTime,
      createdAt: fields[2] as DateTime,
      raisedAmount: fields[4] as double,
      icon: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.fund)
      ..writeByte(1)
      ..write(obj.estimatedDate)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.raisedAmount)
      ..writeByte(5)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
