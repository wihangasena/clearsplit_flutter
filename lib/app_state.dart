import 'dart:async';

import 'package:flutter/material.dart';

import 'services/backend_client.dart';

class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.displayName,
    required this.email,
    required this.password,
    required this.avatar,
    required this.color,
  });

  final String id;
  final String displayName;
  final String email;
  final String password;
  final String avatar;
  final String color;
}

const List<DemoAccount> demoAccounts = [
  DemoAccount(
    id: 'user-you',
    displayName: 'You',
    email: 'you@clearsplit.app',
    password: 'demo123',
    avatar: '🙂',
    color: '#2563EB',
  ),
  DemoAccount(
    id: 'user-alex',
    displayName: 'Alex',
    email: 'alex@clearsplit.app',
    password: 'demo123',
    avatar: '🧑',
    color: '#10B981',
  ),
  DemoAccount(
    id: 'user-maya',
    displayName: 'Maya',
    email: 'maya@clearsplit.app',
    password: 'demo123',
    avatar: '👩',
    color: '#8B5CF6',
  ),
  DemoAccount(
    id: 'user-jordan',
    displayName: 'Jordan',
    email: 'jordan@clearsplit.app',
    password: 'demo123',
    avatar: '🧔',
    color: '#EF4444',
  ),
];

class Person {
  const Person({required this.id, required this.name, required this.avatar, required this.color});

  final String id;
  final String name;
  final String avatar;
  final String color;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'color': color,
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      color: json['color'] as String,
    );
  }
}

class Group {
  const Group({required this.id, required this.name, required this.emoji, required this.members});

  final String id;
  final String name;
  final String emoji;
  final List<String> members;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'members': members,
      };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      members: List<String>.from(json['members'] as List<dynamic>),
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.category,
    required this.date,
    this.groupId,
    this.note,
    this.settled = false,
    this.personal = false,
  });

  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> participants;
  final String? groupId;
  final String category;
  final DateTime date;
  final String? note;
  final bool settled;
  final bool personal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'participants': participants,
        'groupId': groupId,
        'category': category,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'settled': settled,
        'personal': personal,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      participants: List<String>.from(json['participants'] as List<dynamic>),
      groupId: json['groupId'] as String?,
      category: json['category'] as String,
      date: DateTime.fromMillisecondsSinceEpoch((json['date'] as num).toInt()),
      note: json['note'] as String?,
      settled: (json['settled'] as bool?) ?? false,
      personal: (json['personal'] as bool?) ?? false,
    );
  }
}

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.groupId,
    required this.name,
    this.tag,
    this.qty,
    this.claimedBy,
    this.boughtBy,
    this.price,
    this.done = false,
  });

  final String id;
  final String groupId;
  final String name;
  final String? tag;
  final String? qty;
  final String? claimedBy;
  final String? boughtBy;
  final double? price;
  final bool done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'name': name,
        'tag': tag,
        'qty': qty,
        'claimedBy': claimedBy,
        'boughtBy': boughtBy,
        'price': price,
        'done': done,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      tag: json['tag'] as String?,
      qty: json['qty'] as String?,
      claimedBy: json['claimedBy'] as String?,
      boughtBy: json['boughtBy'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      done: (json['done'] as bool?) ?? false,
    );
  }
}

class AppData {
  const AppData({
    required this.me,
    required this.people,
    required this.groups,
    required this.expenses,
    required this.grocery,
  });

  final String me;
  final List<Person> people;
  final List<Group> groups;
  final List<Expense> expenses;
  final List<GroceryItem> grocery;

  AppData copyWith({
    String? me,
    List<Person>? people,
    List<Group>? groups,
    List<Expense>? expenses,
    List<GroceryItem>? grocery,
  }) {
    return AppData(
      me: me ?? this.me,
      people: people ?? this.people,
      groups: groups ?? this.groups,
      expenses: expenses ?? this.expenses,
      grocery: grocery ?? this.grocery,
    );
  }

