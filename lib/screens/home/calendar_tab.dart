import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final DateTime _selectedDate = DateTime.now();
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<int> _daysInMonth = List.generate(31, (index) => index + 1);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mois et année
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'March 2023',
                style: const TextStyle(
                  color: RahatiTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    onPressed: () {
                      // Mois précédent
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      // Mois suivant
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays.map((day) => Text(
              day,
              style: const TextStyle(
                color: RahatiTheme.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
          
          // Grille du calendrier
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == _selectedDate.day;
              final hasEvent = [5, 12, 20, 25].contains(day);
              
              return GestureDetector(
                onTap: () {
                  // Sélectionner le jour
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? RahatiTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : RahatiTheme.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : RahatiTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          
          // Date sélectionnée
          Text(
            'March 20, 2023',
            style: const TextStyle(
              color: RahatiTheme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Événements du jour
          _buildEventCard(
            title: 'Cardiology Appointment',
            time: '10:00 AM - 11:00 AM',
            location: 'Rahati Medical Center',
            isUpcoming: true,
          ),
          const SizedBox(height: 15),
          _buildEventCard(
            title: 'Blood Test',
            time: '2:30 PM - 3:00 PM',
            location: 'Rahati Lab Services',
            isUpcoming: false,
          ),
          const SizedBox(height: 15),
          _buildEventCard(
            title: 'Medication Reminder',
            time: '8:00 PM',
            location: 'Home',
            isUpcoming: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventCard({
    required String title,
    required String time,
    required String location,
    required bool isUpcoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUpcoming ? RahatiTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUpcoming ? RahatiTheme.primaryColor : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUpcoming ? RahatiTheme.primaryColor : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.event,
              color: isUpcoming ? Colors.white : Colors.grey,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isUpcoming ? RahatiTheme.primaryColor : RahatiTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    color: RahatiTheme.lightTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  location,
                  style: const TextStyle(
                    color: RahatiTheme.lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: isUpcoming ? RahatiTheme.primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }
}
