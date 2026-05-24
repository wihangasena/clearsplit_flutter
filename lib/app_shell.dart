import 'package:flutter/material.dart';

import 'app_state.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return controller.state.people.isEmpty
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : BuddySplitHome(controller: controller);
      },
    );
  }
}

class BuddySplitHome extends StatefulWidget {
  const BuddySplitHome({super.key, required this.controller});

  final AppController controller;

  @override
  State<BuddySplitHome> createState() => _BuddySplitHomeState();
}

class _BuddySplitHomeState extends State<BuddySplitHome> {
  int _index = 0;

  void _openScan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanScreen(controller: widget.controller),
      ),
    );
  }

  void _setIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        controller: widget.controller,
        onOpenGroups: () => _setIndex(1),
        onOpenMyExpenses: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MyExpensesScreen(controller: widget.controller),
            ),
          );
        },
        onOpenAddExpense: () => showAddExpenseSheet(context, widget.controller),
        onOpenGroup: (groupId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupDetailScreen(controller: widget.controller, groupId: groupId),
            ),
          );
        },
      ),
      GroupsScreen(
        controller: widget.controller,
        onOpenGroup: (groupId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupDetailScreen(controller: widget.controller, groupId: groupId),
            ),
          );
        },
        onCreateGroup: () => showCreateGroupSheet(context, widget.controller),
      ),
      ActivityScreen(controller: widget.controller),
      ProfileScreen(controller: widget.controller),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScan,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 18,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white.withValues(alpha: 0.96),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 78,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    label: 'Dashboard',
                    icon: Icons.grid_view_rounded,
                    active: _index == 0,
                    onTap: () => _setIndex(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Groups',
                    icon: Icons.groups_rounded,
                    active: _index == 1,
                    onTap: () => _setIndex(1),
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(
                  child: _NavItem(
                    label: 'Activity',
                    icon: Icons.receipt_long_rounded,
                    active: _index == 2,
                    onTap: () => _setIndex(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Profile',
                    icon: Icons.person_rounded,
                    active: _index == 3,
                    onTap: () => _setIndex(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.icon, required this.active, required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFC7F3E7) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 22, color: active ? colorScheme.primary : Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? colorScheme.primary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onOpenGroups,
    required this.onOpenMyExpenses,
    required this.onOpenAddExpense,
    required this.onOpenGroup,
  });

  final AppController controller;
  final VoidCallback onOpenGroups;
  final VoidCallback onOpenMyExpenses;
  final VoidCallback onOpenAddExpense;
  final void Function(String groupId) onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final balances = controller.computeBalances();
    final topGroup = controller.topGroup;
    final recent = controller.recentSharedExpenses;
    final groupExpenses = topGroup == null ? <Expense>[] : state.expenses.where((expense) => expense.groupId == topGroup.id).toList();
    final settledPct = topGroup == null ? 0 : controller.settledPercent(topGroup.id);
    final personalTotal = controller.personalTotal;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          _PageHeader(
            title: 'clearsplit',
            subtitle: 'Split bills with friends, instantly',
            trailing: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFDDF4EE),
              child: Text(state.people.first.avatar, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabel(text: 'QUICK POKE'),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final person = state.people.where((person) => person.id != state.me).toList()[index];
                return _PersonPokeCard(
                  person: person,
                  onTap: () => _toast(context, 'Poked ${person.name} - they will get a reminder.'),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemCount: state.people.where((person) => person.id != state.me).length,
            ),
          ),
          const SizedBox(height: 18),
          _GradientBalanceCard(summary: balances),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'You are owed',
                  value: money(balances.owed),
                  accent: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'You owe',
                  value: money(balances.owe),
                  accent: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenAddExpense,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Expense'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 56,
                child: FilledButton(
                  onPressed: onOpenGroups,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A261),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionCard(
            onTap: onOpenMyExpenses,
            icon: '🔒',
            title: 'My Expenses',
            subtitle: 'Personal spending - only you see it',
            trailing: money(personalTotal),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Recent Activity',
            actionLabel: 'View All',
            onAction: () => _toast(context, 'Open Activity tab to see the full feed.'),
          ),
          const SizedBox(height: 10),
          ...recent.map((expense) {
            final payer = controller.personById(expense.paidBy);
            final youPaid = expense.paidBy == state.me;
            final share = expense.amount / expense.participants.length;
            final delta = youPaid ? expense.amount - share : -share;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExpenseTile(
                title: expense.title,
                subtitle: youPaid ? 'You paid - split ${expense.participants.length}' : 'Paid by ${payer?.name ?? 'Unknown'}',
                leading: expense.category,
                amount: delta,
                timestamp: timeAgo(expense.date),
              ),
            );
          }),
          const SizedBox(height: 14),
          _SectionHeader(
            title: 'Top Groups',
            actionLabel: 'All Groups',
            onAction: onOpenGroups,
          ),
          const SizedBox(height: 10),
          if (topGroup != null)
            _GroupProgressCard(
              group: topGroup,
              total: controller.groupTotal(topGroup.id),
              settledPercent: settledPct,
              onTap: () => onOpenGroup(topGroup.id),
            ),
          const SizedBox(height: 18),
          _SectionLabel(text: 'TREND'),
          const SizedBox(height: 10),
          _TrendCard(summary: balances, groupExpenseCount: groupExpenses.length),
        ],
      ),
    );
  }
}

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, required this.controller, required this.onOpenGroup, required this.onCreateGroup});

  final AppController controller;
  final void Function(String groupId) onOpenGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          _PageHeader(
            title: 'Groups',
            subtitle: 'Your crews and shared spaces',
            trailing: IconButton.filledTonal(
              onPressed: onCreateGroup,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(backgroundColor: const Color(0xFFF5F1E8)),
            ),
          ),
          const SizedBox(height: 18),
          _SectionHeader(title: 'Your Crews', actionLabel: 'Create', onAction: onCreateGroup),
          const SizedBox(height: 12),
          ...state.groups.map((group) {
            final total = controller.groupTotal(group.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GroupTile(
                group: group,
                total: total,
                onTap: () => onOpenGroup(group.id),
                memberAvatars: group.members.map((memberId) => controller.personById(memberId)).whereType<Person>().toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final balances = controller.computeBalances();
    final shared = controller.sharedExpenses;
    final today = shared.where((expense) => DateTime.now().difference(expense.date).inHours < 24).toList();
    final earlier = shared.where((expense) => DateTime.now().difference(expense.date).inHours >= 24).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          const _PageHeader(
            title: 'clearsplit',
            subtitle: 'Live feed of splits and reminders',
          ),
          const SizedBox(height: 18),
          _GradientBalanceCard(summary: balances, trailingText: '+\$42.00 today'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MetricCard(title: 'You owe', value: money(balances.owe), accent: const Color(0xFFDC2626))),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'You are owed', value: money(balances.owed), accent: const Color(0xFF0F766E))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Feed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () => _toast(context, 'All caught up.'),
                child: const Text('Mark as Read'),
              ),
            ],
          ),
          if (today.isNotEmpty) ...[
            const _SectionLabel(text: 'TODAY'),
            const SizedBox(height: 10),
            ...today.map((expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActivityCard(
                    controller: controller,
                    expense: expense,
                    onSettle: () {
                      controller.markSettled(expense.id);
                      _toast(context, 'Marked as settled.');
                    },
                    onPoke: (name) => _toast(context, 'Poked $name.'),
                  ),
                )),
          ],
          if (earlier.isNotEmpty) ...[
            const _SectionLabel(text: 'EARLIER'),
            const SizedBox(height: 10),
            ...earlier.map((expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActivityCard(
                    controller: controller,
                    expense: expense,
                    onSettle: () {
                      controller.markSettled(expense.id);
                      _toast(context, 'Marked as settled.');
                    },
                    onPoke: (name) => _toast(context, 'Poked $name.'),
                  ),
                )),
          ],
          const SizedBox(height: 4),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScanScreen(controller: controller))),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Split Receipt'),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final balances = controller.computeBalances();
    final state = controller.state;
    final me = controller.personById(state.me)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          const _PageHeader(
            title: 'Profile',
            subtitle: 'Your preferences and payment settings',
          ),
          const SizedBox(height: 18),
          _ProfileHero(person: me, summary: balances),
          const SizedBox(height: 16),
          _SettingsCard(
            title: 'Payment Methods',
            subtitle: 'Bank card ending in 4821',
            icon: Icons.credit_card_rounded,
            onTap: () => _toast(context, 'Payment settings opened.'),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            title: 'Currency',
            subtitle: 'USD - \$',
            icon: Icons.attach_money_rounded,
            onTap: () => _toast(context, 'Currency preferences opened.'),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            title: 'Notifications',
            subtitle: 'Poke reminders and settle alerts',
            icon: Icons.notifications_rounded,
            onTap: () => _toast(context, 'Notification settings opened.'),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            title: 'Appearance',
            subtitle: 'Light mode with warm accents',
            icon: Icons.palette_rounded,
            onTap: () => _toast(context, 'Appearance settings opened.'),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: () {
              controller.reset();
              _toast(context, 'Demo data restored.');
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset Demo Data'),
          ),
        ],
      ),
    );
  }
}