  Map<String, dynamic> toJson() => {
        'me': me,
        'people': people.map((person) => person.toJson()).toList(),
        'groups': groups.map((group) => group.toJson()).toList(),
        'expenses': expenses.map((expense) => expense.toJson()).toList(),
        'grocery': grocery.map((item) => item.toJson()).toList(),
      };

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      me: json['me'] as String,
      people: (json['people'] as List<dynamic>)
          .map((entry) => Person.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList(),
      groups: (json['groups'] as List<dynamic>)
          .map((entry) => Group.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>)
          .map((entry) => Expense.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList(),
      grocery: (json['grocery'] as List<dynamic>)
          .map((entry) => GroceryItem.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList(),
    );
  }

  factory AppData.seedForAccount(DemoAccount account) {
    final now = DateTime.now();
    final meId = account.id;
    List<String> uniqueIds(List<String> values) {
      final result = <String>[];
      for (final value in values) {
        if (!result.contains(value)) {
          result.add(value);
        }
      }
      return result;
    }

    final people = <Person>[
      Person(id: meId, name: account.displayName, avatar: account.avatar, color: account.color),
      const Person(id: 'alex', name: 'Alex', avatar: '🧑', color: '#10B981'),
      const Person(id: 'maya', name: 'Maya', avatar: '👩', color: '#8B5CF6'),
      const Person(id: 'jordan', name: 'Jordan', avatar: '🧔', color: '#EF4444'),
      const Person(id: 'chloe', name: 'Chloe', avatar: '👱‍♀️', color: '#F59E0B'),
      const Person(id: 'sam', name: 'Sam', avatar: '👨', color: '#0EA5E9'),
    ]..removeWhere((person) => person.id == meId && person.name != account.displayName);

    return AppData(
      me: meId,
      people: people,
      groups: [
        Group(id: 'beach', name: 'The Beach House', emoji: '🏖️', members: uniqueIds([meId, 'alex', 'maya', 'chloe'])),
        Group(id: 'apt', name: 'The Apartment Crew', emoji: '🏠', members: uniqueIds([meId, 'alex', 'jordan', 'sam'])),
        Group(id: 'trip', name: 'Road Trip 2026', emoji: '🚗', members: uniqueIds([meId, 'maya', 'sam'])),
      ],
      expenses: [
        Expense(
          id: 'e1',
          title: 'Five Guys Dinner',
          amount: 62.5,
          paidBy: meId,
          participants: uniqueIds([meId, 'alex', 'maya', 'jordan', 'sam']),
          groupId: 'apt',
          category: '🍔',
          date: now.subtract(const Duration(hours: 1)),
        ),
        Expense(
          id: 'e2',
          title: 'Grocery Run',
          amount: 90,
          paidBy: 'alex',
          participants: uniqueIds([meId, 'alex']),
          groupId: 'apt',
          category: '🛒',
          date: now.subtract(const Duration(hours: 26)),
        ),
        Expense(
          id: 'e3',
          title: 'Utilities - Oct',
          amount: 240,
          paidBy: meId,
          participants: uniqueIds([meId, 'alex', 'jordan', 'sam']),
          groupId: 'apt',
          category: '⚡',
          date: now.subtract(const Duration(days: 2)),
        ),
        Expense(
          id: 'e4',
          title: 'Cinema Tickets',
          amount: 48,
          paidBy: meId,
          participants: uniqueIds([meId, 'maya']),
          groupId: 'trip',
          category: '🎬',
          date: now.subtract(const Duration(days: 5)),
        ),
        Expense(
          id: 'e5',
          title: 'Beach BBQ',
          amount: 120,
          paidBy: 'chloe',
          participants: uniqueIds([meId, 'alex', 'maya', 'chloe']),
          groupId: 'beach',
          category: '🔥',
          date: now.subtract(const Duration(days: 9)),
          settled: true,
        ),
        Expense(
          id: 'p1',
          title: 'Morning Coffee',
          amount: 4.75,
          paidBy: meId,
          participants: uniqueIds([meId]),
          category: '☕',
          date: now.subtract(const Duration(hours: 2)),
          personal: true,
          note: 'Food',
        ),
        Expense(
          id: 'p2',
          title: 'Metro Card',
          amount: 30,
          paidBy: meId,
          participants: uniqueIds([meId]),
          category: '🚇',
          date: now.subtract(const Duration(days: 1)),
          personal: true,
          note: 'Transport',
        ),
        Expense(
          id: 'p3',
          title: 'Spotify',
          amount: 10.99,
          paidBy: meId,
          participants: uniqueIds([meId]),
          category: '🎧',
          date: now.subtract(const Duration(days: 3)),
          personal: true,
          note: 'Bills',
        ),
        Expense(
          id: 'p4',
          title: 'Gym Membership',
          amount: 45,
          paidBy: meId,
          participants: uniqueIds([meId]),
          category: '💪',
          date: now.subtract(const Duration(days: 6)),
          personal: true,
          note: 'Health',
        ),
      ],
      grocery: [
        GroceryItem(id: 'g1', groupId: 'apt', name: 'Almond Milk', tag: 'DAIRY FREE', qty: '2 cartons', claimedBy: 'alex'),
        GroceryItem(id: 'g2', groupId: 'apt', name: 'Avocados', tag: 'PRODUCE', qty: 'Pack of 4'),
        GroceryItem(id: 'g3', groupId: 'apt', name: 'Fresh Pasta', boughtBy: 'alex', price: 12.5, done: true),
        GroceryItem(id: 'g4', groupId: 'apt', name: 'Greek Yogurt'),
        GroceryItem(id: 'g5', groupId: 'apt', name: 'Eggs', qty: 'Dozen'),
        GroceryItem(id: 'g6', groupId: 'apt', name: 'Bread', tag: 'BAKERY'),
      ],
    );
  }
}

class BalanceSummary {
  const BalanceSummary({required this.owed, required this.owe, required this.net, required this.perPerson});

