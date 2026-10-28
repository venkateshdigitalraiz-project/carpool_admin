import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final int completedSteps;
  final int totalSteps;
  final String email;
  final bool isEmailConfirmed;
  final String phoneNumber;
  final bool isPhoneVerified;
  final bool isGovtIdVerified;
  final String reliabilityBadge;
  final double rating;
  final int reviewsCount;
  final int savedPassengersCount;
  final String postalAddress;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final String payoutMethod;
  final String paymentMethod;

  const ProfileEntity({
    required this.name,
    this.subtitle = 'Newcomer',
    this.avatarUrl,
    this.completedSteps = 1,
    this.totalSteps = 6,
    required this.email,
    this.isEmailConfirmed = false,
    required this.phoneNumber,
    this.isPhoneVerified = true,
    this.isGovtIdVerified = false,
    this.reliabilityBadge = 'Never cancels bookings as a passenger',
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.savedPassengersCount = 0,
    this.postalAddress = 'Hyderabad, Telangana, 500081',
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.payoutMethod = 'Bank Transfer (HDFC Bank ...8492)',
    this.paymentMethod = 'UPI ID (venkatesh@okhdfcbank)',
  });

  ProfileEntity copyWith({
    String? name,
    String? subtitle,
    String? avatarUrl,
    int? completedSteps,
    int? totalSteps,
    String? email,
    bool? isEmailConfirmed,
    String? phoneNumber,
    bool? isPhoneVerified,
    bool? isGovtIdVerified,
    String? reliabilityBadge,
    double? rating,
    int? reviewsCount,
    int? savedPassengersCount,
    String? postalAddress,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    String? payoutMethod,
    String? paymentMethod,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
      email: email ?? this.email,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isGovtIdVerified: isGovtIdVerified ?? this.isGovtIdVerified,
      reliabilityBadge: reliabilityBadge ?? this.reliabilityBadge,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      savedPassengersCount: savedPassengersCount ?? this.savedPassengersCount,
      postalAddress: postalAddress ?? this.postalAddress,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        name,
        subtitle,
        avatarUrl,
        completedSteps,
        totalSteps,
        email,
        isEmailConfirmed,
        phoneNumber,
        isPhoneVerified,
        isGovtIdVerified,
        reliabilityBadge,
        rating,
        reviewsCount,
        savedPassengersCount,
        postalAddress,
        pushNotifications,
        emailNotifications,
        smsNotifications,
        payoutMethod,
        paymentMethod,
      ];
}