class MyExpensesScreen extends StatelessWidget {
  const MyExpensesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final expenses = controller.personalExpenses;
    final total = controller.personalTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _GradientBalanceCard(
            summary: BalanceSummary(owed: 0, owe: total, net: -total, perPerson: const {}),
            title: 'Private spending',
            trailingText: money(total),
            subtitle: 'Only you can see this list',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showAddExpenseSheet(context, controller, personal: true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              backgroundColor: const Color(0xFF0F766E),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Private Expense'),
          ),
          const SizedBox(height: 16),
          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExpenseTile(
                title: expense.title,
                subtitle: expense.note ?? 'Personal',
                leading: expense.category,
                amount: -expense.amount,
                timestamp: timeAgo(expense.date),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.controller, required this.groupId});

  final AppController controller;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final group = controller.groupById(groupId);
    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found.')),
      );
    }

    final groupExpenses = controller.state.expenses.where((expense) => expense.groupId == groupId).toList();
    final groceries = controller.groceryForGroup(groupId);
    final total = controller.groupTotal(groupId);
    final settled = controller.settledPercent(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _GroupHeroCard(
            group: group,
            total: total,
            settledPercent: settled,
            memberCount: group.members.length,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showAddExpenseSheet(context, controller, initialGroupId: group.id),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Expense'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 54,
                height: 54,
                child: FilledButton(
                  onPressed: () => _toast(context, 'Grocery list is already wired into this group.'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A261),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 54,
                height: 54,
                child: FilledButton(
                  onPressed: () => showManageMembersSheet(context, controller, group),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2FF),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Icon(Icons.manage_accounts_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'SHARED EXPENSES'),
          const SizedBox(height: 10),
          ...groupExpenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExpenseTile(
                title: expense.title,
                subtitle: expense.personal ? 'Private expense' : 'Split with ${expense.participants.length} people',
                leading: expense.category,
                amount: expense.amount,
                timestamp: timeAgo(expense.date),
                positive: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'GROCERY LIST'),
          const SizedBox(height: 10),
          ...groceries.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.done ? const Color(0xFFC7F3E7) : const Color(0xFFF5F1E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.done ? Icons.check_rounded : Icons.shopping_cart_rounded,
                        color: item.done ? const Color(0xFF0F766E) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            [item.tag, item.qty].whereType<String>().join(' · '),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (item.price != null) Text(money(item.price!), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final topGroup = controller.topGroup;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _GradientBalanceCard(
            summary: controller.computeBalances(),
            title: 'AI split preview',
            subtitle: 'Receipt scanning and item detection',
            trailingText: 'NEW AI',
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFD9E2EC)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.document_scanner_rounded, size: 72, color: Color(0xFF0F766E)),
                      SizedBox(height: 14),
                      Text('Place receipt in frame', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('BuddySplit will detect totals and suggested splits.'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _MiniPill(label: 'Receipt OCR'),
                    _MiniPill(label: 'Item split'),
                    _MiniPill(label: 'Tip included'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final group = topGroup ?? controller.state.groups.first;
              controller.addExpense(
                title: 'Demo scan receipt',
                amount: 56.4,
                paidBy: controller.state.me,
                participants: group.members,
                category: '🧾',
                groupId: group.id,
                note: 'Scanned from receipt',
              );
              _toast(context, 'Demo split added for ${group.name}.');
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Use Demo Receipt'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => showAddExpenseSheet(context, controller),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Open Split Flow'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.person, required this.summary});

  final Person person;
  final BalanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _PersonAvatar(person: person, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('You are owed ${money(summary.owed)}', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: const [
                    _MiniPill(label: 'PayPal ready'),
                    _MiniPill(label: 'Light mode'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeroCard extends StatelessWidget {
  const _GroupHeroCard({required this.group, required this.total, required this.settledPercent, required this.memberCount});

  final Group group;
  final double total;
  final int settledPercent;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFC7F3E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(child: Text(group.emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('$memberCount members · ${money(total)} tracked', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: settledPercent / 100,
              backgroundColor: const Color(0xFFE8EEF4),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0F766E)),
            ),
          ),
          const SizedBox(height: 10),
          Text('$settledPercent% settled', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.total, required this.onTap, required this.memberAvatars});

  final Group group;
  final double total;
  final VoidCallback onTap;
  final List<Person> memberAvatars;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: Text(group.emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${group.members.length} members · ${money(total)} tracked', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 26,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < memberAvatars.take(5).length; i++)
                        Positioned(
                          left: i * 18,
                          child: _PersonAvatar(person: memberAvatars[i], size: 26, ring: true),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.title, required this.subtitle, required this.leading, required this.amount, required this.timestamp, this.positive = false});

  final String title;
  final String subtitle;
  final String leading;
  final double amount;
  final String timestamp;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive || amount >= 0 ? const Color(0xFF0F766E) : const Color(0xFFDC2626);
    final sign = positive || amount >= 0 ? '+' : '-';

    return _SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(leading, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${money(amount.abs())}', style: TextStyle(fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 4),
              Text(timestamp, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.controller, required this.expense, required this.onSettle, required this.onPoke});

  final AppController controller;
  final Expense expense;
  final VoidCallback onSettle;
  final void Function(String name) onPoke;

  @override
  Widget build(BuildContext context) {
    final payer = controller.personById(expense.paidBy);
    final me = controller.state.me;
    final youOwe = expense.paidBy != me && expense.participants.contains(me);
    final share = expense.amount / expense.participants.length;

    return _SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PersonAvatar(person: payer, size: 46, ring: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${payer?.id == me ? 'You' : payer?.name ?? 'Unknown'} ', style: const TextStyle(fontWeight: FontWeight.w800)),
                          const TextSpan(text: 'added ', style: TextStyle(color: Colors.black87)),
                          TextSpan(text: expense.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${expense.category} · ${timeAgo(expense.date)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money(expense.amount), style: const TextStyle(fontWeight: FontWeight.w900)),
                  if (youOwe)
                    Text('You owe ${money(share)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE6ECF2)),
          const SizedBox(height: 10),
          Row(
            children: [
              Wrap(
                spacing: 8,
                children: const [
                  _MiniPill(label: '🍕'),
                  _MiniPill(label: '🔥'),
                  _MiniPill(label: '😅'),
                ],
              ),
              const Spacer(),
              if (expense.settled)
                const _StatusPill(label: 'Settled', color: Color(0xFF0F766E))
              else if (youOwe)
                FilledButton.tonalIcon(
                  onPressed: onSettle,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: const Icon(Icons.payments_rounded, size: 16),
                  label: const Text('Settle'),
                )
              else
                FilledButton(
                  onPressed: () => onPoke(payer?.name ?? 'the group'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Poke'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.accent});

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: accent)),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.summary, required this.groupExpenseCount});

  final BalanceSummary summary;
  final int groupExpenseCount;

  @override
  Widget build(BuildContext context) {
    final bars = [40, 58, 50, 78, 64, 92, 100];
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7-Day Trend', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < bars.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 18,
                    height: bars[i] * 0.65,
                    decoration: BoxDecoration(
                      color: i == bars.length - 1 ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$groupExpenseCount items', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(summary.net >= 0 ? 'In your favor' : 'You owe', style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientBalanceCard extends StatelessWidget {
  const _GradientBalanceCard({
    required this.summary,
    this.title = 'Live Balance',
    this.subtitle,
    this.trailingText,
  });

  final BalanceSummary summary;
  final String title;
  final String? subtitle;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final favor = summary.net >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F766E).withValues(alpha: 0.22), blurRadius: 28, offset: const Offset(0, 16)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -36,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lens_rounded, size: 12, color: Color(0xFF9EF0D0)),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.6, color: Colors.white),
                    ),
                    const Spacer(),
                    if (trailingText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(trailingText!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  money(summary.net.abs()),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle ?? (favor ? 'In your favor this week' : 'You owe this week'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final bar in [40, 65, 50, 80, 55, 90, 100])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          width: 18,
                          height: bar * 0.55,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: bar == 100 ? 0.82 : 0.24),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('7-Day Trend', style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 11)),
                        const SizedBox(height: 2),
                        const Text('Settled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupProgressCard extends StatelessWidget {
  const _GroupProgressCard({required this.group, required this.total, required this.settledPercent, required this.onTap});

  final Group group;
  final double total;
  final int settledPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${group.emoji} ${group.name}', style: const TextStyle(fontWeight: FontWeight.w900)),
              Text('$settledPercent% Settled', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: settledPercent / 100,
              backgroundColor: const Color(0xFFE8EEF4),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0F766E)),
            ),
          ),
          const SizedBox(height: 10),
          Text('${money(total)} tracked', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.onTap, required this.icon, required this.title, required this.subtitle, required this.trailing});

  final VoidCallback onTap;
  final String icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
          ),
          Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F766E))),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: Colors.grey.shade600),
    );
  }
}