  final double owed;
  final double owe;
  final double net;
  final Map<String, double> perPerson;
}

class AppController extends ChangeNotifier {
  AppController({BackendClient? backendClient}) : _backendClient = backendClient ?? BackendClient();

  final BackendClient _backendClient;
  DemoAccount? _activeAccount;
  AppData _state = AppData.seedForAccount(demoAccounts.first);

  AppData get state => _state;

  bool get isSignedIn => _activeAccount != null;

  DemoAccount? get activeAccount => _activeAccount;

  List<DemoAccount> get availableAccounts => demoAccounts;

  DemoAccount? accountByEmail(String email) {
    for (final account in demoAccounts) {
      if (account.email.toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      final session = await _backendClient.signIn(email: email.trim(), password: password);
      _activeAccount = session.account;
      _state = session.state;
      notifyListeners();
      return null;
    } on BackendAuthException catch (error) {
      return error.message;
    } on BackendClientException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to connect to the backend.';
    }
  }

  Future<void> signOut() async {
    if (_activeAccount != null) {
      unawaited(_backendClient.saveState(userId: _activeAccount!.id, state: _state));
    }
    _activeAccount = null;
    _state = AppData.seedForAccount(demoAccounts.first);
    notifyListeners();
  }

  Future<void> resetCurrentAccount() async {
    if (_activeAccount == null) {
      _state = AppData.seedForAccount(demoAccounts.first);
      notifyListeners();
      return;
    }

    _state = AppData.seedForAccount(_activeAccount!);
    notifyListeners();
    unawaited(_backendClient.saveState(userId: _activeAccount!.id, state: _state));
  }

  void _update(AppData next) {
    _state = next;
    notifyListeners();
    if (_activeAccount != null) {
      unawaited(_backendClient.saveState(userId: _activeAccount!.id, state: next));
    }
  }

  Person? personById(String id) {
    for (final person in _state.people) {
      if (person.id == id) {
        return person;
      }
    }
    return null;
  }

  Group? groupById(String id) {
    for (final group in _state.groups) {
      if (group.id == id) {
        return group;
      }
    }
    return null;
  }

  List<Expense> get recentSharedExpenses => _state.expenses.where((expense) => !expense.personal).take(4).toList();

  List<Expense> get personalExpenses => _state.expenses.where((expense) => expense.personal).toList();

  List<Expense> get sharedExpenses => _state.expenses.where((expense) => !expense.personal).toList();

  List<GroceryItem> groceryForGroup(String groupId) => _state.grocery.where((item) => item.groupId == groupId).toList();

