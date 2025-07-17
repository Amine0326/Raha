import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: RahatiTheme.primaryColor,
            child: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUpcomingAppointments(),
                _buildPastAppointments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppointmentCard(
            doctorName: 'Dr. Sarah Johnson',
            specialty: 'Cardiologist',
            date: 'May 20, 2023',
            time: '10:00 AM',
            status: 'Confirmed',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 15),
          _buildAppointmentCard(
            doctorName: 'Dr. Michael Chen',
            specialty: 'Neurologist',
            date: 'May 25, 2023',
            time: '2:30 PM',
            status: 'Pending',
            statusColor: Colors.orange,
          ),
          const SizedBox(height: 15),
          _buildAppointmentCard(
            doctorName: 'Dr. Emily Williams',
            specialty: 'Dermatologist',
            date: 'June 3, 2023',
            time: '11:15 AM',
            status: 'Confirmed',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 30),
          
          // Bouton pour ajouter un nouveau rendez-vous
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Naviguer vers l'écran de prise de rendez-vous
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RahatiTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Book New Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointments() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppointmentCard(
            doctorName: 'Dr. Robert Smith',
            specialty: 'General Practitioner',
            date: 'April 15, 2023',
            time: '9:00 AM',
            status: 'Completed',
            statusColor: Colors.blue,
          ),
          const SizedBox(height: 15),
          _buildAppointmentCard(
            doctorName: 'Dr. Lisa Wong',
            specialty: 'Ophthalmologist',
            date: 'March 28, 2023',
            time: '3:45 PM',
            status: 'Completed',
            statusColor: Colors.blue,
          ),
          const SizedBox(height: 15),
          _buildAppointmentCard(
            doctorName: 'Dr. James Miller',
            specialty: 'Dentist',
            date: 'February 10, 2023',
            time: '1:30 PM',
            status: 'Cancelled',
            statusColor: Colors.red,
          ),
          const SizedBox(height: 15),
          _buildAppointmentCard(
            doctorName: 'Dr. Sarah Johnson',
            specialty: 'Cardiologist',
            date: 'January 5, 2023',
            time: '11:00 AM',
            status: 'Completed',
            statusColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: RahatiTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person,
                  color: RahatiTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: RahatiTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      specialty,
                      style: const TextStyle(
                        color: RahatiTheme.lightTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: RahatiTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: RahatiTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: const TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: RahatiTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Clinic',
                    style: TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 14,
                    ),
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
