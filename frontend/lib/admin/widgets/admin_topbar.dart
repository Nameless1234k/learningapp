import 'package:flutter/material.dart';
import '../../services/user_session.dart';

class AdminTopbar extends StatelessWidget {
  final String title;

  const AdminTopbar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final adminName = UserSession.currentFullName ?? 'Quản Trị Viên';
    final adminEmail = UserSession.currentEmail ?? 'admin@gmail.com';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // Tiêu đề trang
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),

          // Thông tin Admin đăng nhập
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adminName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    adminEmail,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