  BalanceSummary computeBalances() {
    double owed = 0;
    double owe = 0;
    final perPerson = <String, double>{};

    for (final expense in _state.expenses) {
      if (expense.settled || expense.personal) {
        continue;
      }
      if (!expense.participants.contains(_state.me) && expense.paidBy != _state.me) {
        continue;
      }

      final share = expense.amount / expense.participants.length;
      for (final participantId in expense.participants) {
        if (participantId == expense.paidBy) {
          continue;
        }
        if (expense.paidBy == _state.me) {
          perPerson[participantId] = (perPerson[participantId] ?? 0) + share;
        } else if (participantId == _state.me) {
          perPerson[expense.paidBy] = (perPerson[expense.paidBy] ?? 0) - share;
        }
      }
    }

    for (final value in perPerson.values) {
      if (value > 0) {
        owed += value;
      } else {
        owe += -value;
      }
    }

    return BalanceSummary(owed: owed, owe: owe, net: owed - owe, perPerson: perPerson);
  }

  double get personalTotal => personalExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  Group? get topGroup => _state.groups.isEmpty ? null : _state.groups.first;

  double groupTotal(String groupId) => _state.expenses.where((expense) => expense.groupId == groupId).fold<double>(0, (sum, expense) => sum + expense.amount);

  int settledPercent(String groupId) {
    final groupExpenses = _state.expenses.where((expense) => expense.groupId == groupId).toList();
    if (groupExpenses.isEmpty) {
      return 0;
    }
    final settled = groupExpenses.where((expense) => expense.settled).length;
    return ((settled / groupExpenses.length) * 100).round();
  }

  void addExpense({
    required String title,
    required double amount,
    required String paidBy,
    required List<String> participants,
    required String category,
    String? groupId,
    String? note,
    bool settled = false,
    bool personal = false,
    DateTime? date,
  }) {
    final normalizedParticipants = <String>{...participants};
    if (personal) {
      normalizedParticipants
        ..clear()
        ..add(_state.me);
      groupId = null;
    } else if (!normalizedParticipants.contains(paidBy)) {
      normalizedParticipants.add(paidBy);
    }

    final updated = Expense(
      id: 'e${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      amount: amount,
      paidBy: paidBy,
      participants: normalizedParticipants.toList(),
      groupId: groupId,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
      settled: settled,
      personal: personal,
    );

    _update(_state.copyWith(expenses: [updated, ..._state.expenses]));
  }

  void createGroup({required String name, required String emoji}) {
    final next = Group(
      id: 'g${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      members: [_state.me],
    );
    _update(_state.copyWith(groups: [..._state.groups, next]));
  }

  void addMemberToGroup(String groupId, String personId) {
    final group = groupById(groupId);
    if (group == null) return;
    if (group.members.contains(personId)) return;
    final updated = Group(id: group.id, name: group.name, emoji: group.emoji, members: [...group.members, personId]);
    final nextGroups = _state.groups.map((g) => g.id == groupId ? updated : g).toList();
    _update(_state.copyWith(groups: nextGroups));
  }

  void removeMemberFromGroup(String groupId, String personId) {
    final group = groupById(groupId);
    if (group == null) return;
    if (!group.members.contains(personId)) return;
    final updated = Group(id: group.id, name: group.name, emoji: group.emoji, members: group.members.where((m) => m != personId).toList());
    final nextGroups = _state.groups.map((g) => g.id == groupId ? updated : g).toList();
    _update(_state.copyWith(groups: nextGroups));
  }

  void markSettled(String id) {
    final nextExpenses = _state.expenses
        .map((expense) => expense.id == id ? Expense(
              id: expense.id,
              title: expense.title,
              amount: expense.amount,
              paidBy: expense.paidBy,
              participants: expense.participants,
              groupId: expense.groupId,
              category: expense.category,
              date: expense.date,
              note: expense.note,
              settled: true,
              personal: expense.personal,
            ) : expense)
        .toList();
    _update(_state.copyWith(expenses: nextExpenses));
  }

  Future<void> reset() => resetCurrentAccount();
}

String money(double value) => '\$${value.toStringAsFixed(2)}';

String moneySigned(double value) => value >= 0 ? '+${money(value)}' : '-${money(value.abs())}';

String timeAgo(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) {
    return 'just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return diff.inHours == 1 ? '1h ago' : '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  return '${when.month}/${when.day}';
}

