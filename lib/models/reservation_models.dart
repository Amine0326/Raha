// Reservation Models for Rahati Healthcare App
// Models for handling accommodation reservations from API

import 'package:flutter/material.dart';

class Reservation {
  final int id;
  final int appointmentId;
  final int roomId;
  final int mealOptionId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final String totalPrice;
  final String status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Appointment appointment;
  final Room room;
  final MealOption mealOption;

  Reservation({
    required this.id,
    required this.appointmentId,
    required this.roomId,
    required this.mealOptionId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.status,
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    required this.appointment,
    required this.room,
    required this.mealOption,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      appointmentId: json['appointment_id'],
      roomId: json['room_id'],
      mealOptionId: json['meal_option_id'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      numberOfGuests: json['number_of_guests'],
      totalPrice: json['total_price'],
      status: json['status'],
      specialRequests: json['special_requests'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      appointment: Appointment.fromJson(json['appointment']),
      room: Room.fromJson(json['room']),
      mealOption: MealOption.fromJson(json['meal_option']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'room_id': roomId,
      'meal_option_id': mealOptionId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'number_of_guests': numberOfGuests,
      'total_price': totalPrice,
      'status': status,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'appointment': appointment.toJson(),
      'room': room.toJson(),
      'meal_option': mealOption.toJson(),
    };
  }
}

class Appointment {
  final int id;
  final int patientId;
  final int centerId;
  final int? providerId;
  final DateTime appointmentDatetime;
  final int appointmentDuration;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Patient patient;
  final Provider? provider;

  Appointment({
    required this.id,
    required this.patientId,
    required this.centerId,
    this.providerId,
    required this.appointmentDatetime,
    required this.appointmentDuration,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.patient,
    this.provider,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      centerId: json['center_id'],
      providerId: json['provider_id'],
      appointmentDatetime: DateTime.parse(json['appointment_datetime']),
      appointmentDuration: json['appointment_duration'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      patient: Patient.fromJson(json['patient']),
      provider: json['provider'] != null ? Provider.fromJson(json['provider']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'center_id': centerId,
      'provider_id': providerId,
      'appointment_datetime': appointmentDatetime.toIso8601String(),
      'appointment_duration': appointmentDuration,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'patient': patient.toJson(),
      'provider': provider?.toJson(),
    };
  }
}

class Patient {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String role;
  final String phone;
  final String address;
  final String caregiverName;
  final String caregiverPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? centerId;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.phone,
    required this.address,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.createdAt,
    required this.updatedAt,
    this.centerId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at']) 
          : null,
      role: json['role'],
      phone: json['phone'],
      address: json['address'],
      caregiverName: json['caregiver_name'],
      caregiverPhone: json['caregiver_phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      centerId: json['center_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'role': role,
      'phone': phone,
      'address': address,
      'caregiver_name': caregiverName,
      'caregiver_phone': caregiverPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'center_id': centerId,
    };
  }
}

class Provider {
  final int id;
  final String name;
  final String email;
  final String specialization;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      specialization: json['specialization'],
      phone: json['phone'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'specialization': specialization,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Room {
  final int id;
  final int centerId;
  final String roomNumber;
  final String type;
  final String description;
  final String pricePerNight;
  final int capacity;
  final bool isAccessible;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MedicalCenter center;

  Room({
    required this.id,
    required this.centerId,
    required this.roomNumber,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.isAccessible,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.center,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      centerId: json['center_id'],
      roomNumber: json['room_number'],
      type: json['type'],
      description: json['description'],
      pricePerNight: json['price_per_night'],
      capacity: json['capacity'],
      isAccessible: json['is_accessible'],
      isAvailable: json['is_available'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      center: MedicalCenter.fromJson(json['center']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_id': centerId,
      'room_number': roomNumber,
      'type': type,
      'description': description,
      'price_per_night': pricePerNight,
      'capacity': capacity,
      'is_accessible': isAccessible,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'center': center.toJson(),
    };
  }
}

class MedicalCenter {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String latitude;
  final String longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalCenter({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalCenter.fromJson(Map<String, dynamic> json) {
    return MedicalCenter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MealOption {
  final int id;
  final String name;
  final String description;
  final String price;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      isVegetarian: json['is_vegetarian'],
      isVegan: json['is_vegan'],
      isGlutenFree: json['is_gluten_free'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum ReservationStatus {
  reserved,
  cancelled,
  completed,
  pending,
}

extension ReservationStatusExtension on ReservationStatus {
  String get displayName {
    switch (this) {
      case ReservationStatus.reserved:
        return 'محجوز';
      case ReservationStatus.cancelled:
        return 'ملغي';
      case ReservationStatus.completed:
        return 'مكتمل';
      case ReservationStatus.pending:
        return 'في الانتظار';
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.reserved:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.pending:
        return Colors.orange;
    }
  }
}
