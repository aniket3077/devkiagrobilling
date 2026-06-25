import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/user_management/user_management_bloc.dart';
import '../bloc/user_management/user_management_event.dart';
import '../bloc/user_management/user_management_state.dart';
import '../../domain/entities/app_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserManagementBloc>().add(const LoadUsers('temp_tenant_id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            label: const Text('ADD USER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<UserManagementBloc, UserManagementState>(
        builder: (context, state) {
          if (state is UserManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UsersLoaded) {
            final users = state.users;
            if (users.isEmpty) {
              return const Center(child: Text('No users registered yet. Add a user to get started.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 380,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(context, user);
              },
            );
          }
          return const Center(child: Text('Add users to see them here'));
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user) {
    Color roleColor;
    switch (user.role) {
      case UserRole.admin:
        roleColor = Colors.red;
        break;
      case UserRole.shopkeeper:
        roleColor = Theme.of(context).colorScheme.primary;
        break;
    }

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6EFEA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Text(user.displayName?.isNotEmpty == true ? user.displayName![0].toUpperCase() : 'U', style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? 'Name not set', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (user.phoneNumber != null)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(user.phoneNumber!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showChangeRoleDialog(context, user),
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('Change Role'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmDialog(context, user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailCont = TextEditingController();
    final nameCont = TextEditingController();
    final phoneCont = TextEditingController();
    UserRole selectedRole = UserRole.shopkeeper;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add User / Staff', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCont, decoration: const InputDecoration(labelText: 'Display Name *')),
              TextField(controller: emailCont, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address *')),
              TextField(controller: phoneCont, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'System Role *'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedRole = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (emailCont.text.isEmpty || nameCont.text.isEmpty) return;
                final user = AppUser(
                  uid: const Uuid().v4(),
                  email: emailCont.text,
                  displayName: nameCont.text,
                  phoneNumber: phoneCont.text.isEmpty ? null : phoneCont.text,
                  tenantId: 'temp_tenant_id',
                  role: selectedRole,
                );
                context.read<UserManagementBloc>().add(AddUser(user));
                Navigator.pop(context);
              },
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, AppUser user) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change Role: ${user.displayName}'),
          content: DropdownButtonFormField<UserRole>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Role'),
            items: UserRole.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase())))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setDialogState(() {
                  selectedRole = val;
                });
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                context.read<UserManagementBloc>().add(UpdateUserRole(user.uid, selectedRole));
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.displayName}? This user will lose access to the system.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context.read<UserManagementBloc>().add(DeleteUser(user.uid));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
