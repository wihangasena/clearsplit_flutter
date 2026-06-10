// Supabase Database Client for ClearSplit Backend
import 'package:supabase/supabase.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // e.g., https://xxxxx.supabase.co
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

  static late SupabaseClient client;

  static Future<void> initialize() async {
    client = SupabaseClient(supabaseUrl, supabaseKey);
  }

  static SupabaseClient getClient() => client;
}

class SupabaseDatabase {
  final SupabaseClient _client;

  SupabaseDatabase(this._client);

  // Users operations
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return response as Map<String, dynamic>?;
  }

  Future<void> createUser(String userId, String email, String displayName, String avatar, String color) async {
    await _client.from('users').insert({
      'id': userId,
      'email': email,
      'display_name': displayName,
      'avatar': avatar,
      'color': color,
    });
  }

  // People operations
  Future<List<Map<String, dynamic>>> getPeopleForUser(String userId) async {
    final response = await _client
        .from('people')
        .select()
        .eq('user_id', userId);
    return response as List<Map<String, dynamic>>;
  }

  Future<String> addPerson(String userId, String name, String avatar, String color) async {
    final response = await _client.from('people').insert({
      'user_id': userId,
      'name': name,
      'avatar': avatar,
      'color': color,
    }).select();
    return response.first['id'] as String;
  }

  // Groups operations
  Future<List<Map<String, dynamic>>> getGroupsForUser(String userId) async {
    final response = await _client
        .from('groups')
        .select('*, group_members(person_id)')
        .eq('user_id', userId);
    return response as List<Map<String, dynamic>>;
  }

  Future<String> createGroup(String userId, String name, String emoji) async {
    final response = await _client.from('groups').insert({
      'user_id': userId,
      'name': name,
      'emoji': emoji,
    }).select();
    return response.first['id'] as String;
  }

  Future<void> addGroupMember(String groupId, String personId) async {
    await _client.from('group_members').insert({
      'group_id': groupId,
      'person_id': personId,
    });
  }

  Future<void> removeGroupMember(String groupId, String personId) async {
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('person_id', personId);
  }

  // Expenses operations
  Future<List<Map<String, dynamic>>> getExpensesForUser(String userId) async {
    final response = await _client
        .from('expenses')
        .select('*, expense_participants(person_id, share_amount)')
        .eq('user_id', userId)
        .order('date', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<String> createExpense(
    String userId,
    String title,
    double amount,
    String paidById,
    List<String> participantIds,
    String category,
    String? groupId,
    String? note,
    String splitMethod,
    Map<String, double> splits,
    bool settled,
    bool personal,
    DateTime date,
  ) async {
    final response = await _client.from('expenses').insert({
      'user_id': userId,
      'title': title,
      'amount': amount,
      'paid_by': paidById,
      'category': category,
      'group_id': groupId,
      'note': note,
      'split_method': splitMethod,
      'settled': settled,
      'personal': personal,
      'date': date.toIso8601String(),
    }).select();
    
    final expenseId = response.first['id'] as String;

    // Add participants
    for (final participantId in participantIds) {
      final shareAmount = splits[participantId] ?? (amount / participantIds.length);
      await _client.from('expense_participants').insert({
        'expense_id': expenseId,
        'person_id': participantId,
        'share_amount': shareAmount,
      });
    }

    return expenseId;
  }

  Future<void> markExpenseSettled(String expenseId) async {
    await _client
        .from('expenses')
        .update({'settled': true})
        .eq('id', expenseId);
  }

  // Grocery items operations
  Future<List<Map<String, dynamic>>> getGroceryItemsForGroup(String groupId) async {
    final response = await _client
        .from('grocery_items')
        .select()
        .eq('group_id', groupId);
    return response as List<Map<String, dynamic>>;
  }

  Future<String> addGroceryItem(
    String groupId,
    String name,
    String? tag,
    String? qty,
    String? claimedById,
    String? boughtById,
    double? price,
  ) async {
    final response = await _client.from('grocery_items').insert({
      'group_id': groupId,
      'name': name,
      'tag': tag,
      'qty': qty,
      'claimed_by': claimedById,
      'bought_by': boughtById,
      'price': price,
    }).select();
    return response.first['id'] as String;
  }

  Future<void> updateGroceryItem(String itemId, Map<String, dynamic> updates) async {
    await _client.from('grocery_items').update(updates).eq('id', itemId);
  }

  // Analytics/Reports
  Future<Map<String, dynamic>> getExpenseSummary(String userId) async {
    final response = await _client.rpc('get_expense_summary', params: {'user_id': userId});
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getGroupBalance(String groupId) async {
    final response = await _client.rpc('get_group_balance', params: {'group_id': groupId});
    return response as Map<String, dynamic>;
  }
}