class _PersonPokeCard extends StatelessWidget {
  const _PersonPokeCard({required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            _PersonAvatar(person: person, size: 56, ring: true),
            const SizedBox(height: 8),
            Text(person.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.person, required this.size, this.ring = false});

  final Person? person;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final bg = person == null ? const Color(0xFFE2E8F0) : _hexColor(person!.color).withValues(alpha: 0.16);
    final fg = person == null ? Colors.grey.shade600 : _hexColor(person!.color);
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Text(
          person?.avatar ?? '?',
          style: TextStyle(fontSize: size * 0.46, color: fg),
        ),
      ),
    );
    if (!ring) {
      return avatar;
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: avatar,
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({this.onTap, required this.child, required this.padding});

  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: card);
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

Color _hexColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ),
  );
}

Future<void> showCreateGroupSheet(BuildContext context, AppController controller) async {
  final nameController = TextEditingController();
  const emojis = ['🏠', '🏖️', '🚗', '✈️', '🎉', '🍕'];
  String selectedEmoji = emojis.first;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Create Group', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: emojis
                        .map(
                          (emoji) => ChoiceChip(
                            label: Text(emoji),
                            selected: selectedEmoji == emoji,
                            onSelected: (_) => setSheetState(() => selectedEmoji = emoji),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        return;
                      }
                      controller.createGroup(name: name, emoji: selectedEmoji);
                      Navigator.of(sheetContext).pop();
                      _toast(context, 'Created $name.');
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Create Group'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showAddExpenseSheet(
  BuildContext context,
  AppController controller, {
  String? initialGroupId,
  bool personal = false,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final categories = ['🍔', '🛒', '⚡', '🎬', '🔥', '☕', '🚇', '🎧'];
  bool isPersonal = personal;
  String selectedCategory = categories.first;
  String? selectedGroupId = initialGroupId ?? (controller.state.groups.isEmpty ? null : controller.state.groups.first.id);
  String selectedPayerId = controller.state.me;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final group = selectedGroupId == null ? null : controller.groupById(selectedGroupId!);
          final payerOptions = isPersonal ? [controller.state.me] : (group?.members.isNotEmpty == true ? group!.members : [controller.state.me]);
          if (!payerOptions.contains(selectedPayerId)) {
            selectedPayerId = payerOptions.first;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Add Expense', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isPersonal,
                      onChanged: (value) => setSheetState(() {
                        isPersonal = value;
                        if (isPersonal) {
                          selectedGroupId = null;
                          selectedPayerId = controller.state.me;
                        } else if (selectedGroupId == null && controller.state.groups.isNotEmpty) {
                          selectedGroupId = controller.state.groups.first.id;
                        }
                      }),
                      title: const Text('Personal expense'),
                      subtitle: const Text('Only visible to you'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Category'),
                      items: categories
                          .map(
                            (emoji) => DropdownMenuItem<String>(
                              value: emoji,
                              child: Text(emoji),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setSheetState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (!isPersonal)
                      DropdownButtonFormField<String>(
                        initialValue: selectedGroupId,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Group'),
                        items: controller.state.groups
                            .map(
                              (group) => DropdownMenuItem<String>(
                                value: group.id,
                                child: Text(group.name),
                              ),
                            )
                            .toList(),
                        onChanged: controller.state.groups.isEmpty
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }
                                setSheetState(() {
                                  selectedGroupId = value;
                                  final nextGroup = controller.groupById(value);
                                  if (nextGroup != null && !nextGroup.members.contains(selectedPayerId)) {
                                    selectedPayerId = nextGroup.members.first;
                                  }
                                });
                              },
                      ),
                    if (!isPersonal) const SizedBox(height: 12),
                    if (!isPersonal)
                      DropdownButtonFormField<String>(
                        initialValue: selectedPayerId,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Paid by'),
                        items: payerOptions
                            .map(
                              (personId) => DropdownMenuItem<String>(
                                value: personId,
                                child: Text(controller.personById(personId)?.name ?? personId),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setSheetState(() => selectedPayerId = value);
                        },
                      ),
                    if (!isPersonal) const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories
                          .map(
                            (emoji) => ChoiceChip(
                              label: Text(emoji),
                              selected: selectedCategory == emoji,
                              onSelected: (_) => setSheetState(() => selectedCategory = emoji),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text.trim());
                        if (title.isEmpty || amount == null || amount <= 0) {
                          return;
                        }

                        final groupToUse = isPersonal ? null : selectedGroupId;
                        final participants = isPersonal
                            ? [controller.state.me]
                            : (groupToUse == null ? [controller.state.me] : (controller.groupById(groupToUse)?.members ?? [controller.state.me]));

                        controller.addExpense(
                          title: title,
                          amount: amount,
                          paidBy: isPersonal ? controller.state.me : selectedPayerId,
                          participants: participants,
                          category: selectedCategory,
                          groupId: groupToUse,
                          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                          personal: isPersonal,
                        );
                        Navigator.of(sheetContext).pop();
                        _toast(context, 'Added $title.');
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: const Color(0xFF0F766E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text('Save Expense'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showManageMembersSheet(BuildContext context, AppController controller, Group group) async {
  final allPeople = controller.state.people;
  final selected = <String>{...group.members};

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999))),
                ),
                const SizedBox(height: 18),
                Text('Manage Members — ${group.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allPeople.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final person = allPeople[index];
                      final isMember = selected.contains(person.id);
                      return CheckboxListTile(
                        value: isMember,
                        onChanged: (value) {
                          setSheetState(() {
                            if (value == true) {
                              selected.add(person.id);
                              controller.addMemberToGroup(group.id, person.id);
                              _toast(context, 'Added ${person.name} to ${group.name}.');
                            } else {
                              selected.remove(person.id);
                              controller.removeMemberFromGroup(group.id, person.id);
                              _toast(context, 'Removed ${person.name} from ${group.name}.');
                            }
                          });
                        },
                        title: Text(person.name),
                        secondary: _PersonAvatar(person: person, size: 36),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: const Color(0xFF0F766E)),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
